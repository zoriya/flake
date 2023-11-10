import { Brightness } from "../services/brightness.js";

import Service from 'resource:///com/github/Aylur/ags/service.js';
import { exec, execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import { Icon, Label, Slider } from 'resource:///com/github/Aylur/ags/widget.js';

export const BrightnessSlider = (props) =>
	Slider({
		...props,
		drawValue: false,
		hexpand: true,
		connections: [
			[
				Brightness,
				(slider) => {
					slider.value = Brightness.screen;
				},
			],
		],
		onChange: ({ value }) => (Brightness.screen = value),
	});

export const Indicator = (props) =>
	Icon({
		...props,
		icon: "display-brightness-symbolic",
	});

export const PercentLabel = (props) =>
	Label({
		...props,
		connections: [
			[
				Brightness,
				(label) => {
					const perc = Math.floor(Brightness.screen * 100);
					label.label = `${("  " + perc).slice(-3)}%`;
				},
			],
		],
	});
