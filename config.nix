# config.nix
# ============================================================
# BASE CONFIGURATION — applies to ALL machines.
#
# This is the single entrypoint to understand and configure
# every aspect of the system. Sensible defaults are set here.
#
# To customise per machine, override values in:
#   machines/<hostname>/config-override.nix
#
# After any change, rebuild with:
#   sudo nixos-rebuild switch --flake .#<hostname>
# ============================================================
{ config, pkgs, lib, ... }: {

  # ------------------------------------------------------------
  # DESKTOP ENVIRONMENT
  # Options: "gnome" | "kde" | "hyprland" | "none"
  # Default: GNOME on Wayland (recommended for laptops).
  # Override per machine in config-override.nix if needed.
  # ------------------------------------------------------------
  cfg.desktop = lib.mkDefault "gnome";

  # ------------------------------------------------------------
  # OPTIONAL COMMUNICATION APPS
  # All off by default — large downloads, some unfree.
  # Set to true in machines/<hostname>/config-override.nix.
  #
  # Available options (all default false via mkEnableOption):
  #   cfg.apps.slack.enable    — Slack desktop client
  #   cfg.apps.discord.enable  — Discord
  #   cfg.apps.signal.enable   — Signal messenger
  #   cfg.apps.telegram.enable — Telegram Desktop
  #   cfg.apps.zoom.enable     — Zoom video conferencing
  # ------------------------------------------------------------

  # ------------------------------------------------------------
  # BOOTLOADER
  # systemd-boot for UEFI systems (most modern laptops/desktops).
  # Override to boot.loader.grub.* in config-override.nix for legacy BIOS.
  # ------------------------------------------------------------
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Workaround for Synaptics firmware PR3584089 touchpad issues.
  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];

  # ------------------------------------------------------------
  # NIX SETTINGS
  # ------------------------------------------------------------
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Allow unfree packages (Slack, Discord, Zoom, etc.)
  nixpkgs.config.allowUnfree = true;

  # ------------------------------------------------------------
  # LOCALE & TIME
  # Timezone is detected automatically via geoclue2.
  # To pin a static timezone instead, set time.timeZone in config-override.nix:
  #   time.timeZone = "America/Sao_Paulo";
  # ------------------------------------------------------------
  services.automatic-timezone.enable = true;
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

  # ------------------------------------------------------------
  # NETWORKING
  # hostname is set per machine in config-override.nix.
  # ------------------------------------------------------------
  networking.networkmanager.enable = true;

  # ------------------------------------------------------------
  # DEFAULT BROWSER — Firefox
  # ------------------------------------------------------------
  programs.firefox.enable = true;

  # ------------------------------------------------------------
  # NIX-LD — run dynamically linked executables (rustup, etc.)
  # Sets up a stub ld-linux so FHS binaries work without patching.
  # ------------------------------------------------------------
  programs.nix-ld.enable = true;
  # To fix "missing shared library" errors for specific binaries:
  # programs.nix-ld.libraries = with pkgs; [ openssl zlib stdenv.cc.cc ];

  # ------------------------------------------------------------
  # DOCKER
  # Enables the Docker daemon. flejz is added to docker group.
  # Use docker-compose (installed via home-manager packages).
  # ------------------------------------------------------------
  virtualisation.docker.enable = true;

  # ------------------------------------------------------------
  # AUDIO — PipeWire (modern replacement for PulseAudio)
  # ------------------------------------------------------------
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;  # conflicts with PipeWire

  # ------------------------------------------------------------
  # USER — always flejz, shell always bash
  # ------------------------------------------------------------
  users.users.flejz = {
    isNormalUser = true;
    description  = "flejz";
    shell        = pkgs.bash;
    extraGroups  = [ "wheel" "networkmanager" "video" "audio" "docker" ];
  };

  # ------------------------------------------------------------
  # SYSTEM STATE VERSION
  # This should match the NixOS version when you first installed.
  # Check your existing /etc/nixos/configuration.nix for the
  # correct value if you're migrating an existing system.
  # Do NOT change this after initial setup.
  # ------------------------------------------------------------
  system.stateVersion = "25.11";
}
