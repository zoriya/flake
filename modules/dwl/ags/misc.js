const { Box, Label, Overlay, Icon } = ags.Widget;
const { timeout } = ags.Utils;

export const Spinner = ({ icon = "process-working-symbolic" }) =>
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
		className: "icon",
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
		className: "fill accent",
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
		className: "max-indicator",
	});
	const progress = Overlay({
		...props,
		child: Box({
			className: "progress",
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

		log(value, max, axisv, axisv /max)
		maxIndicator.setStyle(`margin-${vertical ? "top" : "left"}: ${axisv / max}px; `);
		fill.toggleClassName("over", value > 1);

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
