{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.kernelModules = ["kvm-intel" "coretemp" "nct6775"];
  boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
  boot.blacklistedKernelModules = ["nouveau"];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["size=2G" "mode=755"];
  };

  fileSystems."/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = ["size=4G" "mode=755"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/kadan";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  fileSystems."/mnt/a" = {
    device = "/dev/disk/by-label/sda";
    fsType = "ext4";
  };
  fileSystems."/mnt/c" = {
    device = "/dev/disk/by-label/sdc";
    fsType = "ext4";
  };
  fileSystems."/mnt/d" = {
    device = "/dev/disk/by-label/sdd";
    fsType = "ext4";
  };
  fileSystems."/mnt/parity" = {
    device = "/dev/disk/by-label/parity";
    fsType = "ext4";
  };

  environment.systemPackages = with pkgs; [mergerfs];
  fileSystems."/mnt/kyoo" = {
    device = "/mnt/a:/mnt/c:/mnt/d";
    depends = ["/mnt/a" "/mnt/c" "/mnt/d"];
    fsType = "fuse.mergerfs";
    options = [
      "func.getattr=newest" # For kyoo's scanner
      "cache.files=partial" # To enable mmap (used by rtorrent)
      "dropcacheonclose=true"
      "category.create=mfs"
    ];
  };

  services.snapraid = {
    enable = true;
    exclude = [
      "*.unrecoverable"
      "/tmp/"
      "/lost+found/"
    ];
    dataDisks = {
      a = "/mnt/a/";
      c = "/mnt/c/";
      d = "/mnt/d/";
    };
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/a/snapraid.content"
      "/mnt/c/snapraid.content"
      "/mnt/d/snapraid.content"
    ];
    parityFiles = [
      "/mnt/parity/snapraid.parity"
    ];
  };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  #networking.interfaces.eno1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [vaapiVdpau];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  virtualisation.docker.enableNvidia = true;

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Do not disable this unless your GPU is unsupported or if you have a good reason to.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  system.stateVersion = "23.05";
}
