{pkgs, ...}: {
  imports = [
    ./fonts.nix
    ./nix.nix
    ./impermanence.nix
  ];

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
  services.automatic-timezoned.enable = true;

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
  programs.command-not-found.enable = false;

  services.locate = {
    enable = true;
    package = pkgs.mlocate;
    interval = "hourly";
    localuser = null;
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

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # This was needed on older versions of the kernel.
  #boot.kernelParams = ["i915.force_probe=46a6" "i915.enable_psr=0"];
}
