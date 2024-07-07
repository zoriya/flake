// import * as audio from "../modules/audio.js";
// import * as brightness from "../modules/brightness.js";
// import * as network from "../modules/network.js";
// import * as bluetooth from "../modules/bluetooth.js";
// import * as darkmode from "../modules/darkmode.js";
// import * as nightmode from "../modules/nightmode.js";
import * as mpris from "../modules/mpris.js";
import PopupWindow from "../misc/popup.js";
// import { opened, Arrow } from "../services/quicksettings.js";
// import { FontIcon, PopupOverlay } from "../misc.js";

const mprisService = await Service.import("mpris");

// const Submenu = ({ menuName, icon, title, contentType }) =>
// 	Revealer({
// 		transition: "slide_down",
// 		connections: [
// 			[opened, (r) => (r.reveal_child = menuName === opened.value)],
// 		],
// 		child: Box({
// 			className: "qs-submenu surface",
// 			vertical: true,
// 			children: [
// 				Box({
// 					className: "qs-sub-title accent",
// 					children: [icon, Label({ label: title, className: "bold f16" })],
// 				}),
// 				contentType({ className: "qs-sub-content", hexpand: true }),
// 			],
// 		}),
// 	});
//
// const VolumeBox = () =>
// 	Box({
// 		vertical: true,
// 		children: [
// 			Box({
// 				className: "qs-slider",
// 				children: [
// 					Button({
// 						child: audio.SpeakerIndicator(),
// 						onClicked: () =>
// 							execAsync("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
// 					}),
// 					audio.SpeakerSlider({ hexpand: true }),
// 					audio.SpeakerPercentLabel(),
// 					Arrow({ name: "stream-selector" }),
// 				],
// 			}),
// 			Submenu({
// 				menuName: "stream-selector",
// 				icon: Icon("audio-volume-medium-symbolic"),
// 				title: "Audio Stream",
// 				contentType: audio.StreamSelector,
// 			}),
// 		],
// 	});
//
// const BrightnessBox = () =>
// 	Box({
// 		className: "qs-slider",
// 		children: [
// 			brightness.Indicator(),
// 			brightness.BrightnessSlider({ hexpand: true }),
// 			brightness.PercentLabel(),
// 			Box({ className: "qs-icon", css: "margin-right: 18px;" }),
// 		],
// 	});

export const Quicksettings = () =>
	PopupWindow({
		name: "quicksettings",
		exclusivity: "exclusive",
		transition: "slide_down",
		layout: "top-right",
		child: Widget.Box({
			vertical: true,
			className: "bgcont qs-container",
			children:
				mprisService
					.bind("players")
					.as((x) => x.map((player) => mpris.MprisPlayer({ player }))),
			// children: [
			// 	VolumeBox(),
			// 	BrightnessBox(),
			// 	Widget.Box({
			// 		children: [network.Toggle({}), bluetooth.Toggle({})],
			// 	}),
			// 	Submenu({
			// 		menuName: "network",
			// 		icon: "network-wireless-symbolic",
			// 		title: "Network",
			// 		contentType: network.Selection,
			// 	}),
			// 	Submenu({
			// 		menuName: "bluetooth",
			// 		icon: "bluetooth-symbolic",
			// 		title: "Bluetooth",
			// 		contentType: bluetooth.Devices,
			// 	}),
			// 	Box({
			// 		children: [darkmode.DarkToggle(), nightmode.NightToggle()],
			// 	}),
			// 	Box({
			// 		children: [audio.AppMixerToggle(), audio.MuteToggle()],
			// 	}),
			// 	Submenu({
			// 		menuName: "app-mixer",
			// 		icon: FontIcon({ icon: "" }),
			// 		title: "App Mixer",
			// 		contentType: audio.AppMixer,
			// 	}),
			// ],
		}),
	});
