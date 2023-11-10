import App from 'resource:///com/github/Aylur/ags/app.js'
import Service from 'resource:///com/github/Aylur/ags/service.js'
import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import { Box, Button, Icon } from 'resource:///com/github/Aylur/ags/widget.js'
import { timeout } from 'resource:///com/github/Aylur/ags/utils.js';

export const opened = Variable('');
App.instance.connect('window-toggled', (_, name, visible) => {
	if (name === 'quicksettings' && !visible)
		timeout(500, () => opened.value = '');
});

export const ArrowToggle = ({ icon, label, toggle, name, expand, ...props }) => {
	icon.className = `${icon.className} qs-icon`;
	return Box({
		className: "qs-button surface",
		children: [
			Button({
				hexpand: true,
				onClicked: toggle,
				child: Box({
					children: [icon, label],
				}),
			}),
			Arrow({ name, expand }),
		],
		...props,
	});
};

export const Arrow = ({ name, expand, ...props }) =>
	Button({
		...props,
		className: "qs-icon",
		onClicked: () => {
			opened.value = opened.value === name ? "" : name;
			if (expand) expand();
		},
		connections: [
			[
				opened,
				(button) => {
					button.toggleClassName("opened", opened.value === name);
				},
			],
		],
		child: Icon({
			icon: "pan-end-symbolic",
			properties: [
				["deg", 0],
				["opened", false],
			],
			connections: [
				[
					opened,
					(icon) => {
						if ((opened.value === name && !icon._opened) || (opened.value !== name && icon._opened)) {
							const step = opened.value === name ? 10 : -10;
							icon._opened = !icon._opened;
							for (let i = 0; i < 9; ++i) {
								timeout(5 * i, () => {
									icon._deg += step;
									icon.setStyle(`-gtk-icon-transform: rotate(${icon._deg}deg);`);
								});
							}
						}
					},
				],
			],
		}),
	});
