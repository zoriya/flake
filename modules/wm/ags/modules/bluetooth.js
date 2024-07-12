import { ArrowToggleButton, Menu, SettingsButton } from "../misc/menu.js";

const bluetooth = await Service.import("bluetooth");

const connected = Utils.merge(
	[bluetooth.bind("enabled"), bluetooth.bind("connected_devices")],
	(enabled, devices) => enabled && devices.length > 0,
);

/** @param {{hideIfDisabled?: boolean} & import("../types/widgets/icon.js").IconProps} props */
export const Indicator = ({ hideIfDisabled = false, ...props } = {}) =>
	Widget.Icon({
		icon: connected.as(
			(x) => `bluetooth-${x ? "active" : "disabled"}-symbolic`,
		),
		visible: connected.as((x) => x || !hideIfDisabled),
		...props,
	});

/** @param {import("../types/widgets/label.js").LabelProps} props */
export const ConnectedLabel = (props) =>
	Widget.Label(props).hook(bluetooth, (self) => {
		if (!bluetooth.enabled) self.label = "Disabled";

		if (bluetooth.connected_devices.length === 0) self.label = "Disconnected";
		else if (bluetooth.connected_devices.length === 1)
			self.label = bluetooth.connected_devices[0].alias;
		else self.label = `${bluetooth.connected_devices.length} Connected`;
	});

/** @param {Partial<import("../misc/menu.js").ArrowToggleButtonProps>} props */
export const Toggle = (props) =>
	ArrowToggleButton({
		name: "bluetooth",
		icon: Indicator({ className: "qs-icon" }),
		label: ConnectedLabel({
			max_width_chars: 20,
		}),
		activate: () => {
			bluetooth.enabled = true;
		},
		deactivate: () => {
			bluetooth.enabled = false;
		},
		connection: [bluetooth, () => bluetooth.enabled],
		...props,
	});

/** @param {Partial<import("../misc/menu.js").MenuProps>} props */
export const Selection = (props) =>
	Menu({
		name: "bluetooth",
		icon: Indicator({}),
		title: "Bluetooth",
		content: [
			Widget.Box({
				vertical: true,
				className: "qs-sub-sub-content",
				children: bluetooth.bind("devices").as((x) => x.map(DeviceItem)),
			}),
			Widget.Separator({ className: "accent" }),
			SettingsButton({ command: "blueberry" }),
		],
		...props,
	});

/** @param {import("../types/service/bluetooth.js").BluetoothDevice} device */
const DeviceItem = (device) =>
	Widget.Box({
		children: [
			Widget.Icon(`${device.icon_name}-symbolic`),
			Widget.Label(device.name),
			Widget.Box({ hexpand: true }),
			Widget.Label({
				label: `${device.battery_percentage}%`,
				css: "padding-right: 24px;",
				visible: device.bind("battery_percentage").as((x) => x > 0),
			}),
			Widget.Spinner({
				active: device.bind("connecting"),
				visible: device.bind("connecting"),
			}),
			Widget.Switch({
				active: device.bind("connected"),
				visible: device.bind("connecting").as((p) => !p),
				setup: (self) =>
					// TODO: If connecting to the device failed, reset back the switch to `active: false`.
					self.connect("state_set", () => {
						device.setConnection(self.active);
						return true;
					}),
			}),
		],
	});
