# NixConfig

NixOS and nix-darwin system configurations using [flake-parts](https://github.com/hercules-ci/flake-parts) and [import-tree](https://github.com/vic/import-tree).

## Architecture

### Flake-parts modules

Every `.nix` file under `modules/` and `hosts/` is a **flake-parts module**, which *defines* NixOS and home-manager modules via `flake.modules.nixos.<name>` and `flake.modules.homeManager.<name>`.

### Host configs

Host configs in `hosts/` compose modules via imports. Hosts with the prefix `hosts/nixos/` become `nixosConfigurations`, and `hosts/darwin/` become `darwinConfigurations`. The prefix is stripped to form the config name (e.g., `hosts/nixos/rwzfs` becomes `nixosConfigurations.rwzfs`).

```nix
# hosts/nixos/rwzfs/default.nix
{
  config,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/rwzfs" = {
    imports = with config.flake.modules.nixos; [
      base
      desktop
      # ...
    ];

    home-manager.users.myuser = {
      imports = with config.flake.modules.homeManager; [
        base
        desktop
        # ...
      ];
    };
  };
}
```

### Directory structure

- `modules/` — Reusable flake-parts modules (nixos + home-manager)
  - `base/` — Core system config (boot, networking, nix settings, etc.)
  - `desktop/` — GNOME desktop environment
  - `apps/` — Application configs (browser, editor, etc.)
  - `languages/` — Programming language toolchains
  - `services/` — System services (docker, ssh, microvm, etc.)
  - `shell/` — Shell configuration
  - `users/` — User account definitions
  - `flake-parts/` — Flake-level config (host-machines builder, formatter, nixpkgs)
- `hosts/` — Per-machine host configs that compose modules
  - `nixos/` — NixOS hosts (rwzfs, zylphia, microvm/)
  - `darwin/` — macOS hosts (xlthlx)

## Inspiration

+ [Dendritic Nix](https://dendrix.oeiuwq.com/Dendritic.html)
+ @drupol's [nixconfig](https://github.com/drupol/infra)
