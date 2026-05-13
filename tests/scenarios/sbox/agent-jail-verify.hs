{-# LANGUAGE OverloadedStrings #-}

-- | In-jail assertions for the agent-jail NixOS test.
-- Usage: @agent-jail-verify {isolated|blocked|worktree}@.
module Main where

import Control.Monad (unless, when)
import Data.List (isSuffixOf)
import Data.Text qualified as T
import System.Directory (doesPathExist, removeFile)
import System.Environment (getArgs)
import System.Exit (ExitCode (..), die)
import Turtle qualified as Tu

assertExists :: FilePath -> IO ()
assertExists p = do
  ok <- doesPathExist p
  unless ok $ die (p <> " should exist inside the sandbox")

assertMissing :: FilePath -> IO ()
assertMissing p = do
  ok <- doesPathExist p
  when ok $ die (p <> " should NOT be visible inside the sandbox")

verifyIsolated :: IO ()
verifyIsolated = do
  -- Sibling dir and its sentinel must be invisible (no allowParent leakage).
  assertMissing "/home/alice/work/sibling"
  assertMissing "/home/alice/work/sibling/sentinel"
  -- ~/.ssh content is not exposed.
  assertMissing "/home/alice/.ssh/id_test"
  -- Declared binds appear inside the sandbox.
  assertExists "/home/alice/.claude"
  assertExists "/home/alice/.gemini"
  -- The project's own .git is reachable.
  assertExists "/home/alice/work/proj/.git"
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
        [ "lo",
          "ip6tnl0",
          "tunl0",
          "sit0",
          "gre0",
          "gretap0",
          "ip6gre0",
          "erspan0",
          "ip6_vti0"
        ]
      offenders = filter (`notElem` allowedPseudo) ifaces
  unless (null offenders) $
    die
      ( "--network blocked should expose only `lo` plus known kernel pseudo-stubs; found unexpected: "
          <> show offenders
      )

verifyWorktree :: IO ()
verifyWorktree = do
  -- Main repo's .git is bound (the dynamic --bind injected by agent-jail).
  assertExists "/home/alice/work/proj/.git"
  -- The main repo's working tree was NOT bound; only .git was. The sentinel
  -- file sitting next to .git in the main repo must therefore be invisible.
  assertMissing "/home/alice/work/proj/sentinel-in-main"
  -- git status works from the worktree, proving the bound .git is usable.
  (code, out) <- Tu.shellStrict "git status --porcelain" Tu.empty
  case code of
    ExitSuccess -> pure ()
    ExitFailure n ->
      die $
        "git status exited "
          <> show n
          <> " inside worktree; output: "
          <> T.unpack out

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["isolated"] -> verifyIsolated
    ["blocked"] -> verifyBlocked
    ["worktree"] -> verifyWorktree
    _ -> die "usage: agent-jail-verify {isolated|blocked|worktree}"
