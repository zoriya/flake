{
  nix-colors,
  lib,
  pkgs,
  ...
}: let
  theme-switcher = pkgs.writeShellScriptBin "settheme" (builtins.readFile ./settheme.sh);
in rec {
  imports = [nix-colors.homeManagerModule];

  home.packages = with pkgs; [
    (google-chrome.override {
      commandLineArgs = ["--force-dark-mode" "--enable-features=WebUIDarkMode"];
    })
    home-manager
    theme-switcher
  ];

  colorScheme = lib.mkDefault specialization.dark.configuration.colorScheme;
  home.file.".local/state/theme".text = lib.mkDefault "dark";
  darkColors = specialization.dark.configuration.colorScheme.colors;
  specialization = {
    dark.configuration = {
      home.file.".local/state/theme".text = "dark";

      colorScheme = {
        slug = "catppuccin-mocha";
        name = "Catppuccin Mocha";
        author = "https://github.com/catppuccin/catppuccin";
        colors = {
          base00 = "1e1e2e"; # base
          base01 = "181825"; # mantle
          base02 = "313244"; # surface0
          base03 = "45475a"; # surface1
          base04 = "585b70"; # surface2
          base05 = "cdd6f4"; # text
          base06 = "f5e0dc"; # rosewater
          base07 = "b4befe"; # lavender
          base08 = "f38ba8"; # red
          base09 = "fab387"; # peach
          base0A = "f9e2af"; # yellow
          base0B = "a6e3a1"; # green
          base0C = "94e2d5"; # teal
          base0D = "89b4fa"; # blue
          base0E = "cba6f7"; # mauve
          base0F = "f2cdcd"; # flamingo
        };
      };
    };

    light.configuration = {
      home.file.".local/state/theme".text = "light";

      colorScheme = {
        slug = "catppuccin-latte";
        name = "Catppuccin Latte";
        author = "https://github.com/catppuccin/catppuccin";
        colors = {
          base00 = "eff1f5"; # base
          base01 = "e6e9ef"; # mantle
          base02 = "ccd0da"; # surface0
          base03 = "bcc0cc"; # surface1
          base04 = "acb0be"; # surface2
          base05 = "4c4f69"; # text
          base06 = "dc8a78"; # rosewater
          base07 = "7287fd"; # lavender
          base08 = "d20f39"; # red
          base09 = "fe640b"; # peach
          base0A = "df8e1d"; # yellow
          base0B = "40a02b"; # green
          base0C = "179299"; # teal
          base0D = "1e66f5"; # blue
          base0E = "8839ef"; # mauve
          base0F = "dd7878"; # flamingo
        };
      };

      # programs.kitty.settings = {
      #   background_opacity = "0.7";
      # };
    };
  };
}
