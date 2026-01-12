{
  pkgs,
  lib,
  neovim-nightly,
  ...
}: let
  mkNvim = import ./nix/mknvim.nix {inherit pkgs lib;};
  # mkPlugin = src: pname:
  #   (pkgs.vimUtils.buildVimPlugin
  #     {
  #       inherit pname src;
  #       version = src.lastModifiedDate;
  #     })
  #   .overrideAttrs {doCheck = false;};
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

          nvim-treesitter.withAllGrammars
          nvim-treesitter-textobjects
          vim-illuminate
          nvim-lspconfig
          (blink-cmp.overrideAttrs {
            # clashes with oil
            postPatch = "rm -rf doc/";
          })
          SchemaStore-nvim
          roslyn-nvim
          (conform-nvim.overrideAttrs {
            # clashes with oil
            postPatch = "rm doc/recipes.md";
          })

          oil-nvim
          harpoon2

          gitsigns-nvim
          jj-nvim
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

          (snacks-nvim.overrideAttrs {
            postPatch = "rm -rf queries";
          })
          quicker-nvim

          sniprun

          vim-helm
          vim-sleuth
          auto-save-nvim

          noice-nvim
          statuscol-nvim
          mini-icons
          which-key-nvim
          lualine-nvim
          nvim-navic
          virt-column-nvim

          codecompanion-nvim
          # enable this just to signin (used by the chat plugin above)
          # (copilot-vim.overrideAttrs {
          #   postPatch = "rm doc/copilot.txt";
          # })
        ];
        opt = [ ];
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
      basedpyright
      typescript-language-server
      nil
      vscode-langservers-extracted # html, jsonls
      marksman
      texlab
      helm-ls
      zls
      lua-language-server
      bash-language-server
      sqls
      biome
      tailwindcss-language-server
      kdePackages.qtdeclarative # qmlls

      # gopls also needs go /shame
      gopls
      go
      # yaml-ls needs node /shame
      yaml-language-server
      nodejs
      # haskell-language-server needs ghc /shame
      ghc

      # formatter
      alejandra
      pgformatter
      csharpier
      ruff

      # repl
      usql
      mono
    ];
  }
