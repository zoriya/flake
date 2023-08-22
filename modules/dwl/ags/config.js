import topbar from './layouts/topbar.js';
import * as shared from './layouts/shared.js';

// TODO: (ags) dwl patch
// const monitors = ags.Service.Hyprland.HyprctlGet('monitors')
//     .map(mon => mon.id);
const monitors = [0];

export default {
    closeWindowDelay: {
        'quicksettings': 300,
        'dashboard': 300,
    },
    windows: [
        ...topbar(monitors),
        // shared.ApplauncherPopup(),
        shared.PowermenuPopup(),
        // shared.VerificationPopup(),
    ],
};
