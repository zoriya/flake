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
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    nur.url = "github:nix-community/NUR";
    jq = {
      url = "github:reegnz/jq-zsh-plugin";
      flake = false;
    };
  };

  outputs = {
    self,
    home-manager,
    hyprland,
    neovim-nightly,
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
      inputs =
        rawInput
        // {
          inherit nixpkgs user;
        };
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
              extraGroups = ["wheel" "input"];
              shell = pkgs.zsh;
              packages = with pkgs; [
                git
                jq
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
              neovim-nightly.overlay
            ];
          }

          # TODO: use a module instead of this.
          hyprland.nixosModules.default
          {programs.hyprland.enable = true;}

          ({pkgs, ...}: {
            programs.zsh.enable = true;
            environment.shells = with pkgs; [zsh];
          })
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
          rofi.enable = true;
          apps.enable = true;
          zsh.enable = true;
          git.enable = true;
          nvim.enable = true;
          direnv.enable = true;
        };
      };
    };
  };
}
