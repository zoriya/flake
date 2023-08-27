import Gio from "gi://Gio";

const { Service } = ags;


class DwlService extends Service {
	static { Service.register(this); }

	_decoder = new TextDecoder();
	_monitors = new Map();
	tagCount = 9;

	constructor() {
		super();
		this._monitors = new Map();

		this.watchSocket(
			new Gio.DataInputStream({
				base_stream: new Gio.UnixInputStream({ fd: 0 }),
				close_base_stream: true,
			})
		);
	}

	watchSocket(stream) {
		stream.read_line_async(0, null, (stream, result) => {
			if (!stream) {
				console.error("Error reading dwl socket");
				return;
			}

			const [line] = stream.read_line_finish(result);
			this._onEvent(this._decoder.decode(line));
			this.watchSocket(stream);
		});
	}

	_onEvent(event) {
		if (!event) return;

		/*
WL-1 title YouTube Music
WL-1 appid YouTube Music
WL-1 fullscreen 0
WL-1 floating 0
WL-1 selmon 1
WL-1 tags 1 1 1 0
WL-1 layout []=
WL-1 title YouTube Music
WL-1 appid YouTube Music
WL-1 fullscreen 0
WL-1 floating 0
WL-1 selmon 1
WL-1 tags 1 1 1 0
WL-1 layout []=
WL-1 title YouTube Music
WL-1 appid YouTube Music
WL-1 fullscreen 0
WL-1 floating 0
WL-1 selmon 1
WL-1 tags 1 1 1 0
WL-1 layout []=
		*/

		const [mon, type, ...values] = event.split(" ");

		this._monitors[mon] ??= new Map();
		switch (type) {
			case "tags":
				const [occ, monSel, clientSel, urg] = values.map((x) => parseInt(x));
				this._monitors[mon]["tags"] = Array.from({ length: this.tagCount }).map(
					(_, i) => ({
						occupied: occ & (1 << i),
						selected: monSel & (1 << i),
						clientSelected: clientSel && 1 << 1,
						urgent: urg & (1 << i),
					})
				);
				break;
			case "selmon":
			case "floating":
			case "fullscreen":
				this._monitors[mon][type] = values?.[0] === "1";
				break;
			case "title":
			case "appid":
			case "layout":
			default:
				this._monitors[mon][type] = values.join(" ");
				break;
		}

		// All events are sent at the same time, layout is the last one. prevent unnecessaries updates.
		if (type === "layout")
			this.emit("changed");
	}
}

export default class Dwl {
	static {
		Service.export(this, "Dwl");
	}
	static _instance;

	static get instance() {
		Service.ensureInstance(Dwl, DwlService);
		return Dwl._instance;
	}

	static get monitors() {
		return Dwl.instance._monitors;
	}

	static tags(mon) { return Dwl.instance._monitors[mon]?.["tags"] ?? []; }
	static layout(mon) { return Dwl.instance._monitors[mon]?.["layout"] ?? JSON.stringify(Dwl.instance._monitors); }
	static title(mon) { return Dwl.instance._monitors[mon]?.["title"] ?? ""; }
}
