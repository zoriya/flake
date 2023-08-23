import { Bar } from "./layouts/bar.js";
import { OSD } from "./layouts/osd.js";

// TODO: (ags) dwl patch
// const monitors = ags.Service.Hyprland.HyprctlGet('monitors')
//     .map(mon => mon.id);
const monitors = [0];

export default {
	closeWindowDelay: {
		quicksettings: 300,
		dashboard: 300,
	},
	style: ags.App.configDir + "/style.css",
	windows: monitors.flatMap((mon) => [
		Bar(mon),
		// shared.Quicksettings({ position: 'top right' }),
		// shared.Dashboard({ position: 'top' }),
		// shared.ApplauncherPopup(),
		// shared.PowermenuPopup(),
		// shared.VerificationPopup(),
	]).concat([
		OSD(),
	]),
};
