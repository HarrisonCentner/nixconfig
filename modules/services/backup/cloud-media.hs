#!/usr/bin/env runghc
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wall -Wincomplete-uni-patterns -Wincomplete-record-updates #-}

{- | Client-side encrypted media archive on Backblaze B2.

Wraps two rclone remotes that exist only as environment variables, so no
rclone config file is ever written: @b2@ speaks S3 to Backblaze, and
@media@ is the crypt layer on top of it. Nothing here accepts a remote
name, so there is no way to address @b2:@ directly and push plaintext
past the crypt layer by mistake.

B2's S3 endpoint reports multipart ETags that are not MD5, so 'archive'
verifies by reading back through the crypt layer with @cryptcheck@
rather than trusting the transfer's own hash check.

Configuration arrives via @CLOUD_MEDIA_*@ (see 'loadConfig'), set by the
nix wrapper.
-}
module Main where

import Control.Monad (forM_, unless)
import Data.Maybe (fromMaybe)
import Data.Text qualified as T
import Data.Text.IO qualified as TIO
import Options.Applicative qualified as Opt
import System.Directory (createDirectoryIfMissing, doesDirectoryExist, doesPathExist, removePathForcibly)
import System.Environment (getEnv, setEnv)
import System.Exit (ExitCode (..), die, exitWith)
import System.FilePath (dropTrailingPathSeparator, takeDirectory, takeFileName)
import System.IO (stderr)
import System.Posix.Process (executeFile)
import Turtle qualified as Tu

data Command
    = Archive [FilePath]
    | List (Maybe FilePath)
    | Get FilePath FilePath
    | Verify
    | Mount

data Config = Config
    { bucketPath :: String
    , endpoint :: String
    , region :: String
    , keyIdFile :: FilePath
    , appKeyFile :: FilePath
    , passwordFile :: FilePath
    , saltFile :: FilePath
    , mountPoint :: FilePath
    , cacheDir :: FilePath
    }

commandParser :: Opt.Parser Command
commandParser =
    Opt.hsubparser $
        mconcat
            [ Opt.command "archive" $
                Opt.info
                    (Archive <$> Opt.some (Opt.strArgument (mconcat [Opt.metavar "PATH...", Opt.action "file"])))
                    (Opt.progDesc "Upload, verify, then remove the local copy")
            , Opt.command "ls" $
                Opt.info
                    (List <$> Opt.optional (Opt.strArgument (Opt.metavar "PATH")))
                    (Opt.progDesc "List the archive")
            , Opt.command "get" $
                Opt.info
                    ( Get
                        <$> Opt.strArgument (Opt.metavar "PATH")
                        <*> (fromMaybe "." <$> Opt.optional (Opt.strArgument (mconcat [Opt.metavar "DEST", Opt.action "directory"])))
                    )
                    (Opt.progDesc "Download into DEST (default: .)")
            , Opt.command "verify" $
                Opt.info
                    (pure Verify)
                    (Opt.progDesc "Check the bucket for unencrypted names")
            , Opt.command "mount" $
                Opt.info
                    (pure Mount)
                    (Opt.progDesc "Mount the archive read-only (used by the systemd unit)")
            ]

parserInfo :: Opt.ParserInfo Command
parserInfo =
    Opt.info
        (commandParser Opt.<**> Opt.helper)
        ( mconcat
            [ Opt.fullDesc
            , Opt.progDesc "Encrypted media archive on Backblaze B2"
            ]
        )

loadConfig :: IO Config
loadConfig =
    Config
        <$> getEnv "CLOUD_MEDIA_BUCKET_PATH"
        <*> getEnv "CLOUD_MEDIA_ENDPOINT"
        <*> getEnv "CLOUD_MEDIA_REGION"
        <*> getEnv "CLOUD_MEDIA_KEY_ID_FILE"
        <*> getEnv "CLOUD_MEDIA_APP_KEY_FILE"
        <*> getEnv "CLOUD_MEDIA_PASSWORD_FILE"
        <*> getEnv "CLOUD_MEDIA_SALT_FILE"
        <*> getEnv "CLOUD_MEDIA_MOUNTPOINT"
        <*> getEnv "CLOUD_MEDIA_CACHE_DIR"

{- | Fail loudly on a missing or empty secret; an empty passphrase would
otherwise derive a different key and silently write an unreadable archive.
-}
readSecret :: FilePath -> IO String
readSecret path = do
    exists <- doesPathExist path
    unless exists $ die ("cloud-media: missing secret: " ++ path)
    value <- T.strip <$> TIO.readFile path
    if T.null value
        then die ("cloud-media: empty secret: " ++ path)
        else pure (T.unpack value)

-- | Fed on stdin rather than argv so the passphrase never appears in @ps@.
obscure :: String -> IO String
obscure secret = do
    let input = Tu.select [Tu.unsafeTextToLine (T.pack secret)]
    (code, out) <- Tu.procStrict "rclone" ["obscure", "-"] input
    case code of
        ExitSuccess -> pure (T.unpack (T.strip out))
        ExitFailure n -> die ("cloud-media: rclone obscure failed with " ++ show n)

-- | Define both remotes in the environment, so no config file is needed.
configureRclone :: Config -> IO ()
configureRclone cfg = do
    keyId <- readSecret (keyIdFile cfg)
    appKey <- readSecret (appKeyFile cfg)
    password <- obscure =<< readSecret (passwordFile cfg)
    salt <- obscure =<< readSecret (saltFile cfg)
    mapM_
        (uncurry setEnv)
        [ ("RCLONE_CONFIG", "/dev/null")
        , ("RCLONE_CONFIG_B2_TYPE", "s3")
        , -- Backblaze is not an enumerated provider, so quirks stay unpinned without this
          ("RCLONE_CONFIG_B2_PROVIDER", "Other")
        , ("RCLONE_CONFIG_B2_ENDPOINT", endpoint cfg)
        , ("RCLONE_CONFIG_B2_REGION", region cfg)
        , -- bucket-restricted application keys cannot ListBuckets
          ("RCLONE_CONFIG_B2_NO_CHECK_BUCKET", "true")
        , ("RCLONE_CONFIG_B2_ACCESS_KEY_ID", keyId)
        , ("RCLONE_CONFIG_B2_SECRET_ACCESS_KEY", appKey)
        , ("RCLONE_CONFIG_MEDIA_TYPE", "crypt")
        , ("RCLONE_CONFIG_MEDIA_REMOTE", "b2:" ++ bucketPath cfg)
        , ("RCLONE_CONFIG_MEDIA_PASSWORD", password)
        , ("RCLONE_CONFIG_MEDIA_PASSWORD2", salt)
        ]

rclone :: [String] -> IO ()
rclone args =
    Tu.proc "rclone" (map T.pack args) Tu.empty >>= \case
        ExitSuccess -> pure ()
        code -> exitWith code

rcloneOut :: [String] -> IO T.Text
rcloneOut args = do
    (code, out) <- Tu.procStrict "rclone" (map T.pack args) Tu.empty
    case code of
        ExitSuccess -> pure out
        _ -> exitWith code

{- | Upload one path, verify it reads back through the crypt layer, then
drop the local copy. A directory keeps its name; a file lands at the
archive root, matching @rclone copy@'s own source semantics.
-}
archive :: FilePath -> IO ()
archive src = do
    exists <- doesPathExist src
    unless exists $ die ("cloud-media: no such path: " ++ src)
    isDir <- doesDirectoryExist src
    let name = takeFileName (dropTrailingPathSeparator src)
    if isDir
        then do
            rclone ["copy", "--progress", src, "media:" ++ name]
            rclone ["cryptcheck", "--one-way", src, "media:" ++ name]
        else do
            rclone ["copy", "--progress", src, "media:"]
            rclone ["cryptcheck", "--one-way", "--include", "/" ++ name, takeDirectory src, "media:"]
    putStrLn ("verified; removing local copy: " ++ src)
    removePathForcibly src

{- | Backstop for the crypt layer being bypassed: standard filename
encryption emits base32, so any readable path segment in the bucket means
something was written without going through @media:@.
-}
verify :: Config -> IO ()
verify cfg = do
    out <- rcloneOut ["lsf", "-R", "--files-only", "b2:" ++ bucketPath cfg]
    let segments = filter (not . T.null) (concatMap (T.splitOn "/") (T.lines out))
        bad = filter (not . T.all base32) segments
    if null bad
        then putStrLn "all remote names are encrypted"
        else do
            TIO.hPutStrLn stderr "cloud-media: unencrypted names present in bucket:"
            mapM_ (TIO.hPutStrLn stderr) bad
            exitWith (ExitFailure 1)
  where
    base32 c = (c >= 'a' && c <= 'z') || (c >= '2' && c <= '7')

{- | Replaces this process so the systemd unit's @Type=notify@ still sees
rclone's own readiness notification.
-}
mount :: Config -> IO ()
mount cfg = do
    createDirectoryIfMissing True (mountPoint cfg)
    createDirectoryIfMissing True (cacheDir cfg)
    executeFile
        "rclone"
        True
        [ "mount"
        , "media:"
        , mountPoint cfg
        , -- writes go through `archive` alone, so a file manager cannot damage the archive
          "--read-only"
        , "--vfs-cache-mode"
        , "full"
        , "--vfs-cache-max-size"
        , "5G"
        , "--cache-dir"
        , cacheDir cfg
        , "--dir-cache-time"
        , "1h"
        ]
        Nothing

main :: IO ()
main = do
    cmd <- Opt.execParser parserInfo
    cfg <- loadConfig
    configureRclone cfg
    case cmd of
        Archive paths -> forM_ paths archive
        List path -> rclone ["lsf", "-R", "media:" ++ fromMaybe "" path]
        Get path dest -> rclone ["copy", "--progress", "media:" ++ path, dest]
        Verify -> verify cfg
        Mount -> mount cfg
