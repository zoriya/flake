{pkgs, lib, ...}: {
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

  launchd.user.agents.caffeinate = {
    command = "${pkgs.darwin.PowerManagement}/bin/caffeinate -diu";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/caffeinate.log";
      StandardErrorPath = "/tmp/caffeinate.err";
    };
  };

  launchd.user.agents.ssh-tunnel = let 
    ssh-tunnel = pkgs.writeShellScriptBin "ssh-tunnel" ''
      while true; do
        dns-sd -m -Q fuhen.local
        echo "Host found, starting tunnel" | tee /dev/stderr
        ssh -NR "2222:localhost:22" zoriya@fuhen.local
        echo "Connetion closed" | tee /dev/stderr
        sleep 5
      done
    '';
  in {
    command = lib.getExe ssh-tunnel;
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/ssh-tunnel.log";
      StandardErrorPath = "/tmp/ssh-tunnel.err";
    };
  };
}
