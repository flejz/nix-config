{
  description = "flejz NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprswitch = {
      url = "github:H3rmt/hyprswitch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ai-tools = {
      url = "github:numtide/nix-ai-tools";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;

      machineNames = builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./machines)
      );

      buildMachine = name: lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Overlays — makes nix-ai-tools and wezterm-flake available as pkgs.*
          {
            nixpkgs.overlays = [
              inputs.rust-overlay.overlays.default
              (final: prev: {
                nix-ai-tools   = inputs.nix-ai-tools.packages.${final.stdenv.hostPlatform.system};
                wezterm-flake  = inputs.wezterm.packages.${final.stdenv.hostPlatform.system}.default;
              })
            ];
          }

          ./system.nix
          ./machines/${name}/config-override.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs        = true;
            home-manager.useUserPackages      = true;
            home-manager.backupFileExtension  = "bak";
            home-manager.extraSpecialArgs     = { inherit inputs; };
            home-manager.users.flejz          = import ./home/flejz/home.nix;
          }
        ];
      };
    in
    {
      nixosConfigurations = lib.genAttrs machineNames buildMachine;
    };
}
