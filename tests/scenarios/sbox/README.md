# Test Purpose

This test verifies that `agent-jail` (sbox) sandboxes an agent session correctly:
+ in isolated mode: sibling dirs and `~/.ssh` stay invisible, declared binds and the project's `.git` are reachable, and the project dir stays writable
+ `--network blocked` exposes only `lo` plus inert kernel pseudo-stubs (no `tap0`)
+ from a git worktree, the main repo's `.git` is bound while its working tree stays hidden, and `git status` still works
+ the Nix daemon reports the jailed user as untrusted and still completes a sandboxed build
+ `/dev/kvm` is mounted automatically when present (a mknod stand-in, since the test VM lacks nested virt)

The host assertions require `rwzfs` and `zylphia` to trust only root in Nix.
Agents continue to run as the desktop user; that user no longer receives Nix daemon administrator privileges.
