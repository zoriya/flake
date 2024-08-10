{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:zoriya/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "git+ssh://git@github.com/mitchellh/ghostty";
    };
    flood = {
      url = "github:zoriya/flood";
      flake = false;
    };
    astal-river = {
      url = "github:astal-sh/river";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    river-src = {
      url = "github:zoriya/river/br-v0.3.5";
      flake = false;
    };
  };

  outputs = {
    self,
    home-manager,
    neovim-nightly,
    nixpkgs,
    ghostty,
    flood,
    river-src,
    impermanence,
    nixos-hardware,
    nix-index-database,
    ...
  } @ inputs: let
    user = "zoriya";

    mkSystem = hostname: de: custom:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules =
          [
            impermanence.nixosModules.impermanence
            ./modules/cli
            (./environments + "/${de}")
            {
              nixpkgs.overlays = [
                (import ./overlays {inherit flood river-src;})
                neovim-nightly.overlays.default
              ];
            }

            ({pkgs, ...}: {
              networking.hostName = hostname;
              users.users.root.hashedPassword = builtins.readFile ./password/root;
              users.users.${user} = {
                hashedPassword = builtins.readFile ./password/${user};
                isNormalUser = true;
                extraGroups = ["wheel" "input" "docker" "audio" "mlocate" "libvirtd"];
                shell = pkgs.zsh;
              };
            })
            ./hosts/${hostname}/hardware-configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {inherit inputs;};
                users.${user} = {
                  imports = [
                    ./modules/cli/home.nix
                    (./environments + "/${de}/home.nix")
                    nix-index-database.hmModules.nix-index
                  ];
                };
              };
            }
          ]
          ++ custom;
      };
  in {
    nixosConfigurations = {
      fuhen = mkSystem "fuhen" "river" [
        nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7
        ({
          lib,
          pkgs,
          ...
        }: {
          hardware.keyboard.zsa.enable = true;
          environment.systemPackages = with pkgs; [
            wally-cli
            ghostty.packages.x86_64-linux.default
          ];
        })
      ];

      saikai = mkSystem "saikai" "server" [];

      kadan = mkSystem "kadan" "server" [
        ({pkgs, ...}: {
          environment.systemPackages = with pkgs; [python3Packages.guessit mediainfo yt-dlp];
        })
      ];

      lucca = mkSystem "lucca" "wsl" [];
    };
  };
}
