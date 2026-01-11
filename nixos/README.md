# NixOS Configuration

Complete declarative NixOS setup using Nix Flakes. Manages system state, packages, services, and dotfiles from one source of truth.

**Default:** `nixos-25.11` stable (tested, reliable). Optional: `nixos-unstable` (latest packages).

## Quick Start

**Clone and apply:**

```shell
# Public repo
nix run nixpkgs#git -- clone https://github.com/R-D-King/dotfiles.git
cd dotfiles
sudo nixos-rebuild switch --flake ./nixos#nixos

# Private repo (authenticate first)
nix run nixpkgs#gh -- auth login
nix run nixpkgs#gh -- repo clone R-D-King/dotfiles
cd dotfiles
sudo nixos-rebuild switch --flake ./nixos#nixos
```

## Files Overview

| File | Purpose |
|------|---------|
| `flake.nix` | Entry point, defines inputs and configurations |
| `configuration.nix` | System-wide settings (bootloader, services, packages) |
| `home.nix` | User config for `king` (packages, shell, dotfiles) |
| `hardware-configuration.nix` | Auto-generated hardware settings (don't edit) |

## Making Changes

### Edit and Apply System Config
```shell
vim ~/dotfiles/nixos/hosts/default/configuration.nix
sudo nixos-rebuild switch --flake ./nixos#nixos
```

### Edit and Apply User Config
```shell
vim ~/dotfiles/nixos/hosts/default/home.nix
home-manager switch --flake ./nixos#
```

### Add/Remove Packages

**User packages** (`home.nix`):
```nix
home.packages = with pkgs; [
  ripgrep             # stable (default)
  (pkgs-unstable.helix) # unstable (use with parentheses!)
];
```

**System packages** (`configuration.nix`):
```nix
environment.systemPackages = with pkgs; [
  curl
  (pkgs-unstable.neovim)  # unstable
];
```

**Find packages:**
```shell
nix search nixpkgs PACKAGE_NAME
```

## Applying Configuration

| Command | Effect |
|---------|--------|
| `sudo nixos-rebuild switch --flake ./nixos#nixos` | Build, activate, set as default |
| `sudo nixos-rebuild test --flake ./nixos#nixos` | Test (reverts on reboot) |
| `sudo nixos-rebuild dry-build --flake ./nixos#nixos` | Show changes without building |
| `sudo nixos-rebuild list-generations` | List all generations |
| `sudo nixos-rebuild switch --profile-name system-1` | Rollback to previous |

## Channels Explained

### Stable (Default)
- Tested packages, 6-month release cycle
- Best for: stability, servers, everyday use
- Manually updated (or change input to new release)

### Unstable
- Latest packages, daily updates
- Best for: specific tools needing latest features
- Auto-updated with `nix flake update`

### Using Unstable Packages

**Remember: Always use parentheses with `pkgs-unstable`!**

```nix
home.packages = with pkgs; [
  firefox                      # stable
  (pkgs-unstable.helix)        # unstable ← needs ()
  (pkgs-unstable.jujutsu)      # unstable ← needs ()
];
```

### Update Stable Channel

When new stable version releases:

1. Edit `flake.nix`:
   ```nix
   # Example: Updating from 25.11 to 26.05
   # Update the URL to the new stable release
   nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
   ```

2. Rebuild:
   ```shell
   nix flake update --flake ./nixos
   sudo nixos-rebuild switch --flake ./nixos#nixos
   ```

3. Commit:
   ```shell
   git add ./nixos/flake.nix ./nixos/flake.lock
   git commit -m "Update system to nixos-26.05"
   ```

**No auto-updates:** Only update when you explicitly change the version.

## Understanding `#nixos`

The `#nixos` in `--flake ./nixos#nixos` is the **configuration name**.

```nix
nixosConfigurations = {
  nixos = nixpkgs.lib.nixosSystem { ... };  # ← This "nixos"
};
```

You can create multiple configurations:
```nix
nixosConfigurations = {
  nixos = nixpkgs.lib.nixosSystem { ... };        # desktop
  nixos-laptop = nixpkgs.lib.nixosSystem { ... }; # laptop
  nixos-server = nixpkgs.lib.nixosSystem { ... }; # server
};
```

Deploy with: `sudo nixos-rebuild switch --flake ./nixos#nixos-laptop`

## Dotfiles Management

Home Manager automatically creates symlinks. To add a new config:

```nix
xdg.configFile."APPNAME".source =
  config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/APPNAME/.config/APPNAME";

home.file.".FILENAME".source =
  config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/app/.FILENAME";
```

The `dotfilesDir` is defined at the top of `home.nix`:
```nix
let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
in
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Cannot find flake" error | `cd ~/dotfiles` then rebuild |
| Home Manager not applying | Run `home-manager switch --flake ./nixos#` |
| Package not found | `nix search nixpkgs PACKAGE_NAME` |
| Conflicting symlinks | `home-manager switch --flake ./nixos# --force` |
| System broken | `sudo nixos-rebuild switch --profile-name system-1` |

## Configuration Summary

- **User:** king
- **System:** Dell Precision 7520 + GNOME
- **Default Branch:** nixos-25.11 (Stable)
- **Unstable Branch:** nixos-unstable (Latest)
- **Key Packages:** Go, Rust, Python, Helix, Zed, Fish, Git

## Resources

**Official Documentation:**
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)

**Package & Configuration Search:**
- [Nixpkgs Search](https://search.nixos.org/packages) - Find packages
- [MyNixOS](https://mynixos.com/) - Interactive config builder
- [NixHub](https://www.nixhub.io/) - Package & module explorer

**Other:**
- [NixOS Release Schedule](https://nixos.org/download.html)
