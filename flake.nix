{
  description = "NixOS and Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
  };

  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };

    homeManagerConfigurations.last = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs;
      homeDirectory = "/home/last";
      username = "last";
      configuration = import ./modules/home-manager.nix;
    };
  };
}

