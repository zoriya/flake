import App from 'resource:///com/github/Aylur/ags/app.js'
import { Box, Label, Revealer, EventBox, Overlay, Icon } from 'resource:///com/github/Aylur/ags/widget.js'
import { timeout } from 'resource:///com/github/Aylur/ags/utils.js';


export const Spinner = ({ icon = "process-working-symbolic" } = {}) =>
	Icon({
		icon,
		properties: [["deg", 0]],
		connections: [
			[
				10,
				(w) => {
					w.setCss(`-gtk-icon-transform: rotate(${w._deg++ % 360}deg);`);
				},
			],
		],
	});

export const FontIcon = ({ icon = "", ...props }) => {
	const box = Box({
		css: "min-width: 1px; min-height: 1px;",
	});
	const label = Label({
		label: icon,
		hpack: "center",
		vpack: "center",
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

							box.setCss(`min-width: ${size}px; min-height: ${size}px;`);
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
		hpack: vertical ? "fill" : "start",
		vpack: vertical ? "end" : "fill",
	});
	const maxIndicator = Box({
		hexpand: vertical,
		vexpand: !vertical,
		hpack: vertical ? "fill" : "start",
		vpack: vertical ? "end" : "fill",
		className: "max-indicator red",
	});
	const progress = Overlay({
		...props,
		child: Box({
			className: "progress surface",
			css: `
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

		maxIndicator.setCss(`margin-${vertical ? "top" : "left"}: ${axisv / max}px; `);
		fill.toggleClassName("red", value > 1);

		if (!fill._size) {
			fill._size = preferred;
			fill.setCss(`min-${axis}: ${preferred}px;`);
			return;
		}

		const frames = 10;
		const goal = preferred - fill._size;
		const step = goal / frames;

		for (let i = 0; i < frames; ++i) {
			timeout(5 * i, () => {
				fill._size += step;
				fill.setCss(`min-${axis}: ${fill._size}px`);
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
