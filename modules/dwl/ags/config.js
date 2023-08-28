import { Bar } from "./layouts/bar.js";
import { Notifications } from "./layouts/notifications.js";
import { OSD } from "./layouts/osd.js";
import { Powermenu } from "./layouts/powermenu.js";
import { Quicksettings } from "./layouts/quicksettings.js";

const { App } = ags;
const { Display } = imports.gi.Gdk;

const config = {
	closeWindowDelay: {
		quicksettings: 300,
		notifications: 300,
	},
	style: ags.App.configDir + "/style.css",
	monitorFactory: (mon) => [Bar(mon)],
	windows: [
		Bar({id: 0, name: "eDP-1"}),
		Quicksettings(),
		Notifications(),
		OSD(),
		Powermenu(),
	],
};

export default config;

// const registerMonitors = (config) => {
// 	const display = Display.get_default();
// 	display.connect("monitor-added", (_, monitor) => {
// 		const newWindows = config.monitorFactory(monitor);
// 		for (const window of newWindows)
// 			App.addWindow(window);
// 	});
// 	display.connect("monitor-removed", (_, monitor) => {
// 		for (const [name, win] of App.windows) {
// 			if (win.monitor == monitor) ags.App.removeWindow(name);
// 		}
// 	});
//
// 	for (let i = 0; i < display.get_n_monitors(); i++) {
// 		const mon = display.get_monitor(i);
// 		config.monitorFactory(mon);
// 	}
//
// 	return config;
// };
//
// export default registerMonitors(config);
