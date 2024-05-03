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
  ];

  # Disable it for wls
  environment.persistence."/nix/persist".enable = false;
}
