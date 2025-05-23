import Gdk from "gi://Gdk?version=3.0";

const hyprland = await Service.import("hyprland");

const display = Gdk.Display.get_default();
/** @param {number} monitor */
const getMonitorName = (monitor) => {
	return display.get_default_screen().get_monitor_plug_name(monitor);
};

/** @type {Record<number, boolean>} */
const urgents = {}

/** @param {{monitor: number, labels: string[]} & import("types/widgets/box").BoxProps} props */
export const Tags = ({ monitor, labels, ...props }) => {
	const monName = getMonitorName(monitor);
	// @ts-ignore
	return Widget.Box({
		...props,
		children: Array.from({ length: 9 }, (_, i) => i).map((i) =>
			Widget.EventBox({
				child: Widget.Label({ label: labels[i], className: "tags" }),
				attribute: i + 1,
				onPrimaryClickRelease: () => {
					hyprland.message(`dispatch workspace ${i + 1}`);
				},
			}),
		),
		setup: (self) => {
			self.hook(hyprland, (_, address) => {
				const client = hyprland.getClient(address);
				if (!client) return;
				const ws = client.workspace.id;
				urgents[ws] = true;
			}, "urgent-window");

			self.hook(hyprland, () =>
				self.children.forEach((btn) => {
					const mon = hyprland.monitors.find((x) => x.name === monName);
					const ws = hyprland.workspaces.find((x) => x.id === btn.attribute);

					const occupied = (ws?.windows ?? 0) > 0;
					const selected = mon?.activeWorkspace?.id === btn.attribute;
					if (selected) urgents[btn.attribute] = false;
					const urgent = urgents[btn.attribute];

					btn.visible = occupied || selected;
					btn.class_names = [
						selected ? "accent" : "",
						urgent ? "secondary" : "",
					];
				}),
			);
		},
	});
};

/** @param {{monitor: number } & import("types/widgets/label").LabelProps} props */
export const Layout = ({ monitor, ...props }) => {
	const monName = getMonitorName(monitor);
	return Widget.Label({
		className: "module",
		...props,
	}).hook(
		hyprland,
		(self) => {
			const mon = hyprland.monitors.find((x) => x.name === monName);
			const ws = hyprland.workspaces.find(
				(x) => x.id === mon?.activeWorkspace?.id,
			);
			self.label = ws?.windows ? `[${ws?.windows}]` : "";
		},
		"changed",
	);
}

/** @param {{monitor: number, fallback?: string} & import("types/widgets/label").LabelProps} props */
export const ClientLabel = ({ monitor, fallback = "", ...props }) => {
	const monName = getMonitorName(monitor);
	return Widget.Label({
		truncate: "end",
		maxWidthChars: 25,
		className: "module",
		...props,
	}).hook(
		hyprland,
		(self) => {
			const mon = hyprland.monitors.find((x) => x.name === monName);
			const ws = hyprland.workspaces.find(
				(x) => x.id === mon?.activeWorkspace?.id,
			);
			self.label = ws?.lastwindowtitle || fallback;
		},
		"changed",
	);
};
