import { ArrowToggleButton, Menu } from "../misc/menu.js";

const systemtray = await Service.import("systemtray");

/** @param {Partial<import("../misc/menu.js").ArrowToggleButtonProps>} props */
export const Toggle = (props) =>
	ArrowToggleButton({
		name: "systray",
		icon: Widget.Icon({ icon: "open-menu-symbolic", className: "qs-icon" }),
		label: Widget.Label("Systray"),
		activate: () => {},
		deactivate: () => {},
		connection: [systemtray, () => systemtray.items.length > 0],
		...props,
	});

/** @param {Partial<import("../misc/menu.js").MenuProps>} props */
export const Selection = (props) =>
	Menu({
		name: "systray",
		icon: Widget.Icon("open-menu-symbolic"),
		title: "Systray",
		content: [
			Widget.Box({
				vertical: true,
				className: "qs-sub-sub-content",
				children: systemtray.bind("items").as((i) => i.map(SysTrayItem)),
			}),
		],
		...props,
	});

/** @param {import('../types/service/systemtray.js').TrayItem} item */
const SysTrayItem = (item) =>
	Widget.Button({
		css: "margin: 12px;",
		child: Widget.Box({
			children: [
				Widget.Icon({ icon: item.bind("icon") }),
				Widget.Label({
					truncate: "end",
					maxWidthChars: 28,
				}).hook(item, (self) => {
					self.label = item.title || item.tooltip_markup;
				}),
			],
		}),
		tooltipMarkup: item.bind("tooltip_markup"),
		onPrimaryClick: (_, event) => item.activate(event),
		onSecondaryClick: (_, event) => item.openMenu(event),
	});
