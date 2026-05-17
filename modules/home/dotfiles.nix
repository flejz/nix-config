# modules/home/dotfiles.nix
# Ensures ~/.dotfiles is always present and up to date,
# then symlinks relevant configs so edits take effect
# immediately without a NixOS rebuild.
{ config, lib, pkgs, ... }: {

  # ---- Auto-sync dotfiles repo on every activation ----------
  # Clones on first run; does `git pull --ff-only` on subsequent runs.
  # If pull fails (e.g. local uncommitted changes), it skips silently.
  home.activation.syncDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    DOTFILES="$HOME/.dotfiles"
    if [ ! -d "$DOTFILES/.git" ]; then
      echo "Cloning dotfiles from github.com/flejz/.dotfiles..."
      ${pkgs.git}/bin/git clone https://github.com/flejz/.dotfiles "$DOTFILES"
    else
      echo "Updating dotfiles..."
      ${pkgs.git}/bin/git -C "$DOTFILES" pull --ff-only || \
        echo "Dotfiles pull skipped (resolve conflicts manually in $DOTFILES)"
    fi
  '';

  # ---- Auto-install nvm via git -----------------------------
  # nvm is not in nixpkgs. This clones the latest stable nvm
  # into ~/.nvm on first run and skips if already installed.
  # nvm.sh is sourced from shell.nix.
  home.activation.installNvm = lib.hm.dag.entryAfter [ "syncDotfiles" ] ''
    NVM_DIR="$HOME/.nvm"
    if [ ! -f "$NVM_DIR/nvm.sh" ]; then
      echo "Installing nvm..."
      ${pkgs.git}/bin/git clone --depth 1 \
        https://github.com/nvm-sh/nvm.git "$NVM_DIR" || \
        echo "nvm install failed — run manually: git clone https://github.com/nvm-sh/nvm.git ~/.nvm"
    fi
  '';

  # ---- Symlinks to ~/.dotfiles (mkOutOfStoreSymlink) --------
  # These symlinks point OUTSIDE the Nix store, so editing
  # ~/.dotfiles/.tmux.conf or ~/.dotfiles/nvim/ takes effect
  # immediately — no rebuild required.
  home.file = {
    ".tmux.conf".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.dotfiles/.tmux.conf";

    ".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.dotfiles/nvim";
  };
}
