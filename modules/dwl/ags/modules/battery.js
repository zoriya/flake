const { Battery } = ags.Service;
const { Label, Icon, Stack, Box } = ags.Widget;

const icons = (charging) =>
	Array.from({ length: 11 }, (_, i) => i * 10).map((i) => [
		`${i}`,
		Icon({
			className: `${i} ${charging ? "charging" : "discharging"}`,
			icon: `battery-level-${i}${charging ? (i === 100 ? "-charged" : "-charging") : ""
				}-symbolic`,
		}),
	]);

const Indicators = (charging) =>
	Stack({
		items: icons(charging),
		connections: [
			[
				Battery,
				(stack) => {
					stack.shown = "100"; //`${Math.floor(Battery.percent / 10) * 10}`;
				},
			],
		],
	});

export const IconIndicator = ({
	charging = Indicators(true),
	discharging = Indicators(false),
	...props
} = {}) =>
	Stack({
		...props,
		items: [
			["true", charging],
			["false", discharging],
		],
		connections: [
			[
				Battery,
				(stack) => {
					const { charging, charged } = Battery;
					stack.shown = `${charging || charged}`;
					stack.toggleClassName("green", Battery.charging || Battery.charged);
					stack.toggleClassName("red", Battery.percent < 30);
				},
			],
		],
	});

export const LevelLabel = ({ ...props }) =>
	Label({
		...props,
		connections: [[Battery, (label) => (label.label = `${Battery.percent}%`)]],
	});

export const Indicator = ({ ...props }) =>
	Box({
		...props,
		children: [IconIndicator(), LevelLabel({})],
		connections: [
			[
				Battery,
				(box) => {
					box.visible = Battery.available;
				},
			],
		],
	});

// export const BatteryProgress = (props) =>
// 	Box({
// 		...props,
// 		className: "battery-progress",
// 		connections: [
// 			[
// 				Battery,
// 				(w) => {
// 					w.toggleClassName("half", Battery.percent < 46);
// 					w.toggleClassName("charging", Battery.charging);
// 					w.toggleClassName("charged", Battery.charged);
// 					w.toggleClassName("low", Battery.percent < 30);
// 				},
// 			],
// 		],
// 		children: [
// 			Overlay({
// 				child: ProgressBar({
// 					hexpand: true,
// 					connections: [
// 						[
// 							Battery,
// 							(progress) => {
// 								progress.fraction = Battery.percent / 100;
// 							},
// 						],
// 					],
// 				}),
// 				overlays: [
// 					Label({
// 						connections: [
// 							[
// 								Battery,
// 								(l) => {
// 									l.label =
// 										Battery.charging || Battery.charged
// 											? "󱐋"
// 											: `${Battery.percent}%`;
// 								},
// 							],
// 						],
// 					}),
// 				],
// 			}),
// 		],
// 	});