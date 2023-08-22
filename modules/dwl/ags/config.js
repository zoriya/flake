import topbar from "./layouts/bar.js";

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
	windows: [
		...topbar(monitors),
		// shared.ApplauncherPopup(),
		// shared.PowermenuPopup(),
		// shared.VerificationPopup(),
	],
};
