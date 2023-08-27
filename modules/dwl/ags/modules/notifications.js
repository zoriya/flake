import { FontIcon } from "../misc.js";

const { GLib } = imports.gi;
const { Notifications } = ags.Service;
const { lookUpIcon, timeout } = ags.Utils;
const { Box, Icon, Label, EventBox, Button, Stack, Revealer } = ags.Widget;

export const Indicator = ({ ...props }) =>
	Box({
		...props,
		connections: [
			[
				Notifications,
				(box) => {
					box.visible = Notifications.notifications.size > 0 && !Notifications.dnd;
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

							if (rev._current === id) {
								rev.reveal_child = false;
								return;
							}

							rev._current = id;
							const notif = Notifications.notifications.get(id);
							rev.child.label = `${notif.summary?.substring(0, 18)?.trim()}: ${notif.body?.substring(0, 45)?.trim()}`;
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
					label: "",
				}),
			}),
		],
	});

const NotificationIcon = ({ appEntry, appIcon, image }) => {
	if (image) {
		return Box({
			valign: "start",
			hexpand: false,
			className: "icon img",
			style: `
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

	return Box({
		valign: "start",
		hexpand: false,
		className: "icon",
		style: "min-width: 78px; min-height: 78px;",
		children: [
			Icon({
				icon,
				size: 58,
				halign: "center",
				hexpand: true,
				valign: "center",
				vexpand: true,
			}),
		],
	});
};

const Notification = ({ id, summary, body, actions, urgency, time, ...icon }) =>
	Button({
		className: "surface r20 p10",
		style: "margin: 8px 0;",
		onClicked: () => Notifications.invoke(id, "view"),
		vexpand: false,
		child: Box({
			vertical: true,
			children: [
				Box({
					children: [
						NotificationIcon(icon),
						Box({
							hexpand: true,
							vertical: true,
							children: [
								Box({
									children: [
										Label({
											className: "title",
											xalign: 0,
											justification: "left",
											hexpand: true,
											maxWidthChars: 24,
											ellipsize: 3,
											wrap: true,
											label: summary,
											useMarkup: summary.startsWith("<"),
										}),
										Label({
											className: "time",
											valign: "start",
											label: GLib.DateTime.new_from_unix_local(time).format("%H:%M"),
										}),
										Button({
											className: "close-button",
											valign: "start",
											child: Icon("window-close-symbolic"),
											onClicked: () => Notifications.close(id),
										}),
									],
								}),
								Label({
									className: "description",
									hexpand: true,
									useMarkup: true,
									xalign: 0,
									justification: "left",
									label: body,
									wrap: true,
								}),
							],
						}),
					],
				}),
			],
		}),
	});

export const List = (props) =>
	Box({
		...props,
		vertical: true,
		vexpand: true,
		connections: [
			[
				Notifications,
				(box) => {
					box.children = Array.from(Notifications.notifications.values()).map((n) => Notification(n));

					box.visible = Notifications.notifications.size > 0;
				},
			],
		],
	});

export const Placeholder = (props) =>
	Box({
		vertical: true,
		valign: "center",
		halign: "center",
		...props,
		children: [
			Label({ label: "󰂛", style: "margin-top: 150px;" }),
			Label({ label: "Your inbox is empty", style: "margin-bottom: 150px;" }),
		],
		connections: [[Notifications, (box) => (box.visible = Notifications.notifications.size === 0)]],
	});

export const ClearButton = (props) =>
	Button({
		...props,
		onClicked: Notifications.clear,
		connections: [[Notifications, (button) => (button.sensitive = Notifications.notifications.size > 0)]],
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
								stack.shown = `${Notifications.notifications.size > 0}`;
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
