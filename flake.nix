{
  description = "Rex's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xr3x/zen-browser-flake";
    
    claude-code.url = "github:0xr3x/claude-code-nix";
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, claude-code, ... }@inputs: {
    nixosConfigurations.rex-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix

        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.rex = import ./home.nix;
        }

        # Global config
        {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [ 
            claude-code.overlays.default
          ];
        }
      ];
    };
  };
}
