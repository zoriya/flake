import { Bar } from "./layouts/bar.js";
 import { Notifications } from "./layouts/notifications.js";
// import { OSD } from "./layouts/osd.js";
// import { Powermenu } from "./layouts/powermenu.js";
// import { Quicksettings } from "./layouts/quicksettings.js";

import Gtk from "gi://Gtk?version=3.0";
import Gdk from "gi://Gdk";

/**
 * @param {(monitor: number) => Gtk.Window} widget
 */
export function forMonitors(widget) {
	const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
	return Array.from({ length: n }, (_, i) => i).flatMap(widget);
}

App.config({
	closeWindowDelay: {
		quicksettings: 300,
		notifications: 300,
	},
	style: `${App.configDir}/style.css`,
	windows: [
		...forMonitors(Bar),
		// Quicksettings(),
		 Notifications(),
		// OSD(),
		// Powermenu(),
	],
});
