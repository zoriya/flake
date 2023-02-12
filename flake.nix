{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    ...
  } @ inputs: let
    user = "zoriya";

    # TODO: mode this to a lib folder
    mkSystem = system: hostname: {
      nixModules,
      homeModules,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          ({pkgs, ...}: {
            networking.hostName = hostname;
            nixpkgs.config.allowUnfree = true;
            users.users.${user} = {
              isNormalUser = true;
              extraGroups = ["wheel"];
              packages = with pkgs; [
                firefox
                git
                google-chrome
              ];
            };
          })
          {
            imports = [./modules/nixos];
            config = nixModules;
          }
          ./hosts/${hostname}/hardware-configuration.nix

          home-manager.nixosModules.home-manager
          #{programs.home-manager.enable = true;}
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit user;};
              users.${user} = {
                imports = [
                  ./modules/home
                  hyprland.homeManagerModules.default
                ];
                config.modules = homeModules;
              };
            };
          }

          # TODO: use a module instead of this.
          hyprland.nixosModules.default
          {programs.hyprland.enable = true;}
        ];
      };
  in {
    nixosConfigurations = {
      fuhen = mkSystem "x86_64-linux" "fuhen" {
        nixModules = {
          fonts.enable = true;
          nix.enable = true;
          #wayland.enable = true;
        };
        homeModules = {
          hyprland.enable = true;
        };
      };
    };
  };
}
