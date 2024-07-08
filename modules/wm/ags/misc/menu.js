import GObject from "gi://GObject?version=2.0";
import Gtk from "gi://Gtk?version=3.0";

export const opened = Variable("");
App.connect("window-toggled", (_, name, visible) => {
	if (name === "quicksettings" && !visible)
		Utils.timeout(500, () => {
			opened.value = "";
		});
});

/**
 * @param {{
 *   name: string,
 *   activate?: false | (() => void),
 * } & import("../types/widgets/button").ButtonProps} props
 */
export const Arrow = ({ name, activate, ...props }) => {
	let deg = 0;
	let iconOpened = false;
	const icon = Widget.Icon("pan-end-symbolic").hook(opened, () => {
		if (
			(opened.value === name && !iconOpened) ||
			(opened.value !== name && iconOpened)
		) {
			const step = opened.value === name ? 10 : -10;
			iconOpened = !iconOpened;
			for (let i = 0; i < 9; ++i) {
				Utils.timeout(15 * i, () => {
					deg += step;
					icon.setCss(`-gtk-icon-transform: rotate(${deg}deg);`);
				});
			}
		}
	});
	return Widget.Button({
		child: icon,
		className: "qs-icon",
		onClicked: () => {
			opened.value = opened.value === name ? "" : name;
			if (typeof activate === "function") activate();
		},
		...props,
	});
};

/**
 * @typedef {{
 *   name: string,
 *   icon: Gtk.Widget,
 *   label: Gtk.Widget,
 *   activate: () => void
 *   deactivate: () => void
 *   activateOnArrow?: boolean
 *   connection: [GObject.Object, () => boolean]
 * } & import("../types/widgets/box").BoxProps} ArrowToggleButtonProps
 * @param {ArrowToggleButtonProps} props
 */
export const ArrowToggleButton = ({
	name,
	icon,
	label,
	activate,
	deactivate,
	activateOnArrow = true,
	connection: [service, condition],
}) =>
	Widget.Box({
		className: "qs-button surface",
		setup: (self) =>
			self.hook(service, () => {
				self.toggleClassName("accent", condition());
			}),
		children: [
			Widget.Button({
				child: Widget.Box({
					hexpand: true,
					children: [icon, label],
				}),
				onClicked: () => {
					if (condition()) {
						deactivate();
						if (opened.value === name) opened.value = "";
					} else {
						activate();
					}
				},
			}),
			Arrow({ name, activate: activateOnArrow && activate }),
		],
	});

/**
 * @typedef {{
 *   icon: Gtk.Widget,
 *   label: Gtk.Widget,
 *   activate: () => void
 *   deactivate: () => void
 *   connection: [GObject.Object, () => boolean]
 * } & import("../types/widgets/box").BoxProps} SimpleToggleButtonProps
 * @param {SimpleToggleButtonProps} props
 */
export const SimpleToggleButton = ({
	icon,
	label,
	activate,
	deactivate,
	connection: [service, condition],
}) =>
	Widget.Box({
		className: "qs-button surface",
		setup: (self) =>
			self.hook(service, () => {
				self.toggleClassName("accent", condition());
			}),
		children: [
			Widget.Button({
				child: Widget.Box({
					hexpand: true,
					children: [icon, label],
				}),
				onClicked: () => {
					if (condition()) {
						deactivate();
					} else {
						activate();
					}
				},
			}),
		],
	});

/**
 * @typedef {{
 *   name: string,
 *   icon: Gtk.Widget,
 *   title: string,
 *   content: Gtk.Widget[],
 * } & import("../types/widgets/revealer").RevealerProps} MenuProps
 * @param {MenuProps} props
 */
export const Menu = ({ name, icon, title, content, ...props }) =>
	Widget.Revealer({
		transition: "slide_down",
		reveal_child: opened.bind().as((v) => v === name),
		child: Widget.Box({
			className: "qs-submenu surface",
			vertical: true,
			children: [
				Widget.Box({
					className: "qs-sub-title accent",
					children: [
						icon,
						Widget.Label({
							className: "bold f16",
							truncate: "end",
							label: title,
						}),
					],
				}),
				Widget.Box({
					vertical: true,
					className: "qs-sub-content",
					children: content,
				}),
			],
		}),
		...props,
	});

/** @param {{type: string} & import("../types/widgets/button").ButtonProps} props */
export const SettingsButton = ({ type, ...props }) =>
	Widget.Button({
		onClicked: () => {
			Utils.execAsync(`gnome-control-center ${type}`);
			App.closeWindow("quicksettings");
		},
		hexpand: true,
		child: Widget.Box({
			children: [
				Widget.Icon("emblem-system-symbolic"),
				Widget.Label("Settings"),
			],
		}),
		...props,
	});
