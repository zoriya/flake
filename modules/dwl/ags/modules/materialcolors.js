const { Service } = ags;
const { Box, Stack, Button, Icon } = ags.Widget;
const { CONFIG_DIR, exec, execAsync, timeout, } = ags.Utils;
const { Mpris } = ags.Service;

const prefer = (name) => (players) => {
	let last;
	for (const [busName, player] of players) {
		if (busName.includes(name)) return player;

		last = player;
	}
	return last;
};

class MaterialcolorsService extends Service {
	static {
		Service.register(this);
	}

	getColors(url) {
		if (url !== undefined) {
			const commandString = `python ${CONFIG_DIR}/bin/getCoverColors "${url}"`;
			try {
				this._colors = JSON.parse(exec(commandString));
			} catch {
				return;
			}
		}
	}

	constructor() {
		super();
		this._colors = {
			primary: "#222222",
			onPrimary: "#ffffff",
			background: "#222222",
			onBackground: "#ffffff",
		};

		Mpris.instance.connect("changed", () => {
			this._mprisPlayer = Mpris.getPlayer("");
			this._coverPath = this._mprisPlayer?.coverPath;
			// this._colors = this.getColors(this.coverPath);
			this.emit("changed");
		});
	}

	get colors() {
		return this._colors;
	}
	get coverPath() {
		return this._coverPath;
	}
}

class Materialcolors {
	static {
		Service.export(this, "Materialcolors");
	}
	static instance = new MaterialcolorsService();
	static get colors() {
		return Materialcolors.instance._colors;
	}
	static get coverPath() {
		return Materialcolors.instance._coverPath;
	}
}

export const PlayPause = ({ player, ...props }) =>
	Button({
		child: Stack({
			items: [
				[ "Playing", Icon("media-playback-pause-symbolic") ],
				[ "Paused", Icon("media-playback-start-symbolic") ],
				[ "Stopped", Icon("media-playback-start-symbolic") ],
			],
			connections: [
				[
					Mpris,
					(stack) => {
						const mpris = Mpris.getPlayer(player);
						stack.shown = mpris?.playBackStatus ?? "Stopped";
					},
				],
			],
		}),
		onClicked: () => Mpris.getPlayer(player)?.playPause(),
		connections: [
			[
				Materialcolors,
				(icon) => {
					icon.setStyle(`
						background-color: ${Materialcolors.colors.primary};
						color: ${Materialcolors.colors.onPrimary};
					`);
				},
			],
			[
				Mpris,
				(button) => {
					const mpris = Mpris.getPlayer(player);
					if (!mpris || !mpris.canPlay) return button.hide();

					button.show();
				},
			],
		],
		...props,
	});

export const CoverArt = (props) =>
	Box({
		...props,
		className: `mpris-cover-art ${props.className}`,
		connections: [
			[
				Materialcolors,
				(box) => {
					box.setStyle(`
						background-image: radial-gradient(circle, rgba(0, 0, 0, 0.4) 30%, ${Materialcolors.colors.primary}), url("${Materialcolors.coverPath}"); \
						color: ${Materialcolors.colors.onBackground};
					`);
				},
			],
			...(props.connections ?? [])
		],
	});

export const BackgroundBox = (props = {}) =>
	Box({
		...props,
		connections: [
			[
				Materialcolors,
				(box) => {
					box.setStyle(`
						color: ${Materialcolors.colors.onBackground};
					`);
				},
			],
		],
	});
