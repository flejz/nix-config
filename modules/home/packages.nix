# modules/home/packages.nix
# User-level packages installed via Home Manager.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ---- Version control & secrets --------------------------
    git
    gh
    gnupg
    pass
    ripgrep
    wl-clipboard
    pinentry-all
    tree

    # ---- Editors & terminal tools ---------------------------
    neovim
    tmux

    # ---- Development: Go ------------------------------------
    go

    # ---- Development: Python --------------------------------
    python3

    # ---- Development: Rust ----------------------------------
    # rustup manages its own toolchains outside the Nix store.
    # Do NOT also install pkgs.cargo or pkgs.rustc — conflicts.
    # Run `rustup toolchain install stable` after first boot.
    rustup

    # ---- Development: Node (via nvm) ------------------------
    # nvm is NOT in nixpkgs. It is installed via git clone in
    # the activation script in dotfiles.nix, then sourced in
    # shell.nix. No package entry needed here.
    # Alternative: uncomment fnm below (faster, NixOS-native):
    # fnm

    # ---- Development: C/C++ suite ---------------------------
    # clang dropped: gcc and clang both ship ld.bfd wrappers that
    # conflict in home-manager's buildEnv. clang-tools provides
    # clangd (LSP) and clang-format without the compiler wrapper.
    gcc
    clang-tools      # includes clangd (LSP) and clang-format
    cmake
    ninja
    gnumake
    gdb
    valgrind
    pkg-config

    # ---- AI tooling -----------------------------------------
    claude-code

    # ---- Containers -----------------------------------------
    docker-compose

    # ---- Diff viewer (used by git delta in git.nix) ---------
    delta
  ];
}
