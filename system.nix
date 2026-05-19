# system.nix — NixOS base config + custom option definitions for all machines.
{ config, pkgs, lib, ... }:
let
  desktop = config.cfg.desktop;
in
{
  options.cfg = {
    desktop = lib.mkOption {
      type    = lib.types.enum [ "gnome" "kde" "hyprland" "none" ];
      default = "hyprland";
      description = ''
        Desktop environment. Override per machine in machines/<name>/config-override.nix.
          "gnome"    — GNOME on Wayland via GDM
          "kde"      — KDE Plasma 6 on Wayland via SDDM
          "hyprland" — Hyprland tiling WM via GDM
          "none"     — No DE/WM managed by Nix
      '';
    };

    apps = {
      slack.enable    = lib.mkEnableOption "Slack desktop client";
      discord.enable  = lib.mkEnableOption "Discord";
      signal.enable   = lib.mkEnableOption "Signal messenger";
      telegram.enable = lib.mkEnableOption "Telegram Desktop";
      zoom.enable     = lib.mkEnableOption "Zoom video conferencing";
    };
  };

  config = lib.mkMerge [
    {
      boot.loader.systemd-boot.enable       = lib.mkDefault true;
      boot.loader.efi.canTouchEfiVariables  = lib.mkDefault true;

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store   = true;
      };
      nixpkgs.config.allowUnfree = true;

      services.automatic-timezoned.enable = true;
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS        = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT    = "en_US.UTF-8";
        LC_MONETARY       = "en_US.UTF-8";
        LC_NAME           = "en_US.UTF-8";
        LC_NUMERIC        = "en_US.UTF-8";
        LC_PAPER          = "en_US.UTF-8";
        LC_TELEPHONE      = "en_US.UTF-8";
        LC_TIME           = "en_US.UTF-8";
      };

      networking.networkmanager.enable       = true;

      programs.firefox.enable = true;

      # nix-ld: run dynamically linked executables (rustup, etc.)
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        (pkgs.runCommand "libxml2-compat" {} ''
          mkdir -p $out/lib
          ln -s ${pkgs.libxml2.out}/lib/libxml2.so.16 $out/lib/libxml2.so.2
        '')
        zlib
        stdenv.cc.cc.lib
        libxml2
      ];

      virtualisation.docker.enable = true;

      services.pipewire = {
        enable           = true;
        alsa.enable      = true;
        alsa.support32Bit = true;
        pulse.enable     = true;
      };
      services.pulseaudio.enable = false;

      users.users.flejz = {
        isNormalUser = true;
        description  = "flejz";
        shell        = pkgs.bash;
        extraGroups  = [ "wheel" "networkmanager" "video" "audio" "docker" ];
      };

      system.stateVersion = "25.11";

      environment.systemPackages =
        lib.optionals config.cfg.apps.slack.enable    [ pkgs.slack ]
        ++ lib.optionals config.cfg.apps.discord.enable  [ pkgs.discord ]
        ++ lib.optionals config.cfg.apps.signal.enable   [ pkgs.signal-desktop ]
        ++ lib.optionals config.cfg.apps.telegram.enable [ pkgs.telegram-desktop ]
        ++ lib.optionals config.cfg.apps.zoom.enable     [ pkgs.zoom-us ];
    }

    (lib.mkIf (desktop == "gnome") {
      services.xserver.enable                  = true;
      services.desktopManager.gnome.enable     = true;
      services.displayManager.gdm.enable       = true;
      services.displayManager.gdm.wayland      = true;
      environment.gnome.excludePackages = with pkgs; [
        gnome-tour
        epiphany
      ];
    })

    (lib.mkIf (desktop == "kde") {
      services.desktopManager.plasma6.enable       = true;
      services.displayManager.sddm.enable          = true;
      services.displayManager.sddm.wayland.enable  = true;
    })

    (lib.mkIf (desktop == "hyprland") {
      programs.hyprland.enable            = true;
      services.displayManager.gdm.enable  = true;
      services.displayManager.gdm.wayland = true;
      xdg.portal = {
        enable       = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      };
      home-manager.users.flejz.home.packages = with pkgs; [ hyprlauncher kdePackages.dolphin ];
    })
  ];
}
