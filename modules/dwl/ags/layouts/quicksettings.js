import * as audio from "../modules/audio.js";
import * as network from "../modules/network.js";
import * as bluetooth from "../modules/bluetooth.js";
import { QSMenu, Arrow } from "../services/quicksettings.js";
import { Separator } from "../misc.js";

const { Window, Revealer, Icon, CenterBox, Box, Button, Label } = ags.Widget;

const Submenu = ({ menuName, icon, title, contentType }) =>
	Revealer({
		transition: "slide_down",
		connections: [[QSMenu, (r) => (r.reveal_child = menuName === QSMenu.opened)]],
		child: Box({
			className: "qs-submenu surface",
			vertical: true,
			children: [
				Box({ className: "qs-sub-title accent", children: [icon, Label({ label: title, className: "bold f16" })] }),
				contentType({ className: "qs-sub-content", hexpand: true }),
			],
		}),
	});

const VolumeBox = () =>
	Box({
		vertical: true,
		children: [
			Box({
				className: "qs-slider",
				children: [
					Button({
						child: audio.SpeakerIndicator(),
						onClicked: "pactl set-sink-mute @DEFAULT_SINK@ toggle",
					}),
					audio.SpeakerSlider({ hexpand: true }),
					audio.SpeakerPercentLabel(),
					Arrow({ name: "stream-selector" }),
				],
			}),
			Submenu({
				menuName: "stream-selector",
				icon: Icon("audio-volume-medium-symbolic"),
				title: "Audio Stream",
				contentType: audio.StreamSelector,
			}),
		],
	});

export const Quicksettings = () =>
	Window({
		name: "quicksettings",
		exclusive: true,
		popup: true,
		anchor: "top right",
		child: Box({
			vertical: true,
			className: "transparent qs-container",
			hexpand: false,
			children: [
				VolumeBox(),
				Box({
					children: [network.Toggle({}), bluetooth.Toggle({})],
				}),
				Submenu({
					menuName: "network",
					icon: Icon("network-wireless-symbolic"),
					title: "Network",
					contentType: network.Selection,
				}),
				Submenu({
					menuName: "bluetooth",
					icon: Icon("bluetooth-symbolic"),
					title: "Bluetooth",
					contentType: bluetooth.Devices,
				}),
				// Box({
				// 	children: [NightMode, AppMixer ],
				// }),
			],
		}),
	});
