{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    # neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    nur.url = "github:nix-community/NUR";
    nix-colors.url = "github:misterio77/nix-colors";
    jq = {
      url = "github:reegnz/jq-zsh-plugin";
      flake = false;
    };
    tuxedo-nixos = {
      url = "path:/home/zoriya/projects/tuxedo-nixos"; #"github:blitz/tuxedo-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dwl-source = {
      # Use dwl's master.
      url = "github:djpohly/dwl";
      flake = false;
    };
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    home-manager,
    # neovim-nightly,
    nur,
    ags,
    nixpkgs,
    tuxedo-nixos,
    dwl-source,
    ...
  } @ rawInput: let
    user = "zoriya";

    mkSystem = system: hostname: {
      nixModules,
      homeModules,
    }: let
      inputs = rawInput // {inherit user;};
    in
      nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          ./modules/nixos
          # ./modules/gnome
          ./modules/dwl
          nixModules
          nur.nixosModules.nur
          {
            nixpkgs.overlays = [
              (import ./overlays { inherit dwl-source; })
              nur.overlay
              # neovim-nightly.overlay
            ];
          }

          ({pkgs, ...}: {
            networking.hostName = hostname;
            users.users.root.hashedPassword = builtins.readFile ./password/root;
            users.users.${user} = {
              hashedPassword = builtins.readFile ./password/${user};
              isNormalUser = true;
              extraGroups = ["wheel" "input" "docker" "audio" "mlocate"];
              shell = pkgs.zsh;
              packages = with pkgs; [
                git
                docker-compose
                jq
                ags.packages.x86_64-linux.default
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
                  # ./modules/gnome/home.nix
                  ./modules/dwl/home.nix
                ];
                config.modules = homeModules;
              };
            };
          }

          ({pkgs, ...}: {
            programs.zsh.enable = true;
            environment.shells = with pkgs; [zsh];

            services.locate = {
              enable = true;
              locate = pkgs.mlocate;
              interval = "hourly";
              localuser = null;
            };

            virtualisation.docker.enable = true;
            environment.systemPackages = with pkgs; [
              docker-compose
              git
              man-pages
              man-pages-posix
            ];
            documentation.dev.enable = true;
          })

          tuxedo-nixos.nixosModules.default
          ({lib, ...}: {
            hardware.tuxedo-keyboard.enable = true;
            hardware.tuxedo-control-center.enable = true;
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
          apps.enable = true;
          zsh.enable = true;
          git.enable = true;
          nvim.enable = true;
          direnv.enable = true;
          ntfy.enable = true;
        };
      };
    };
  };
}
