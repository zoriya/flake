import PopupWindow from "../misc/popup.js";
import * as notifications from "../modules/notifications.js";

const notificationsService = await Service.import("notifications");

const Header = () =>
	Widget.Box({
		hexpand: true,
		css: "margin-bottom: 40px",
		children: [
			notifications.DNDToggle({
				className: "surface p10 round",
				css: "min-width: 24px; min-height: 24px;",
				hpack: "start",
				hexpand: true,
			}),
			notifications.ClearButton({
				className: "surface p10 r100",
				hpack: "end",
				hexpand: true,
			}),
		],
	});

export const Notifications = () =>
	PopupWindow({
		name: "notifications",
		exclusivity: "exclusive",
		transition: "slide_down",
		layout: "top-center",
		child: Widget.Box({
			vertical: true,
			className: "bgcont qs-container",
			css: "min-width: 600px",
			children:
				/** @type {any} */
				(
					notificationsService
						.bind("notifications")
						.as((x) =>
							x.length > 0
								? [Header(), notifications.List({})]
								: [Header(), notifications.Placeholder({})],
						)
				),
		}),
	});
