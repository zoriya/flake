import { Clock } from "../modules/clock.js";
import * as audio from "../modules/audio.js";
import * as network from "../modules/network.js";
import * as bluetooth from "../modules/bluetooth.js";
import * as battery from "../modules/battery.js";
import * as notifications from "../modules/notifications.js";

/**
 *@param {number} monitor
 */
export const Bar = (monitor) =>
	Widget.Window({
		monitor,
		name: `bar${monitor}`,
		className: "transparent",
		exclusivity: "exclusive",
		anchor: ["top", "left", "right"],
		layer: "bottom",
		child: Widget.CenterBox({
			startWidget: Widget.Box({
				children: [
					// dwl.Tags({
					// 	mon: monId,
					// 	labels: ["一", "二", "三", "四", "五", "六", "七", "八", "九"],
					// }),
					// dwl.Layout({
					// 	mon: monId,
					// }),
					// dwl.ClientLabel({ mon: monId }),
				],
			}),
			centerWidget: Widget.Box({
				hpack: "center",
				children: [
					Widget.Button({
						css: "min-width: 200px;",
						onClicked: () => App.toggleWindow("notifications"),
						child: notifications.Indicator({
							hexpand: true,
							hpack: "center",
						}),
					}),
				],
			}),
			endWidget: Widget.Box({
				hpack: "end",
				children: [
					Widget.Button({
						onClicked: () => App.toggleWindow("quicksettings"),
						className: "module quicksettings",
						child: Widget.Box({
							children: [
								audio.MicrophoneIndicator({
									className: "qs-item",
								}),
								notifications.DNDIndicator({
									className: "qs-item",
								}),
								network.Indicator({ className: "qs-item" }),
								audio.VolumeIndicator({ className: "qs-item" }),
								bluetooth.Indicator({
									hideIfDisabled: true,
									className: "qs-item",
								}),
								battery.Indicator({ className: "qs-item" }),
							],
						}),
					}).hook(App, (self, win, visible) => {
						self.toggleClassName("active", win === "quicksettings" && visible);
					}),
					Clock({ format: "%a %d %b", className: "module bold" }),
					Clock({
						format: "%H:%M",
						className: "module accent bold",
						css: "margin-right: 0px",
					}),
				],
			}),
		}),
	});