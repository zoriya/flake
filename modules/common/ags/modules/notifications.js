// import { FontIcon } from "../misc.js";

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

// const NotificationIcon = ({ appEntry, appIcon, image }) => {
// 	if (image) {
// 		return Widget.Box({
// 			vpack: "start",
// 			hexpand: false,
// 			className: "icon img",
// 			css: `
// 				background-image: url("${image}");
// 				background-size: contain;
// 				background-repeat: no-repeat;
// 				background-position: center;
// 				min-width: 78px;
// 				min-height: 78px;
// 			`,
// 		});
// 	}
//
// 	let icon = "dialog-information-symbolic";
// 	if (lookUpIcon(appIcon)) icon = appIcon;
//
// 	if (lookUpIcon(appEntry)) icon = appEntry;
//
// 	return Widget.Box({
// 		vpack: "start",
// 		hexpand: false,
// 		className: "icon",
// 		css: `
// 			min-width: 78px;
// 			min-height: 78px;
// 		`,
// 		children: [
// 			Widget.Icon({
// 				icon,
// 				size: 58,
// 				hpack: "center",
// 				hexpand: true,
// 				vpack: "center",
// 				vexpand: true,
// 			}),
// 		],
// 	});
// };
//
// export const Notification = (n) =>
// 	Widget.EventBox({
// 		className: `surface r20 p10 notification ${n.urgency}`,
// 		css: "margin: 8px 0;",
// 		onPrimaryClick: () => n.dismiss(),
// 		properties: [["hovered", false]],
// 		onHover: (self) => {
// 			if (self._hovered) return;
//
// 			// if there are action buttons and they are hovered
// 			// EventBox onHoverLost will fire off immediately,
// 			// so to prevent this we delay it
// 			timeout(300, () => (self._hovered = true));
// 		},
// 		onHoverLost: (self) => {
// 			if (!self._hovered) return;
//
// 			self._hovered = false;
// 			n.dismiss();
// 		},
// 		vexpand: false,
// 		child: Widget.Box({
// 			vertical: true,
// 			children: [
// 				Widget.Box({
// 					children: [
// 						NotificationIcon(n),
// 						Widget.Box({
// 							hexpand: true,
// 							vertical: true,
// 							children: [
// 								Widget.Box({
// 									children: [
// 										Widget.Label({
// 											className: "title",
// 											xalign: 0,
// 											justification: "left",
// 											hexpand: true,
// 											maxWidthChars: 24,
// 											truncate: "end",
// 											wrap: true,
// 											label: n.summary,
// 											useMarkup: true,
// 										}),
// 										Widget.Button({
// 											className: "close-button",
// 											vpack: "start",
// 											child: Widget.Icon("window-close-symbolic"),
// 											onClicked: n.close.bind(n),
// 										}),
// 									],
// 								}),
// 								Widget.Label({
// 									className: "description",
// 									hexpand: true,
// 									useMarkup: true,
// 									xalign: 0,
// 									justification: "left",
// 									label: n.body,
// 									wrap: true,
// 								}),
// 							],
// 						}),
// 					],
// 				}),
// 				Widget.Box({
// 					className: "actions",
// 					children: n.actions.map(({ id, label }) =>
// 						Widget.Button({
// 							className: "action-button",
// 							onClicked: () => n.invoke(id),
// 							hexpand: true,
// 							child: Widget.Label(label),
// 						}),
// 					),
// 				}),
// 			],
// 		}),
// 	});
//
// export const List = (props) =>
// 	Box({
// 		...props,
// 		vertical: true,
// 		connections: [
// 			[
// 				Notifications,
// 				(box) => {
// 					box.children = Notifications.notifications.map((n) =>
// 						Notification(n),
// 					);
//
// 					box.visible = Notifications.notifications.length > 0;
// 				},
// 			],
// 		],
// 	});
//
// export const Placeholder = (props) =>
// 	Box({
// 		vertical: true,
// 		vpack: "center",
// 		hpack: "center",
// 		...props,
// 		children: [
// 			Label({ label: "󰂛", css: "margin-top: 150px;" }),
// 			Label({ label: "Your inbox is empty", css: "margin-bottom: 150px;" }),
// 		],
// 		connections: [
// 			[
// 				Notifications,
// 				(box) => (box.visible = Notifications.notifications.length === 0),
// 			],
// 		],
// 	});
//
// export const ClearButton = (props) =>
// 	Button({
// 		...props,
// 		onClicked: () => Notifications.clear(),
// 		connections: [
// 			[
// 				Notifications,
// 				(button) => (button.sensitive = Notifications.notifications.length > 0),
// 			],
// 		],
// 		child: Box({
// 			children: [
// 				Label("Clear "),
// 				Stack({
// 					items: [
// 						["true", Icon("user-trash-full-symbolic")],
// 						["false", Icon("user-trash-symbolic")],
// 					],
// 					connections: [
// 						[
// 							Notifications,
// 							(stack) => {
// 								stack.shown = `${Notifications.notifications.length > 0}`;
// 							},
// 						],
// 					],
// 				}),
// 			],
// 		}),
// 	});
//
// export const DNDToggle = (props) =>
// 	Button({
// 		...props,
// 		onClicked: () => {
// 			Notifications.dnd = !Notifications.dnd;
// 		},
// 		child: DNDIndicator(),
// 		connections: [
// 			[
// 				Notifications,
// 				(button) => {
// 					button.toggleClassName("on", Notifications.dnd);
// 				},
// 			],
// 		],
// 	});
