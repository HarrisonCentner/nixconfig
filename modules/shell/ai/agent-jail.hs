#!/usr/bin/env runghc
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wall -Wincomplete-uni-patterns -Wincomplete-record-updates #-}

{- | Run @sbox@ with extra binds wired up for AI agent workflows.

Recognises @--readable DIR@, @--writeable DIR@, and @--network MODE@.
Anything else is appended to the inner program command (after the
@--@), so e.g. @agent-jail --readable /foo --resume X -- claude@ reaches
@claude@ as @claude --resume X@. When invoked inside a linked git
worktree, the main repo's common @.git@ directory is bind-mounted so the
worktree stays usable.
-}
module Main where

import Data.Foldable (asum)
import Data.List (isPrefixOf)
import Data.Text qualified as T
import Options.Applicative qualified as Opt
import Options.Applicative.Extra (helperWith)
import System.Directory (canonicalizePath, doesDirectoryExist, getCurrentDirectory)
import System.Environment (getArgs, lookupEnv)
import System.Exit (ExitCode (..))
import System.Posix.Files (fileExist)
import System.Posix.Process (executeFile, getProcessID)
import Turtle qualified as Tu

data BindMode
    = ReadOnly
    | ReadWrite

data Arg
    = ArgBind BindMode FilePath
    | ArgNetwork String
    | ArgTun
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
    ArgOther s -> pure ([], [s])

build :: [Arg] -> IO ([String], [String])
build = fmap mconcat . traverse contribute

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
    runSandbox $
        mconcat
            [ worktree
            , sboxArgs
            , rest
            , forwarded
            ]
