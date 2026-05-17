# modules/nixos/apps.nix
# Defines cfg.apps.* options for optional communication apps.
{ config, lib, pkgs, ... }: {

  options.cfg.apps = {
    slack.enable    = lib.mkEnableOption "Slack desktop client";
    discord.enable  = lib.mkEnableOption "Discord";
    signal.enable   = lib.mkEnableOption "Signal messenger";
    telegram.enable = lib.mkEnableOption "Telegram Desktop";
    zoom.enable     = lib.mkEnableOption "Zoom video conferencing";
  };

  config = {
    environment.systemPackages =
      lib.optionals config.cfg.apps.slack.enable    [ pkgs.slack ]
      ++ lib.optionals config.cfg.apps.discord.enable  [ pkgs.discord ]
      ++ lib.optionals config.cfg.apps.signal.enable   [ pkgs.signal-desktop ]
      ++ lib.optionals config.cfg.apps.telegram.enable [ pkgs.telegram-desktop ]
      ++ lib.optionals config.cfg.apps.zoom.enable     [ pkgs.zoom-us ];
  };
}
