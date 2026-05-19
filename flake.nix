{
  description = "flejz NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;

      # Auto-discover all machine directories under ./machines/
      machineNames = builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./machines)
      );

      buildMachine = name: lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # 1. Base system config + option definitions (applies to all machines)
          ./system.nix

          # 2. Machine-specific overrides (hostname, hardware, etc.)
          ./machines/${name}/config-override.nix

          # 3. Home Manager as NixOS module (single nixos-rebuild switch)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs        = true;
            home-manager.useUserPackages      = true;
            home-manager.backupFileExtension  = "bak";
            home-manager.users.flejz          = import ./home/flejz/home.nix;
          }
        ];
      };
    in
    {
      # Build all discovered machines.
      # Usage: sudo nixos-rebuild switch --flake .#<hostname>
      nixosConfigurations = lib.genAttrs machineNames buildMachine;
    };
}
