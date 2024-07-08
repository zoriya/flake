import Gdk from "gi://Gdk?version=3.0";
import AstalRiver from "gi://AstalRiver";

const river = AstalRiver.River.get_default();

const display = Gdk.Display.get_default();
/** @param {number} monitor */
const getOutput = (monitor) => {
	const monitorName = display
		.get_default_screen()
		.get_monitor_plug_name(monitor);
	return river.get_output(monitorName);
};

/** @param {{monitor: number, labels: string[]} & import("types/widgets/box").BoxProps} props */
export const Tags = ({ monitor, labels, ...props }) =>
	Widget.Box(props).hook(
		river,
		(self) => {
			const output = getOutput(monitor);
			if (!output) return;
			const focused = output.focused_tags;
			const occupied = output.occupied_tags;
			const urgent = output.urgent_tags;
			self.children = Array.from({ length: 9 }, (_, i) => i).map((i) =>
				TagItem({
					output,
					occupied: !!(occupied & (1 << i)),
					selected: !!(focused & (1 << i)),
					urgent: !!(urgent & (1 << i)),
					i,
					label: labels[i],
				}),
			);
			self.children.forEach((button, i) => {
				// We need to set this here because assigning children to self calls show_all() and ignore visibility
				button.visible = !!(occupied & (1 << i));
			});
		},
		"changed",
	);

/** @param {{
 *    occupied: boolean,
 *    selected: boolean,
 *    urgent: boolean,
 *    i: number,
 *    output: any,
 *    label: string
 * }} props */
const TagItem = ({ occupied, selected, urgent, i, output, label }) =>
	Widget.EventBox({
		classNames: [selected ? "accent" : "", urgent ? "secondary" : ""],
		visible: occupied,
		onPrimaryClickRelease: () => {
			river.run_command_async(["set-focused-tags", `${1 << i}`], null);
		},
		onSecondaryClickRelease: () => {
			const tags = output.get_focused_tags() ^ (1 << i);
			river.run_command_async(["set-focused-tags", `${tags}`], null);
		},
		onMiddleClickRelease: () => {
			river.run_command_async(["set-view-tags", `${1 << i}`], null);
		},
		child: Widget.Label({ label, className: "tags" }),
	});

/** @param {{monitor: number, fallback?: string} & import("types/widgets/label").LabelProps} props */
export const ClientLabel = ({ monitor, fallback = "", ...props }) =>
	Widget.Label({
		truncate: "end",
		maxWidthChars: 25,
		className: "module",
		...props,
	}).hook(
		river,
		(self) => {
			const output = getOutput(monitor);
			if (!output) return;
			self.label = output.focused_view || fallback;
		},
		"changed",
	);
