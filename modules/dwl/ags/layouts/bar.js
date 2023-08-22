// import { Separator } from '../modules/misc.js';
// import { PanelIndicator as NotificationIndicator } from './widgets/notifications.js';
// import { PanelButton as ColorPicker } from '../modules/colorpicker.js';
// import { PanelButton as DashBoard } from './widgets/dashboard.js';
// import { PanelButton as ScreenRecord } from '../modules/screenrecord.js';
// import { PanelButton as QuickSettings } from './widgets/quicksettings.js';

import { Clock } from "../modules/clock.js";
import { BatteryIndicator } from "../modules/battery.js";

const { App } = ags;
const { Window, CenterBox, Box, Button } = ags.Widget;

const Bar = (monitor) =>
	Window({
		name: `bar${monitor}`,
		className: "transparent",
		exclusive: true,
		anchor: "top left right",
		monitor,
		child: CenterBox({
			startWidget: Box({
				children: [
					// Workspaces(),
					// Separator({ valign: "center" }),
					// Client(),
				],
			}),
			endWidget: Box({
				halign: "end",
				children: [
					// NotificationIndicator({
					//     direction: "right",
					//     hexpand: true,
					//     halign: "start",
					// }),
					// ags.Widget.Box({ hexpand: true }),
					// ScreenRecord(),
					// ColorPicker(),
					// Separator({ valign: "center" }),
					Button({
						onClicked: () => App.toggleWindow("quicksettings"),
						connections: [[App, (btn, win, visible) => {
							btn.toggleClassName( "active", win === "quicksettings" && visible);
						}]],
						child: Box({
							children: [
								// audio.MicrophoneMuteIndicator({ unmuted: null }),
								// notifications.DNDIndicator({ noisy: null }),
								// BluetoothIndicator(),
								// bluetooth.Indicator({ disabled: null }),
								// network.Indicator(),
								// audio.SpeakerIndicator(),
								BatteryIndicator(),
							],
						}),
					}),
					Clock({ format: "%a %d %b", className: "module bold" }),
					Clock({ format: "%H:%M", className: "module accent bold" }),
				],
			}),
		}),
	});

export default (monitors) =>
	[
		...monitors.map((mon) => [
			Bar(mon),
			// shared.Notifications(mon, 'slide_down', 'top'),
			// shared.OSDIndicator(mon),
		]),
		// shared.Quicksettings({ position: 'top right' }),
		// shared.Dashboard({ position: 'top' }),
	].flat(2);
