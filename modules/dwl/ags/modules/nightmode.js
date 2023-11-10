import { Icon, Label, Button, Box, Stack } from 'resource:///com/github/Aylur/ags/widget.js';

// class ThemeService extends Service {
// 	static {
// 		Service.register(this);
// 	}
//
// 	_dark = false;
//
// 	get dark() {
// 		return this._dark;
// 	}
//
// 	dark(value) {
// 		this._dark = value;
// 		execAsync(`gsettings set org.gnome.desktop.interface color-scheme prefer-${this._dark ? "dark" : "light"}`).catch(
// 			print
// 		);
// 	}
//
// 	constructor() {
// 		super();
// 		this._dark = Boolean(exec(`brightnessctl -d ${KBD} g`));
// 	}
// }
//
// class Theme {
// 	static {
// 		Service.export(this, "Theme");
// 	}
//
// 	static get dark() {
// 		return Theme.dark;
// 	}
// 	static set dark(value) {
// 		Theme.instance.dark = value;
// 	}
// }

export const Indicator = ({
	light = Icon("weather-clear-symbolic"),
	dark = Icon("weather-clear-night-symbolic"),
	...props
} = {}) =>
	Stack({
		items: [["light", light], [("dark", dark)]],
		shown: "dark",
		...props
		// connections: [
		// 	[
		// 		Theme,
		// 		(stack) => {
		// 			stack.shown = Theme.dark ? "dark" : "light";
		// 		},
		// 	],
		// ],
	});

export const NightLabel = () =>
	Label({
		label: "Todo",
		connections: [
			// [
			// 	Theme,
			// 	(label) => {
			// 		label.label = "Todo";
			// 	},
			// ],
		],
	});

export const NightToggle = ({ ...props } = {}) =>
	Button({
		className: "qs-button surface",
		hexpand: true,
		onClicked: () => {},
		child: Box({
			children: [Indicator({ className: "qs-icon" }), NightLabel()],
		}),
		// connections: [[Theme, (button) => button.toggleClassName("accent", Theme.dark)]],
		...props,
	});
