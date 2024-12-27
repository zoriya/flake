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
        # TODO: use catppuccin's compile feature. see: https://github.com/stasjok/dotfiles/blob/36037f523185ba1409dd953999fda0f0db0dbd4f/nvim/default.nix#L136C8-L148C12
        catppuccin-nvim
        nvim-treesitter.withAllGrammars
        nvim-lspconfig
        oil-nvim
        mini-nvim
        nvim-surround
        telescope-fzf-native-nvim
        vim-sleuth
        auto-save-nvim

        SchemaStore-nvim
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
