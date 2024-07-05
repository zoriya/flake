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
  home.packages = with pkgs; [
	# TODO: Remove this
    covercolors
    alsa-utils
    sassc
    brightnessctl
    pavucontrol
    glib
  ];

  xdg.configFile."ags" = {
    source = ./.;
    recursive = true;
  };

}
