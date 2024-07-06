// Stollen from https://github.com/Aylur/dotfiles/blob/main/ags/widget/PopupWindow.ts#

/** @typedef {import('types/widgets/window').WindowProps} WindowProps */
/** @typedef {import('types/widgets/revealer').RevealerProps} RevealerProps */
/** @typedef {import('types/widgets/eventbox').EventBoxProps} EventBoxProps */
/** @typedef {import('gi://Gtk?version=3.0')} Gtk */

/**
 * @param {string} name
 * @param {EventBoxProps}
 * @returns {any}
 */
export const Padding = (
	name,
	{ css = "", hexpand = true, vexpand = true } = {},
) =>
	Widget.EventBox({
		hexpand,
		vexpand,
		can_focus: false,
		child: Widget.Box({ css }),
		setup: (w) => w.on("button-press-event", () => App.toggleWindow(name)),
	});
/**
 * @param {string} name
 * @param {Child} child
 * @param {Transition} [transition="slide_down"]
 * @param {number} duration
 */
const PopupRevealer = (
	name,
	child,
	transition = "slide_down",
	duration = 500,
) =>
	Widget.Box(
		{ css: "padding: 1px;" },
		Widget.Revealer({
			transition,
			child: Widget.Box({
				class_name: "window-content",
				child,
			}),
			transitionDuration: duration,
			setup: (self) =>
				self.hook(App, (_, wname, visible) => {
					if (wname === name) self.reveal_child = visible;
				}),
		}),
	);
/**
 * @param {string} name
 * @param {Child} child
 * @param {Transition} [transition]
 * @param {number} [duration]
 * @returns {{ center: () => any; top: () => any; "top-right": () => any; "top-center": () => any; "top-left": () => any; "bottom-left": () => any; "bottom-center": () => any; "bottom-right": () => any; }}
 */
const Layout = (name, child, transition, duration) => ({
	center: () =>
		Widget.CenterBox(
			{},
			Padding(name),
			Widget.CenterBox(
				{ vertical: true },
				Padding(name),
				PopupRevealer(name, child, transition, duration),
				Padding(name),
			),
			Padding(name),
		),
	top: () =>
		Widget.CenterBox(
			{},
			Padding(name),
			Widget.Box(
				{ vertical: true },
				PopupRevealer(name, child, transition, duration),
				Padding(name),
			),
			Padding(name),
		),
	"top-right": () =>
		Widget.Box(
			{},
			Padding(name),
			Widget.Box(
				{
					hexpand: false,
					vertical: true,
				},
				PopupRevealer(name, child, transition, duration),
				Padding(name),
			),
		),
	"top-center": () =>
		Widget.Box(
			{},
			Padding(name),
			Widget.Box(
				{
					hexpand: false,
					vertical: true,
				},
				PopupRevealer(name, child, transition, duration),
				Padding(name),
			),
			Padding(name),
		),
	"top-left": () =>
		Widget.Box(
			{},
			Widget.Box(
				{
					hexpand: false,
					vertical: true,
				},
				PopupRevealer(name, child, transition, duration),
				Padding(name),
			),
			Padding(name),
		),
	"bottom-left": () =>
		Widget.Box(
			{},
			Widget.Box(
				{
					hexpand: false,
					vertical: true,
				},
				Padding(name),
				PopupRevealer(name, child, transition, duration),
			),
			Padding(name),
		),
	"bottom-center": () =>
		Widget.Box(
			{},
			Padding(name),
			Widget.Box(
				{
					hexpand: false,
					vertical: true,
				},
				Padding(name),
				PopupRevealer(name, child, transition, duration),
			),
			Padding(name),
		),
	"bottom-right": () =>
		Widget.Box(
			{},
			Padding(name),
			Widget.Box(
				{
					hexpand: false,
					vertical: true,
				},
				Padding(name),
				PopupRevealer(name, child, transition, duration),
			),
		),
});

/** @typedef {RevealerProps["transition"]} Transition */
/** @typedef {WindowProps["child"]} Child */
/**
 * @typedef {Omit<WindowProps, "name"> & {
 *     name: string
 *     layout?: keyof ReturnType<typeof Layout>
 *     transition?: Transition,
 *     duration?: number
 * }} PopupWindowProps
 * @param {PopupWindowProps} props
 */
export default ({
	name,
	child,
	layout = "center",
	transition,
	exclusivity = "ignore",
	duration,
	...props
}) =>
	Widget.Window({
		name,
		class_names: [name, "popup-window"],
		setup: (w) => w.keybind("Escape", () => App.closeWindow(name)),
		visible: false,
		keymode: "on-demand",
		exclusivity,
		layer: "top",
		anchor: ["top", "bottom", "right", "left"],
		child: Layout(name, child, transition, duration)[layout](),
		...props,
	});
