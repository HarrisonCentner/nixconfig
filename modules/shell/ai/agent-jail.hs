#!/usr/bin/env runghc
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wall -Wincomplete-uni-patterns -Wincomplete-record-updates #-}

{- | Run @sbox@ with extra binds wired up for AI agent workflows.

Recognises @--readable DIR@, @--writeable DIR@, @--network MODE@,
@--session-key KEY@, and @--share@/@--no-share@ (defaulting to
@--no-share@, so concurrent sessions in one directory get separate
sandboxes).
Anything else is appended to the inner program command (after the
@--@), so e.g. @agent-jail --readable /foo --resume X -- claude@ reaches
@claude@ as @claude --resume X@. When the inner program is @claude@, its
session id doubles as the session key (see 'claudeSession'). When invoked
inside a linked git worktree, the main repo's common @.git@ directory is
bind-mounted so the worktree stays usable.
-}
module Main where

import Control.Applicative ((<|>))
import Data.Char (isAlphaNum, isHexDigit)
import Data.Foldable (asum)
import Data.List (isPrefixOf, stripPrefix)
import Data.Maybe (listToMaybe, mapMaybe)
import Data.Text qualified as T
import Data.Text.IO qualified as TIO
import Options.Applicative qualified as Opt
import Options.Applicative.Extra (helperWith)
import System.Directory (canonicalizePath, createDirectoryIfMissing, doesDirectoryExist, getCurrentDirectory)
import System.Environment (getArgs, lookupEnv)
import System.Exit (ExitCode (..), die)
import System.FilePath (takeFileName)
import System.Posix.Files (fileExist, fileOwner, getSymbolicLinkStatus, isDirectory)
import System.Posix.Process (executeFile, getProcessID)
import System.Posix.Temp (mkdtemp)
import System.Posix.User (getEffectiveUserID)
import Turtle qualified as Tu

data BindMode
    = ReadOnly
    | ReadWrite

data Arg
    = ArgBind BindMode FilePath
    | ArgNetwork String
    | ArgTun
    | ArgShare Bool
    | ArgSessionKey String
    | ArgOther String

-- Wrap each token in a sum so the alternatives are tried per-arg; this
-- avoids the forwardOptions + many strArgument interaction where the
-- positional parser swallows recognised long options.
argParser :: Opt.Parser Arg
argParser =
    let bindOption name access =
            Opt.strOption
                ( mconcat
                    [ Opt.long name
                    , Opt.metavar "DIR"
                    , Opt.help ("Bind DIR into the sandbox " <> access)
                    , Opt.action "directory"
                    ]
                )
     in asum
            [ ArgBind ReadOnly <$> bindOption "readable" "read-only"
            , ArgBind ReadWrite <$> bindOption "writeable" "read-write"
            , ArgNetwork
                <$> Opt.strOption
                    ( mconcat
                        [ Opt.long "network"
                        , Opt.metavar "MODE"
                        , Opt.help "Network mode forwarded to sbox"
                        , Opt.completeWith ["isolated", "blocked", "host"]
                        ]
                    )
            , Opt.flag'
                ArgTun
                ( mconcat
                    [ Opt.long "tun"
                    , Opt.help "Binds /dev/net/tun into the sandbox"
                    ]
                )
            , Opt.flag'
                (ArgShare True)
                ( mconcat
                    [ Opt.long "share"
                    , Opt.help "Join an sbox already running in this directory"
                    ]
                )
            , Opt.flag'
                (ArgShare False)
                ( mconcat
                    [ Opt.long "no-share"
                    , Opt.help "Start a separate sandbox (default)"
                    ]
                )
            , ArgSessionKey
                <$> Opt.strOption
                    ( mconcat
                        [ Opt.long "session-key"
                        , Opt.metavar "KEY"
                        , Opt.help "Reuse the /tmp session dir named by KEY"
                        ]
                    )
            , ArgOther <$> Opt.strArgument (Opt.metavar "FWD...")
            ]

-- Each branch yields (sbox-side, forwarded-side); mconcat over the
-- tuple monoid stitches them together in argv order.
contribute :: Arg -> IO ([String], [String])
contribute = \case
    ArgBind mode dir -> do
        bind <- bbwrapBind mode dir
        pure (bind, [])
    ArgNetwork n -> pure (["--network", n], [])
    ArgTun -> pure (["--dev-bind-try", "/dev/net/tun"], [])
    ArgShare _ -> pure mempty
    ArgSessionKey _ -> pure mempty
    ArgOther s -> pure ([], [s])

build :: [Arg] -> IO ([String], [String])
build = fmap mconcat . traverse contribute

-- | Always passed explicitly so sbox never prompts on a config mismatch.
shareArg :: [Arg] -> [String]
shareArg args =
    let shares = [b | ArgShare b <- args]
     in if last (False : shares) then ["--share"] else ["--no-share"]

-- | Last @--session-key@ wins, as for 'shareArg'.
sessionKey :: [Arg] -> Maybe String
sessionKey args = case [k | ArgSessionKey k <- args] of
    [] -> Nothing
    ks -> Just (last ks)

longHelper :: Opt.Parser (a -> a)
longHelper =
    helperWith
        ( mconcat
            [ Opt.long "help"
            , Opt.help "Show this help text"
            , Opt.hidden
            ]
        )

parserInfo :: Opt.ParserInfo [Arg]
parserInfo =
    Opt.info
        (Opt.many argParser Opt.<**> longHelper)
        ( mconcat
            [ Opt.fullDesc
            , Opt.progDesc "Run sbox with extra binds for AI agent workflows"
            , Opt.forwardOptions
            ]
        )

bbwrapBind :: BindMode -> FilePath -> IO [String]
bbwrapBind mode dir = do
    let bbarg = case mode of
            ReadOnly -> "--ro-bind"
            ReadWrite -> "--bind"
    resolved <- canonicalizePath dir
    pure [bbarg, resolved, resolved]

{- | Bind a disk-backed dir over sbox's memory-backed @--tmpfs /tmp@
(later binds shadow it). A key names a stable dir, so a resumed agent
session finds the scratch files it left behind; without one the dir is
fresh per run. Sessions are never cleaned up here; the ephemeral root
reclaims @\/var\/tmp\/agents@ on reboot.
-}
tmpDirBind :: Maybe String -> IO [String]
tmpDirBind key = do
    createDirectoryIfMissing True agentsDir
    dir <- case key of
        Nothing -> mkdtemp (agentsDir <> "/session.")
        Just k
            | not (null k) && all safe k -> ownedDir (agentsDir <> "/session." <> k)
            | otherwise -> die $ "agent-jail: invalid --session-key: " <> k
    pure ["--bind", dir, "/tmp"]
  where
    agentsDir = "/var/tmp/agents"
    safe c = isAlphaNum c || c `elem` ("._-" :: String)

{- | @\/var\/tmp\/agents@ is world-writable (sticky), so unlike 'mkdtemp' a
predictable name can be pre-created by another user; refuse to bind a
directory we do not own.
-}
ownedDir :: FilePath -> IO FilePath
ownedDir dir = do
    createDirectoryIfMissing True dir
    st <- getSymbolicLinkStatus dir
    uid <- getEffectiveUserID
    if isDirectory st && fileOwner st == uid
        then pure dir
        else die $ "agent-jail: session dir not owned by us: " <> dir

-- | Session id in canonical 8-4-4-4-12 form, which is all claude accepts.
isSessionId :: String -> Bool
isSessionId s =
    map T.length groups == [8, 4, 4, 4, 12]
        && T.all isHexDigit (T.concat groups)
  where
    groups = T.splitOn "-" (T.pack s)

-- | The id claude was told to use, from either spelling of either flag.
givenSessionId :: [String] -> Maybe String
givenSessionId inner =
    listToMaybe . reverse . filter isSessionId $
        mapMaybe value (zip ("" : inner) inner)
  where
    value (prev, cur)
        | prev `elem` ["-r", "--resume", "--session-id"] = Just cur
        | otherwise = asum [stripPrefix p cur | p <- ["--resume=", "--session-id="]]

{- | Claude invents a session id unless handed one, but a resumed session
must land on the same @\/tmp@ as the run that created it. Pinning the id
ourselves makes it — and so the session dir — known before claude starts.
Yields the session key and any arguments to add to claude's command line.
An id we cannot know up front (@--resume@ with no id, @--continue@) leaves
the dir unkeyed, as for any other program.
-}
claudeSession :: [String] -> IO (Maybe String, [String])
claudeSession inner = case inner of
    prog : rest
        | takeFileName prog == "claude" -> case givenSessionId rest of
            Just sid -> pure (Just sid, [])
            Nothing
                | any picksLater rest -> pure (Nothing, [])
                | otherwise -> do
                    sid <- newSessionId
                    pure (Just sid, ["--session-id", sid])
    _ -> pure (Nothing, [])
  where
    picksLater a =
        a `elem` ["-c", "--continue", "-r", "--resume", "--session-id", "--fork-session"]
            || any (`isPrefixOf` a) ["--resume=", "--session-id="]

-- | The kernel's generator, so agent-jail needs no uuid dependency.
newSessionId :: IO String
newSessionId = T.unpack . T.strip <$> TIO.readFile "/proc/sys/kernel/random/uuid"

{- | The main repo's @.git@ when the cwd is a linked worktree; 'Nothing'
otherwise (plain repo, not a repo, or git missing).
-}
gitCommonDir :: IO (Maybe FilePath)
gitCommonDir = do
    (code, out, _err) <-
        Tu.procStrictWithErr
            "git"
            ["rev-parse", "--path-format=absolute", "--git-common-dir"]
            Tu.empty
    case code of
        ExitFailure _ -> pure Nothing
        ExitSuccess -> do
            let path = T.unpack (T.strip out)
            cwd <- getCurrentDirectory
            exists <- doesDirectoryExist path
            pure $
                if exists && path /= cwd <> "/.git"
                    then Just path
                    else Nothing

{- | Rebuild the inner program command line, splicing @extra@ in right
after the program name so it cannot be swallowed by a trailing option.
-}
innerCommand :: [String] -> [String] -> [String] -> [String]
innerCommand rest forwarded extra = case rest of
    [] -> forwarded
    [sep] -> sep : forwarded
    sep : prog : more -> [sep, prog] <> extra <> more <> forwarded

{- | Exec @sbox@ inside a transient @ai-agents.slice@ scope via
@systemd-run --scope@ when the user manager is reachable; otherwise run
@sbox@ directly so the binary stays usable outside a user session.
-}
runSandbox :: [String] -> IO ()
runSandbox sboxArgs = do
    runtime <- lookupEnv "XDG_RUNTIME_DIR"
    hasUserBus <- case runtime of
        Nothing -> pure False
        Just xdg -> fileExist (xdg <> "/systemd/private")
    if not hasUserBus
        then executeFile "sbox" True sboxArgs Nothing
        else do
            pid <- getProcessID
            let unit = "agent-jail-" <> show pid
                desc = "Agent jail session (pid " <> show pid <> ")"
                args =
                    [ "--user"
                    , "--quiet"
                    , "--scope"
                    , "--collect"
                    , "--slice=ai-agents.slice"
                    , "--unit=" <> unit
                    , "--property=Description=" <> desc
                    , "--"
                    , "sbox"
                    ]
                        <> sboxArgs
            putStrLn $ "Sandbox scope: " <> unit <> ".scope"
            executeFile "systemd-run" True args Nothing

main :: IO ()
main = do
    -- Split at the first literal `--` so it (and anything after) reaches
    -- sbox verbatim as the inner program command line. Completion
    -- callbacks re-encode the typed line as --bash-completion-word
    -- arguments, so a literal `--` there must not split the request.
    rawArgs <- getArgs
    let completing = any ("--bash-completion-" `isPrefixOf`) rawArgs
        (before, rest) =
            if completing
                then (rawArgs, [])
                else break (== "--") rawArgs
    args <-
        Opt.handleParseResult $
            Opt.execParserPure Opt.defaultPrefs parserInfo before
    (sboxArgs, forwarded) <- build args
    worktree <-
        gitCommonDir >>= \case
            Just dir -> bbwrapBind ReadWrite dir
            Nothing -> pure []
    (claudeKey, claudeArgs) <- claudeSession (drop 1 rest <> forwarded)
    tmpBind <- tmpDirBind (sessionKey args <|> claudeKey)
    runSandbox $
        mconcat
            [ shareArg args
            , worktree
            , tmpBind
            , sboxArgs
            , innerCommand rest forwarded claudeArgs
            ]
