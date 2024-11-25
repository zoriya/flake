{lib, ...}: {
  imports = [];

  boot.initrd.availableKernelModules = ["virtio_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  boot.loader.systemd-boot.enable = lib.mkForce false;

  fileSystems."/mnt/wsl" = {
    device = "none";
    fsType = "tmpfs";
  };

  fileSystems."/usr/lib/wsl/drivers" = {
    device = "none";
    fsType = "9p";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3d4637c7-738d-4b8b-874d-1bac3a208ad5";
    fsType = "ext4";
  };

  fileSystems."/mnt/wslg" = {
    device = "none";
    fsType = "tmpfs";
  };

  fileSystems."/mnt/wslg/distro" = {
    device = "none";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/usr/lib/wsl/lib" = {
    device = "none";
    fsType = "overlay";
  };

  fileSystems."/mnt/wslg/doc" = {
    device = "none";
    fsType = "overlay";
  };

  fileSystems."/mnt/wslg/.X11-unix" = {
    device = "/mnt/wslg/.X11-unix";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/mnt/c" = {
    device = "drvfs";
    fsType = "9p";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/a892733e-b1ef-4bf6-be4c-270ce67c4c5b";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.bonding_masters.useDHCP = lib.mkDefault true;
  # networking.interfaces.eth0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "23.05";
}
