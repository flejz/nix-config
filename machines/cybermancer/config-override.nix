{ lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "cybermancer";

  # Synaptics touchpad firmware workaround (PR3584089)
  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];

  # VNC via GNOME Remote Desktop (Wayland-native, port 5900)
  networking.firewall.allowedTCPPorts = [ 5900 ];
  services.gnome.gnome-remote-desktop.enable = true;

  cfg.apps.slack.enable = true;
  cfg.desktop           = "hyprland";
}
