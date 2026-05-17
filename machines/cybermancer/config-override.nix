# machines/cybermancer/config-override.nix
# ============================================================
# MACHINE OVERRIDES — cybermancer (laptop)
#
# Only put values here that DIFFER from config.nix defaults.
# All available options are documented in ../../config.nix.
#
# To add a new machine:
#   cp -r machines/cybermancer machines/<newhostname>
#   Edit this file (update hostname, timezone, etc.)
#   On the new machine, run: sudo nixos-generate-config
#   (this writes /etc/nixos/hardware-configuration.nix automatically)
#   sudo nixos-rebuild switch --flake .#<newhostname>
# ============================================================
{ config, pkgs, lib, ... }: {
  imports = [ ./hardware-configuration.nix ];

  # Machine identity
  networking.hostName = "cybermancer";

  # Timezone — see: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  # time.timeZone = "Europe/Berlin";

  # ---- App overrides (uncomment to install) ------------------
  # cfg.apps.discord.enable  = true;
  # cfg.apps.slack.enable    = true;
  # cfg.apps.signal.enable   = true;
  # cfg.apps.telegram.enable = true;
  # cfg.apps.zoom.enable     = true;

  # ---- Desktop override (uncomment to change) ----------------
  # cfg.desktop = "kde";        # switch to KDE Plasma 6
  # cfg.desktop = "hyprland";   # switch to Hyprland tiling WM
}
