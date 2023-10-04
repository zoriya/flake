import { ArrowToggle } from "../services/quicksettings.js";
import { Separator } from "../misc.js";

const { App } = ags;
const { Network } = ags.Service;
const { Label, Icon, Box, Stack, Button } = ags.Widget;
const { execAsync } = ags.Utils;

export const SSIDLabel = (props) =>
	Label({
		truncate: "end",
		...props,
		connections: [
			[
				Network,
				(label) => {
					if (Network.primary === "wifi") label.label = Network.wifi?.ssid || "Not Connected";
					else
						label.label =
							Network.wired?.internet === "connected" || Network.wired?.internet === "connection"
								? "Wired"
								: "Not Connected";
				},
			],
		],
	});

export const WifiStrengthLabel = (props) =>
	Label({
		...props,
		connections: [[Network, (label) => (label.label = `${Network.wifi?.strength || -1}`)]],
	});

export const Indicator = () => Stack({
	items: [
		['wifi', Icon({
			connections: [[Network, self => {
				self.icon = Network.wifi?.iconName || '';
			}]],
		})],
		['wired', Icon({
			connections: [[Network, self => {
				self.icon = Network.wired?.iconName || '';
			}]],
		})],
	],
	binds: [['shown', Network, 'primary', p => p || 'wifi']],
});

export const Toggle = (props) =>
	ArrowToggle({
		...props,
		name: "network",
		icon: Indicator(),
		label: SSIDLabel(),
		toggle: Network.toggleWifi,
		expand: () => {
			Network.wifi.enabled = true;
			Network.wifi.scan();
		},
		connections: [
			[
				Network,
				(button) => {
					button.toggleClassName("accent", Network.wifi?.enabled);
				},
			],
		],
	});

const icons = [
	{ value: 80, icon: "network-wireless-signal-excellent-symbolic" },
	{ value: 60, icon: "network-wireless-signal-good-symbolic" },
	{ value: 40, icon: "network-wireless-signal-ok-symbolic" },
	{ value: 20, icon: "network-wireless-signal-weak-symbolic" },
	{ value: 0, icon: "network-wireless-signal-none-symbolic" },
];

export const Selection = (props) =>
	Box({
		...props,
		vertical: true,
		connections: [
			[
				Network,
				(box) => {
					box.children = Network.wifi?.accessPoints
						.map((ap) =>
							Button({
								onClicked: `nmcli device wifi connect ${ap.bssid}`,
								child: Box({
									children: [
										Icon(icons.find(({ value }) => value <= ap.strength).icon),
										Label(ap.ssid),
										ap.active &&
										Icon({
											icon: "object-select-symbolic",
											hexpand: true,
											halign: "end",
										}),
									],
								}),
							})
						)
						.concat([
							Separator(),
							Button({
								onClicked: () => {
									execAsync("nm-connection-editor").catch(print);
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
