import GLib from 'gi://GLib';

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

	set dark(value) {
		this._dark = value;
		execAsync(`gsettings set org.gnome.desktop.interface color-scheme prefer-${this._dark ? "dark" : "light"}`).catch(
			print
		);
		execAsync(`gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3${this._dark ? "-dark" : ""}`).catch(
			print
		);
		const conf = GLib.get_user_config_dir();
		execAsync(`ln -sf ${conf}/kitty/${this._dark ? "dark" : "light"}.conf ${conf}/kitty/theme.conf`).catch(
			print
		);
		execAsync("pkill -USR1 kitty").catch(print);
		this.emit("changed");
	}

	toggle() {
		this.dark = !this.dark;
	}

	constructor() {
		super();
		this._dark = exec(`gsettings get org.gnome.desktop.interface color-scheme`) === "'prefer-dark'";
		// Ensure that the gtk theme is in sync with the theme.
		this._dark = this._dark;
	}
}

const Theme = new ThemeService();

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
		onClicked: () => Theme.toggle(),
		child: Box({
			children: [Indicator({ className: "qs-icon" }), ThemeLabel()],
		}),
		connections: [[Theme, (button) => button.toggleClassName("accent", Theme.dark)]],
		...props,
	});
