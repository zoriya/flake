import { Clock } from "../modules/clock.js";
import * as dwl from "../modules/dwl.js";
import * as audio from "../modules/audio.js";
import * as network from "../modules/network.js";
import * as bluetooth from "../modules/bluetooth.js";
import * as battery from "../modules/battery.js";
import * as notifications from "../modules/notifications.js";

import App from 'resource:///com/github/Aylur/ags/app.js';
import { Window, CenterBox, Box, Button } from 'resource:///com/github/Aylur/ags/widget.js';

export const Bar = (mon, monId) =>
	Window({
		name: `bar${monId}`,
		className: "transparent",
		exclusive: true,
		anchor: ["top", "left", "right"],
		layer: "bottom",
		gdkmonitor: mon,
		child: CenterBox({
			startWidget: Box({
				children: [
					dwl.Tags({
						mon: monId,
						labels: ["一", "二", "三", "四", "五", "六", "七", "八", "九"],
					}),
					dwl.Layout({
						mon: monId,
					}),
					dwl.ClientLabel({ mon: monId }),
				],
			}),
			centerWidget: Box({
				hpack: "center",
				children: [
					Button({
						css: "min-width: 200px;",
						onClicked: () => App.toggleWindow("notifications"),
						child: notifications.Indicator({
							hexpand: true,
							hpack: "center",
						}),
					}),
				],
			}),
			endWidget: Box({
				hpack: "end",
				children: [
					// TODO:
					// ScreenShare()
					// Webcam
					// ScreenRecord(),
					// ColorPicker(),
					Button({
						onClicked: () => App.toggleWindow("quicksettings"),
						className: "module quicksettings",
						connections: [
							[
								App,
								(btn, win, visible) => {
									btn.toggleClassName("active", win === "quicksettings" && visible);
								},
							],
						],
						child: Box({
							children: [
								// audio.MicUseIndicator({ className: "qs-icon" }),
								audio.MicrophoneMuteIndicator({ unmuted: null, className: "qs-item" }),
								notifications.DNDIndicator({ noisy: null, className: "qs-item" }),
								network.Indicator({ className: "qs-item" }),
								audio.SpeakerIndicator({ className: "qs-item" }),
								bluetooth.Indicator({ disabled: null, className: "qs-item" }),
								battery.Indicator({ className: "qs-item" }),
							],
						}),
					}),
					Clock({ format: "%a %d %b", className: "module bold" }),
					Clock({ format: "%H:%M", className: "module accent bold", css: "margin-right: 0px" }),
				],
			}),
		}),
	});
