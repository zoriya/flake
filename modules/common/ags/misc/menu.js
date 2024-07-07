import Gtk from "gi://Gtk?version=3.0";

export const opened = Variable("");
App.connect("window-toggled", (_, name, visible) => {
	if (name === "quicksettings" && !visible)
		Utils.timeout(500, () => (opened.value = ""));
});

/**
 * @param {{
 *   name: string,
 *   activate?: false | (() => void),
 * } & import("types/widgets/button").ButtonProps} props
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
 *   icon: string,
 *   title: string,
 *   content: Gtk.Widget[],
 * } & import("types/widgets/revealer").RevealerProps} MenuProps
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
						Widget.Icon({
							icon,
						}),
						Widget.Label({
							className: "bold f16",
							truncate: "end",
							label: title,
						}),
					],
				}),
				Widget.Separator(),
				Widget.Box({
					vertical: true,
					className: "qs-sub-content",
					children: content,
				}),
			],
		}),
		...props,
	});
