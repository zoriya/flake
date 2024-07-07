import Gio from "gi://Gio";
import GLib from "gi://GLib?version=2.0";

import { SimpleToggleButton } from "../misc/menu.js";

const theme = Variable(/** @type {"light" | "dark"} */ ("light"));

/** @param {Partial<import("../misc/menu.js").SimpleToggleButtonProps>} props */
export const Toggle = ({ ...props } = {}) =>
	SimpleToggleButton({
		icon: Widget.Icon({
			className: "qs-icon",
			icon: theme
				.bind()
				.as((x) =>
					x === "light"
						? "weather-clear-symbolic"
						: "weather-clear-night-symbolic",
				),
		}),
		label: Widget.Label({
			label: theme.bind().as((x) => (x === "light" ? "Light" : "Dark")),
		}),
		activate: () => theme.setValue("dark"),
		deactivate: () => theme.setValue("light"),
		connection: [theme, () => theme.value === "dark"],
		...props,
	});

function init() {
	const settings = new Gio.Settings({
		schema: "org.gnome.desktop.interface",
	});
	const initial = /** @type {"prefer-light" | "prefer-dark"}} */ (
		settings.get_value("color-scheme").get_string()[0]
	);
	theme.setValue(/** @type {any}} */ (initial.substring("prefer-".length)));
	theme.connect("changed", () => {
		settings.set_string("color-scheme", `prefer-${theme.value}`);
		settings.set_string(
			"gtk-theme",
			`adw-gtk3${theme.value === "dark" ? "-dark" : ""}`,
		);

		const conf = GLib.get_user_config_dir();
		Utils.execAsync(
			`bash -c 'ln -sf ${conf}/kitty/${theme.value}.conf ${conf}/kitty/theme.conf && pkill -USR1 kitty'`,
		).catch(print);
	});
}
init();
