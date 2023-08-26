const { lookUpIcon } = ags.Utils;
const { Window, Revealer, Stack, Box, Icon } = ags.Widget;
import { FontIcon, Progress } from "../misc.js";
import { Indicator } from "../services/osd.js";

export const OSD = () =>
	Window({
		name: "osd",
		popup: true,
		// Follow active monitor
		monitor: undefined,
		layer: "overlay",
		anchor: ["bottom"],
		child: Revealer({
			transition: "crossfade",
			connections: [
				[
					Indicator,
					(revealer, value) => {
						revealer.revealChild = value > -1;
					},
				],
			],
			child: Box({
				className: "osd transparent osd",
				valign: "center",
				halign: "center",
				children: [
					Stack({
						valign: "center",
						halign: "center",
						style: "padding: 20px;",
						hexpand: false,
						items: [
							[
								"true",
								Icon({
									halign: "center",
									valign: "center",
									size: 40,
									connections: [[Indicator, (icon, _v, name) => (icon.icon = name || "")]],
								}),
							],
							[
								"false",
								FontIcon({
									halign: "center",
									valign: "center",
									hexpand: true,
									style: `font-size: 40px;`,
									connections: [[Indicator, ({ label }, _v, name) => (label.label = name || "")]],
								}),
							],
						],
						connections: [
							[
								Indicator,
								(stack, _v, name) => {
									stack.shown = `${!!lookUpIcon(name)}`;
								},
							],
						],
					}),
					Progress({
						width: 200,
						height: 10,
						halign: "center",
						valign: "center",
						style: "margin-right: 20px;",
						hexpand: false,
						vexpand: false,
						connections: [
							[
								Indicator,
								(progress, value, icon) => {
									if (!icon) return;
									progress.setValue(value, icon.startsWith("audio") ? 1.5 : 1);
								},
							],
						],
					}),
				],
			}),
		}),
	});
