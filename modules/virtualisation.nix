{ pkgs, ... }:

{
  # Podman replaces Docker.
  virtualisation.docker.enable = false;
  virtualisation.podman = {
    enable         = true;
    dockerCompat   = true;  # `docker` command works as podman alias
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  users.extraGroups.podman.members = [ "flejz" ];

  environment.systemPackages = with pkgs; [
    podman-compose
    podman-tui
    lazydocker
    distrobox
    nerdctl
  ];
}
