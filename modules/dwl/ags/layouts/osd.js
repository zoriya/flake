import { lookUpIcon } from 'resource:///com/github/Aylur/ags/utils.js';
import { Window, Revealer, Stack, Box, Icon } from 'resource:///com/github/Aylur/ags/widget.js'
import { FontIcon, Progress } from "../misc.js";
import Indicator from "../services/osd.js";

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
				className: "osd bgcont osd",
				vpack: "center",
				hpack: "center",
				children: [
					Stack({
						vpack: "center",
						hpack: "center",
						css: "padding: 20px;",
						hexpand: false,
						items: [
							[
								"true",
								Icon({
									hpack: "center",
									vpack: "center",
									size: 40,
									connections: [[Indicator, (icon, _v, name) => (icon.icon = name || "")]],
								}),
							],
							[
								"false",
								FontIcon({
									hpack: "center",
									vpack: "center",
									hexpand: true,
									css: `font-size: 40px;`,
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
						hpack: "center",
						vpack: "center",
						css: "margin-right: 20px;",
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
