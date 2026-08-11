#!/usr/bin/env runghc
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wall -Wincomplete-uni-patterns -Wincomplete-record-updates #-}

{- | Repopulate opnix's secrets directory from the 1Password desktop app.

@opnix-secrets.service@ authenticates with a service-account token
against 1Password's servers, so a boot without network leaves the
tmpfs-backed secrets directory empty. The desktop app keeps a local
vault cache; once the session is unlocked, @op read@ resolves the same
@op://@ references offline through the app integration.

Run via @sudo opnix-restore@: secrets are written straight to their
destinations with the declared owner and mode, while @op read@ drops
back to @$SUDO_USER@ so the desktop-app integration still sees the
caller's session. Reads the manifest at @$OPNIX_RESTORE_MANIFEST@
(name, path, reference, ownership — generated from the opnix nix
config) and overwrites every secret with the freshly resolved value.
Ends by printing the systemd units worth restarting.
-}
module Main where

import Control.Exception (bracket)
import Control.Monad (when)
import Data.Aeson qualified as A
import Data.List (nub)
import Data.Text qualified as T
import GHC.Generics (Generic)
import Numeric (readOct)
import Options.Applicative qualified as Opt
import System.Directory (createDirectoryIfMissing)
import System.Environment (lookupEnv)
import System.Exit (ExitCode (..), die)
import System.FilePath (takeDirectory)
import System.IO (hClose, hPutStr)
import System.Posix.Files (setFileMode, setOwnerAndGroup)
import System.Posix.IO (createFile, fdToHandle)
import System.Posix.User (getEffectiveUserID, getGroupEntryForName, getUserEntryForName, groupID, userID)
import Turtle qualified as Tu

data Secret = Secret
    { name :: String
    , path :: FilePath
    , reference :: String
    , owner :: String
    , group :: String
    , mode :: String
    , services :: [String]
    }
    deriving (Generic)

instance A.FromJSON Secret

opRead :: String -> String -> IO String
opRead user ref = do
    op <- Tu.which "op" >>= maybe (die "op not on PATH; run the wrapped binary") pure
    (code, out, err) <-
        Tu.procStrictWithErr "sudo" (map T.pack ["-u", user, op, "read", "--no-newline", ref]) Tu.empty
    case code of
        ExitSuccess -> pure (T.unpack out)
        ExitFailure _ ->
            die ("op read " ++ ref ++ " failed (is the 1Password app unlocked, with CLI integration on?):\n" ++ T.unpack err)

-- createFile's mode is masked by the umask and ignored for existing
-- files; setFileMode restores the declared bits after writing. chown
-- comes last so the file stays root-owned while the secret is in
-- flight.
restore :: String -> Secret -> IO ()
restore user Secret{..} = do
    value <- opRead user reference
    fileMode <- case readOct mode of
        [(m, "")] -> pure m
        _ -> die ("bad mode " ++ mode ++ " for " ++ name)
    uid <- userID <$> getUserEntryForName owner
    gid <- groupID <$> getGroupEntryForName group
    createDirectoryIfMissing True (takeDirectory path)
    bracket (fdToHandle =<< createFile path fileMode) hClose (\h -> hPutStr h value)
    setFileMode path fileMode
    setOwnerAndGroup path uid gid
    putStrLn ("→ " ++ name ++ " restored")

needEnv :: String -> String -> IO String
needEnv var msg = lookupEnv var >>= maybe (die (var ++ " not set; " ++ msg)) pure

parserInfo :: Opt.ParserInfo ()
parserInfo =
    Opt.info
        (pure () Opt.<**> Opt.helper)
        ( mconcat
            [ Opt.fullDesc
            , Opt.progDesc "Repopulate opnix's secrets directory from the 1Password desktop app"
            ]
        )

main :: IO ()
main = do
    -- parsed first so --help and completion requests answer without root
    Opt.execParser parserInfo
    euid <- getEffectiveUserID
    when (euid /= 0) (die "needs root: sudo opnix-restore")
    user <- needEnv "SUDO_USER" "invoke via sudo, not from a root shell"
    manifest <- needEnv "OPNIX_RESTORE_MANIFEST" "run the wrapped binary"
    secrets <-
        A.eitherDecodeFileStrict manifest >>= \case
            Left err -> die ("decoding manifest: " ++ err)
            Right s -> pure (s :: [Secret])
    mapM_ (restore user) secrets
    case nub (concatMap services secrets) of
        [] -> pure ()
        units ->
            putStrLn ("affected units:\n    sudo systemctl restart " ++ unwords units)
