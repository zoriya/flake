import { getMaterialColors } from "./materialcolors.js";

const mpris = await Service.import("mpris");

/** @param {{player: import("types/service/mpris").MprisPlayer} & import("types/widgets/icon").IconProps} props */
const PlayerIcon = ({ player, ...props }) =>
	Widget.Icon({
		size: 24,
		hpack: "start",
		vpack: "start",
		tooltipText: player.identity || "",
		icon: player.bind("entry").transform((entry) => {
			const name = `${entry}-symbolic`;
			return Utils.lookUpIcon(name)
				? name
				: Utils.lookUpIcon(entry)
					? entry
					: "audio-x-generic-symbolic";
		}),
		...props,
	});

/** @param {{player: import("types/service/mpris").MprisPlayer} & import("types/widgets/label").LabelProps} props */
const TitleLabel = ({ player, ...props }) =>
	Widget.Label({
		wrap: true,
		truncate: "end",
		hpack: "start",
		label: player.bind("track_title"),
		...props,
	});

/** @param {{player: import("types/service/mpris").MprisPlayer} & import("types/widgets/label").LabelProps} props */
const ArtistLabel = ({ player, ...props }) =>
	Widget.Label({
		wrap: true,
		truncate: "end",
		hpack: "start",
		label: player.bind("track_artists").transform((x) => x.join(", ")),
		...props,
	});

/** @param {{player: import("types/service/mpris").MprisPlayer} & import("types/widgets/button").ButtonProps} props */
export const PlayPause = ({ player, ...props }) =>
	Widget.Button({
		child: Widget.Icon({
			icon: player.bind("play_back_status").as(
				(x) =>
					({
						Playing: "media-playback-pause-symbolic",
						Paused: "media-playback-start-symbolic",
						Stopped: "media-playback-start-symbolic",
					})[x],
			),
		}),
		onClicked: () => player.playPause(),
		visible: player.bind("can_play"),
		...props,
	});

/** @param {{player: import("types/service/mpris").MprisPlayer} & import("types/widgets/button").ButtonProps} props */
const PreviousButton = ({ player, ...props }) =>
	Widget.Button({
		child: Widget.Icon({ icon: "media-skip-backward-symbolic" }),
		onClicked: () => player.previous(),
		visible: player.bind("can_go_prev"),
		...props,
	});

/** @param {{player: import("types/service/mpris").MprisPlayer} & import("types/widgets/button").ButtonProps} props */
const NextButton = ({ player, ...props }) =>
	Widget.Button({
		child: Widget.Icon({ icon: "media-skip-forward-symbolic" }),
		onClicked: () => player.next(),
		visible: player.bind("can_go_next"),
		...props,
	});

/** @param {{player: import("types/service/mpris").MprisPlayer} & import("types/widgets/slider").SliderProps} props */
const PositionSlider = ({ player, ...props }) =>
	Widget.Slider({
		className: "mpris-position-slider",
		drawValue: false,
		onChange: ({ value }) => {
			player.position = value * player.length;
		},
		visible: player.bind("length").as((l) => l > 0),
		setup: (self) => {
			function update() {
				const value = player.position / player.length;
				self.value = value > 0 ? value : 0;
			}
			self.hook(player, update);
			self.hook(player, update, "position");
			self.poll(1000, update);
		},
		...props,
	});

// export const currentPlayer = Utils.watch(
// 	null,
// 	[
// 		[mpris, "player-added"],
// 		[mpris, "player-changed"],
// 	],
// 	/** @param {any} name */
// 	(name) => mpris.getPlayer(name),
// );

/** @param {{player?: import("types/service/mpris").MprisPlayer | null} & import("types/widgets/box").BoxProps} props */
export const MprisPlayer = ({ player, ...props }) => {
	if (!player) return Widget.Box({ visible: false });
	const colors = getMaterialColors(player);

	return Widget.Box({
		visible: player.bind("play_back_status").as((x) => x !== "Stopped"),
		className: `mpris-cover-art ${props.className}`,
		css: colors.bind().as(
			(x) => `
				background-image: radial-gradient(circle, rgba(0, 0, 0, 0.4) 30%, ${x.primary}), url("${x.coverPath}"); \
				color: ${x.onBackground};
			`,
		),
		vexpand: false,
		children: [
			Widget.Box({
				vertical: true,
				hexpand: true,
				children: [
					Widget.Box({
						vertical: true,
						vexpand: true,
						css: colors.bind().as((x) => `color: ${x.onBackground}`),
						child: PlayerIcon({ player }),
					}),
					Widget.Box({
						hexpand: true,
						children: [
							Widget.Box({
								css: colors.bind().as((x) => `color: ${x.onBackground}`),
								vertical: true,
								vpack: "center",
								hexpand: true,
								children: [
									TitleLabel({
										player,
										css: "font-weight: 600; font-size: 19px;",
									}),
									ArtistLabel({
										player,
										css: "font-weight: 400; font-size: 17px;",
									}),
								],
							}),
							Widget.Box({
								children: [
									PlayPause({
										player,
										hpack: "end",
										className: "mpris-play",
										css: colors.bind().as(
											(x) => `
												background-color: ${x.primary};
												color: ${x.onPrimary};
											`,
										),
									}),
								],
							}),
						],
					}),
					Widget.Box({
						css: colors.bind().as((x) => `color: ${x.onBackground}`),
						vpack: "end",
						children: [
							Widget.Box({
								hexpand: true,
								children: [
									PreviousButton({ player, css: "margin-left: 16px;" }),
									PositionSlider({ player, hexpand: true }),
									NextButton({ player, css: "margin-right: 16px;" }),
								],
							}),
						],
					}),
				],
			}),
		],
		...props,
	});
};
