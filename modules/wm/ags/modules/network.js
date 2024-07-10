import { ArrowToggleButton, Menu, SettingsButton } from "../misc/menu.js";

const network = await Service.import("network");

/** @param {import("../types/widgets/icon.js").IconProps} props*/
export const Indicator = (props) =>
	Widget.Icon(props).hook(network, (self) => {
		self.icon =
			network[network.primary || "wifi"].icon_name ??
			"network-wireless-offline-symbolic";
	});

/** @param {import("../types/widgets/label.js").LabelProps} props */
export const SSIDLabel = (props) =>
	Widget.Label({
		truncate: "end",
		...props,
	}).hook(network, (self) => {
		if (network.primary === "wifi")
			self.label = network.wifi.ssid || "Not Connected";
		else
			self.label =
				network.wired.internet !== "disconnected" ? "Wired" : "Not Connected";
	});

/** @param {Partial<import("../misc/menu.js").ArrowToggleButtonProps>} props */
export const Toggle = (props) =>
	ArrowToggleButton({
		name: "network",
		icon: Indicator({ className: "qs-icon" }),
		label: SSIDLabel({
			max_width_chars: 20,
		}),
		activate: () => {
			network.wifi.enabled = true;
			network.wifi.scan();
		},
		deactivate: () => {
			network.wifi.enabled = false;
		},
		connection: [network.wifi, () => network.wifi.enabled],
		...props,
	});

/** @param {Partial<import("../misc/menu.js").MenuProps>} props */
export const Selection = (props) =>
	Menu({
		name: "network",
		icon: Indicator({}),
		title: "Network Selection",
		content: [
			Wired(),
			Widget.Box({
				vertical: true,
				className: "qs-sub-sub-content",
				children: network.wifi.bind("access_points").as((x) =>
					x
						.sort((a, b) => b.strength - a.strength)
						.reduce((acc, x) => {
							if (!acc.find((y) => y.ssid === x.ssid)) acc.push(x);
							return acc;
						}, [])
						.slice(0, 10)
						.map(WifiItem),
				),
			}),
			Widget.Separator({ className: "accent" }),
			SettingsButton({ type: "wifi" }),
		],
		...props,
	});

const Wired = () =>
	Widget.Button({
		// onClicked:
		// visible: network.wired.bind("state").as(x => (console.log(x), true)),
		child: Widget.Box({
			children: [
				Widget.Icon({ icon: network.wired.bind("icon_name") }),
				Widget.Label("Wired"),
				Widget.Icon({
					icon: "object-select-symbolic",
					hexpand: true,
					hpack: "end",
					visible: network.bind("primary").as((x) => x === "wired"),
				}),
			],
		}),
	});

/** @param {import("../types/service/network.js").Wifi["access_points"][0]} wifi */
const WifiItem = (wifi) =>
	Widget.Button({
		onClicked: () => Utils.execAsync(`nmcli device wifi connect ${wifi.bssid}`),
		child: Widget.Box({
			children: [
				Widget.Icon(wifi.iconName),
				Widget.Label({
					truncate: "end",
					max_width_chars: 28,
					label: wifi.ssid || "",
				}),
				Widget.Icon({
					icon: "object-select-symbolic",
					hexpand: true,
					hpack: "end",
					setup: (self) =>
						Utils.idle(() => {
							if (!self.is_destroyed) self.visible = wifi.active;
						}),
				}),
			],
		}),
	});
