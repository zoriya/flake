// import { Spinner, Separator } from "../misc.js";
// import { ArrowToggle } from "../services/quicksettings.js";

const bluetooth = await Service.import("bluetooth");

const connected = Utils.merge(
	[bluetooth.bind("enabled"), bluetooth.bind("connected_devices")],
	(enabled, devices) => enabled && devices.length > 0,
);

/** @param {{hideIfDisabled?: boolean} & import("types/widgets/icon").IconProps} props */
export const Indicator = ({ hideIfDisabled, ...props } = {}) =>
	Widget.Icon({
		icon: connected.as(
			(x) => `bluetooth-${x ? "active" : "disabled"}-symbolic`,
		),
		visible: connected.as(x => x || !hideIfDisabled),
		...props,
	});

// export const Toggle = (props) =>
// 	ArrowToggle({
// 		...props,
// 		name: "bluetooth",
// 		icon: Indicator(),
// 		label: ConnectedLabel(),
// 		toggle: () => (Bluetooth.enabled = !Bluetooth.enabled),
// 		expand: () => (Bluetooth.enabled = true),
// 		connections: [[Bluetooth, (button) => button.toggleClassName("accent", Bluetooth.enabled)]],
// 	});
//
// export const ConnectedLabel = (props) =>
// 	Label({
// 		truncate: "end",
// 		...props,
// 		connections: [
// 			[
// 				Bluetooth,
// 				(label) => {
// 					if (!Bluetooth.enabled) return (label.label = "Disabled");
//
// 					if (Bluetooth.connectedDevices.length === 0) return (label.label = "Not Connected");
//
// 					if (Bluetooth.connectedDevices.length === 1)
// 						return (label.label = Bluetooth.connectedDevices[0].alias);
//
// 					label.label = `${Bluetooth.connectedDevices.length} Connected`;
// 				},
// 			],
// 		],
// 	});
//
// export const Devices = (props) =>
// 	Box({
// 		...props,
// 		vertical: true,
// 		connections: [
// 			[
// 				Bluetooth,
// 				(box) => {
// 					box.children = Bluetooth.devices
// 						.map((device) =>
// 							Button({
// 								onClicked: () => device.setConnection(!device.connected),
// 								hexpand: false,
// 								child: Box({
// 									children: [
// 										Icon(device.iconName + "-symbolic"),
// 										Label(device.name),
// 										Box({ hexpand: true }),
// 										device._connecting ? Spinner() : Label(device.connected ? "Disconnect" : "Connect"),
// 									],
// 								}),
// 							})
// 						)
// 						.concat([
// 							Separator(),
// 							Button({
// 								onClicked: () => {
// 									execAsync("blueberry").catch(print);
// 									App.closeWindow("quicksettings");
// 								},
// 								child: Label({
// 									label: "Settings",
// 									xalign: 0,
// 								}),
// 							}),
// 						]);
// 				},
// 			],
// 		],
// 	});
