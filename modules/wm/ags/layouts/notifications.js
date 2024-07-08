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
				css: `
					min-width: 24px;
					min-height: 24px;
				`,
				hpack: "start",
				hexpand: true,
			}),
			notifications.ClearButton({
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
		duration: 300,
		child: Widget.Box({
			vertical: true,
			className: "bgcont",
			css: `
				min-width: 600px;
				margin: 10px;
				padding: 12px;
				border-radius: 20px;
			`,
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
