{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nix/nix.nix
  ];
  nix.package = pkgs.nix;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    git
    man-pages
    man-pages-posix
    vim
    tmux
    jq
    telepresence2
  ];

  programs.zsh.enable = true;
  programs.nix-index-database.comma.enable = true;
  environment.shells = with pkgs; [zsh];

  documentation = {
    enable = true;
    man = {
      enable = true;
    };
    info.enable = true;
  };

  # /usr/bin/{git,make,clang,python3,...} are xcrun shims that prompt to install the CLT when no developer dir is set.
  # Point xcode-select to a fake developer dir whose xcrun just fails instead.
  system.activationScripts.postActivation.text = let
    devDir = pkgs.runCommand "fake-developer-dir" {} ''
      mkdir -p $out/usr/bin
      # the /usr/bin shims exec $DEVELOPER_DIR/usr/bin/xcrun <tool> <args...>
      cat > $out/usr/bin/xcrun <<'EOF'
      #!/bin/sh
      echo "xcrun: $1: command line tools are not installed" >&2
      exit 72
      EOF
      chmod +x $out/usr/bin/xcrun
    '';
  in ''
    /usr/bin/xcode-select --switch ${devDir}
  '';

  launchd.user.agents.caffeinate = {
    command = "/usr/bin/caffeinate -diu";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/caffeinate.log";
      StandardErrorPath = "/tmp/caffeinate.err";
    };
  };

  # launchd.user.agents.ssh-tunnel = let
  #   ssh-tunnel = pkgs.writeShellScriptBin "ssh-tunnel" ''
  #     while true; do
  #       dns-sd -m -Q fuhen.local > /dev/null 2> /dev/null
  #       echo "Host found, starting tunnel" | tee /dev/stderr
  #       ssh -NR "2222:localhost:22" zoriya@fuhen.local
  #       echo "Connetion closed" | tee /dev/stderr
  #       sleep 5
  #     done
  #   '';
  # in {
  #   command = lib.getExe ssh-tunnel;
  #   serviceConfig = {
  #     KeepAlive = true;
  #     RunAtLoad = true;
  #     StandardOutPath = "/tmp/ssh-tunnel.log";
  #     StandardErrorPath = "/tmp/ssh-tunnel.err";
  #   };
  # };
}
