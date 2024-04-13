import { BackgroundBox, CoverArt, PlayPause } from "./materialcolors.js";
import { addElipsis } from "../misc.js";

import { Box, Button, Slider, Icon, CenterBox, Label } from 'resource:///com/github/Aylur/ags/widget.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js'
import { lookUpIcon } from 'resource:///com/github/Aylur/ags/utils.js';

const PlayerIcon = ({ player, symbolic = false, ...props }) =>
	Icon({
		...props,
		size: 24,
		hpack: "start",
		vpack: "start",
		connections: [
			[
				Mpris,
				(icon) => {
					const name = `${Mpris.getPlayer(player)?.entry}${symbolic ? "-symbolic" : ""}`;
					lookUpIcon(name) ? (icon.icon_name = name) : (icon.icon_name = "audio-x-generic-symbolic");
				},
			],
		],
	});

const TitleLabel = ({ player, ...props } = {}) =>
	Label({
		...props,
		truncate: "end",
		wrap: true,
		connections: [
			[
				Mpris,
				(label) => {
					label.label = addElipsis(Mpris.getPlayer(player)?.trackTitle || "", 25);
				},
			],
		],
	});

const ArtistLabel = ({ player, ...props }) =>
	Label({
		...props,
		truncate: "end",
		connections: [
			[
				Mpris,
				(label) => {
					label.label = addElipsis(Mpris.getPlayer(player)?.trackArtists.join(", ") || "", 25);
				},
			],
		],
	});

const PreviousButton = ({ player, ...props }) =>
	Button({
		child: Icon("media-skip-backward-symbolic"),
		onClicked: () => Mpris.getPlayer(player)?.previous(),
		connections: [
			[
				Mpris,
				(button) => {
					const mpris = Mpris.getPlayer(player);
					if (!mpris || !mpris.canGoPrev) return button.hide();

					button.show();
				},
			],
		],
		...props,
	});

const NextButton = ({ player, ...props }) =>
	Button({
		child: Icon("media-skip-forward-symbolic"),
		onClicked: () => Mpris.getPlayer(player)?.next(),
		connections: [
			[
				Mpris,
				(button) => {
					const mpris = Mpris.getPlayer(player);
					if (!mpris || !mpris.canGoNext) return button.hide();

					button.show();
				},
			],
		],
		...props,
	});

const PositionSlider = ({ player, ...props }) => {
	const update = (slider) => {
		if (slider._dragging) return;

		const mpris = Mpris.getPlayer(player);
		// Only set opacity and not change the visible bool to keep it expanded.
		slider.opacity = mpris?.length > 0 ? 1 : 0;
		if (mpris && mpris.length > 0) slider.adjustment.value = mpris.position / mpris.length;
	};

	return Slider({
		drawValue: false,
		className: "mpris-position-slider",
		onChange: (value) => {
			const mpris = Mpris.getPlayer(player);
			if (mpris && mpris.length >= 0) Mpris.getPlayer(player).position = mpris.length * value;
		},
		connections: [
			[Mpris, update],
			[1000, update],
		],
		...props,
	});
};

export const MprisPlayer = ({ player = "YoutubeMusic", ...props } = {}) =>
	CoverArt({
		vexpand: false,
		children: [
			CenterBox({
				vertical: true,
				hexpand: true,
				children: [
					BackgroundBox({
						vertical: true,
						vexpand: true,
						child: PlayerIcon({ player }),
					}),
					Box({
						hexpand: true,
						children: [
							BackgroundBox({
								vertical: true,
								vpack: "center",
								hexpand: true,
								children: [
									TitleLabel({ player, css: "font-weight: 600; font-size: 19px;" }),
									ArtistLabel({ player, css: "font-weight: 400; font-size: 17px;" }),
								],
							}),
							Box({
								children: [PlayPause({ player, hpack: "end", className: "mpris-play" })],
							}),
						],
					}),
					BackgroundBox({
						vpack: "end",
						children: [
							Box({
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
		connections: [
			[
				Mpris,
				(widget) => {
					const mpris = Mpris.getPlayer(player);
					widget.visible = mpris !== null && mpris.playBackStatus !== "Stopped";
				},
			],
		],
		...props,
	});
