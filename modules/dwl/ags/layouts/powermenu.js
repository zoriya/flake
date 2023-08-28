import { PopupOverlay } from "../misc.js";

const { Box, Button, Icon, Label, Window } = ags.Widget;

const cmd = {
	Sleep: "systemctl suspend",
	Reboot: "systemctl reboot",
	"Log Out": "pkill dwl",
	Shutdown: "shutdown now",
};

const SysButton = (icon, action) =>
	Button({
		onClicked: cmd[action],
		child: Box({
			vertical: true,
			children: [Icon(icon), Label(action)],
		}),
	});

export const Powermenu = () =>
	Window({
		name: "powermenu",
		monitor: undefined,
		popup: true,
		focusable: true,
		anchor: ["top", "right", "bottom", "left"],
		child: PopupOverlay(
			"powermenu",
			"center",
			Box({
				homogeneous: true,
				className: "powermenu transparent",
				children: [
					SysButton("system-shutdown-symbolic", "Shutdown"),
					SysButton("system-reboot-symbolic", "Reboot"),
					SysButton("system-log-out-symbolic", "Log Out"),
					SysButton("weather-clear-night-symbolic", "Sleep"),
				],
			})
		),
	});
