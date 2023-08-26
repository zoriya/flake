import { BackgroundBox, CoverArt, PlayPause } from "./materialcolors.js";

const { Box, Button, Icon, CenterBox, Label } = ags.Widget;
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
		connections: [
			[
				Mpris,
				(label) => {
					const body = Mpris.getPlayer(player)?.trackTitle || "";
					label.label = body.length > 35 ? body.substring(0, 35) + "..." : body;
				},
			],
		],
	});

const ArtistLabel = ({ player, ...props }) =>
	Label({
		...props,
		connections: [
			[
				Mpris,
				(label) => {
					const body = Mpris.getPlayer(player)?.trackArtists.join(", ") || "";
					label.label = body.length > 40 ? body.substring(0, 40) + "..." : body;
				},
			],
		],
	});

export const MprisPlayer = ({ player = "", ...props } = {}) =>
	CoverArt({
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
								children: [TitleLabel({player}), ArtistLabel({player})],
							}),
							Box({
								children: [PlayPause({ halign: "end", player })],
							}),
						],
					}),
					// BackgroundBox({
					// 	valign: "end",
					// 	children: [
					// 		Box({
					// 			hexpand: true,
					// 			children: [
					// 				Button
					// 			],
					// 		}),
					// 	],
					// }),
				],
			}),
		],
		...props,
	});
