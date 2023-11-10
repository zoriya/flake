import { Spinner, Separator } from "../misc.js";
import { ArrowToggle } from "../services/quicksettings.js";

import App from 'resource:///com/github/Aylur/ags/app.js'
import Bluetooth from 'resource:///com/github/Aylur/ags/service/bluetooth.js'
import { Icon, Label, Box, Button, Stack } from 'resource:///com/github/Aylur/ags/widget.js';
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

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
					stack.shown = `${Bluetooth.enabled && Bluetooth.connectedDevices.length > 0}`;
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

					if (Bluetooth.connectedDevices.length === 0) return (label.label = "Not Connected");

					if (Bluetooth.connectedDevices.length === 1)
						return (label.label = Bluetooth.connectedDevices[0].alias);

					label.label = `${Bluetooth.connectedDevices.length} Connected`;
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
					box.children = Bluetooth.devices
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
