import Gtk from "gi://Gtk?version=3.0";
import Gdk from "gi://Gdk";

import { Bar } from "./layouts/bar.js";
import { Notifications } from "./layouts/notifications.js";
import { OSD } from "./layouts/osd.js";
import { Quicksettings } from "./layouts/quicksettings.js";
import { lockscreen } from "./lockscreen.js";

// @ts-ignore
App.lock = lockscreen;

/**
 * @param {Array<(monitor: number) => Gtk.Window>} widgets
 */
export function forMonitors(widgets) {
	const display = Gdk.Display.get_default();

	display?.connect("monitor-added", (disp, gdkmonitor) => {
		let monitor = 0;
		for (let i = 0; i < display.get_n_monitors(); i++) {
			if (gdkmonitor === display.get_monitor(i)) {
				monitor = i;
				break;
			}
		}

		widgets.forEach((win) => App.addWindow(win(monitor)));
	});

	display?.connect("monitor-removed", (disp, monitor) => {
		App.windows.forEach((win) => {
			// @ts-ignore
			if (win.gdkmonitor === monitor) App.removeWindow(win);
		});
	});

	const n = display?.get_n_monitors() || 1;
	return Array.from({ length: n }, (_, i) => i).flatMap((mon) =>
		widgets.map((x) => x(mon)),
	);
}

App.config({
	closeWindowDelay: {
		quicksettings: 300,
		notifications: 200,
		osd: 300,
	},
	style: `${App.configDir}/style.css`,
	windows: [...forMonitors([Bar]), Quicksettings(), Notifications(), OSD()],
});
