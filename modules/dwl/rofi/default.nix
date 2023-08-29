{
  pkgs,
  config,
  lib,
  ...
}: {
  xdg.configFile."rofi/base16.rasi".text = with {
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
    }; ''
  * {
      base00: #${base00};
      base01: #${base01};
      base02: #${base02};
      base03: #${base03};
      base04: #${base04};
      base05: #${base05};
      base06: #${base06};
      base07: #${base07};
      base08: #${base08};
      base09: #${base09};
      base0A: #${base0A};
      base0B: #${base0B};
      base0C: #${base0C};
      base0D: #${base0D};
      base0E: #${base0E};
      base0F: #${base0F};
  }

  /* vim:ft=css
  '';
  home.packages = with pkgs; [rofi-wayland];
  xdg.configFile."rofi" = {
    source = ./.;
    recursive = true;
  };
}
