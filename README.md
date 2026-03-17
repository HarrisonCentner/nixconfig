# NixConfig

NixOS and nix-darwin system configurations using flake-parts and import-tree.

## Architecture

This project uses [flake-parts](https://github.com/hercules-ci/flake-parts) with [import-tree](https://github.com/vic/import-tree) to auto-import all `.nix` files under `modules/` and `hosts/`.

### Flake-parts modules

Every `.nix` file under `modules/` and `hosts/` is a **flake-parts module**. These are NOT raw NixOS/home-manager modules — they are flake-parts modules that *define* NixOS and home-manager modules via `flake.modules.nixos.<name>` and `flake.modules.homeManager.<name>`.

Example module pattern:
```nix
{
  flake.modules.nixos.desktop =
    { pkgs, lib, ... }:
    {
      # NixOS config goes here
    };
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      # home-manager config goes here
    };
}
```

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
