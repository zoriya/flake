// import { Separator, FontIcon, addElipsis } from "../misc.js";
// import { ArrowToggle, opened } from "../services/quicksettings.js";
//
const audio = await Service.import("audio");

const volumeIcons = /** @type {const} */ ([
	[101, "overamplified"],
	[67, "high"],
	[34, "medium"],
	[1, "low"],
	[0, "muted"],
]);

/** @param {import("types/widgets/icon").IconProps} props */
export const VolumeIndicator = (props) =>
	Widget.Icon({
		icon: audio.speaker.bind("volume").as((vol) => {
			const val = volumeIcons.find(
				([threshold]) => threshold <= vol * 100,
			)?.[1];
			return `audio-volume-${val}-symbolic`;
		}),
		...props,
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
//
// export const SpeakerPercentLabel = (props) =>
// 	Label({
// 		...props,
// 		connections: [
// 			[
// 				Audio,
// 				(label) => {
// 					if (!Audio.speaker) return;
//
// 					const perc = Math.floor(Audio.speaker.volume * 100);
// 					label.label = `${("  " + perc).slice(-3)}%`;
// 				},
// 				"speaker-changed",
// 			],
// 		],
// 	});
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
//
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
//
// export const StreamSelector = ({ streams = "speakers", ...props } = {}) =>
// 	Box({
// 		...props,
// 		vertical: true,
// 		connections: [
// 			[
// 				Audio,
// 				(box) => {
// 					box.children = Audio[streams]
// 						.map((stream) =>
// 							Button({
// 								child: Box({
// 									children: [
// 										Icon({
// 											icon: iconSubstitute(stream.iconName),
// 											tooltipText: stream.iconName,
// 										}),
// 										Label(stream.description.split(" ").slice(0, 4).join(" ")),
// 										Icon({
// 											icon: "object-select-symbolic",
// 											hexpand: true,
// 											hpack: "end",
// 											connections: [
// 												[
// 													"draw",
// 													(icon) => {
// 														icon.visible = Audio.speaker === stream;
// 													},
// 												],
// 											],
// 										}),
// 									],
// 								}),
// 								onClicked: () => {
// 									if (streams === "speakers") Audio.speaker = stream;
//
// 									if (streams === "microphones") Audio.microphone = stream;
// 								},
// 							}),
// 						)
// 						.concat([
// 							Separator(),
// 							Button({
// 								onClicked: () => {
// 									execAsync("pavucontrol").catch(print);
// 									App.closeWindow("quicksettings");
// 								},
// 								child: Label({
// 									label: "Settings",
// 									xalign: 0,
// 								}),
// 							}),
// 						]);
// 				},
// 			],
// 		],
// 	});
