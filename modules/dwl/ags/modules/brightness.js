import { Brightness } from "../services/brightness.js";

const { Service } = ags;
const { exec, execAsync } = ags.Utils;
const { Icon, Label, Slider } = ags.Widget;

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
