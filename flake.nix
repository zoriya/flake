{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:zoriya/nixpkgs/nixos-unstable"; #"github:zoriya/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.22.0beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    nur.url = "github:nix-community/NUR";
    nix-colors.url = "github:misterio77/nix-colors";
    jq = {
      url = "github:reegnz/jq-zsh-plugin";
      flake = false;
    };
    tuxedo-nixos = {
      url = "github:blitz/tuxedo-nixos";
    };
  };

  outputs = {
    self,
    home-manager,
    hyprland,
    neovim-nightly,
    nur,
    tuxedo-nixos,
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
              extraGroups = ["wheel" "input" "docker"];
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
            virtualisation.docker.enable = true;
            environment.systemPackages = with pkgs; [docker-compose];
          })

          tuxedo-nixos.nixosModules.default
          ({lib, ...}: {
            hardware.tuxedo-keyboard.enable = true;
            hardware.tuxedo-control-center.enable = true;
            # hardware.tuxedo-control-center.package = tuxedo-nixos.packages.x86_64-linux.default;
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
          games.enable = true;
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
          fcitx5.enable = true;
        };
      };
    };
  };
}
