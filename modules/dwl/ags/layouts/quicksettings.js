import * as audio from "../modules/audio.js";
import * as brightness from "../modules/brightness.js";
import * as network from "../modules/network.js";
import * as bluetooth from "../modules/bluetooth.js";
import * as darkmode from "../modules/darkmode.js";
import * as nightmode from "../modules/nightmode.js";
import { QSMenu, Arrow } from "../services/quicksettings.js";

const { Window, Revealer, Icon, Box, Button, Label } = ags.Widget;

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

const BrightnessBox = () =>
	Box({
		className: "qs-slider",
		children: [
			brightness.Indicator(),
			brightness.BrightnessSlider({ hexpand: true }),
			brightness.PercentLabel(),
			Box({ className: "qs-icon", style: "margin-right: 18px;" }),
		],
	});

export const Quicksettings = () =>
	Window({
		name: "quicksettings",
		exclusive: true,
		popup: true,
		focusable: true,
		anchor: "top right",
		child: Box({
			vertical: true,
			className: "transparent qs-container",
			hexpand: false,
			children: [
				VolumeBox(),
				BrightnessBox(),
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
				Box({
					children: [darkmode.DarkToggle(), nightmode.NightToggle()]
				}),
				Box({
					children: [audio.AppMixer(), audio.MuteToggle()],
				}),
				// Media player
			],
		}),
	});
