import { Bar } from "./layouts/bar.js";
import { Notifications } from "./layouts/notifications.js";
import { OSD } from "./layouts/osd.js";
import { Powermenu } from "./layouts/powermenu.js";
import { Quicksettings } from "./layouts/quicksettings.js";

import App from 'resource:///com/github/Aylur/ags/app.js'
import { timeout } from 'resource:///com/github/Aylur/ags/utils.js';
const { Display } = imports.gi.Gdk;

const config = {
	closeWindowDelay: {
		quicksettings: 300,
		notifications: 300,
	},
	style: App.configDir + "/style.css",
	monitorFactory: (mon) => [Bar(mon, `${mon.geometry.x},${mon.geometry.y}`)],
	windows: [Quicksettings(), Notifications(), OSD(), Powermenu()],
};

const registerMonitors = (config) => {
	const display = Display.get_default();
	display.connect("monitor-added", (_, monitor) => {
		// We wait for the geometry to be initialized by gdk.
		timeout(500, () => {
			const newWindows = config.monitorFactory(monitor);
			for (const window of newWindows) App.addWindow(window);
		});
	});
	display.connect("monitor-removed", (_, monitor) => {
		for (const [name, win] of App.windows) {
			if (win.monitor == monitor) ags.App.removeWindow(name);
		}
	});

	for (let i = 0; i < display.get_n_monitors(); i++) {
		const mon = display.get_monitor(i);
		config.monitorFactory(mon);
	}

	return config;
};

export default registerMonitors(config);
