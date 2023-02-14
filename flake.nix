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
    nur.url = "github:nix-community/NUR";
  };

  outputs = {
    self,
    home-manager,
    hyprland,
    nur,
    ...
  } @ rawInput: let
    user = "zoriya";

    # TODO: mode this to a lib folder
    mkSystem = system: hostname: {
      nixModules,
      homeModules,
    }: let
      nixpkgs = import rawInput.nixpkgs {
        inherit system;
        overlays = [
          (import ./pkgs)
        ];
      };
      inputs = rawInput // {inherit nixpkgs;};
    in
      rawInput.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          ./modules/nixos
          nixModules
          nur.nixosModules.nur

          ({pkgs, ...}: {
            networking.hostName = hostname;
            users.users.${user} = {
              isNormalUser = true;
              extraGroups = ["wheel"];
              packages = with pkgs; [
                git
              ];
            };
          })
          ./hosts/${hostname}/hardware-configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = inputs;
              users.${user} = {
                imports = [
                  ./modules/home
                  hyprland.homeManagerModules.default
                ];
                config.modules = homeModules;
              };
            };
            nixpkgs.overlays = [
                                nur.overlay
                                ];
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
          nixconf.enable = true;
          wayland.enable = true;
        };
        homeModules = {
          hyprland.enable = true;
          eww.enable = true;
          apps.enable = true;
        };
      };
    };
  };
}
