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
  systemdTarget = "graphical-session.target";
  # TODO: Add this in the offcial ags derivation
  ags = pkgs.ags.overrideAttrs (_: prev: {
    buildInputs = prev.buildInputs ++ [pkgs.libdbusmenu-gtk3];
  });
in {
  home.packages = with pkgs; [
    # TODO: Remove this after testing
    ags
    # TODO: Find a way to add this for ags only
    covercolors
    brightnessctl
  ];
  systemd.user.services.ags = {
    Unit = {
      Description = " A customizable and extensible shell ";
      PartOf = systemdTarget;
      Requires = systemdTarget;
      After = systemdTarget;
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.ags}/bin/ags";
      Restart = "always";
    };

    Install = {WantedBy = [systemdTarget];};
  };

  xdg.configFile."ags" = {
    source = ./.;
    recursive = true;
  };
}
