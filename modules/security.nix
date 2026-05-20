{ pkgs, lib, ... }:

{
  security.apparmor = {
    enable                     = true;
    killUnconfinedConfinables  = true;
    packages = with pkgs; [
      apparmor-utils
      apparmor-profiles
    ];
  };

  services.dbus.apparmor = "enabled";
  services.fail2ban.enable = true;

  services.clamav = {
    daemon.enable      = true;
    updater.enable     = true;
    updater.interval   = "daily";
    updater.frequency  = 12;
  };

  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      mpv = {
        executable = "${lib.getBin pkgs.mpv}/bin/mpv";
        profile    = "${pkgs.firejail}/etc/firejail/mpv.profile";
      };
      imv = {
        executable = "${lib.getBin pkgs.imv}/bin/imv";
        profile    = "${pkgs.firejail}/etc/firejail/imv.profile";
      };
      zathura = {
        executable = "${lib.getBin pkgs.zathura}/bin/zathura";
        profile    = "${pkgs.firejail}/etc/firejail/zathura.profile";
      };
      qutebrowser = {
        executable = "${lib.getBin pkgs.qutebrowser}/bin/qutebrowser";
        profile    = "${pkgs.firejail}/etc/firejail/qutebrowser.profile";
      };
      thunar = {
        executable = "${lib.getBin pkgs.xfce.thunar}/bin/thunar";
        profile    = "${pkgs.firejail}/etc/firejail/thunar.profile";
      };
    };
  };

  # USBGuard — FIXME: run `sudo usbguard generate-policy` after first boot
  # to generate a policy for your current USB devices, then paste it here.
  services.usbguard = {
    enable                = true;
    dbus.enable           = true;
    implicitPolicyTarget  = "allow"; # permissive until you configure your device list
  };

  environment.systemPackages = with pkgs; [
    gnupg
    openssl
    usbutils     # for `lsusb` to generate USBGuard policy
    vulnix       # nix vulnerability scanner: `vulnix --system`
    clamav
    pass-wayland
    pwgen
    mullvad-vpn
  ];
}
