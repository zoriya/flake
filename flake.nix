{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    # neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    # nur.url = "github:nix-community/NUR";
    tuxedo-nixos = {
      url = "github:blitz/tuxedo-nixos";
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
    # nur,
    ags,
    nixpkgs,
    tuxedo-nixos,
    dwl-source,
    ...
  } @ rawInput: let
    user = "zoriya";

    mkSystem = system: hostname: de: custom: let
      inputs = rawInput // {inherit user;};
    in
      nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules =
          [
            ./modules/misc
            (./modules + "/${de}")
            # nur.nixosModules.nur
            {
              nixpkgs.overlays = [
                (import ./overlays {inherit dwl-source;})
                # nur.overlay
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
                    ./modules/misc/home.nix
                    (./modules + "/${de}/home.nix")
                  ];
                };
              };
            }
          ]
          ++ custom;
      };
  in {
    nixosConfigurations = {
      fuhen = mkSystem "x86_64-linux" "fuhen" "dwl" [
        tuxedo-nixos.nixosModules.default
        ({lib, ...}: {
          hardware.tuxedo-keyboard.enable = true;
          hardware.tuxedo-control-center.enable = true;
        })
      ];
    };
  };
}
