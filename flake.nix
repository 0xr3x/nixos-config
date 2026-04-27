{
  description = "Rex's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xr3x/zen-browser-flake";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, zen-browser, ... }@inputs:
  let
    pkgs-stable = import nixpkgs-stable {
      system = "x86_64-linux";
      config.allowUnfree = true;
      config.permittedInsecurePackages = [
        "python3.12-ecdsa-0.19.1"
      ];
    };
  in {
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs pkgs-stable; };

      modules = [
        ./configuration.nix

        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs pkgs-stable; };
          home-manager.users.rex = import ./home.nix;
        }

        # Global config
        {
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
  };
}
