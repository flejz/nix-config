# modules/nixos/desktop.nix
# Defines the cfg.desktop option and enables the chosen DE.
{ config, lib, pkgs, ... }:
let
  desktop = config.cfg.desktop;
in
{
  options.cfg.desktop = lib.mkOption {
    type        = lib.types.enum [ "gnome" "kde" "hyprland" "none" ];
    default     = "gnome";
    description = ''
      Desktop environment to use.
        "gnome"    — GNOME on Wayland via GDM (recommended for laptops)
        "kde"      — KDE Plasma 6 on Wayland via SDDM
        "hyprland" — Hyprland tiling WM via GDM
        "none"     — No DE/WM managed by Nix
    '';
  };

  config = lib.mkMerge [

    # ---- GNOME ------------------------------------------------
    (lib.mkIf (desktop == "gnome") {
      services.xserver.enable = true;
      services.desktopManager.gnome.enable = true;
      services.displayManager.gdm.enable = true;
      services.displayManager.gdm.wayland = true;
      # Remove default GNOME bloat apps
      environment.gnome.excludePackages = with pkgs; [
        gnome-tour
        epiphany   # GNOME web browser (Firefox is used instead)
      ];
    })

    # ---- KDE Plasma 6 ----------------------------------------
    (lib.mkIf (desktop == "kde") {
      services.desktopManager.plasma6.enable = true;
      services.displayManager.sddm.enable = true;
      services.displayManager.sddm.wayland.enable = true;
    })

    # ---- Hyprland --------------------------------------------
    (lib.mkIf (desktop == "hyprland") {
      programs.hyprland.enable = true;
      services.displayManager.gdm.enable = true;
      services.displayManager.gdm.wayland = true;
      # Hyprland needs XDG portal for screen sharing etc.
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      };
    })

  ];
}
