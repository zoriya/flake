{
  pkgs,
  neovim-nightly,
  ...
}: let
  mkNvim = pkgs.callPackage ./mknvim.nix {inherit pkgs;};
in
  mkNvim {
    withNodeJs = false;
    withRuby = false;
    withPython3 = false;

    package = neovim-nightly.packages.${pkgs.system}.default;

    config = ./.;

    plugins = with pkgs.vimPlugins; {
      start = [
        lz-n
        catppuccin-nvim
        nvim-treesitter.withAllGrammars
        plenary-nvim
      ];
      opts = [
        telescope-nvim
        telescope-fzf-native-nvim
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
