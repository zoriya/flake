{
  pkgs,
  neovim-nightly,
  lz-nvim,
  ...
}: let
  mkNvim = pkgs.callPackage ./nix/mknvim.nix {inherit pkgs;};

  mkPlugin = src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };
in
  mkNvim {
    name = "nvim";

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
        nvim-treesitter-textobjects
        vim-illuminate
        nvim-lspconfig
        oil-nvim
        nvim-surround
        telescope-fzf-native-nvim
        vim-sleuth
        auto-save-nvim

        gitsigns-nvim
        git-conflict-nvim

        mini-icons
        mini-operators
        mini-splitjoin
        vim-wordmotion
        increment-activator

        leap-nvim
        flit-nvim

        noice-nvim
        statuscol-nvim

        which-key-nvim
        nvim-colorizer-lua
        nvim-pqf
        lualine-nvim
        nvim-navic
        virt-column-nvim
        indent-blankline-nvim

        SchemaStore-nvim
        blink-cmp
        ts-comments-nvim
        undotree
        nvim-lint
        (conform-nvim.overrideAttrs {
          # clashes with oil
          postPatch = "rm doc/recipes.md";
        })
        vim-helm
      ];
      opt = [
        telescope-nvim
        harpoon2
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
