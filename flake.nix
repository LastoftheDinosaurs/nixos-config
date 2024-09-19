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
          # If any other NixOS modules are needed, include them here
        ];

        specialArgs = { inherit nixpkgs catppuccin; };
      };
    };

    homeConfigurations = {
      last = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./modules/home-manager.nix
          catppuccin.homeManagerModules.catppuccin
          {
            home = {
              username = "last";
              homeDirectory = "/home/last";
              stateVersion = "24.05";  # Ensure this matches the Home Manager version
            };
          }
        ];
      };
    };
  };
}


