const { Service } = ags;
const { exec, execAsync } = ags.Utils;
const { Icon, Label, Button, Box, Stack } = ags.Widget;

class ThemeService extends Service {
	static {
		Service.register(this);
	}

	_dark = false;

	get dark() {
		return this._dark;
	}

	dark(value) {
		this._dark = value;
		execAsync(`gsettings set org.gnome.desktop.interface color-scheme prefer-${this._dark ? "dark" : "light"}`).catch(
			print
		);
		this.emit("changed");
	}

	constructor() {
		super();
		this._dark = Boolean(exec(`gsettings get org.gnome.desktop.interface color-scheme`));
	}
}

class Theme {
	static {
		Service.export(this, "Theme");
	}
	static instance = new ThemeService();

	static get dark() {
		return Theme.instance.dark;
	}
	static set dark(value) {
		Theme.instance.dark = value;
	}
}

export const Indicator = ({ ...props } = {}) =>
	Stack({
		items: [
			["light", Icon("weather-clear-symbolic")],
			["dark", Icon("weather-clear-night-symbolic")],
		],
		...props,
		connections: [
			[
				Theme,
				(stack) => {
					stack.shown = Theme.dark ? "dark" : "light";
				},
			],
		],
	});

export const ThemeLabel = () =>
	Label({
		connections: [
			[
				Theme,
				(label) => {
					label.label = Theme.dark ? "Dark Theme" : "Light Theme";
				},
			],
		],
	});

export const DarkToggle = ({ ...props } = {}) =>
	Button({
		className: "qs-button surface",
		hexpand: true,
		onClicked: () => {},
		child: Box({
			children: [Indicator({ className: "qs-icon" }), ThemeLabel()],
		}),
		connections: [[Theme, (button) => button.toggleClassName("accent", Theme.dark)]],
		...props,
	});
