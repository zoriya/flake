{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.fcitx5;
in {
  options.modules.fcitx5 = {enable = mkEnableOption "fcitx5";};

  config = mkIf cfg.enable {
    i18n = {
      inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = with pkgs; [
          fcitx5-mozc
        ];
      };
    };

    xdg.configFile."fcitx5/config".text = ''
    [Hotkey/TriggerKeys]
    0=Super+N

    [Behavior]
    ShowInputMethodInformation=False
    CompactInputMethodInformation=False
    ShowFirstInputMethodInformation=False
    '';
    xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    Name=Default
    Default Layout=us
    DefaultIM=mozc

    [Groups/0/Items/0]
    Name=keyboard-us
    Layout=

    [Groups/0/Items/1]
    Name=mozc
    Layout=

    [GroupOrder]
    0=Default
    '';
  };
}
