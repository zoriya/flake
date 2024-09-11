{
  pkgs,
  lib,
  ...
}: let
  gitea-mirror = pkgs.stdenv.mkDerivation rec {
    name = "gitea-mirror";
    nativeBuildInputs = with pkgs; [makeWrapper];
    propagatedBuildInputs = with pkgs; [
      curl
      jq
      coreutils
    ];
    dontUnpack = true;
    installPhase = "
      install -Dm755 ${./mirror.sh} $out/bin/gitea-mirror
      wrapProgram $out/bin/gitea-mirror --prefix PATH : '${lib.makeBinPath propagatedBuildInputs}'
    ";
  };
in {
  systemd.user.timers."gitea-mirror" = {
    Unit = {
      Description = "Mirror github repo to gitea";
    };
    Install = {
      WantedBy = ["timers.target"];
    };
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "gitea-mirror.service";
    };
  };
  systemd.user.services."gitea-mirror" = {
    Unit = {
      Description = "Mirror github repo to gitea";
      After = ["network.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = toString (pkgs.writeShellScript "gitea-sync" ''
        set -eou pipefail
        export GITEA_URL="https://git.sdg.moe"
        export ACCESS_TOKEN=$(< ~/stuff/gitea-access-token)
        export GITHUB_TOKEN=$(${pkgs.gh}/bin/gh auth token)
        exec ${gitea-mirror}/bin/gitea-mirror -m user -u zoriya
      '');
    };
  };
}
