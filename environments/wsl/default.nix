{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ];

  wsl.enable = true;
  wsl.defaultUser = "zoriya";
  environment.systemPackages = with pkgs; [
    wslu
    wsl-open

    # jetbrains.rider Waiting for https://github.com/NixOS/nixpkgs/pull/284857
    jetbrains.jdk 
  ];

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

  # Disable it for wls
  environment.persistence."/nix/persist".enable = false;
}
