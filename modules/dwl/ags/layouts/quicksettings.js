import * as audio from "../modules/audio.js";
import * as brightness from "../modules/brightness.js";
import * as network from "../modules/network.js";
import * as bluetooth from "../modules/bluetooth.js";
import * as darkmode from "../modules/darkmode.js";
import * as nightmode from "../modules/nightmode.js";
import * as mpris from "../modules/mpris.js";
import { opened, Arrow } from "../services/quicksettings.js";
import { FontIcon, PopupOverlay } from "../misc.js";

import { Window, Revealer, Icon, Box, Button, Label } from 'resource:///com/github/Aylur/ags/widget.js'
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js'

const Submenu = ({ menuName, icon, title, contentType }) =>
	Revealer({
		transition: "slide_down",
		connections: [[opened, (r) => (r.reveal_child = menuName === opened.value)]],
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
						onClicked: () => execAsync("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
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
			Box({ className: "qs-icon", css: "margin-right: 18px;" }),
		],
	});


export const Quicksettings = () =>
	Window({
		name: "quicksettings",
		popup: true,
		visible: false,
		anchor: ["top", "right", "bottom", "left"],
		child: PopupOverlay(
			"quicksettings",
			"top right",
			Box({
				vertical: true,
				className: "bgcont qs-container",
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
						children: [darkmode.DarkToggle(), nightmode.NightToggle()],
					}),
					Box({
						children: [audio.AppMixerToggle(), audio.MuteToggle()],
					}),
					Submenu({
						menuName: "app-mixer",
						icon: FontIcon({ icon: "" }),
						title: "App Mixer",
						contentType: audio.AppMixer,
					}),
					mpris.MprisPlayer(),
				],
			})
		),
	});
