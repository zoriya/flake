# Common file for both nixos and nix-darwin
{pkgs, ...}: {
  imports = [
    ./nix.nix
  ];
  nix.package = pkgs.nix;
  services.nix-daemon.enable = true;

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
  environment.shells = with pkgs; [zsh];

  documentation = {
    enable = true;
    man = {
      enable = true;
    };
    info.enable = true;
  };
}
