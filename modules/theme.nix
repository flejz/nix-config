{ pkgs, lib, ... }:

{
  # Catppuccin Macchiato (Teal) — system-level theming
  # HM handles per-user gtk/qt/cursor; this provides packages + console + env vars.

  console = {
    earlySetup = true;
    colors = [
      "1e1e2e" # black      (base)
      "f38ba8" # red
      "a6e3a1" # green
      "f9e2af" # yellow
      "89b4fa" # blue
      "f5c2e7" # magenta
      "94e2d5" # cyan
      "bac2de" # white
      "585b70" # bright black
      "f38ba8" # bright red
      "a6e3a1" # bright green
      "f9e2af" # bright yellow
      "89b4fa" # bright blue
      "f5c2e7" # bright magenta
      "94e2d5" # bright cyan
      "a6adc8" # bright white
    ];
  };

  environment.sessionVariables = {
    XCURSOR_THEME = "Catppuccin-Macchiato-Teal";
    XCURSOR_SIZE  = "24";
    GTK_THEME     = "Catppuccin-Macchiato-Teal-standard";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    catppuccin-gtk = pkgs.catppuccin-gtk.override {
      accents = [ "teal" ];
      size     = "standard";
      variant  = "macchiato";
    };
    colloid-icon-theme = pkgs.colloid-icon-theme.override {
      colorVariants = [ "teal" ];
    };
  };

  environment.systemPackages = with pkgs; [
    catppuccin-gtk
    catppuccin-cursors
    colloid-icon-theme
    numix-icon-theme-circle
    kdePackages.qtstyleplugin-kvantum
  ];
}
