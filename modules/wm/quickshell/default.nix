{
  programs.quickshell = {
    enable = true;
    systemd.enable = true;
    configs = {
      default = ./.;
    };
    activeConfig = "default";
  };
}
