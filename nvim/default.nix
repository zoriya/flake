{
  pkgs,
  lib,
  neovim-nightly,
  vim-lumen,
  ltex-extra,
  ...
}: let
  mkNvim = import ./nix/mknvim.nix {inherit pkgs lib;};

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

    plugins = let
      catppuccin-nvim = let
        neovim = pkgs.neovim.override {
          configure.packages.catppuccin-nvim.start = [pkgs.vimPlugins.catppuccin-nvim];
        };
      in
        pkgs.runCommand "catppuccin-nvim" {} ''
          mkdir -p $out
          cp -r --no-preserve=mode,ownership ${pkgs.vimPlugins.catppuccin-nvim}/* $out
          rm -rf $out/doc $out/colors/*

          ${neovim}/bin/nvim -l ${./catppuccin.lua}
          rm $out/lua/colors/cached
          cd $out/lua/colors
          for flavor in *; do
            mv "$out/lua/colors/$flavor" "catppuccin-$flavor.lua"
            cat <<-eof > $out/colors/catppuccin-''${flavor}.lua
            if vim.g.colors_name == "catppuccin-$flavor" and vim.o.background ~= (vim.g.colors_name == "catppuccin-latte" and "light" or "dark") then
              dofile("$out/lua/colors/catppuccin-" .. (vim.o.background == "light" and "latte" or "mocha") .. ".lua")
            else
              dofile("$out/lua/colors/catppuccin-$flavor.lua")
            end
          eof
          done

          cat <<-eof > $out/colors/catppuccin.lua
          dofile("$out/lua/colors/catppuccin-" .. (vim.o.background == "light" and "latte" or "mocha") .. ".lua")
          eof
        '';
    in
      with pkgs.vimPlugins; {
        start = [
          lz-n

          catppuccin-nvim
          (mkPlugin vim-lumen "vim-lumen")

          nvim-treesitter.withAllGrammars
          ts-comments-nvim

          nvim-lspconfig
          blink-cmp
          SchemaStore-nvim
          roslyn-nvim
          ((mkPlugin ltex-extra "ltex-extra").overrideAttrs {doCheck = false;})
          nvim-lint
          (conform-nvim.overrideAttrs {
            # clashes with oil
            postPatch = "rm doc/recipes.md";
          })

          oil-nvim
          telescope-fzf-native-nvim
          harpoon2

          gitsigns-nvim
          vim-fugitive
          vim-rhubarb
          git-conflict-nvim

          nvim-surround
          mini-operators
          mini-splitjoin
          vim-wordmotion
          increment-activator
          leap-nvim
          flit-nvim

          vim-helm
          vim-sleuth
          auto-save-nvim
          undotree

          noice-nvim
          statuscol-nvim
          dressing-nvim
          mini-icons
          which-key-nvim
          nvim-colorizer-lua
          quicker-nvim
          lualine-nvim
          nvim-navic
          virt-column-nvim
          indent-blankline-nvim
          zen-mode-nvim
        ];
        opt = [
          telescope-nvim
          vim-illuminate
          nvim-treesitter-textobjects
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
      roslyn-ls
      pyright
      typescript-language-server
      nil
      vscode-langservers-extracted # html, jsonls
      yaml-language-server
      marksman
      ltex-ls
      texlab
      helm-ls
      zls
      lua-language-server
      bash-language-server

      # gopls also needs go /shame
      gopls
      go

      # formatter
      alejandra
      # might need to find a way to disable it for projects that use prettier but it's just more convenient to have it always on
      # (for json or to allow use without an outer shell)
      biome

      # Give access to gdbus for color-scheme detection (vim-lumen).
      glib
    ];
  }
