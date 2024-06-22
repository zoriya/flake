import Gio from "gi://Gio";
import GioUnix from "gi://GioUnix";

import Service from 'resource:///com/github/Aylur/ags/service.js'

class DwlService extends Service {
	static {
		Service.register(this);
	}

	_decoder = new TextDecoder();
	_monitors = new Map();
	tagCount = 9;

	constructor() {
		super();
		this._monitors = new Map();

		this.watchSocket(
			new Gio.DataInputStream({
				base_stream: new GioUnix.InputStream({ fd: 0 }),
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
WL-1:0,0 title YouTube Music
WL-1 appid YouTube Music
WL-1 fullscreen 0
WL-1 floating 0
WL-1 selmon 1
WL-1 tags 1 1 1 0
WL-1 layout []=
		*/

		const [monAll, type, ...values] = event.split(" ");
		const [_connector, mon] = monAll.split(":");

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

	get monitors() {
		return this._monitors;
	}

	tags(mon) { return this._monitors[mon]?.["tags"] ?? []; }
	layout(mon) { return this._monitors[mon]?.["layout"] ?? JSON.stringify(this._monitors); }
	title(mon) { return this._monitors[mon]?.["title"] ?? ""; }
}

export const Dwl = new DwlService();
globalThis.dwl = Dwl;
