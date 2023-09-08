{pkgs, ...}: {
  imports = [
    ./fonts.nix
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
  networking.networkmanager.enable = true;
  services.automatic-timezoned.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.flatpak.enable = true;

  hardware.steam-hardware.enable = true;
  hardware.opengl.driSupport32Bit = true;
  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
    docker-compose
    git
    man-pages
    man-pages-posix
  ];

  programs.zsh.enable = true;
  environment.shells = with pkgs; [zsh];

  services.locate = {
    enable = true;
    locate = pkgs.mlocate;
    interval = "hourly";
    localuser = null;
  };

  virtualisation.docker.enable = true;
  documentation.dev.enable = true;

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # This was needed on older versions of the kernel.
  #boot.kernelParams = ["i915.force_probe=46a6" "i915.enable_psr=0"];

  # Never change this.
  system.stateVersion = "22.11";
}
