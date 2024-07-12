const mpris = await Service.import("mpris");

/** @param {{player: import("../types/service/mpris").MprisPlayer} & import("../types/widgets/icon").IconProps} props */
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

/** @param {{player: import("../types/service/mpris").MprisPlayer} & import("../types/widgets/label").LabelProps} props */
const TitleLabel = ({ player, ...props }) =>
	Widget.Label({
		wrap: true,
		truncate: "end",
		hpack: "start",
		label: player.bind("track_title"),
		...props,
	});

/** @param {{player: import("../types/service/mpris").MprisPlayer} & import("../types/widgets/label").LabelProps} props */
const ArtistLabel = ({ player, ...props }) =>
	Widget.Label({
		wrap: true,
		truncate: "end",
		hpack: "start",
		label: player.bind("track_artists").transform((x) => x.join(", ")),
		...props,
	});

/** @param {{player: import("../types/service/mpris").MprisPlayer} & import("../types/widgets/button").ButtonProps} props */
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

/** @param {{player: import("../types/service/mpris").MprisPlayer} & import("../types/widgets/button").ButtonProps} props */
const PreviousButton = ({ player, ...props }) =>
	Widget.Button({
		child: Widget.Icon({ icon: "media-skip-backward-symbolic" }),
		onClicked: () => player.previous(),
		visible: player.bind("can_go_prev"),
		...props,
	});

/** @param {{player: import("../types/service/mpris").MprisPlayer} & import("../types/widgets/button").ButtonProps} props */
const NextButton = ({ player, ...props }) =>
	Widget.Button({
		child: Widget.Icon({ icon: "media-skip-forward-symbolic" }),
		onClicked: () => player.next(),
		visible: player.bind("can_go_next"),
		...props,
	});

/** @param {{player: import("../types/service/mpris").MprisPlayer} & import("../types/widgets/slider").SliderProps} props */
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

export const activePlayer = Variable(mpris.players[0]);
mpris.connect("player-added", (_, bus) => {
	mpris.getPlayer(bus)?.connect("changed", (player) => {
		console.log("Player changed", bus, player);
		if (player?.play_back_status !== "Stopped") {
			activePlayer.value = player || mpris.players[0];
		} else {
			activePlayer.value = mpris.players[0];
		}
	});
});

/** @param {{player?: import("../types/service/mpris").MprisPlayer | null} & import("../types/widgets/box").BoxProps} props */
export const MprisPlayer = ({ player, ...props }) => {
	if (!player) return Widget.Box({ visible: false });
	const colors = getMaterialColors(player);

	return Widget.Box({
		visible: player.bind("play_back_status").as((x) => x !== "Stopped"),
		className: `mpris-cover-art ${props.className}`,
		css: Utils.merge(
			[colors.bind(), player.bind("cover_path")],
			(colors, cover) => `
				background-image: radial-gradient(circle, rgba(0, 0, 0, 0.4) 30%, ${colors.primary}), url("${cover}"); \
				color: ${colors.onBackground};
			`,
		),
		vexpand: false,
		children: [
			Widget.CenterBox({
				vertical: true,
				hexpand: true,
				startWidget: Widget.Box({
					vertical: true,
					vexpand: true,
					css: colors.bind().as((x) => `color: ${x.onBackground}`),
					child: PlayerIcon({ player }),
				}),
				centerWidget: Widget.Box({
					hexpand: true,
					children: [
						Widget.Box({
							css: colors.bind().as(
								(x) => `
									color: ${x.onBackground};
									margin-right: 12px;
								`,
							),
							vertical: true,
							vpack: "center",
							hexpand: true,
							children: [
								TitleLabel({
									player,
									css: "font-weight: 600; font-size: 19px;",
									maxWidthChars: 33,
								}),
								ArtistLabel({
									player,
									css: "font-weight: 400; font-size: 17px;",
									maxWidthChars: 40,
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
				endWidget: Widget.Box({
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
			}),
		],
		...props,
	});
};

// TODO: Move ret inside getMaterialColors to support multiple players.
const ret = Variable({
	primary: "#222222",
	onPrimary: "#ffffff",
	background: "#222222",
	onBackground: "#ffffff",
});
/** @param {import("../types/service/mpris").MprisPlayer} player */
export const getMaterialColors = (player) => {
	// TODO: Move that to a hook to allow graceful disconnections
	player.connect("changed", (player) => {
		const cover = player.cover_path;
		// TODO: Wait for the cover to be downloaded, currently we hope that it's ready in <100ms
		Utils.timeout(100, () => {
			Utils.execAsync(["covercolors", cover])
				.then((colors) => {
					const col = JSON.parse(colors);
					if (!col) return;
					ret.setValue(col);
				})
				.catch(print);
		});
	});

	return ret;
};
