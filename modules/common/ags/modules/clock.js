import GLib from "gi://GLib";

export const clock = Variable(GLib.DateTime.new_now_local(), {
	poll: [1000, () => GLib.DateTime.new_now_local()],
});

/**
 * @param {{format?: string} & import("types/widgets/label").LabelProps} props
 */
export const Clock = ({ format = "%a %d %b %H:%M ", ...props } = {}) =>
	Widget.Label({
		...props,
		label: Utils.derive([clock], (c) => c.format(format) || "").bind(),
	});
