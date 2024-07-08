const battery = await Service.import("battery");

/** @param {import("../types/widgets/box").BoxProps} props */
export const Indicator = ({ ...props }) =>
	Widget.Box({
		children: [
			Widget.Icon({
				icon: battery.bind("icon_name"),
				className: Utils.merge(
					[
						battery.bind("charging"),
						battery.bind("charged"),
						battery.bind("percent"),
					],
					(charging, charged, percent) => {
						if (charging || charged) return "green";
						if (percent < 30) return "red";
						return "";
					},
				),
			}),
			Widget.Label({
				label: battery.bind("percent").as((x) => `${x}%`),
			}),
		],
		visible: battery.bind("available"),
		...props,
	});
