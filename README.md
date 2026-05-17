# nix-config

NixOS flake configuration for `flejz`. Multi-machine, modular, home-manager integrated.

## Structure

```
nix-config/
├── config.nix                      # Root entrypoint — all options documented w/ defaults
├── flake.nix                       # Inputs + auto-discovers all machines/
├── machines/
│   └── <hostname>/
│       ├── config-override.nix    # Machine-specific overrides (hostname, timezone, apps)
│       └── hardware-configuration.nix  # Generated locally, NOT committed to git
├── modules/
│   ├── nixos/
│   │   ├── desktop.nix            # cfg.desktop option (gnome/kde/hyprland)
│   │   └── apps.nix               # cfg.apps.* optional communication apps
│   └── home/
│       ├── packages.nix           # User packages (dev tools, CLI, etc.)
│       ├── shell.nix              # Bash config, nvm, environment variables
│       ├── git.nix                # Git config with GPG signing
│       └── dotfiles.nix          # Symlinks ~/.dotfiles/ + auto-sync on rebuild
└── home/
    └── flejz/
        └── default.nix            # Home Manager entrypoint
```

**One file to understand everything:** `config.nix` documents all available options with
descriptions and defaults. Machine overrides only contain what differs.

---

## Prerequisites

- NixOS installed
- Git

---

## Step 1 — Enable Flakes (one-time bootstrap)

> **Already using flakes?** Check: `nix flake --version`
> If it prints a version, skip this step.

Flakes must be enabled before you can use this repo (chicken-and-egg: you need flakes to
apply the flake, but the flake enables them for future rebuilds). Do this once from your
existing `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Then rebuild with the old config:

```bash
sudo nixos-rebuild switch
```

From here on, all rebuilds use the flake.

---

## Step 2 — Bootstrap

```bash
# Clone the repo
git clone https://github.com/flejz/nix-config ~/nix-config
cd ~/nix-config

# Generate hardware config for your machine (not committed to git)
sudo nixos-generate-config --show-hardware-config \
  > machines/cybermancer/hardware-configuration.nix

# Review/edit machines/cybermancer/config-override.nix
# (at minimum: verify the timezone is correct)

# Build and switch
sudo nixos-rebuild switch --flake .#cybermancer
```

On first activation, Home Manager will:
- Clone `~/.dotfiles` from `github.com/flejz/.dotfiles`
- Install `nvm` into `~/.nvm`
- Symlink `~/.tmux.conf` and `~/.config/nvim` to `~/.dotfiles/`

---

## Customisation

### Global defaults
Edit `config.nix`. Changes apply to all machines on next rebuild.

### Per-machine overrides
Edit `machines/<hostname>/config-override.nix`. Only set what differs from `config.nix`.

**Switch desktop environment:**
```nix
# machines/cybermancer/config-override.nix
cfg.desktop = "kde";       # or "hyprland" or "none"
```

**Enable optional apps:**
```nix
cfg.apps.discord.enable  = true;
cfg.apps.signal.enable   = true;
```

**Rebuild after changes:**
```bash
sudo nixos-rebuild switch --flake .#cybermancer
```

---

## Adding a New Machine

```bash
cp -r machines/cybermancer machines/<newhostname>
# Edit machines/<newhostname>/config-override.nix — update hostname, timezone
sudo nixos-generate-config --show-hardware-config \
  > machines/<newhostname>/hardware-configuration.nix
sudo nixos-rebuild switch --flake .#<newhostname>
```

The flake auto-discovers all directories under `machines/`.

---

## Dotfiles

`~/.dotfiles` is automatically cloned from `github.com/flejz/.dotfiles` and updated
(`git pull --ff-only`) on every `nixos-rebuild switch`.

`~/.tmux.conf` and `~/.config/nvim` are symlinks into `~/.dotfiles/` — edit files there
directly, no rebuild needed.

---

## Installed Software

| Category        | Packages |
|-----------------|----------|
| Shell           | bash (default shell) |
| Editors         | neovim, tmux |
| Version control | git (with GPG signing + delta diffs) |
| Secrets         | gnupg, pass |
| Languages       | go, python3, rustup (manages own toolchains), nvm (node) |
| C/C++           | gcc, clang, clangd, clang-format, cmake, ninja, make, gdb, valgrind |
| Containers      | docker (daemon), docker-compose |
| Browser         | firefox (default) |
| AI              | claude-code |
| Optional        | slack, discord, signal, telegram, zoom (enable per machine) |

### Post-install steps
After first boot, install Rust and Node:
```bash
rustup toolchain install stable   # install Rust stable
nvm install --lts                  # install latest LTS Node
```
