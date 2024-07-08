import brightness from "../services/brightness.js";

/** @param {import("../types/widgets/slider.js").SliderProps} props */
const BrightnessSlider = (props) =>
	Widget.Slider({
		drawValue: false,
		hexpand: true,
		value: brightness.bind("screen"),
		onChange: ({ value }) => {
			brightness.screen = value;
		},
		...props,
	});

/** @param {import("../types/widgets/box.js").BoxProps} props */
export const Brightness = (props) =>
	Widget.Box({
		className: "qs-slider",
		children: [
			Widget.Icon({
				vpack: "center",
				icon: "display-brightness-symbolic",
				tooltipText: brightness
					.bind("screen")
					.as((x) => `Screen Brightness: ${Math.floor(x * 100)}%`),
			}),
			BrightnessSlider({}),
			Widget.Label({
				label: brightness.bind("screen").as(
					(x) =>
						`${Math.floor(x * 100)
							.toString()
							.padStart(3)}%`,
				),
			}),
		],
		...props,
	});
