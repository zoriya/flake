{
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
      url = "github:mitchellh/ghostty";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };
    flood = {
      url = "github:zoriya/flood";
      flake = false;
    };
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    river-src = {
      url = "github:zoriya/river/0.3.x";
      flake = false;
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vim-lumen = {
      url = "github:vimpostor/vim-lumen";
      flake = false;
    };
    ltex-extra = {
      url = "github:barreiroleo/ltex_extra.nvim/dev";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    neovim-nightly,
    nixos-hardware,
    ...
  } @ inputs: let
    overlays = {
      nixpkgs.overlays = [
        (import ./overlays inputs)
        nvim-overlay
      ];
    };

    mkSystem = import ./lib/mksystem.nix (inputs // {inherit overlays inputs;});
    eachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;

    nvim-overlay = final: prev:
      import ./nvim (inputs
        // {
          pkgs = prev.pkgs;
          lib = nixpkgs.lib;
        });
  in {
    nixosConfigurations.fuhen = mkSystem "fuhen" {
      env = "river";
      custom = [
        nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7
      ];
    };

    nixosConfigurations.saikai = mkSystem "saikai" {
      env = "server";
    };

    nixosConfigurations.kadan = mkSystem "kadan" {
      env = "server";
      custom = [
        ({pkgs, ...}: {
          environment.systemPackages = with pkgs; [
            python3Packages.guessit
            mediainfo
            yt-dlp
            mkvtoolnix-cli
          ];
        })
      ];
    };

    nixosConfigurations.lucca = mkSystem "lucca" {
      env = "wsl";
      wsl = true;
    };

    darwinConfigurations."zroux-mac" = mkSystem "zroux-mac" {
      env = "none";
      user = "zroux";
      system = "aarch64-darwin";
      darwin = true;
      customHome = [
        ./modules/gui/ghostty.nix
        ({pkgs, ...}: let
          dotnet = with pkgs.dotnetCorePackages;
            combinePackages [
              sdk_9_0
              sdk_8_0
              aspnetcore_9_0
              aspnetcore_8_0
            ];
        in {
          home.packages = with pkgs; [
            nodejs
            dotnet
            csharpier
            kubernetes-helm
            colima
            kubectl
            kustomize
            docker
            pgformatter
            sqlcmd
          ];
          home.sessionVariables = {
            DOTNET_ROOT = "${dotnet}/share/dotnet";
            DOTNET_HOST_ROOT = "${dotnet}/share/dotnet";
          };
        })
      ];
    };

    packages = eachSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [nvim-overlay];
      };
    in rec {
      default = nvim;
      nvim = pkgs.nvim;
    });

    devShells = eachSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [nvim-overlay];
      };
    in rec {
      default = nvim-lua;
      nvim-lua = pkgs.mkShell {
        name = "nvim-lua";
        shellHook = ''
          ln -fs ${pkgs.nvim-luarc} .luarc.json
        '';
      };
    });

    overlays = rec {
      default = nvim;
      nvim = nvim-overlay;
    };
  };
}
