import { Separator, FontIcon, addElipsis } from "../misc.js";
import { ArrowToggle, opened } from "../services/quicksettings.js";

import App from 'resource:///com/github/Aylur/ags/app.js'
import Service from 'resource:///com/github/Aylur/ags/service.js'
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js'
import { Label, Box, Icon, Stack, Button, Slider } from 'resource:///com/github/Aylur/ags/widget.js';
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

const iconSubstitute = (item) => {
	const substitues = [
		{ from: "audio-headset-bluetooth", to: "audio-headphones-symbolic" },
		{ from: "audio-card-analog-usb", to: "audio-speakers-symbolic" },
		{ from: "audio-card-analog-pci", to: "audio-card-symbolic" },
	];

	for (const { from, to } of substitues) {
		if (from === item) return to;
	}
	return item;
};

export const SpeakerIndicator = ({
	items = [
		["101", Icon("audio-volume-overamplified-symbolic")],
		["67", Icon("audio-volume-high-symbolic")],
		["34", Icon("audio-volume-medium-symbolic")],
		["1", Icon("audio-volume-low-symbolic")],
		["0", Icon("audio-volume-muted-symbolic")],
	],
	...props
} = {}) =>
	Stack({
		...props,
		items,
		connections: [
			[
				Audio,
				(stack) => {
					if (!Audio.speaker) return;

					if (Audio.speaker.isMuted) return (stack.shown = "0");

					const vol = Audio.speaker.volume * 100;
					for (const threshold of [100, 66, 33, 0, -1]) {
						if (vol > threshold + 1) return (stack.shown = `${threshold + 1}`);
					}
				},
				"speaker-changed",
			],
		],
	});

export const SpeakerPercentLabel = (props) =>
	Label({
		...props,
		connections: [
			[
				Audio,
				(label) => {
					if (!Audio.speaker) return;

					const perc = Math.floor(Audio.speaker.volume * 100);
					label.label = `${("  " + perc).slice(-3)}%`;
				},
				"speaker-changed",
			],
		],
	});

export const SpeakerSlider = (props) => {
	const slider = Slider({
		...props,
		drawValue: false,
		onChange: ({ value }) => (Audio.speaker.volume = value),
		max: 1.5,
		connections: [
			[
				Audio,
				(slider) => {
					if (!Audio.speaker) return;

					slider.sensitive = !Audio.speaker.isMuted;
					slider.value = Audio.speaker.volume;
				},
				"speaker-changed",
			],
		],
	});
	slider.add_mark(1, 0, null);
	slider.add_mark(1, 1, null);
	slider.max = 1.5;
	return slider;
};

export const MicrophoneMuteIndicator = ({
	muted = Icon("microphone-disabled-symbolic"),
	unmuted = Icon("microphone-sensitivity-high-symbolic"),
	...props
} = {}) =>
	Stack({
		...props,
		items: [
			["true", muted],
			["false", unmuted],
		],
		connections: [
			[
				Audio,
				(stack) => {
					stack.shown = `${Audio.microphone?.isMuted}`;
				},
				"microphone-changed",
			],
		],
	});

export const MuteToggle = (props) =>
	Button({
		...props,
		className: "qs-button surface",
		onClicked: () => execAsync("pactl set-source-mute @DEFAULT_SOURCE@ toggle"),
		child: Box({
			children: [
				MicrophoneMuteIndicator({ className: "qs-icon" }),
				Label({
					connections: [
						[
							Audio,
							(label) => {
								if (!Audio.microphone) return;
								label.label = Audio.microphone.isMuted ? "Muted" : "Not muted";
							},
							"microphone-changed",
						],
					],
				}),
			],
		}),
		connections: [
			[
				Audio,
				(button) => {
					if (!Audio.microphone) return;

					button.toggleClassName("accent", Audio.microphone.isMuted);
				},
				"microphone-changed",
			],
		],
	});

export const AppMixerToggle = (props) =>
	ArrowToggle({
		icon: FontIcon({ icon: "", className: "qs-icon" }),
		label: Label("App Mixer"),
		name: "app-mixer",
		toggle: () => opened.value = opened.value === "app-mixer" ? "" : "app-mixer",
		...props,
	});

export const AppMixer = (props) => {
	const AppItem = (stream) => {
		const icon = Icon();
		const label = Label({
			xalign: 0,
			justify: "left",
			wrap: true,
			ellipsize: 3,
		});
		const percent = Label({ xalign: 1 });
		const slider = Slider({
			hexpand: true,
			drawValue: false,
			onChange: ({ value }) => {
				stream.volume = value;
			},
		});
		const sync = () => {
			icon.icon = stream.iconName;
			icon.tooltipText = stream.name;
			slider.value = stream.volume;
			percent.label = `${Math.floor(stream.volume * 100)}%`;
			label.label = addElipsis(stream.description || "", 30, "middle");
		};
		const id = stream.connect("changed", sync);
		return Box({
			hexpand: true,
			children: [
				icon,
				Box({
					children: [
						Box({
							vertical: true,
							children: [label, slider],
						}),
						percent,
					],
				}),
			],
			connections: [["destroy", () => stream.disconnect(id)]],
			setup: sync,
		});
	};

	return Box({
		...props,
		vertical: true,
		connections: [
			[
				Audio,
				(box) => {
					box.children = Audio.apps.map((stream) => AppItem(stream));
				},
			],
		],
	});
};

export const StreamSelector = ({ streams = "speakers", ...props } = {}) =>
	Box({
		...props,
		vertical: true,
		connections: [
			[
				Audio,
				(box) => {
					box.children = Audio[streams]
						.map((stream) =>
							Button({
								child: Box({
									children: [
										Icon({
											icon: iconSubstitute(stream.iconName),
											tooltipText: stream.iconName,
										}),
										Label(stream.description.split(" ").slice(0, 4).join(" ")),
										Icon({
											icon: "object-select-symbolic",
											hexpand: true,
											hpack: "end",
											connections: [
												[
													"draw",
													(icon) => {
														icon.visible = Audio.speaker === stream;
													},
												],
											],
										}),
									],
								}),
								onClicked: () => {
									if (streams === "speakers") Audio.speaker = stream;

									if (streams === "microphones") Audio.microphone = stream;
								},
							})
						)
						.concat([
							Separator(),
							Button({
								onClicked: () => {
									execAsync("pavucontrol").catch(print);
									App.closeWindow("quicksettings");
								},
								child: Label({
									label: "Settings",
									xalign: 0,
								}),
							}),
						]);
				},
			],
		],
	});

// export const MicUseIndicator = ({ className, ...props } = {}) =>
// 	Icon({
// 		icon: "microphone-sensitivity-high-symbolic",
// 		className: `${className} red`,
// 		connections: [
// 			[
// 				Audio,
// 				(button) => {
// 					log(Audio.recordingApps.map(x => ({desc: x.description, origin: x.origin, type: x.type})));
// 					if (!Audio.recordingApps.length) return button.hide();
// 					button.show();
// 				},
// 			],
// 		],
// 		...props,
// 	});
