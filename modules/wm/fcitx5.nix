{pkgs, ...}: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };
  systemd.user.services.fcitx5-daemon = {
    Unit = {
      After = ["graphical-session.target"];
    };
  };

  xdg.configFile."fcitx5/config" = {
    force = true;
    text = ''
      [Hotkey/TriggerKeys]
      0=Super+space

      [Behavior]
      ShowInputMethodInformation=False
      CompactInputMethodInformation=False
      ShowFirstInputMethodInformation=False
    '';
  };
  xdg.configFile."fcitx5/profile" = {
    force = true;
    text = ''
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
