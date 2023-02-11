{ lib, config, ... }:
let
	cfg = config.modules.hyprland;
in {
	options.modules.hyprland = { enable = lib.mkEnableOption "hyprland"; };
	config = lib.mkIf cfg.enable
		{
			wayland.windowManager.hyprland = {
				enable = true;
				extraConfig = builtins.readFile ./hyprland.conf;
			};
			#home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;
		}
	;
}
