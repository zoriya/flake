import { Spinner, Separator } from "../misc.js";
import { ArrowToggle } from "../services/quicksettings.js";

const { App } = ags;
const { Bluetooth } = ags.Service;
const { Icon, Label, Box, Button, Stack } = ags.Widget;
const { execAsync } = ags.Utils;

export const Indicator = ({
	enabled = Icon({ icon: "bluetooth-active-symbolic", className: "enabled" }),
	disabled = Icon({
		icon: "bluetooth-disabled-symbolic",
		className: "disabled",
	}),
	...props
} = {}) =>
	Stack({
		...props,
		items: [
			["true", enabled],
			["false", disabled],
		],
		connections: [
			[
				Bluetooth,
				(stack) => {
					stack.shown = `${Bluetooth.enabled && Bluetooth.connectedDevices.size > 0}`;
				},
			],
		],
	});

export const Toggle = (props) =>
	ArrowToggle({
		...props,
		name: "bluetooth",
		icon: Indicator(),
		label: ConnectedLabel(),
		toggle: () => (Bluetooth.enabled = !Bluetooth.enabled),
		expand: () => (Bluetooth.enabled = true),
		connections: [[Bluetooth, (button) => button.toggleClassName("accent", Bluetooth.enabled)]],
	});

export const ConnectedLabel = (props) =>
	Label({
		truncate: "end",
		...props,
		connections: [
			[
				Bluetooth,
				(label) => {
					if (!Bluetooth.enabled) return (label.label = "Disabled");

					if (Bluetooth.connectedDevices.size === 0) return (label.label = "Not Connected");

					if (Bluetooth.connectedDevices.size === 1)
						return (label.label = Bluetooth.connectedDevices.entries().next().value[1].alias);

					label.label = `${Bluetooth.connectedDevices.size} Connected`;
				},
			],
		],
	});

export const Devices = (props) =>
	Box({
		...props,
		vertical: true,
		connections: [
			[
				Bluetooth,
				(box) => {
					box.children = Array.from(Bluetooth.devices.values())
						.map((device) =>
							Button({
								onClicked: () => device.setConnection(!device.connected),
								hexpand: false,
								child: Box({
									children: [
										Icon(device.iconName + "-symbolic"),
										Label(device.name),
										Box({ hexpand: true }),
										device._connecting ? Spinner() : Label(device.connected ? "Disconnect" : "Connect"),
									],
								}),
							})
						)
						.concat([
							Separator(),
							Button({
								onClicked: () => {
									execAsync("blueberry").catch(print);
									App.closeWindow("quicksettings");
								},
								child: Label({
									label: "Settings",
									xalign: 0,
								}),
							}),
						]);
				},
			],
		],
	});