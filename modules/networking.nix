{ pkgs, ... }:

{
  # iwd replaces NetworkManager.
  # IMPORTANT: saved WiFi networks do NOT migrate automatically.
  # After switching, reconnect using: iwgtk (GUI) or `iwctl` (CLI).
  # iwctl usage: `iwctl station wlan0 connect "SSID"`
  networking.networkmanager.enable = false;
  networking.wireless.iwd.enable   = true;
  networking.wireless.iwd.settings = {
    General.EnableNetworkConfiguration  = true;
    IPv6.Enabled                         = true;
    Scan.DisablePeriodicScan             = true;
    Network.NameResolutionMethod         = "none"; # DNSCrypt handles DNS
  };

  environment.systemPackages = with pkgs; [
    iwgtk   # GUI wifi manager for iwd
    impala  # TUI wifi manager for iwd
  ];
}
