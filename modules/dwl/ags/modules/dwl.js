const { Box, Button, Label } = ags.Widget;
import Dwl from "../services/dwl.js";

export const Tags = ({ mon, labels, ...props } = {}) =>
	Box({
		...props,
		connections: [
			[
				Dwl,
				(box) => {
					box.children = Dwl.tags(mon).map((tag, i) =>
						tag.occupied || tag.selected
							? Button({
									child: Label(labels[i]),
									className: `${tag.selected ? "selected" : ""} ${
										tag.urgent ? "urgent" : ""
									}`,
							  })
							: null
					);
				},
			],
		],
	});

export const ClientLabel = ({
	mon,
	substitutes = [], // { from: string, to: string }[]
	fallback = "",
	...props
} = {}) =>
	Label({
		...props,
		connections: [
			[
				Dwl,
				(label) => {
					let name = Dwl.title(mon);
					substitutes.forEach(({ from, to }) => {
						if (name === from) name = to;
					});
					label.label = name;
				},
			],
		],
	});

export const Layout = ({ mon, ...props }) =>
	Label({
		...props,
		connections: [
			[
				Dwl,
				(label) => {
					label.label = Dwl.layout(mon);
				},
			],
		],
	});
