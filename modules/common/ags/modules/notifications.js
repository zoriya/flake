const notifications = await Service.import("notifications");
notifications.popupTimeout = 2000; //in seconds
notifications.forceTimeout = true; //force all notifications to timeout

/** @param {import("types/widgets/icon").IconProps} props */
export const DNDIndicator = (props) =>
	Widget.Icon({
		visible: notifications.bind("dnd"),
		icon: "notifications-disabled-symbolic",
		...props,
	});

/** @param {import("types/widgets/button").ButtonProps} props */
export const DNDToggle = (props) =>
	Widget.Button({
		onClicked: () => {
			notifications.dnd = !notifications.dnd;
		},
		child: Widget.Icon({
			icon: notifications
				.bind("dnd")
				.as((x) =>
					x
						? "preferences-system-notifications-symbolic"
						: "notifications-disabled-symbolic",
				),
		}),
		className: notifications.bind("dnd").as((x) => (x ? "on" : "")),
		...props,
	});

/** @param {import("types/widgets/box").BoxProps} props */
export const Indicator = ({ ...props }) =>
	Widget.Box({
		visible: notifications.bind("notifications").as((x) => x.length > 0),
		children: [
			Widget.Icon({ icon: "preferences-system-notifications-symbolic" }),
			Widget.Revealer({
				transition: "slide_right",
				revealChild: notifications.bind("popups").as((x) => x.length > 0),
				child: Widget.Label({
					use_markup: true,
					truncate: "end",
					wrap: false,
					label: notifications.bind("popups").as((x) => {
						const notif = x[x.length - 1];
						// Keep the text of the old notif for the fade out animation.
						if (!notif) return old_notif;
						const summary = notif.summary.substring(0, 18).trim();
						const body = notif.body.substring(0, 45).trim();
						old_notif = `${summary}: ${body}`.replaceAll("\n", " ");
						return old_notif;
					}),
				}),
			}),
		],
		...props,
	});
let old_notif = "";

/** @param {import("types/service/notifications").Notification} param */
const NotificationIcon = ({ app_entry, app_icon, image }) => {
	if (image) {
		return Widget.Box({
			vpack: "start",
			hexpand: false,
			className: "r20",
			css: `
				background-image: url("${image}");
				background-size: cover;
				background-repeat: no-repeat;
				background-position: center;
				min-width: 78px;
				min-height: 78px;
				margin-right: 12px;
			`,
		});
	}

	let icon = "dialog-information-symbolic";
	if (Utils.lookUpIcon(app_icon)) icon = app_icon;
	if (Utils.lookUpIcon(app_entry || "")) icon = app_entry || "";

	return Widget.Box({
		vpack: "start",
		hexpand: false,
		className: "r20",
		css: `
			min-width: 78px;
			min-height: 78px;
			margin-right: 12px;
		`,
		child: Widget.Icon({
			icon,
			size: 58,
			hpack: "center",
			hexpand: true,
			vpack: "center",
			vexpand: true,
		}),
	});
};

import GLib from "gi://GLib";

/** @param {number} time */
const time = (time, format = "%H:%M") =>
	GLib.DateTime.new_from_unix_local(time).format(format);

/** @param {import("types/service/notifications").Notification} notification */
export const Notification = (notification) => {
	const content = Widget.Box({
		children: [
			NotificationIcon(notification),
			Widget.Box({
				hexpand: true,
				vertical: true,
				children: [
					Widget.Box({
						children: [
							Widget.Label({
								css: `
									font-size: 1.1em;
									margin-right: 12pt;
								`,
								xalign: 0,
								justification: "left",
								hexpand: true,
								max_width_chars: 24,
								truncate: "end",
								wrap: true,
								label: notification.summary.trim(),
								use_markup: true,
							}),
							Widget.Label({
								vpack: "start",
								label: time(notification.time),
							}),
							Widget.Button({
								css: `
									margin-left: 6pt;
									min-width: 1.2em;
									min-height: 1.2em;
								`,
								vpack: "start",
								child: Widget.Icon("window-close-symbolic"),
								on_clicked: notification.close,
							}),
						],
					}),
					Widget.Label({
						css: "font-size: .9em;",
						hexpand: true,
						use_markup: true,
						xalign: 0,
						justification: "left",
						label: notification.body.trim(),
						max_width_chars: 24,
						wrap: true,
					}),
				],
			}),
		],
	});

	const actionsbox =
		notification.actions.length > 0
			? Widget.Revealer({
					transition: "slide_down",
					child: Widget.EventBox({
						child: Widget.Box({
							class_name: "actions horizontal",
							children: notification.actions.map((action) =>
								Widget.Button({
									className: "button",
									on_clicked: () => notification.invoke(action.id),
									hexpand: true,
									child: Widget.Label(action.label),
								}),
							),
						}),
					}),
				})
			: null;

	const eventbox = Widget.EventBox({
		vexpand: false,
		on_primary_click: notification.dismiss,
		on_hover() {
			if (actionsbox) actionsbox.reveal_child = true;
		},
		on_hover_lost() {
			if (actionsbox) actionsbox.reveal_child = true;

			notification.dismiss();
		},
		child: Widget.Box({
			vertical: true,
			children: actionsbox ? [content, actionsbox] : [content],
		}),
	});

	return Widget.Box({
		className: "surface r20 p10",
		css: "margin: 8px 0;",
		child: eventbox,
	});
};

/** @param {import("types/widgets/scrollable").ScrollableProps} props */
export const List = (props) =>
	Widget.Scrollable({
		vscroll: "automatic",
		hscroll: "never",
		css: "min-height: 500px;",
		child: Widget.Box({
			vertical: true,
			children: notifications
				.bind("notifications")
				.as((x) => x.map(Notification)),
		}),
		...props,
	});

/** @param {import("types/widgets/box").BoxProps} props */
export const Placeholder = (props) =>
	Widget.Box({
		vertical: true,
		vpack: "center",
		hpack: "center",
		children: [
			Widget.Icon({
				icon: "notifications-disabled-symbolic",
				size: 75,
				css: "margin: 50px 0",
			}),
			Widget.Label({
				label: "Your inbox is empty",
				css: "margin-bottom: 150px;",
			}),
		],
		...props,
	});

/** @param {import("types/widgets/button").ButtonProps} props */
export const ClearButton = (props) =>
	Widget.Button({
		className: "button surface",
		onClicked: () => notifications.clear(),
		sensitive: notifications.bind("notifications").as((x) => x.length > 0),
		child: Widget.Box({
			children: [
				Widget.Label({ label: "Clear " }),
				Widget.Icon({
					icon: notifications
						.bind("notifications")
						.as((x) =>
							x.length > 0 ? "user-trash-full-symbolic" : "user-trash-symbolic",
						),
				}),
			],
		}),
		...props,
	});
