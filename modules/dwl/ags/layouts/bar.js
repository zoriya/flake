import { Clock } from "../modules/clock.js";
import * as dwl from "../modules/dwl.js";
import * as audio from "../modules/audio.js";
import * as network from "../modules/network.js";
import * as bluetooth from "../modules/bluetooth.js";
import * as battery from "../modules/battery.js";
import * as notifications from "../modules/notifications.js";

const { App } = ags;
const { Window, CenterBox, Box, Button } = ags.Widget;

export const Bar = (mon) =>
	Window({
		name: `bar${mon.id}`,
		className: "transparent",
		exclusive: true,
		anchor: "top left right",
		monitor: mon.id,
		child: CenterBox({
			startWidget: Box({
				children: [
					dwl.Tags({
						mon: mon.name,
						labels: ["一", "二", "三", "四", "五", "六", "七", "八", "九"],
					}),
					dwl.Layout({
						mon: mon.name,
					}),
					dwl.ClientLabel({ mon: mon.name }),
				],
			}),
			centerWidget: Box({
				halign: "center",
				children: [
					Button({
						style: "min-width: 200px;",
						onClicked: () => App.toggleWindow("notifications"),
						child: notifications.Indicator({
							hexpand: true,
							halign: "center",
						}),
					}),
				],
			}),
			endWidget: Box({
				halign: "end",
				children: [
					// TODO:
					// ags.Widget.Box({ hexpand: true }),
					// ScreenShare() & MicInUse()
					// ScreenRecord(),
					// ColorPicker(),
					// Separator({ valign: "center" }),
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
					Clock({ format: "%H:%M", className: "module accent bold", style: "margin-right: 0px" }),
				],
			}),
		}),
	});
