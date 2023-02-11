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
  }: let
    user = "zoriya";

    lib = nixpkgs.lib;

    mkSystem = pkgs: system: hostname: modules:
      lib.nixosSystem {
        inherit system;
        modules = [
          {networking.hostName = hostname;}
          ./nixos/configuration.nix

          hyprland.nixosModules.default
{ programs.hyprland.enable = true; }

       #   home-manager.nixosModules.home-manager
       #   {
       #     home-manager = {
       #       useGlobalPkgs = true;
       #       useUserPackages = true;
       #       extraSpecialArgs = {inherit user;};
       #       users.${user} = {config, ...}: {
       #         imports = [
       #           ./modules/default.nix
       #           hyprland.homeManagerModules.default
       #         ];
       #         config.modules = modules;
       #       };
       #     };
       #   }
        ];
      };
  in {
    nixosConfigurations = {
      fuhen = mkSystem nixpkgs "x86_64-linux" "fuhen" {
        hyprland.enable = true;
      };
    };
  };
}
