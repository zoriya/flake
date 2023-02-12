{
  imports = [
    ./fonts
    ./nix
    ./wayland
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Tokyo";

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  boot.kernelParams = ["i915.force_probe=46a6"];

  # Never change this.
  system.stateVersion = "22.11";
}
