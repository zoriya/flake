{
  pkgs,
  neovim-nightly,
  lz-nvim,
  vim-lumen,
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
          (mkPlugin lz-nvim "lz-n")
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
          (mkPlugin vim-lumen "vim-lumen")
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
