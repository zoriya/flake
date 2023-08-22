const { Label } = ags.Widget;
const { DateTime } = imports.gi.GLib;

export const Clock = ({
    format = '%a %d %b %H:%M ',
    interval = 1000,
    ...props
} = {}) => Label({
    className: 'clock',
    ...props,
    connections: [[interval, label =>
        label.label = DateTime.new_now_local().format(format),
    ]],
});
