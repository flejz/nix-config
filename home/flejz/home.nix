{ config, lib, pkgs, inputs, ... }:
let
  # Catppuccin Macchiato palette
  c = {
    base     = "#24273a";
    mantle   = "#1e2030";
    crust    = "#181926";
    surface0 = "#363a4f";
    surface1 = "#494d64";
    surface2 = "#5b6078";
    overlay0 = "#6e738d";
    text     = "#cad3f5";
    subtext1 = "#b8c0e0";
    lavender = "#b7bdf8";
    blue     = "#8aadf4";
    teal     = "#8bd5ca";
    green    = "#a6da95";
    yellow   = "#eed49f";
    peach    = "#f5a97f";
    red      = "#ed8796";
    mauve    = "#c6a0f6";
    pink     = "#f5bde6";
  };

  # Hyprland plugins — all disabled until nixpkgs catches up with Hyprland 0.55 ABI
  hyprPlugins = [];
in
{
  home.username      = "flejz";
  home.homeDirectory = "/home/flejz";
  home.stateVersion  = "25.11";

  # ── Packages ──────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Version control & secrets
    git gh gnupg pass-wayland ripgrep wl-clipboard pinentry-all tree

    # Remote desktop
    remmina

    # Editors
    neovim tmux

    # Dev
    go rustup python3 gcc clang-tools cmake ninja gnumake gdb valgrind pkg-config

    # AI
    claude-code

    # Wayland utilities
    brightnessctl grim slurp satty wf-recorder hyprshade
    swayosd wlogout hyprsunset localsend hyprsunset
    hyprpicker hyprpolkitagent

    # Window switcher (from flake)
    inputs.hyprswitch.packages.${pkgs.system}.default

    # Git
    delta lazygit
    (pkgs.writeShellScriptBin "jjui" "exec ${pkgs.jujutsu}/bin/jj $@")  # placeholder until jjui lands

    # File management
    kdePackages.dolphin
    yazi thunar fd bat lsd

    # System monitors & info
    fastfetch onefetch btop bottom kmon wlr-randr gpu-viewer nvtopPackages.intel

    # Media
    mpv imv zathura spotify pavucontrol

    # Browsers
    firefox qutebrowser tor-browser mullvad-browser

    # Misc
    speedtest-rs topgrade kanata numbat magic-wormhole-rs croc yt-dlp
    tealdeer asciinema progress noti ouch duf dust ncdu
    doggo gping procs sd tokei grex
    viu chafa mdcat hexyl tidy-viewer tabiew
    cmatrix pipes-rs cbonsai figlet lolcat

    # Aider (AI pair programming)
    aider-chat
  ];

  # ── Cursor ────────────────────────────────────────────────────────────────
  home.pointerCursor = {
    package    = pkgs.catppuccin-cursors;
    name       = "catppuccin-macchiato-teal-cursors";
    size       = 24;
    gtk.enable = true;
  };

  # ── GTK ───────────────────────────────────────────────────────────────────
  gtk = {
    enable = true;
    theme = {
      name    = "Catppuccin-Macchiato-Teal-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "teal" ];
        size    = "standard";
        variant = "macchiato";
      };
    };
    iconTheme = {
      name    = "Numix-Circle";
      package = pkgs.numix-icon-theme-circle;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4 = {
      theme       = null;
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
    font = {
      name    = "JetBrains Mono";
      package = pkgs.jetbrains-mono;
      size    = 11;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };

  # ── Qt ────────────────────────────────────────────────────────────────────
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style = {
      name    = "kvantum";
      package = pkgs.kdePackages.qtstyleplugin-kvantum;
    };
  };

  # Kvantum — point to Catppuccin Macchiato theme
  home.file.".config/Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=catppuccin-macchiato
  '';

  # ── Shell: Fish ───────────────────────────────────────────────────────────
  programs.fish = {
    enable = true;
    shellAliases = {
      # NixOS
      nswitch = "sudo nixos-rebuild switch --flake /home/flejz/nix-config#cybermancer";
      nboot   = "sudo nixos-rebuild boot --flake /home/flejz/nix-config#cybermancer";
      ntest   = "sudo nixos-rebuild test --flake /home/flejz/nix-config#cybermancer";
      ngc     = "sudo nix-collect-garbage -d";
      conf    = "cd /home/flejz/nix-config && nvim .";

      # Git
      g   = "git";
      ga  = "git add";
      gc  = "git commit";
      gp  = "git push";
      gs  = "git status";
      gl  = "git log --oneline --graph --decorate --all";
      gd  = "git diff";
      gco = "git checkout";

      # Navigation
      ls   = "lsd";
      ll   = "lsd -la";
      cat  = "bat";
      find = "fd";
      grep = "rg";
      cd   = "z";

      # Tools
      lg  = "lazygit";
      top = "btop";
      ff  = "fastfetch";
    };
    interactiveShellInit = ''
      # Starship prompt
      starship init fish | source

      # Zoxide
      zoxide init fish | source

      # Direnv
      direnv hook fish | source

      # FZF
      fzf --fish | source

      # nvm (if installed)
      set -x NVM_DIR "$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && bass source "$NVM_DIR/nvm.sh"

      set -x EDITOR nvim
      set -x VISUAL nvim
      set -x RUSTUP_HOME "$HOME/.rustup"
      set -x CARGO_HOME "$HOME/.cargo"
      fish_add_path "$CARGO_HOME/bin"
    '';
  };

  # ── Starship prompt ───────────────────────────────────────────────────────
  programs.starship = {
    enable   = true;
    settings = {
      format = "$all";
      character = {
        success_symbol = "[❯](bold ${c.teal})";
        error_symbol   = "[❯](bold ${c.red})";
      };
      git_branch.style   = "bold ${c.mauve}";
      git_status.style   = "bold ${c.red}";
      directory.style    = "bold ${c.blue}";
      rust.style         = "bold ${c.peach}";
      golang.style       = "bold ${c.teal}";
      python.style       = "bold ${c.yellow}";
      nodejs.style       = "bold ${c.green}";
      nix_shell.style    = "bold ${c.lavender}";
      package.style      = "bold ${c.peach}";
    };
  };

  # ── Zoxide ────────────────────────────────────────────────────────────────
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # ── FZF ───────────────────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    colors = {
      "bg+"     = c.surface0;
      "bg"      = c.base;
      "spinner" = c.teal;
      "hl"      = c.red;
      "fg"      = c.text;
      "header"  = c.red;
      "info"    = c.mauve;
      "pointer" = c.teal;
      "marker"  = c.teal;
      "fg+"     = c.text;
      "prompt"  = c.mauve;
      "hl+"     = c.red;
    };
  };

  # ── Direnv ────────────────────────────────────────────────────────────────
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ── Kitty ─────────────────────────────────────────────────────────────────
  programs.kitty = {
    enable   = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      # Catppuccin Macchiato
      foreground            = c.text;
      background            = c.base;
      selection_foreground  = c.base;
      selection_background  = c.teal;
      cursor                = c.teal;
      cursor_text_color     = c.base;
      url_color             = c.blue;
      active_border_color   = c.teal;
      inactive_border_color = c.overlay0;
      bell_border_color     = c.yellow;

      # Tabs
      active_tab_foreground   = c.base;
      active_tab_background   = c.teal;
      inactive_tab_foreground = c.subtext1;
      inactive_tab_background = c.mantle;

      # Catppuccin color table
      color0  = c.surface1;
      color1  = c.red;
      color2  = c.green;
      color3  = c.yellow;
      color4  = c.blue;
      color5  = c.pink;
      color6  = c.teal;
      color7  = c.subtext1;
      color8  = c.surface2;
      color9  = c.red;
      color10 = c.green;
      color11 = c.yellow;
      color12 = c.blue;
      color13 = c.pink;
      color14 = c.teal;
      color15 = c.text;

      # Behaviour
      cursor_shape         = "block";
      cursor_blink_interval = "0.5";
      scrollback_lines     = 10000;
      enable_audio_bell    = false;
      shell_integration    = "enabled";
    };
    shellIntegration.enableFishIntegration = true;
  };

  # ── WezTerm ───────────────────────────────────────────────────────────────
  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm-flake;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config  = {}

      config.font             = wezterm.font('JetBrainsMono Nerd Font')
      config.font_size        = 12.0
      config.color_scheme     = 'Catppuccin Macchiato'
      config.enable_tab_bar   = true
      config.use_fancy_tab_bar = false
      config.window_padding   = { left = 4, right = 4, top = 4, bottom = 4 }
      config.window_background_opacity = 0.95
      config.front_end        = 'WebGpu'
      config.default_prog     = { '${pkgs.fish}/bin/fish' }

      return config
    '';
  };

  # ── Bat ───────────────────────────────────────────────────────────────────
  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Macchiato";
    themes = {
      "Catppuccin Macchiato" = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo  = "bat";
          rev   = "d714cc1d358ea51bfc02550dabab693f70cccea0";
          hash  = "sha256-Q5B4NDrfCIK3UAMs94vdXnR42k4AXCqZz6sRn8bzmf4=";
        };
        file = "themes/Catppuccin Macchiato.tmTheme";
      };
    };
  };

  # ── Zellij ────────────────────────────────────────────────────────────────
  programs.zellij = {
    enable = true;
    settings = {
      theme          = "catppuccin-macchiato";
      default_shell  = "fish";
      copy_clipboard = "system";
    };
  };

  # ── Git ───────────────────────────────────────────────────────────────────
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
      syntax-theme = "Catppuccin Macchiato";
    };
  };

  # ── GPG ───────────────────────────────────────────────────────────────────
  programs.gpg = {
    enable   = true;
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

  # ── Waybar ────────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    settings = [{
      layer    = "top";
      position = "top";
      height   = 36;
      modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right  = [ "pulseaudio" "network" "battery" "backlight" "tray" ];

      "hyprland/workspaces" = {
        format           = "{icon}";
        on-click         = "activate";
        format-icons = {
          "1" = ""; "2" = ""; "3" = ""; "4" = ""; "5" = "";
          active   = "";
          default  = "";
          urgent   = "";
        };
        persistent-workspaces = {
          "*" = 5;
        };
      };

      "hyprland/window" = {
        format          = "  {}";
        max-length      = 50;
        separate-outputs = true;
      };

      clock = {
        format          = "  {:%H:%M}";
        format-alt      = "  {:%A, %B %d, %Y}";
        tooltip-format  = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      battery = {
        states           = { good = 95; warning = 30; critical = 15; };
        format           = "{icon}  {capacity}%";
        format-charging  = "  {capacity}%";
        format-plugged   = "  {capacity}%";
        format-icons     = [ "" "" "" "" "" ];
      };

      network = {
        format-wifi       = "  {signalStrength}%";
        format-ethernet   = "  {ipaddr}";
        format-linked     = "  (No IP)";
        format-disconnected = "⚠  Disconnected";
        tooltip-format    = "{essid} ({signalStrength}%) via {ifname}";
      };

      pulseaudio = {
        format         = "{icon}  {volume}%";
        format-muted   = "  muted";
        format-icons   = { default = [ "" "" "" ]; };
        on-click       = "pavucontrol";
      };

      backlight = {
        format      = "{icon}  {percent}%";
        format-icons = [ "" "" "" "" "" "" "" "" "" ];
      };

      tray = {
        spacing = 8;
      };
    }];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }
      window#waybar {
        background-color: ${c.base};
        color: ${c.text};
        border-bottom: 2px solid ${c.surface0};
      }
      #workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: ${c.subtext1};
        border-bottom: 2px solid transparent;
      }
      #workspaces button.active {
        color: ${c.teal};
        border-bottom: 2px solid ${c.teal};
      }
      #workspaces button.urgent {
        color: ${c.red};
        border-bottom: 2px solid ${c.red};
      }
      #workspaces button:hover {
        background-color: ${c.surface0};
      }
      #window {
        color: ${c.subtext1};
        padding: 0 12px;
      }
      #clock, #battery, #network, #pulseaudio, #backlight, #tray {
        padding: 0 12px;
        color: ${c.text};
      }
      #battery.warning  { color: ${c.yellow}; }
      #battery.critical { color: ${c.red}; }
      #battery.charging { color: ${c.green}; }
    '';
  };

  # ── Rofi ──────────────────────────────────────────────────────────────────
  programs.rofi = {
    enable   = true;
    package  = pkgs.rofi;
    terminal = "${pkgs.kitty}/bin/kitty";
    theme    = "catppuccin-macchiato";
    extraConfig = {
      modi             = "drun,run,window,filebrowser";
      show-icons       = true;
      drun-display-fmt = "{name}";
      display-drun     = "  Apps";
      display-run      = "  Run";
      display-window   = "  Windows";
      display-filebrowser = "  Files";
    };
  };

  # Rofi Catppuccin Macchiato theme
  home.file.".local/share/rofi/themes/catppuccin-macchiato.rasi".text = ''
    * {
      bg0:  ${c.base}F2;
      bg1:  ${c.surface0};
      bg2:  ${c.surface1}80;
      bg3:  ${c.teal}1A;
      fg0:  ${c.text};
      fg1:  ${c.subtext1};
      fg2:  ${c.overlay0};
      acc:  ${c.teal};

      background-color:  transparent;
      text-color:        @fg0;
      font:              "JetBrainsMono Nerd Font 12";
    }
    window {
      background-color: @bg0;
      border:           2px;
      border-color:     @acc;
      border-radius:    12px;
      width:            600px;
    }
    mainbox { children: [ inputbar, listview ]; }
    inputbar {
      background-color: @bg1;
      border-radius:    8px;
      margin:           8px;
      padding:          8px;
      children:         [ prompt, entry ];
    }
    prompt {
      text-color:    @acc;
      padding:       0 8px 0 0;
    }
    entry {
      text-color:    @fg0;
      placeholder:   "Search...";
      placeholder-color: @fg2;
    }
    listview {
      background-color: transparent;
      margin:   4px 8px 8px;
      columns:  1;
      lines:    8;
      spacing:  4px;
    }
    element {
      background-color: transparent;
      border-radius:    6px;
      padding:          8px;
    }
    element selected { background-color: @bg3; }
    element-icon { size: 24px; }
    element-text { text-color: @fg0; }
  '';

  # ── Dunst ─────────────────────────────────────────────────────────────────
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width           = 300;
        height          = 200;
        offset          = "10x10";
        origin          = "top-right";
        font            = "JetBrainsMono Nerd Font 11";
        corner_radius   = 8;
        frame_width     = 2;
        gap_size        = 4;
        icon_path       = "${pkgs.numix-icon-theme-circle}/share/icons/Numix-Circle";
        max_icon_size   = 48;
        notification_limit = 8;
        timeout         = 5;
      };
      urgency_low = {
        background  = c.base;
        foreground  = c.text;
        frame_color = c.surface1;
      };
      urgency_normal = {
        background  = c.base;
        foreground  = c.text;
        frame_color = c.teal;
      };
      urgency_critical = {
        background  = c.base;
        foreground  = c.red;
        frame_color = c.red;
        timeout     = 0;
      };
    };
  };

  # ── Hyprland ──────────────────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable     = true;
    package    = null;
    configType = "hyprlang";

    plugins = hyprPlugins;

    settings = {
      "$mainMod" = "SUPER";

      monitor = ",preferred,auto,1";

      general = {
        gaps_in     = 5;
        gaps_out    = 10;
        border_size = 2;
        "col.active_border"   = "rgba(8bd5caff) rgba(8aadf4ff) 45deg";
        "col.inactive_border" = "rgba(363a4fff)";
        layout      = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size    = 6;
          passes  = 3;
          new_optimizations = true;
        };
        shadow = {
          enabled      = true;
          range        = 15;
          render_power = 3;
          color        = "rgba(1a1a2ebb)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.35, 0.95"
          "linear, 0, 0, 1, 1"
          "myBezier, 0.05, 0.9, 0.1, 1.05"
        ];
        animation = [
          "windows, 1, 6, myBezier"
          "windowsOut, 1, 6, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 5, easeOutQuint"
        ];
      };

      dwindle = {
        preserve_split  = true;
        pseudotile      = true;
      };

      input = {
        kb_layout        = "us";
        follow_mouse     = 1;
        touchpad.natural_scroll = true;
        sensitivity      = 0;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo   = true;
        disable_splash_rendering = true;
      };

      # cursor.no_hardware_cursors = true;  # only needed for hypr-dynamic-cursors plugin

      "exec-once" = [
        "waybar"
        "dunst"
        "hypridle"
        "hyprpolkitagent"
        "swayosd-server"
        "hyprswitch init --show-title"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "wl-clip-persist --clipboard regular"
      ];

      env = [
        "GTK_THEME,Catppuccin-Macchiato-Teal-standard"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATFORMTHEME,kvantum"
        "XCURSOR_THEME,catppuccin-macchiato-teal-cursors"
        "XCURSOR_SIZE,24"
      ];

      windowrule = [
        "match:class ^(hypr-binds)$, float 1, center 1, size 900 600"
      ];

      # plugin = { };  # re-add when nixpkgs plugin ABI catches up to Hyprland 0.55

      # ── Workspaces 1-20 ──
      bind = [
        # Applications
        "$mainMod, backspace, exec, hyprlock"
        "$mainMod, Q, exec, kitty"
        "$mainMod, C, killactive,"
        "$mainMod, E, exec, dolphin"
        "$mainMod, V, togglefloating,"
        "$mainMod, F, fullscreen, 0"
        "$mainMod, M, fullscreen, 1"
        "$mainMod, R, exec, rofi -show drun"
        "$mainMod, T, layoutmsg, togglesplit"
        "$mainMod, slash, exec, kitty --class hypr-binds -e sh -c 'grep -E \"^bind\" ~/.config/hypr/hyprland.conf | less -K'"
        "$mainMod SHIFT, M, exec, hyprctl dispatch exit"
        # Hyprexpo workspace overview
        # "$mainMod, grave, hyprexpo:toggleoverview"  # re-enable when hyprexpo is back
        # Utilities
        "$mainMod SHIFT, C, exec, hyprpicker -a"
        "$mainMod SHIFT, P, exec, wlogout"
        "$mainMod, F8, exec, hyprshade toggle blue-light-filter"
        "$mainMod, F9, exec, mkdir -p $HOME/Videos && wl-screenrec -f $HOME/Videos/$(date +%Y%m%d-%H%M%S).mp4"
        "$mainMod SHIFT, F9, exec, pkill -SIGTERM wl-screenrec"
        # Screenshot
        ", Print, exec, mkdir -p $HOME/Pictures && grim $HOME/Pictures/$(date +%Y%m%d-%H%M%S).png"
        "$mainMod SHIFT, S, exec, slurp | grim -g - - | swappy -f -"
        # Clipboard
        "$mainMod CTRL, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        # Scratchpad
        "$mainMod, S, togglespecialworkspace, scratch"
        # Window cycling
        "ALT, Tab, exec, hyprswitch gui --mod-key alt_l --key tab --close mod-key-release --reverse-key=shift"
        "$mainMod, Tab, workspace, e+1"
        # Focus
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        # Move windows
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, l, movewindow, r"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, j, movewindow, d"
        # Workspaces 1-10
        "$mainMod, 1, workspace, 1"  "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"  "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"  "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"  "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"  "$mainMod, 0, workspace, 10"
        # Workspaces 11-20
        "$mainMod ALT, 1, workspace, 11"  "$mainMod ALT, 2, workspace, 12"
        "$mainMod ALT, 3, workspace, 13"  "$mainMod ALT, 4, workspace, 14"
        "$mainMod ALT, 5, workspace, 15"  "$mainMod ALT, 6, workspace, 16"
        "$mainMod ALT, 7, workspace, 17"  "$mainMod ALT, 8, workspace, 18"
        "$mainMod ALT, 9, workspace, 19"  "$mainMod ALT, 0, workspace, 20"
        # Move to workspace 1-10
        "$mainMod SHIFT, 1, movetoworkspace, 1"  "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"  "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"  "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"  "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"  "$mainMod SHIFT, 0, movetoworkspace, 10"
        # Move to workspace 11-20
        "$mainMod SHIFT ALT, 1, movetoworkspace, 11"  "$mainMod SHIFT ALT, 2, movetoworkspace, 12"
        "$mainMod SHIFT ALT, 3, movetoworkspace, 13"  "$mainMod SHIFT ALT, 4, movetoworkspace, 14"
        "$mainMod SHIFT ALT, 5, movetoworkspace, 15"  "$mainMod SHIFT ALT, 6, movetoworkspace, 16"
        "$mainMod SHIFT ALT, 7, movetoworkspace, 17"  "$mainMod SHIFT ALT, 8, movetoworkspace, 18"
        "$mainMod SHIFT ALT, 9, movetoworkspace, 19"  "$mainMod SHIFT ALT, 0, movetoworkspace, 20"
        # Mouse scroll workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up,   workspace, e-1"
        # Volume
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
      ];

      bindrt = [
        "ALT, ALT_L, exec, hyprswitch close --kill"
      ];

      binde = [
        "$mainMod CTRL, l, resizeactive,  10  0"
        "$mainMod CTRL, h, resizeactive, -10  0"
        "$mainMod CTRL, k, resizeactive,   0 -10"
        "$mainMod CTRL, j, resizeactive,   0  10"
        ", XF86AudioRaiseVolume,  exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume,  exec, swayosd-client --output-volume lower"
        ", XF86MonBrightnessUp,   exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };

  # ── Hyprlock ──────────────────────────────────────────────────────────────
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor         = true;
      };
      background = [{
        monitor = "";
        color   = "rgba(24, 39, 58, 1.0)";
      }];
      input-field = [{
        monitor           = "";
        size              = "200, 50";
        outline_thickness = 2;
        outer_color       = "rgba(8bd5caff)";
        inner_color       = "rgba(24273aff)";
        font_color        = "rgba(cad3f5ff)";
        dots_center       = true;
        fade_on_empty     = false;
        placeholder_text  = "";
      }];
    };
  };

  # ── Hyprpaper ─────────────────────────────────────────────────────────────
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc    = "on";
      splash = false;
    };
  };

  # ── Hypridle ──────────────────────────────────────────────────────────────
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd         = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd  = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300;  on-timeout = "brightnessctl -s set 10"; on-resume = "brightnessctl -r"; }
        { timeout = 600;  on-timeout = "loginctl lock-session"; }
        { timeout = 1800; on-timeout = "systemctl suspend"; }
      ];
    };
  };

  # ── Hyprshade ─────────────────────────────────────────────────────────────
  home.file.".config/hyprshade/config.toml".text = ''
    [[shades]]
    name       = "blue-light-filter"
    start_time = "19:00"
    end_time   = "06:00"
  '';

  # ── Dotfiles (nvim, tmux) ──────────────────────────────────────────────────
  home.activation.syncDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    DOTFILES="$HOME/.dotfiles"
    if [ ! -d "$DOTFILES/.git" ]; then
      ${pkgs.git}/bin/git clone https://github.com/flejz/.dotfiles "$DOTFILES"
    else
      ${pkgs.git}/bin/git -C "$DOTFILES" pull --ff-only || \
        echo "Dotfiles pull skipped — resolve manually in $DOTFILES"
    fi
  '';

  home.activation.installNvm = lib.hm.dag.entryAfter [ "syncDotfiles" ] ''
    NVM_DIR="$HOME/.nvm"
    if [ ! -f "$NVM_DIR/nvm.sh" ]; then
      ${pkgs.git}/bin/git clone --depth 1 \
        https://github.com/nvm-sh/nvm.git "$NVM_DIR" || \
        echo "nvm install failed — run manually"
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
