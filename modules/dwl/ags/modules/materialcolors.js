const { Service } = ags;
const { Box, Stack, Button, Icon } = ags.Widget;
const { execAsync, timeout } = ags.Utils;
const { Mpris } = ags.Service;

class MaterialcolorsService extends Service {
	static {
		Service.register(this);
	}

	getColors(url) {
		if (url) {
			timeout(100, () => {
				execAsync(["covercolors", url])
					.then((colors) => {
						this._colors = JSON.parse(colors);
						this.emit("changed");
					})
					.catch(print);
			});
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
			this.getColors(this.coverPath);
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
				["Playing", Icon("media-playback-pause-symbolic")],
				["Paused", Icon("media-playback-start-symbolic")],
				["Stopped", Icon("media-playback-start-symbolic")],
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
			...(props.connections ?? []),
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
