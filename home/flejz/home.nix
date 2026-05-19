# home/flejz/home.nix — all Home Manager config for user flejz.
{ config, lib, pkgs, ... }: {

  home.username      = "flejz";
  home.homeDirectory = "/home/flejz";
  home.stateVersion  = "25.11";

  home.packages = with pkgs; [
    # Version control & secrets
    git gh gnupg pass ripgrep wl-clipboard pinentry-all tree
    # Remote desktop
    remmina
    # Editors & terminal
    neovim tmux kitty
    # Go
    go
    # Python
    python3
    # Rust (rustup manages toolchains outside Nix store)
    rustup
    # C/C++ (clang dropped: conflicts with gcc in buildEnv; clang-tools provides clangd)
    gcc clang-tools cmake ninja gnumake gdb valgrind pkg-config
    # AI
    claude-code
    # Containers
    docker-compose
    # Git delta (pager)
    delta
  ];

  programs.bash = {
    enable = true;
    sessionVariables = {
      EDITOR      = "nvim";
      VISUAL      = "nvim";
      RUSTUP_HOME = "$HOME/.rustup";
      CARGO_HOME  = "$HOME/.cargo";
      NVM_DIR     = "$HOME/.nvm";
    };
    initExtra = ''
      export PATH="$CARGO_HOME/bin:$PATH"
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
    '';
  };

  programs.git = {
    enable = true;
    signing = {
      key           = "0BE22D455E7C1770";
      signByDefault = true;
    };
    settings = {
      user.name  = "flejz";
      user.email = "flejz@protonmail.com";
      init.defaultBranch   = "main";
      pull.rebase          = true;
      push.autoSetupRemote = true;
      core.editor          = "nvim";
      tag.gpgSign          = true;
      merge.conflictstyle  = "diff3";
      diff.colorMoved      = "default";
      alias = {
        st   = "status";
        co   = "checkout";
        lg   = "log --oneline --graph --decorate --all";
        undo = "reset --soft HEAD~1";
      };
    };
  };

  programs.delta = {
    enable               = true;
    enableGitIntegration = true;
    options = {
      navigate     = true;
      light        = false;
      line-numbers = true;
    };
  };

  programs.gpg = {
    enable = true;
    settings = {
      keyid-format     = "long";
      with-fingerprint = true;
    };
  };

  services.gpg-agent = {
    enable          = true;
    defaultCacheTtl = 3600;
    maxCacheTtl     = 7200;
    pinentryPackage = pkgs.pinentry-all;
  };

  home.activation.syncDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    DOTFILES="$HOME/.dotfiles"
    if [ ! -d "$DOTFILES/.git" ]; then
      echo "Cloning dotfiles..."
      ${pkgs.git}/bin/git clone https://github.com/flejz/.dotfiles "$DOTFILES"
    else
      echo "Updating dotfiles..."
      ${pkgs.git}/bin/git -C "$DOTFILES" pull --ff-only || \
        echo "Dotfiles pull skipped (resolve manually in $DOTFILES)"
    fi
  '';

  home.activation.installNvm = lib.hm.dag.entryAfter [ "syncDotfiles" ] ''
    NVM_DIR="$HOME/.nvm"
    if [ ! -f "$NVM_DIR/nvm.sh" ]; then
      echo "Installing nvm..."
      ${pkgs.git}/bin/git clone --depth 1 \
        https://github.com/nvm-sh/nvm.git "$NVM_DIR" || \
        echo "nvm install failed — run manually: git clone https://github.com/nvm-sh/nvm.git ~/.nvm"
    fi
  '';

  home.file = {
    ".tmux.conf".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.dotfiles/.tmux.conf";
    ".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.dotfiles/nvim";
  };
}
