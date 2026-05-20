{ pkgs, ... }:

{
  programs.dconf.enable  = true;
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  services.tumbler.enable = true;   # thumbnail service for Thunar
  services.gvfs.enable   = true;    # USB automounting
  services.fwupd.enable  = true;    # firmware updates (LVFS)
  services.mpd.enable    = true;    # music player daemon

  services.dbus = {
    enable         = true;
    implementation = "broker";
  };

  environment.systemPackages = with pkgs; [
    # Status bar + launcher + notifications
    waybar
    rofi
    dunst

    # Media
    mpv
    imv
    zathura
    spotify
    playerctl

    # Browsers
    qutebrowser
    tor-browser
    mullvad-browser

    # Screenshot + screen recording
    grim
    slurp
    swappy    # screenshot editor (replaces satty for annotation)
    satty     # keep satty too for quick annotation
    wl-screenrec    # GPU-accelerated screen recording
    imagemagick
    ffmpeg_6-full

    # Clipboard
    wl-clipboard
    wl-clip-persist
    cliphist

    # Wayland utilities
    xdg-utils
    wtype
    wlogout
    qt6.qtwayland
    at-spi2-atk

    # System info fetchers
    fastfetch
    onefetch
    htop
    bottom
    btop
    kmon
    nvtopPackages.intel
    wlr-randr
    gpu-viewer
    dig
    speedtest-rs
  ];
}
