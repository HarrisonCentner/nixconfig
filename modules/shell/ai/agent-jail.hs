#!/usr/bin/env runghc
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StrictData #-}

{- | Run @sbox@ with extra binds wired up for AI agent workflows.

Recognises @--readable DIR@ (repeatable) and forwards everything else to
@sbox@. When invoked inside a linked git worktree, the main repo's
common @.git@ directory is bind-mounted so the worktree stays usable.
-}
module Main where

import Data.Text qualified as T
import Options.Applicative qualified as Opt
import System.Directory (canonicalizePath, doesDirectoryExist, getCurrentDirectory)
import System.Environment (getArgs, lookupEnv)
import System.Exit (ExitCode (..))
import System.Posix.Files (fileExist)
import System.Posix.Process (executeFile, getProcessID)
import Turtle qualified as Tu

data BindMode
    = ReadOnly
    | ReadWrite

data Opts = Opts
    { readable :: [FilePath]
    , writeable :: [FilePath]
    , forwarded :: [String]
    }

optsParser :: Opt.Parser Opts
optsParser =
    Opts
        <$> Opt.many
            ( Opt.strOption
                ( Opt.long "readable"
                    <> Opt.metavar "DIR"
                    <> Opt.help "Bind DIR into the sandbox read-only"
                )
            )
        <*> Opt.many
            ( Opt.strOption
                ( Opt.long "writeable"
                    <> Opt.metavar "DIR"
                    <> Opt.help "Bind DIR into the sandbox read-write"
                )
            )
        <*> Opt.many (Opt.strArgument (Opt.metavar "SBOX_ARGS..."))

parserInfo :: Opt.ParserInfo Opts
parserInfo =
    Opt.info
        (optsParser Opt.<**> Opt.helper)
        ( Opt.fullDesc
            <> Opt.progDesc "Run sbox with extra binds for AI agent workflows"
            <> Opt.forwardOptions
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
    -- sbox verbatim; optparse-applicative would otherwise eat it.
    (before, rest) <- break (== "--") <$> getArgs
    Opts{..} <-
        Opt.handleParseResult $
            Opt.execParserPure Opt.defaultPrefs parserInfo before
    readables <- concat <$> traverse (bbwrapBind ReadOnly) readable
    writeables <- concat <$> traverse (bbwrapBind ReadWrite) writeable
    worktree <-
        gitCommonDir >>= \case
            Just dir -> bbwrapBind ReadWrite dir
            Nothing -> pure []
    runSandbox (worktree <> readables <> forwarded <> rest)
