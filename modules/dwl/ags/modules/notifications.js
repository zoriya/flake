import { FontIcon } from "../misc.js";

const { GLib } = imports.gi;
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js'
import { lookUpIcon, timeout } from 'resource:///com/github/Aylur/ags/utils.js';

import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { Box, Icon, Label, EventBox, Button, Stack, Revealer } from 'resource:///com/github/Aylur/ags/widget.js';

export const Indicator = ({ ...props }) =>
	Box({
		...props,
		connections: [
			[
				Notifications,
				(box) => {
					box.visible = Notifications.notifications.length > 0 && !Notifications.dnd;
				},
			],
		],
		children: [
			Icon("preferences-system-notifications-symbolic"),
			Revealer({
				transition: "slide_right",
				properties: [
					["current", null],
					[
						"update",
						(rev, id, open) => {
							if (!id) return;

							// Only close the notification if it is the currently displayed.
							if (rev._current !== id && !open) return;

							if (rev._current === id && !open) {
								rev.reveal_child = false;
								return;
							}

							rev._current = id;
							const notif = Notifications.getNotification(id);
							rev.child.label = `${notif.summary?.substring(0, 18)?.trim()}: ${notif.body?.substring(0, 45)?.trim()}`.replaceAll("\n", " ");
							rev.reveal_child = true;
						},
					],
				],
				connections: [
					[Notifications, (label, id) => label._update(label, id, true), "notified"],
					[Notifications, (label, id) => label._update(label, id, false), "dismissed"],
					[Notifications, (label, id) => label._update(label, id, false), "closed"],
				],
				child: Label({
					use_markup: true,
					truncate: "end",
					wrap: false,
					label: "",
				}),
			}),
		],
	});

const NotificationIcon = ({ appEntry, appIcon, image }) => {
	if (image) {
		return Widget.Box({
			vpack: "start",
			hexpand: false,
			className: "icon img",
			css: `
				background-image: url("${image}");
				background-size: contain;
				background-repeat: no-repeat;
				background-position: center;
				min-width: 78px;
				min-height: 78px;
			`,
		});
	}

	let icon = "dialog-information-symbolic";
	if (lookUpIcon(appIcon)) icon = appIcon;

	if (lookUpIcon(appEntry)) icon = appEntry;

	return Widget.Box({
		vpack: "start",
		hexpand: false,
		className: "icon",
		css: `
			min-width: 78px;
			min-height: 78px;
		`,
		children: [
			Widget.Icon({
				icon,
				size: 58,
				hpack: "center",
				hexpand: true,
				vpack: "center",
				vexpand: true,
			}),
		],
	});
};

export const Notification = n => Widget.EventBox({
	className: `surface r20 p10 notification ${n.urgency}`,
	css: "margin: 8px 0;",
	onPrimaryClick: () => n.dismiss(),
	properties: [['hovered', false]],
	onHover: self => {
		if (self._hovered)
			return;

		// if there are action buttons and they are hovered
		// EventBox onHoverLost will fire off immediately,
		// so to prevent this we delay it
		timeout(300, () => self._hovered = true);
	},
	onHoverLost: self => {
		if (!self._hovered)
			return;

		self._hovered = false;
		n.dismiss();
	},
	vexpand: false,
	child: Widget.Box({
		vertical: true,
		children: [
			Widget.Box({
				children: [
					NotificationIcon(n),
					Widget.Box({
						hexpand: true,
						vertical: true,
						children: [
							Widget.Box({
								children: [
									Widget.Label({
										className: 'title',
										xalign: 0,
										justification: 'left',
										hexpand: true,
										maxWidthChars: 24,
										truncate: 'end',
										wrap: true,
										label: n.summary,
										useMarkup: true,
									}),
									Widget.Button({
										className: 'close-button',
										vpack: 'start',
										child: Widget.Icon('window-close-symbolic'),
										onClicked: n.close.bind(n),
									}),
								],
							}),
							Widget.Label({
								className: 'description',
								hexpand: true,
								useMarkup: true,
								xalign: 0,
								justification: 'left',
								label: n.body,
								wrap: true,
							}),
						],
					}),
				],
			}),
			Widget.Box({
				className: 'actions',
				children: n.actions.map(({ id, label }) => Widget.Button({
					className: 'action-button',
					onClicked: () => n.invoke(id),
					hexpand: true,
					child: Widget.Label(label),
				})),
			}),
		],
	}),
});

export const List = (props) =>
	Box({
		...props,
		vertical: true,
		connections: [
			[
				Notifications,
				(box) => {
					box.children = Notifications.notifications.map((n) => Notification(n));

					box.visible = Notifications.notifications.length > 0;
				},
			],
		],
	});

export const Placeholder = (props) =>
	Box({
		vertical: true,
		vpack: "center",
		hpack: "center",
		...props,
		children: [
			Label({ label: "󰂛", css: "margin-top: 150px;" }),
			Label({ label: "Your inbox is empty", css: "margin-bottom: 150px;" }),
		],
		connections: [[Notifications, (box) => (box.visible = Notifications.notifications.length === 0)]],
	});

export const ClearButton = (props) =>
	Button({
		...props,
		onClicked: () => Notifications.clear(),
		connections: [[Notifications, (button) => (button.sensitive = Notifications.notifications.length > 0)]],
		child: Box({
			children: [
				Label("Clear "),
				Stack({
					items: [
						["true", Icon("user-trash-full-symbolic")],
						["false", Icon("user-trash-symbolic")],
					],
					connections: [
						[
							Notifications,
							(stack) => {
								stack.shown = `${Notifications.notifications.length > 0}`;
							},
						],
					],
				}),
			],
		}),
	});

export const DNDIndicator = ({
	silent = Icon("notifications-disabled-symbolic"),
	noisy = Icon("preferences-system-notifications-symbolic"),
	...props
} = {}) =>
	Stack({
		...props,
		items: [
			["true", silent],
			["false", noisy],
		],
		connections: [
			[
				Notifications,
				(stack) => {
					stack.shown = `${Notifications.dnd}`;
				},
			],
		],
	});

export const DNDToggle = (props) =>
	Button({
		...props,
		onClicked: () => {
			Notifications.dnd = !Notifications.dnd;
		},
		child: DNDIndicator(),
		connections: [
			[
				Notifications,
				(button) => {
					button.toggleClassName("on", Notifications.dnd);
				},
			],
		],
	});
