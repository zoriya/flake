{pkgs, ...}: let
  covercolors = pkgs.stdenv.mkDerivation {
    name = "covercolors";
    dontUnpack = true;
    propagatedBuildInputs = [
      (pkgs.python3.withPackages (pyPkgs:
        with pyPkgs; [
          material-color-utilities
          pillow
        ]))
    ];
    installPhase = "install -Dm755 ${./covercolors.py} $out/bin/covercolors";
  };
in {
  xdg.configFile."ags" = {
    source = ./ags;
    recursive = true;
  };
  home.packages = with pkgs; [
    ags
    # TOOD: Remove this
    covercolors
  ];
}
