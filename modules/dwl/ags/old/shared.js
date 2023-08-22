const { Window, CenterBox, Box, Button } = ags.Widget;
import { OnScreenIndicator } from '../modules/onscreenindicator.js';
import { Applauncher } from '../modules/applauncher.js';
import { PopupLayout } from './widgets/popuplayout.js';
import * as dashboard from './widgets/dashboard.js';
import * as quicksettings from './widgets/quicksettings.js';
import * as powermenu from './widgets/powermenu.js';
import * as notifications from '../modules/notifications.js';

export const Bar = ({ start, center, end, anchor, monitor }) => Window({
    name: `bar${monitor}`,
    exclusive: true,
    monitor,
    anchor,
    child: CenterBox({
        className: 'panel',
        startWidget: Box({ children: start, className: 'start' }),
        centerWidget: Box({ children: center, className: 'center' }),
        endWidget: Box({ children: end, className: 'end' }),
    }),
});

// static
export const Notifications = (monitor, transition, anchor) => Window({
    monitor,
    name: `notifications${monitor}`,
    anchor,
    child: notifications.PopupList({ transition }),
});

export const OSDIndicator = monitor => Window({
    name: `indicator${monitor}`,
    monitor,
    className: 'indicator',
    layer: 'overlay',
    anchor: ['right'],
    child: OnScreenIndicator(),
});

//popups
const Popup = (name, child) => Window({
    name,
    popup: true,
    focusable: true,
    layer: 'overlay',
    child: PopupLayout({
        layout: 'center',
        window: name,
        child: child(),
    }),
});

export const ApplauncherPopup = () => Popup('applauncher', Applauncher);
export const OverviewPopup = () => Popup('overview', Overview);
export const PowermenuPopup = () => Popup('powermenu', powermenu.PopupContent);
export const VerificationPopup = () => Popup('verification', powermenu.Verification);

export const Dashboard = ({ position }) => Window({
    name: 'dashboard',
    popup: true,
    focusable: true,
    anchor: position,
    child: PopupLayout({
        layout: position,
        window: 'dashboard',
        child: dashboard.PopupContent(),
    }),
});

export const Quicksettings = ({ position }) => Window({
    name: 'quicksettings',
    popup: true,
    focusable: true,
    anchor: position,
    child: PopupLayout({
        layout: position,
        window: 'quicksettings',
        child: quicksettings.PopupContent(),
    }),
});
