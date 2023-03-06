{pkgs, ...}: {
  imports = [
    ./fonts
    ./nix
    ./wayland
    ./games
  ];

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
  time.timeZone = "Asia/Tokyo";

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # This was needed on older versions of the kernel.
  #boot.kernelParams = ["i915.force_probe=46a6" "i915.enable_psr=0"];

  # Never change this.
  system.stateVersion = "22.11";
}
