{
  lib,
  config,
  pkgs,
  user,
  ...
}: {
  imports = [
    ./fonts.nix
    ./impermanence.nix
  ];

  services.printing.enable = true;
  security.rtkit.enable = true;
  security.polkit.enable = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;

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
  ];

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # This was needed on older versions of the kernel.
  #boot.kernelParams = ["i915.force_probe=46a6" "i915.enable_psr=0"];

  # Never change this.
  system.stateVersion = "22.11";
}
