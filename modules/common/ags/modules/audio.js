import { icon } from "../misc/utils.js";
import { Arrow, Menu } from "../misc/menu.js";

const audio = await Service.import("audio");

const volumeIcons = /** @type {const} */ ([
	[101, "overamplified"],
	[67, "high"],
	[34, "medium"],
	[1, "low"],
	[0, "muted"],
]);

/** @param {{type?: "speaker" | "microphone"} & import("types/widgets/icon").IconProps} props */
export const VolumeIndicator = ({ type = "speaker", ...props }) =>
	Widget.Icon(props).hook(audio, (self) => {
		if (audio[type].is_muted) {
			self.icon = "audio-volume-muted-symbolic";
			self.tooltip_text = "Muted";
			return;
		}
		const vol = audio[type].volume * 100;
		const icon = volumeIcons.find(([threshold]) => threshold <= vol)?.[1];
		self.icon = `audio-volume-${icon}-symbolic`;
		self.tooltip_text = `Volume: ${Math.floor(vol)}%`;
	});

/** @param {import("types/widgets/icon").IconProps} props */
export const MicrophoneIndicator = (props) =>
	Widget.Icon(props).hook(audio, (self) => {
		self.visible = audio.microphone.is_muted || audio.recorders.length > 0;
		if (audio.microphone.is_muted) self.icon = "microphone-disabled-symbolic";
		else if (audio.recorders.length > 0)
			self.icon = "microphone-sensitivity-high-symbolic";
	});

/** @param {{type?: "speaker" | "microphone"} & import("types/widgets/slider").SliderProps} props */
const VolumeSlider = ({ type = "speaker", ...props }) =>
	Widget.Slider({
		hexpand: true,
		draw_value: false,
		onChange: ({ value, dragging }) => {
			if (dragging) {
				audio[type].volume = value;
				audio[type].is_muted = false;
			}
		},
		value: audio[type].bind("volume"),
		css: audio[type].bind("is_muted").as((x) => `opacity: ${x ? 0.7 : 1}`),
		...props,
	});

/** @param {{type?: "speaker" | "microphone"} & import("types/widgets/box").BoxProps} props */
export const Volume = ({ type = "speaker", ...props }) =>
	Widget.Box({
		className: "qs-slider",
		children: [
			Widget.Button({
				onClicked: () => {
					audio[type].is_muted = !audio[type].is_muted;
				},
				child: VolumeIndicator({ type }),
			}),
			VolumeSlider({ type }),
			Widget.Label({
				label: audio[type].bind("volume").as(
					(vol) =>
						`${Math.floor(vol * 100)
							.toString()
							.padStart(3)}%`,
				),
			}),
			Widget.Box({
				vpack: "center",
				child: Arrow({ name: "sink-selector" }),
			}),
			Widget.Box({
				vpack: "center",
				child: Arrow({ name: "app-mixer" }),
				visible: audio.bind("apps").as((a) => a.length > 0),
			}),
		],
		...props,
	});

// export const MuteToggle = (props) =>
// 	Button({
// 		...props,
// 		classame: "qs-button surface",
// 		onClicked: () => execAsync("pactl set-source-mute @DEFAULT_SOURCE@ toggle"),
// 		child: Box({
// 			children: [
// 				MicrophoneMuteIndicator({ classame: "qs-icon" }),
// 				Label({
// 					connections: [
// 						[
// 							Audio,
// 							(label) => {
// 								if (!Audio.microphone) return;
// 								label.label = Audio.microphone.isMuted ? "Muted" : "Not muted";
// 							},
// 							"microphone-changed",
// 						],
// 					],
// 				}),
// 			],
// 		}),
// 		connections: [
// 			[
// 				Audio,
// 				(button) => {
// 					if (!Audio.microphone) return;
//
// 					button.toggleClassName("accent", Audio.microphone.isMuted);
// 				},
// 				"microphone-changed",
// 			],
// 		],
// 	});
//
// export const AppMixerToggle = (props) =>
// 	ArrowToggle({
// 		icon: FontIcon({ icon: "", className: "qs-icon" }),
// 		label: Label("App Mixer"),
// 		name: "app-mixer",
// 		toggle: () =>
// 			(opened.value = opened.value === "app-mixer" ? "" : "app-mixer"),
// 		...props,
// 	});

/** @param {import("types/widgets/button").ButtonProps} props */
const SettingsButton = (props) =>
	Widget.Button({
		onClicked: () => {
			Utils.execAsync("gnome-control-center sound");
		},
		hexpand: true,
		child: Widget.Box({
			children: [
				Widget.Icon("emblem-system-symbolic"),
				Widget.Label("Settings"),
			],
		}),
		...props,
	});

/** @param {Partial<import("../misc/menu.js").MenuProps>} props */
export const SinkSelector = (props) =>
	Menu({
		name: "sink-selector",
		icon: "audio-headphones-symbolic",
		title: "Sink Selector",
		content: [
			Widget.Box({
				vertical: true,
				children: audio.bind("speakers").as((a) => a.map(SinkItem)),
			}),
			Widget.Separator({ className: "accent" }),
			SettingsButton({}),
		],
		...props,
	});

/** @param {import("types/service/audio").Stream} stream */
const SinkItem = (stream) =>
	Widget.Button({
		hexpand: true,
		onClicked: () => {
			audio.speaker = stream;
		},
		child: Widget.Box({
			css: "margin-top: 6px; margin-bottom: 6px;",
			children: [
				Widget.Icon({
					icon: icon(stream.icon_name, "audio-x-generic-symbolic"),
					tooltip_text: stream.icon_name || "",
				}),
				Widget.Label({
					label: (stream.description || "").split(" ").slice(0, 4).join(" "),
				}),
				Widget.Icon({
					icon: "object-select-symbolic",
					hexpand: true,
					hpack: "end",
					visible: audio.speaker.bind("stream").as((s) => s === stream.stream),
				}),
			],
		}),
	});

/** @param {Partial<import("../misc/menu.js").MenuProps>} props */
export const AppMixer = (props) =>
	Menu({
		name: "app-mixer",
		icon: "audio-volume-high-symbolic",
		title: "App Mixer",
		content: [
			Widget.Box({
				vertical: true,
				class_name: "vertical mixer-item-box",
				children: audio.bind("apps").as((a) => a.map(MixerItem)),
			}),
			Widget.Separator({ className: "accent" }),
			SettingsButton({}),
		],
		...props,
	});

/** @param {import("types/service/audio").Stream} stream */
const MixerItem = (stream) =>
	Widget.Box({
		hexpand: true,
		children: [
			Widget.Icon({
				tooltipText: stream.bind("name").as((n) => n || ""),
				icon: stream
					.bind("name")
					.as((n) =>
						n && Utils.lookUpIcon(n) ? n : "audio-x-generic-symbolic",
					),
			}),
			Widget.Box({
				vertical: true,
				children: [
					Widget.Label({
						xalign: 0,
						truncate: "end",
						max_width_chars: 28,
						label: stream.bind("description").as((d) => d || ""),
					}),
					Widget.Slider({
						hexpand: true,
						draw_value: false,
						value: stream.bind("volume"),
						onChange: ({ value }) => {
							stream.volume = value;
						},
					}),
				],
			}),
			Widget.Label({
				css: "padding: 12px",
				label: stream.bind("volume").as(
					(x) =>
						`${Math.floor(x * 100)
							.toString()
							.padStart(3)}%`,
				),
			}),
		],
	});
