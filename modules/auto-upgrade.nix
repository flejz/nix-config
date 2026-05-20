{ ... }:

{
  # Weekly automated system upgrade.
  # For full upgrades (cargo, npm, pip, etc.) run `topgrade` manually.
  system.autoUpgrade = {
    enable    = true;
    operation = "switch";
    flake     = "/etc/nixos";
    flags     = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
    dates     = "weekly";
  };
}
