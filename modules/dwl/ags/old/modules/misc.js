const { Box, Label, Overlay, Icon, Revealer, EventBox } = ags.Widget;
const { timeout, exec } = ags.Utils;

export const Separator = ({ className = '', ...props } = {}) => Box({
    hexpand: false,
    vexpand: false,
    ...props,
    className: [...className.split(' '), 'separator'].join(' '),
});


export const DistroIcon = props => FontIcon({
    ...props,
    className: 'distro-icon',
    icon: (() => {
        // eslint-disable-next-line quotes
        const distro = exec(`bash -c "cat /etc/os-release | grep '^ID' | head -n 1 | cut -d '=' -f2"`)
            .toLowerCase();

        switch (distro) {
            case 'fedora': return '';
            case 'arch': return '';
            case 'nixos': return '';
            case 'debian': return '';
            case 'opensuse-tumbleweed': return '';
            case 'ubuntu': return '';
            case 'endeavouros': return '';
            default: return '';
        }
    })(),
});

export const Spinner = ({ icon = 'process-working-symbolic' }) => Icon({
    icon,
    properties: [['deg', 0]],
    connections: [[10, w => {
        w.setStyle(`-gtk-icon-transform: rotate(${w._deg++ % 360}deg);`);
    }]],
});

export const HoverRevealer = ({
    indicator,
    child,
    direction = 'left',
    duration = 300,
    connections,
    ...rest
}) => Box({
    children: [EventBox({
        ...rest,
        onHover: w => {
            if (w._open)
                return;

            w.get_child().get_children()[direction === 'down' || direction === 'right' ? 1 : 0].reveal_child = true;
            timeout(duration, () => w._open = true);
        },
        onHoverLost: w => {
            if (!w._open)
                return;

            w.get_child().get_children()[direction === 'down' || direction === 'right' ? 1 : 0].reveal_child = false;
            w._open = false;
        },
        child: Box({
            vertical: direction === 'down' || direction === 'up',
            children: [
                direction === 'down' || direction === 'right' ? indicator : null,
                Revealer({
                    transition: `slide_${direction}`,
                    connections,
                    transitionDuration: duration,
                    child,
                }),
                direction === 'up' || direction === 'left' ? indicator : null,
            ],
        }),
    })],
});
