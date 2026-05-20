{ config, pkgs, lib, inputs, ... }:
let
  desktop = config.cfg.desktop;
in
{
  imports = [
    ./modules/bootloader.nix
    ./modules/fonts.nix
    ./modules/theme.nix
    ./modules/display-manager.nix
    ./modules/bluetooth.nix
    ./modules/power.nix
    ./modules/networking.nix
    ./modules/dns.nix
    ./modules/security.nix
    ./modules/fingerprint.nix
    ./modules/virtualisation.nix
    ./modules/auto-upgrade.nix
    ./modules/sound.nix
    ./modules/nix-settings.nix
    ./modules/dev.nix
    ./modules/ai.nix
    ./modules/terminal.nix
    ./modules/services.nix
  ];

  options.cfg = {
    desktop = lib.mkOption {
      type    = lib.types.enum [ "gnome" "kde" "hyprland" "none" ];
      default = "hyprland";
      description = ''
        Desktop environment. Override per machine in machines/<name>/config-override.nix.
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
      nixpkgs.config.allowUnfree = true;

      services.automatic-timezoned.enable = true;
      i18n.defaultLocale = "en_US.UTF-8";

      programs.kdeconnect.enable = true;
      programs.firefox.enable    = true;

      programs.nix-ld.enable     = true;
      programs.nix-ld.libraries  = with pkgs; [
        zlib
        stdenv.cc.cc.lib
        libxml2
      ];

      users.users.flejz = {
        isNormalUser = true;
        description  = "flejz";
        shell        = pkgs.fish;  # Fish is now the default shell
        extraGroups  = [ "wheel" "video" "audio" "input" "podman" ];
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
      services.xserver.enable              = true;
      services.desktopManager.gnome.enable = true;
      services.displayManager.gdm.enable   = true;
      services.displayManager.gdm.wayland  = true;
      environment.gnome.excludePackages = with pkgs; [ gnome-tour epiphany ];
    })

    (lib.mkIf (desktop == "kde") {
      services.desktopManager.plasma6.enable      = true;
      services.displayManager.sddm.enable         = true;
      services.displayManager.sddm.wayland.enable = true;
    })

    (lib.mkIf (desktop == "hyprland") {
      programs.hyprland.enable    = true;
      programs.hyprland.withUWSM  = true;
      # display-manager.nix provides greetd — GDM is intentionally not enabled here
      xdg.portal = {
        enable       = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
        config.common.default = "*";
      };
    })
  ];
}
