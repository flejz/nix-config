# modules/home/shell.nix
# Bash configuration: default shell, environment variables, nvm.
{ pkgs, ... }: {

  programs.bash = {
    enable = true;

    sessionVariables = {
      EDITOR    = "nvim";
      VISUAL    = "nvim";
      # Rust toolchain paths (managed by rustup, not Nix)
      RUSTUP_HOME = "$HOME/.rustup";
      CARGO_HOME  = "$HOME/.cargo";
      # Node Version Manager
      NVM_DIR = "$HOME/.nvm";
    };

    initExtra = ''
      # ---- Rust (rustup) -------------------------------------
      export PATH="$CARGO_HOME/bin:$PATH"

      # ---- Node Version Manager (nvm) ------------------------
      # nvm is installed via git in the activation script (dotfiles.nix).
      # It writes node binaries to ~/.nvm/versions/ and manages PATH itself.
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
    '';
  };
}
