{
  description = "NixOS and Home Manager Configuration";

  # Input Sources
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # System and User Configurations
  outputs = { self, nixpkgs, catppuccin, home-manager }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./configuration.nix
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          ./modules/home-manager.nix

          # Include the hardened profile for added security.
          ({ config, pkgs, ... }: import "${nixpkgs}/nixos/modules/profiles/hardened.nix" {
            inherit config pkgs;
            lib = nixpkgs.lib;
          })
        ];

        specialArgs = { inherit nixpkgs catppuccin; };
      };
    };

    homeConfigurations = {
      last = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        homeDirectory = "/home/last";
        username = "last";

        configuration = {
          imports = [
            ./modules/home-manager.nix
            catppuccin.homeManagerModules.catppuccin
          ];
        };
      };
    };
  };
}
