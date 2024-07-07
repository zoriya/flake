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

// const iconSubstitute = (item) => {
// 	const substitues = [
// 		{ from: "audio-headset-bluetooth", to: "audio-headphones-symbolic" },
// 		{ from: "audio-card-analog-usb", to: "audio-speakers-symbolic" },
// 		{ from: "audio-card-analog-pci", to: "audio-card-symbolic" },
// 	];
//
// 	for (const { from, to } of substitues) {
// 		if (from === item) return to;
// 	}
// 	return item;
// };
//

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
				label: audio[type]
					.bind("volume")
					.as((vol) => `${Math.floor(vol * 100)}%`),
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
//
// export const SpeakerSlider = (props) => {
// 	const slider = Slider({
// 		...props,
// 		drawValue: false,
// 		onChange: ({ value }) => (Audio.speaker.volume = value),
// 		max: 1.5,
// 		connections: [
// 			[
// 				Audio,
// 				(slider) => {
// 					if (!Audio.speaker) return;
//
// 					slider.sensitive = !Audio.speaker.isMuted;
// 					slider.value = Audio.speaker.volume;
// 				},
// 				"speaker-changed",
// 			],
// 		],
// 	});
// 	slider.add_mark(1, 0, null);
// 	slider.add_mark(1, 1, null);
// 	slider.max = 1.5;
// 	return slider;
// };

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
//
// export const AppMixer = (props) => {
// 	const AppItem = (stream) => {
// 		const icon = Icon();
// 		const label = Label({
// 			xalign: 0,
// 			justify: "left",
// 			wrap: true,
// 			ellipsize: 3,
// 		});
// 		const percent = Label({ xalign: 1 });
// 		const slider = Slider({
// 			hexpand: true,
// 			drawValue: false,
// 			onChange: ({ value }) => {
// 				stream.volume = value;
// 			},
// 		});
// 		const sync = () => {
// 			icon.icon = Utils.lookUpIcon(stream.name || "")
// 				? stream.name || ""
// 				: "audio-x-generic-symbolic";
// 			icon.tooltipText = stream.name;
// 			slider.value = stream.volume;
// 			percent.label = `${Math.floor(stream.volume * 100)}%`;
// 			label.label = addElipsis(stream.description || "", 30, "middle");
// 		};
// 		const id = stream.connect("changed", sync);
// 		return Box({
// 			hexpand: true,
// 			children: [
// 				icon,
// 				Box({
// 					children: [
// 						Box({
// 							vertical: true,
// 							children: [label, slider],
// 						}),
// 						percent,
// 					],
// 				}),
// 			],
// 			connections: [["destroy", () => stream.disconnect(id)]],
// 			setup: sync,
// 		});
// 	};
//
// 	return Box({
// 		...props,
// 		vertical: true,
// 		connections: [
// 			[
// 				Audio,
// 				(box) => {
// 					box.children = Audio.apps.map((stream) => AppItem(stream));
// 				},
// 			],
// 		],
// 	});
// };

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
			Widget.Separator(),
			// SettingsButton(),
		],
		...props,
	});

/** @param {import("types/service/audio").Stream} stream */
const SinkItem = (stream) =>
	Widget.Button({
		hexpand: true,
		onClicked: () => (audio.speaker = stream),
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
