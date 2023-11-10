import { PopupOverlay } from "../misc.js";
import * as notifications from "../modules/notifications.js";

import { Window, Box }  from 'resource:///com/github/Aylur/ags/widget.js'

export const Notifications = () =>
	Window({
		name: "notifications",
		popup: true,
		anchor: ["top", "right", "bottom", "left"],
		child: PopupOverlay(
			"notifications",
			"top",
			Box({
				vertical: true,
				className: "bgcont qs-container",
				children: [
					Box({
						hexpand: true,
						style: "margin-bottom: 10px;",
						children: [
							notifications.DNDToggle({
								className: "surface p10 round",
								style: "min-width: 24px; min-height: 24px;",
								halign: "start",
								hexpand: true,
							}),
							notifications.ClearButton({ className: "surface p10 r100", halign: "end", hexpand: true }),
						],
					}),
					notifications.List(),
					notifications.Placeholder(),
				],
			})
		),
	});
