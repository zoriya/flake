import { BackgroundBox, CoverArt, PlayPause } from "./materialcolors.js";

const { Box, Button, Slider, Icon, CenterBox, Label } = ags.Widget;
const { Mpris } = ags.Service;
const { lookUpIcon } = ags.Utils;

const PlayerIcon = ({ player, symbolic = false, ...props }) =>
	Icon({
		...props,
		size: 24,
		halign: "start",
		valign: "start",
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
		connections: [
			[
				Mpris,
				(label) => {
					label.label = Mpris.getPlayer(player)?.trackTitle || "";
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
					label.label = Mpris.getPlayer(player)?.trackArtists.join(", ") || "";
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
		// slider.visible = mpris?.length > 0;
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

export const MprisPlayer = ({ player = "", ...props } = {}) =>
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
								valign: "center",
								hexpand: true,
								children: [
									TitleLabel({ player, style: "font-weight: 600; font-size: 19px;" }),
									ArtistLabel({ player, style: "font-weight: 400; font-size: 17px;" }),
								],
							}),
							Box({
								children: [PlayPause({ player, halign: "end", className: "mpris-play" })],
							}),
						],
					}),
					BackgroundBox({
						valign: "end",
						children: [
							Box({
								hexpand: true,
								children: [
									PreviousButton({ player, style: "margin-left: 16px;" }),
									PositionSlider({ player, hexpand: true }),
									NextButton({ player, style: "margin-right: 16px;" }),
								],
							}),
						],
					}),
				],
			}),
		],
		...props,
	});
