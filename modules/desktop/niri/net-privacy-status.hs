#!/usr/bin/env runghc
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StrictData #-}
{-# OPTIONS_GHC -Wall -Wincomplete-uni-patterns -Wincomplete-record-updates #-}

{- | Emit one JSON line (text, icon, iconColor, tooltip) for the
net-privacy Noctalia plugin describing the active network privacy
mode: Mullvad VPN (refined by a DNS-leak probe), DNS-over-Tor
(dnscrypt → onion DoH), exposed, or offline.

Ground truth: @am.i.mullvad.net/json@ for the exit IP, the
@<uuid>.dnsleak.am.i.mullvad.net@ probe for the resolvers that
actually queried Mullvad's authoritative server, and a local dig
against 127.0.0.1:5454 to prove the dnscrypt→Tor chain is the live
datapath. A resolver only counts as a leak when it is neither Mullvad
nor Cloudflare: Cloudflare is expected (blocky upstreams, and the
onion endpoint is Cloudflare's DoH hidden service).
-}
module Main where

import Control.Applicative ((<|>))
import Control.Concurrent (threadDelay)
import Data.Aeson qualified as A
import Data.ByteString.Lazy.Char8 qualified as BL
import Data.Foldable (fold)
import Data.List (nub, sort)
import Data.Maybe (catMaybes, maybeToList)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.Encoding qualified as TE
import GHC.Generics (Generic)
import System.Exit (ExitCode (..))
import Turtle qualified as Tu

snakeCase :: A.Options
snakeCase = A.defaultOptions{A.fieldLabelModifier = A.camelTo2 '_'}

data Conn = Conn
    { ip :: Maybe Text
    , mullvadExitIp :: Maybe Bool
    , mullvadExitIpHostname :: Maybe Text
    , city :: Maybe Text
    , country :: Maybe Text
    }
    deriving (Generic)

instance A.FromJSON Conn where
    parseJSON = A.genericParseJSON snakeCase

-- Fail-safe: only an explicit true counts as Mullvad's own resolver;
-- false, null, or a missing field all mean the query went elsewhere.
data DnsOrigin = MullvadDns | ForeignDns

instance A.FromJSON DnsOrigin where
    parseJSON = \case
        A.Bool True -> pure MullvadDns
        _ -> pure ForeignDns
    omittedField = Just ForeignDns

-- An unidentifiable resolver is still a reportable entity in a leak
-- list, so absence parses to a name instead of vanishing.
newtype Org = Org Text

instance A.FromJSON Org where
    parseJSON = \case
        A.String t -> pure (Org t)
        _ -> pure (Org "unknown")
    omittedField = Just (Org "unknown")

data Resolver = Resolver
    { mullvadDns :: DnsOrigin
    , organization :: Org
    }
    deriving (Generic)

instance A.FromJSON Resolver where
    parseJSON = A.genericParseJSON snakeCase

data Status = Status
    { text :: Text
    , icon :: Text
    , iconColor :: Text
    , tooltip :: Text
    }
    deriving (Generic)

instance A.ToJSON Status where
    toEncoding = A.genericToEncoding A.defaultOptions

emit :: Status -> IO ()
emit = BL.putStrLn . A.encode

curlGet :: (A.FromJSON a) => Text -> IO (Maybe a)
curlGet url = do
    (code, out, _err) <-
        Tu.procStrictWithErr "curl" ["-sf", "--max-time", "10", url] Tu.empty
    pure $ case code of
        ExitSuccess -> A.decodeStrict (TE.encodeUtf8 out)
        ExitFailure _ -> Nothing

dnsleakProbe :: IO [Resolver]
dnsleakProbe = do
    uuid <- T.strip . T.pack <$> readFile "/proc/sys/kernel/random/uuid"
    _ <-
        Tu.procStrictWithErr
            "dig"
            ["+short", "+time=5", "+tries=1", uuid <> ".dnsleak.am.i.mullvad.net"]
            Tu.empty
    threadDelay 1000000
    fold <$> curlGet ("https://am.i.mullvad.net/dnsleak/" <> uuid)

torDnsAlive :: IO Bool
torDnsAlive = do
    (code, _out, _err) <-
        Tu.procStrictWithErr
            "dig"
            ["+time=5", "+tries=1", "@127.0.0.1", "-p", "5454", "mullvad.net"]
            Tu.empty
    pure (code == ExitSuccess)

isCloudflare :: Text -> Bool
isCloudflare = T.isInfixOf "cloudflare" . T.toLower

vpn :: Conn -> IO ()
vpn Conn{..} = do
    resolvers <- dnsleakProbe
    let leaking =
            nub . sort $
                [ org
                | Resolver{mullvadDns = ForeignDns, organization = Org org} <- resolvers
                , not (isCloudflare org)
                ]
        relay = T.unwords ("Mullvad" : maybeToList mullvadExitIpHostname)
        locale = liftA2 (\c k -> c <> "/" <> k) city country <|> city <|> country
    emit $
        if null leaking
            then
                Status
                    { text = "VPN"
                    , icon = "shield-check"
                    , iconColor = "primary"
                    , tooltip = T.intercalate " — " (relay : catMaybes [ip, locale])
                    }
            else
                Status
                    { text = "VPN"
                    , icon = "shield-exclamation"
                    , iconColor = "error"
                    , tooltip = relay <> " — DNS leaking via: " <> T.intercalate ", " leaking
                    }

unprotected :: Conn -> IO ()
unprotected Conn{..} = do
    alive <- torDnsAlive
    resolvers <- dnsleakProbe
    let orgNames = nub (sort [org | Resolver{organization = Org org} <- resolvers])
    emit (verdict alive orgNames)
  where
    ipNote prefix = maybeToList ((prefix <>) <$> ip)
    verdict True orgs@(_ : _)
        | all isCloudflare orgs =
            Status
                { text = "TOR"
                , icon = "spiral"
                , iconColor = "tertiary"
                , tooltip = T.intercalate "; " ("DNS over Tor (dnscrypt → onion DoH)" : ipNote "exit IP ")
                }
    verdict _ [] = exposed "unknown"
    verdict _ orgs = exposed (T.intercalate ", " orgs)
    exposed orgs =
        Status
            { text = "EXPOSED"
            , icon = "shield-off"
            , iconColor = "error"
            , tooltip = T.intercalate "; " (["No VPN", "DNS seen by: " <> orgs] <> ipNote "IP ")
            }

main :: IO ()
main = do
    curlGet "https://am.i.mullvad.net/json" >>= \case
        Nothing ->
            emit
                Status
                    { text = "?"
                    , icon = "question-mark"
                    , iconColor = "secondary"
                    , tooltip = "cannot reach connection check"
                    }
        Just conn@Conn{mullvadExitIp = Just True} -> vpn conn
        Just conn -> unprotected conn
