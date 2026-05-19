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
    # Wayland utilities
    brightnessctl
    # Theming (Qt dark)
    libsForQt5.qt5ct adwaita-qt adwaita-qt6
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

  gtk = {
    enable = true;
    theme = {
      name    = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4 = {
      theme = null; # adopt new default (suppress stateVersion warning)
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;    # NixOS programs.hyprland.enable manages the package
    configType = "hyprlang"; # adopt new default (suppress stateVersion warning)

    settings = {
      "$mainMod" = "SUPER";

      monitor = ",preferred,auto,1";

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        preserve_split = true;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
        sensitivity = 0;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      env = [
        "GTK_THEME,Adwaita:dark"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
      ];

      windowrule = [
        "match:class ^(hypr-binds)$, float 1, center 1, size 900 600"
      ];

      bind = [
        # Applications
        "$mainMod, Q, exec, kitty"
        "$mainMod, C, killactive,"
        "$mainMod, E, exec, dolphin"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, hyprlauncher"
        "$mainMod, T, layoutmsg, togglesplit"
        "$mainMod, slash, exec, kitty --class hypr-binds -e sh -c 'grep -E \"^bind\" ~/.config/hypr/hyprland.conf | less -K'"
        "$mainMod SHIFT, M, exec, hyprctl dispatch exit"
        # Scratchpad
        "$mainMod, S, togglespecialworkspace, scratch"
        "$mainMod SHIFT, S, movetoworkspace, special:scratch"
        # Window cycling (alt-tab)
        "ALT, Tab,       cyclenext"
        "ALT SHIFT, Tab, cyclenext, prev"
        "$mainMod, Tab,  workspace, e+1"
        # Window focus
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        # Move windows
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, l, movewindow, r"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, j, movewindow, d"
        # Workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        # Scroll workspaces with mouse wheel
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up,   workspace, e-1"
        # Volume / brightness (media keys)
        ", XF86AudioMute,        exec, wpctl set-mute   @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp,   exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      binde = [
        # Resize windows
        "$mainMod CTRL, l, resizeactive,  10  0"
        "$mainMod CTRL, h, resizeactive, -10  0"
        "$mainMod CTRL, k, resizeactive,   0 -10"
        "$mainMod CTRL, j, resizeactive,   0  10"
        # Volume with repeat
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
