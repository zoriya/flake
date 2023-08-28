const { App } = ags;
const { Box, Label, Revealer, EventBox, Overlay, Icon } = ags.Widget;
const { timeout } = ags.Utils;

export const addElipsis = (str, max = 20, position = "end") => {
	if (str.length <= max) return str;
	switch (position) {
		case "middle":
			max -= 3;
			return str.substring(0, Math.ceil(max / 2)) + "..." + str.substring(str.length - Math.floor(max / 2));
		case "end":
			return str.substring(0, max - 3) + "...";
	}
};

export const Spinner = ({ icon = "process-working-symbolic" } = {}) =>
	Icon({
		icon,
		properties: [["deg", 0]],
		connections: [
			[
				10,
				(w) => {
					w.setStyle(`-gtk-icon-transform: rotate(${w._deg++ % 360}deg);`);
				},
			],
		],
	});

export const FontIcon = ({ icon = "", ...props }) => {
	const box = Box({
		style: "min-width: 1px; min-height: 1px;",
	});
	const label = Label({
		label: icon,
		halign: "center",
		valign: "center",
	});
	return Box({
		...props,
		setup: (box) => (box.label = label),
		children: [
			Overlay({
				child: box,
				overlays: [label],
				passThrough: true,
				connections: [
					[
						"draw",
						(overlay) => {
							const size =
								overlay.get_style_context().get_property("font-size", imports.gi.Gtk.StateFlags.NORMAL) || 11;

							box.setStyle(`min-width: ${size}px; min-height: ${size}px;`);
						},
					],
				],
			}),
		],
	});
};

export const Progress = ({ height, width, vertical = false, ...props }) => {
	const fill = Box({
		className: "progress accent",
		hexpand: vertical,
		vexpand: !vertical,
		halign: vertical ? "fill" : "start",
		valign: vertical ? "end" : "fill",
	});
	const maxIndicator = Box({
		hexpand: vertical,
		vexpand: !vertical,
		halign: vertical ? "fill" : "start",
		valign: vertical ? "end" : "fill",
		className: "max-indicator red",
	});
	const progress = Overlay({
		...props,
		child: Box({
			className: "progress surface",
			style: `
				min-width: ${width}px;
				min-height: ${height}px;
			`,
			children: [fill],
		}),
		overlays: [maxIndicator],
	});
	progress.setValue = (value, max = 1) => {
		if (value < 0) return;

		const axis = vertical ? "height" : "width";
		const axisv = vertical ? height : width;
		const min = vertical ? width : height;
		const preferred = Math.max(min, (axisv * value) / max);

		maxIndicator.setStyle(`margin-${vertical ? "top" : "left"}: ${axisv / max}px; `);
		fill.toggleClassName("red", value > 1);

		if (!fill._size) {
			fill._size = preferred;
			fill.setStyle(`min-${axis}: ${preferred}px;`);
			return;
		}

		const frames = 10;
		const goal = preferred - fill._size;
		const step = goal / frames;

		for (let i = 0; i < frames; ++i) {
			timeout(5 * i, () => {
				fill._size += step;
				fill.setStyle(`min-${axis}: ${fill._size}px`);
			});
		}
	};
	return progress;
};

export const Separator = ({ className = "", ...props } = {}) =>
	Box({
		hexpand: false,
		vexpand: false,
		...props,
		className: `${className} separator accent`,
	});

const PopupCloser = (windowName) =>
	EventBox({
		hexpand: true,
		vexpand: true,
		connections: [["button-press-event", () => App.toggleWindow(windowName)]],
	});

const PopupRevealer = (windowName, transition, child) =>
	Box({
		style: "padding: 1px;",
		children: [
			Revealer({
				transition,
				child,
				transitionDuration: 350,
				connections: [
					[
						App,
						(revealer, name, visible) => {
							if (name === windowName) revealer.reveal_child = visible;
						},
					],
				],
			}),
		],
	});

export const PopupOverlay = (windowName, layout, child) => {
	switch (layout) {
		case "top":
			return Box({
				children: [
					PopupCloser(windowName),
					Box({
						hexpand: false,
						vertical: true,
						children: [PopupRevealer(windowName, "slide_down", child), PopupCloser(windowName)],
					}),
					PopupCloser(windowName),
				],
			});
		case "top right":
			return Box({
				children: [
					PopupCloser(windowName),
					Box({
						hexpand: false,
						vertical: true,
						children: [PopupRevealer(windowName, "slide_down", child), PopupCloser(windowName)],
					}),
				],
			});
		case "center":
			return Box({
				children: [
					PopupCloser(windowName),
					Box({
						hexpand: false,
						vertical: true,
						children: [PopupCloser(windowName), PopupRevealer(windowName, "crossfade", child), PopupCloser(windowName)],
					}),
					PopupCloser(windowName),
				],
			});
	}
};
