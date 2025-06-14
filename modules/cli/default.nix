{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nix/nix.nix
    ./nix/impermanence.nix
  ];

  security.sudo.wheelNeedsPassword = lib.mkForce true;
  security.sudo.extraConfig = ''
    Defaults  lecture="never"
  '';

  boot.loader = {
    # Hide the boot loader and show it only on keypress.
    timeout = 0;
    systemd-boot = {
      enable = true;
      configurationLimit = 4;
      # A real mode for hidpi
      consoleMode = "max";
    };
    efi.canTouchEfiVariables = true;
  };
  # needed for geoclue, see https://github.com/NixOS/nixpkgs/issues/329522
  services.avahi.enable = true;
  services.automatic-timezoned.enable = true;

  programs.dconf.enable = true;
  services.dbus.enable = true;

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
    mosh
  ];

  programs.zsh.enable = true;
  environment.shells = with pkgs; [zsh];
  programs.nix-index-database.comma.enable = true;

  services.locate = {
    enable = true;
    package = pkgs.mlocate;
    interval = "hourly";
  };

  virtualisation.docker.enable = true;

  documentation = {
    enable = true;
    dev.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
    info.enable = true;
    nixos.enable = true;
  };
}
