{pkgs, ...}: {
  nix = {
    optimise.automatic = true;
    channel.enable = false;
    settings = {
      warn-dirty = false;
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = true;
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      # 500mb of download buffer size (default is 64mb)
      download-buffer-size = 500 * 1024 * 1024;
    };
    gc =
      {
        automatic = true;
        options = "--delete-older-than 14d";
      }
      // (
        if pkgs.stdenv.isLinux
        then {
          dates = "weekly";
        }
        else {
          interval = {
            Weekday = 0;
            Hour = 0;
            Minute = 0;
          };
        }
      );
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;
}
