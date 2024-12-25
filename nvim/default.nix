{
  pkgs,
  neovim-nightly,
  lz-nvim,
  ...
}: let
  mkNvim = pkgs.callPackage ./mknvim.nix {inherit pkgs;};

  mkPlugin = src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };
in
  mkNvim {
    withNodeJs = false;
    withRuby = false;
    withPython3 = false;

    package = neovim-nightly.packages.${pkgs.system}.default;

    config = ./.;

    plugins = with pkgs.vimPlugins; {
      start = [
        (mkPlugin lz-nvim "lz-n")
        catppuccin-nvim
        nvim-treesitter.withAllGrammars
        oil-nvim
        mini-nvim
        telescope-fzf-native-nvim
      ];
      opts = [
        telescope-nvim
      ];
    };

    extraPackages = with pkgs; [
      # telescope helpers
      fd
      ripgrep

      # lsp
      # see for helpers https://github.com/dundalek/lazy-lsp.nvim/blob/master/lua/lazy-lsp/servers.lua
      haskell-language-server
      rust-analyzer
      clang-tools
      omnisharp-roslyn
      pyright
      typescript-language-server
      nil
      gopls
      vscode-langservers-extracted # html, jsonls
      yaml-language-server
      marksman
      ltex-ls
      texlab
      helm-ls
      zls
      lua-language-server

      # Give access to gdbus for color-scheme detection (vim-lumen).
      glib
    ];
  }
