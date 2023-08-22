import { Clock } from '../../modules/clock.js';
const { Box } = ags.Widget;

export const PopupContent = props => Box({
    ...props,
    vertical: true,
    className: 'datemenu',
    children: [
        Clock({ format: '%H:%M' }),
        Box({
            className: 'calendar',
            children: [
                ags.Widget({
                    type: imports.gi.Gtk.Calendar,
                }),
            ],
        }),
    ],
});
