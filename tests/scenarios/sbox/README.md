# Test Purpose

This test verifies that `agent-jail` (sbox) sandboxes an agent session correctly:
+ in isolated mode: sibling dirs and `~/.ssh` stay invisible, declared binds and the project's `.git` are reachable, and the project dir stays writable
+ `--network blocked` exposes only `lo` plus inert kernel pseudo-stubs (no `tap0`)
+ from a git worktree, the main repo's `.git` is bound while its working tree stays hidden, and `git status` still works
