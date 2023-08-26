import * as audio from "../modules/audio.js";
import * as brightness from "../modules/brightness.js";
import * as network from "../modules/network.js";
import * as bluetooth from "../modules/bluetooth.js";
import * as darkmode from "../modules/darkmode.js";
import * as nightmode from "../modules/nightmode.js";
import * as mpris from "../modules/mpris.js";
import { QSMenu, Arrow } from "../services/quicksettings.js";
import { FontIcon } from "../misc.js";

const { App } = ags;
const { Window, Revealer, Icon, Box, Button, Label, EventBox } = ags.Widget;

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

const PopupCloser = (windowName) =>
	EventBox({
		hexpand: true,
		vexpand: true,
		connections: [["button-press-event", () => App.toggleWindow(windowName)]],
	});

const PopupRevealer = (windowName, transition, child) =>
	Box({
		style: "padding: 1px;",
		children: [
			Revealer({
				transition,
				child,
				transitionDuration: 350,
				connections: [
					[
						App,
						(revealer, name, visible) => {
							if (name === windowName) revealer.reveal_child = visible;
						},
					],
				],
			}),
		],
	});

const PopupOverlay = (windowName, child) =>
	Box({
		children: [
			PopupCloser(windowName),
			Box({
				hexpand: false,
				vertical: true,
				children: [PopupRevealer(windowName, "slide_down", child), PopupCloser(windowName)],
			}),
		],
	});

export const Quicksettings = () =>
	Window({
		name: "quicksettings",
		popup: true,
		// focusable: true,
		anchor: ["top", "right", "bottom", "left"],
		child: PopupOverlay(
			"quicksettings",
			Box({
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
