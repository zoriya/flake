{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
    dwl-source = {
      # Use dwl's master.
      url = "github:djpohly/dwl?ref=755fcae2afbed51f38c167bdc56a5437cda8137a";
      flake = false;
    };
    flood = {
      url = "github:zoriya/flood";
      flake = false;
    };
  };

  outputs = {
    self,
    home-manager,
    neovim-nightly,
    nixpkgs,
    ghostty,
    dwl-source,
    flood,
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
            (./modules + "/${de}")
            {
              nixpkgs.overlays = [
                (import ./overlays {inherit dwl-source flood;})
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
                users.${user} = {
                  imports = [
                    ./modules/cli/home.nix
                    (./modules + "/${de}/home.nix")
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

          programs.gamescope.enable = true;
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
