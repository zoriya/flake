import { Label } from 'resource:///com/github/Aylur/ags/widget.js';
const { DateTime } = imports.gi.GLib;

export const Clock = ({
	format = "%a %d %b %H:%M ",
	interval = 1000,
	...props
} = {}) =>
	Label({
		...props,
		connections: [
			[
				interval,
				(label) => (label.label = DateTime.new_now_local().format(format)),
			],
		],
	});
