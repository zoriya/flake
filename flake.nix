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
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nur.url = "github:nix-community/NUR";
    dwl-source = {
      # Use dwl's master.
      url = "github:djpohly/dwl?ref=755fcae2afbed51f38c167bdc56a5437cda8137a";
      flake = false;
    };
    ags = {
      url = "github:zoriya/ags";
      inputs.nixpkgs.follows = "nixpkgs";
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
    # nur,
    ags,
    nixpkgs,
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
            ./modules/misc
            (./modules + "/${de}")
            # nur.nixosModules.nur
            {
              nixpkgs.overlays = [
                (import ./overlays {inherit dwl-source flood;})
                # nur.overlay
                neovim-nightly.overlay
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
                    ./modules/misc/home.nix
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
      fuhen = mkSystem "fuhen" "dwl" [
        nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7
        ({
          lib,
          pkgs,
          ...
        }: {

          # hardware.tuxedo-rs = {
          #   enable = true;
          #   tailor-gui.enable = true;
          # };

          hardware.keyboard.zsa.enable = true;
          environment.systemPackages = with pkgs; [wally-cli];

          programs.gamescope.enable = true;
        })
      ];

      saikai = mkSystem "saikai" "server" [];

      kadan = mkSystem "kadan" "server" [
        ({pkgs, ...}: {
          environment.systemPackages = with pkgs; [tmux python3Packages.guessit mediainfo yt-dlp];
        })
      ];
    };
  };
}
