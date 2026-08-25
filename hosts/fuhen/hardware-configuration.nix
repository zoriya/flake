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

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];

  # powersave settings
  boot = {
    kernelParams = [
      "pcie_aspm.policy=powersave"
      # enable hardware accel (not powersave settings)
      "i915.enable_guc=2"
    ];
    extraModprobeConfig = ''
      options snd_hda_intel power_save=1
      # AX201 firmware (NMI_INTERRUPT_UMAC_FATAL) crashes at boot under the
      # 6.18.38 kernel when the PCIe link is aggressively power-managed
      # (pcie_aspm.policy=powersave above). Keep the Wi-Fi radio awake so the
      # firmware boots reliably; the rest of the bus still saves power.
      options iwlwifi power_save=0
      options iwlmvm power_scheme=1
    '';
    kernel.sysctl = {
      "kernel.nmi_watchdog" = 0;
      "vm.dirty_writeback_centisecs" = 6000;
    };
  };

  boot.initrd.luks.devices.crypt = {
    device = "/dev/disk/by-partlabel/crypt";
    allowDiscards = true;
    bypassWorkqueues = true;
    crypttabExtraOpts = ["tpm2-device=auto"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nix";
    fsType = "btrfs";
    options = ["subvol=@root" "compress=zstd" "noatime"];
  };

  fileSystems."/tmp" = {
    device = "/dev/disk/by-label/nix";
    fsType = "btrfs";
    options = ["subvol=@tmp" "nodatacow" "noatime"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix";
    fsType = "btrfs";
    options = ["subvol=@nix" "compress=zstd" "noatime"];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/nix";
    fsType = "btrfs";
    options = ["subvol=@persist" "compress=zstd" "noatime"];
    neededForBoot = true;
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-label/nix";
    fsType = "btrfs";
    options = ["subvol=@swap" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 64 * 1024;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
    ];
  };

  system.stateVersion = "22.11";
}
