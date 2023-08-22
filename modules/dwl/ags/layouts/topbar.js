import * as shared from './shared.js';
import { Separator } from '../modules/misc.js';
import { PanelIndicator as NotificationIndicator } from './widgets/notifications.js';
import { PanelButton as ColorPicker } from '../modules/colorpicker.js';
import { PanelButton as DashBoard } from './widgets/dashboard.js';
import { PanelButton as ScreenRecord } from '../modules/screenrecord.js';
import { PanelButton as QuickSettings } from './widgets/quicksettings.js';

const Bar = monitor => shared.Bar({
    anchor: 'top left right',
    monitor,
    start: [
        // Workspaces(),
        Separator({ valign: 'center' }),
        // Client(),
    ],
    center: [
        DashBoard(),
    ],
    end: [
        NotificationIndicator({ direction: 'right', hexpand: true, halign: 'start' }),
        ags.Widget.Box({ hexpand: true }),
        ScreenRecord(),
        ColorPicker(),
        Separator({ valign: 'center' }),
        QuickSettings(),
        Separator({ valign: 'center' }),
    ],
});

export default monitors => ([
    ...monitors.map(mon => [
        Bar(mon),
        shared.Notifications(mon, 'slide_down', 'top'),
        shared.OSDIndicator(mon),
    ]),
    shared.Quicksettings({ position: 'top right' }),
    shared.Dashboard({ position: 'top' }),
]).flat(2);
