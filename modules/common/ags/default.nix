{
  pkgs,
  lib,
  ...
}: let
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
  # ags = pkgs.stdenv.mkDerivation rec {
  #   name = "ags";
  #   nativeBuildInputs = with pkgs; [makeWrapper];
  #   propagatedBuildInputs = [
  #     covercolors
  #   ];
  #   dontUnpack = true;
  #   installPhase = "
  #      wrapProgram ${pkgs.ags}/bin/ags --prefix PATH : '${lib.makeBinPath propagatedBuildInputs}'
  #    ";
  # };
  ags = pkgs.ags.overrideAttrs (oldAttrs: {
    runtimeDependencies = [covercolors];
  });
  systemdTarget = "graphical-session.target";
in {
  # TODO: Remove this after testing
  home.packages = [ags];
  systemd.user.services.ags = {
    Unit = {
      Description = " A customizable and extensible shell ";
      PartOf = systemdTarget;
      Requires = systemdTarget;
      After = systemdTarget;
    };

    Service = {
      Type = "simple";
      ExecStart = "${ags}/bin/ags";
      Restart = "always";
    };

    Install = {WantedBy = [systemdTarget];};
  };

  xdg.configFile."ags" = {
    source = ./.;
    recursive = true;
  };
}
