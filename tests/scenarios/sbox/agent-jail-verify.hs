#!/usr/bin/env runghc
{-# LANGUAGE OverloadedStrings #-}

-- | In-jail assertions for the agent-jail NixOS test.
-- Usage: @agent-jail-verify {isolated|blocked|worktree}@.
module Main where

import Control.Monad (unless, when, forM_)
import Data.List (isSuffixOf)
import Data.Text qualified as T
import System.Directory (doesPathExist, removeFile)
import System.Environment (getArgs)
import System.Exit (ExitCode (..), die)
import Turtle qualified as Tu

data Condition
   = Missing
   | Exists
 deriving (Eq)

assertCondition :: Condition -> FilePath -> IO ()
assertCondition c p = do
  ok <- doesPathExist p
  let (respFail, msg) = case c of
        Exists -> (not ok, (p ++ " should exist inside the sandbox"))
        Missing -> (ok, (p ++ " should NOT be visible inside the sandbox"))
  when respFail $ die msg

verifyIsolated :: IO ()
verifyIsolated = do
  mapM_ (uncurry assertCondition) $ 
    -- Sibling dir and its sentinel must be invisible (no allowParent leakage).
    [ (Missing, "/home/alice/work/sibling")
    , (Missing, "/home/alice/work/sibling/sentinel")
    -- ~/.ssh content is not exposed.
    , (Missing, "/home/alice/.ssh/id_test")
    -- Declared binds appear inside the sandbox.
    , (Exists, "/home/alice/.claude")
    , (Exists, "/home/alice/.gemini")
    -- The project's own .git is reachable.
    , (Exists, "/home/alice/work/proj/.git")
    ]
  -- Project dir is writable: write, verify, clean up.
  let marker = "/home/alice/work/proj/.agent-jail-test-marker"
  writeFile marker ""
  exists <- doesPathExist marker
  unless exists $ die "marker file did not persist after write inside sandbox"
  removeFile marker

verifyBlocked :: IO ()
verifyBlocked = do
  -- /proc/net/dev is the canonical view of interfaces in the current netns.
  -- /sys isn't mounted by sbox, so we can't use /sys/class/net here.
  raw <- readFile "/proc/net/dev"
  -- Skip the two header lines, then take the first whitespace token of each
  -- remaining line and strip the trailing ":".
  let ifaces =
        [ take (length name - 1) name
          | line <- drop 2 (lines raw),
            name : _ <- [words line],
            ":" `isSuffixOf` name
        ]
  unless ("lo" `elem` ifaces) $
    die "lo missing from /proc/net/dev inside sandbox"
  -- The kernel auto-creates inert pseudo-stubs (ip6tnl0, tunl0, sit0, ...) in
  -- any fresh netns when the corresponding modules are loaded. They carry no
  -- traffic. Whitelist them and reject anything else (in particular tap0,
  -- which slirp4netns creates in `isolated` mode).
  let allowedPseudo =
        [ "lo"
        , "ip6tnl0"
        , "tunl0"
        , "sit0"
        , "gre0"
        , "gretap0"
        , "ip6gre0"
        , "erspan0"
        , "ip6_vti0"
        ]
      offenders = filter (`notElem` allowedPseudo) ifaces
  unless (null offenders) $
    die
      ( "--network blocked should expose only `lo` plus known kernel pseudo-stubs; found unexpected: "
          <> show offenders
      )

verifyWorktree :: IO ()
verifyWorktree = do
  mapM_ (uncurry assertCondition) $
    -- Main repo's .git is bound (the dynamic --bind injected by agent-jail).
    [ (Exists, "/home/alice/work/proj/.git")
    -- The main repo's working tree was NOT bound; only .git was. The sentinel
    -- file sitting next to .git in the main repo must therefore be invisible.
    , (Missing, "/home/alice/work/proj/sentinel-in-main")
    ]
  -- git status works from the worktree, proving the bound .git is usable.
  (code, out) <- Tu.shellStrict "git status --porcelain" Tu.empty
  case code of
    ExitSuccess -> pure ()
    ExitFailure n -> die $ mconcat
        [ "git status exited "
        , show n
        , " inside worktree; output: "
        , T.unpack out
        ]

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["isolated"] -> verifyIsolated
    ["blocked"] -> verifyBlocked
    ["worktree"] -> verifyWorktree
    _ -> die "usage: agent-jail-verify {isolated|blocked|worktree}"
