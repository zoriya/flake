import { icon } from "../misc/utils.js";
import {
	Arrow,
	Menu,
	SettingsButton,
	SimpleToggleButton,
} from "../misc/menu.js";

const audio = await Service.import("audio");

const volumeIcons = /** @type {const} */ ([
	[101, "overamplified"],
	[67, "high"],
	[34, "medium"],
	[1, "low"],
	[0, "muted"],
]);

/** @param {number} volume */
export const getIcon = (volume) => {
	const icon = volumeIcons.find(([threshold]) => threshold <= volume)?.[1];
	return `audio-volume-${icon}-symbolic`;
};

/** @param {{type?: "speaker" | "microphone"} & import("../types/widgets/icon.js").IconProps} props */
export const VolumeIndicator = ({ type = "speaker", ...props }) =>
	Widget.Icon(props).hook(audio, (self) => {
		if (audio[type].is_muted) {
			self.icon = "audio-volume-muted-symbolic";
			self.tooltip_text = "Muted";
			return;
		}
		const vol = audio[type].volume * 100;
		self.icon = getIcon(vol);
		self.tooltip_text = `Volume: ${Math.floor(vol)}%`;
	});

/** @param {import("../types/widgets/icon.js").IconProps} props */
export const MicrophoneIndicator = (props) =>
	Widget.Icon(props).hook(audio, (self) => {
		self.visible = audio.microphone.is_muted || audio.recorders.length > 0;
		if (audio.microphone.is_muted) self.icon = "microphone-disabled-symbolic";
		else if (audio.recorders.length > 0)
			self.icon = "microphone-sensitivity-high-symbolic";
	});

/** @param {{type?: "speaker" | "microphone"} & import("../types/widgets/slider.js").SliderProps} props */
const VolumeSlider = ({ type = "speaker", ...props }) =>
	Widget.Slider({
		hexpand: true,
		drawValue: false,
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

/** @param {{type?: "speaker" | "microphone"} & import("../types/widgets/box.js").BoxProps} props */
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

/** @param {Partial<import("../misc/menu.js").SimpleToggleButtonProps>} props */
export const MuteToggle = ({ ...props } = {}) =>
	SimpleToggleButton({
		icon: Widget.Icon({
			className: "qs-icon",
			icon: audio.microphone
				.bind("is_muted")
				.as((x) =>
					x
						? "microphone-disabled-symbolic"
						: "microphone-sensitivity-high-symbolic",
				),
		}),
		label: Widget.Label({
			label: audio.microphone
				.bind("is_muted")
				.as((x) => (x ? "Unmute" : "Mute")),
		}),
		activate: () => {
			audio.microphone.is_muted = true;
		},
		deactivate: () => {
			audio.microphone.is_muted = false;
		},
		connection: [audio.microphone, () => audio.microphone.is_muted || false],
		...props,
	});

/** @param {Partial<import("../misc/menu.js").MenuProps>} props */
export const SinkSelector = (props) =>
	Menu({
		name: "sink-selector",
		icon: Widget.Icon("audio-headphones-symbolic"),
		title: "Sink Selector",
		content: [
			Widget.Box({
				className: "qs-sub-sub-content",
				vertical: true,
				children: audio.bind("speakers").as((a) => a.map(SinkItem)),
			}),
			Widget.Separator({ className: "accent" }),
			SettingsButton({ type: "sound" }),
		],
		...props,
	});

/** @param {import("../types/service/audio.js").Stream} stream */
const SinkItem = (stream) =>
	Widget.Button({
		hexpand: true,
		onClicked: () => {
			audio.speaker = stream;
		},
		child: Widget.Box({
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
		icon: Widget.Icon("audio-volume-high-symbolic"),
		title: "App Mixer",
		content: [
			Widget.Box({
				vertical: true,
				className: "qs-sub-sub-content",
				children: audio.bind("apps").as((a) => a.map(MixerItem)),
			}),
			Widget.Separator({ className: "accent" }),
			SettingsButton({ type: "sound" }),
		],
		...props,
	});

/** @param {import("../types/service/audio.js").Stream} stream */
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
