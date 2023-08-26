const { App, Service } = ags;
const { timeout, connect } = ags.Utils;

class IndicatorService extends Service {
	static {
		Service.register(this, {
			popup: ["double", "string"],
		});
	}

	_openned = false;
	_delay = 1500;
	_closeDelay = 300;
	_count = 0;

	popup(value, icon) {
		if (!this._openned) App.openWindow("osd");
		this.emit("popup", value, icon);
		this._count++;
		timeout(this._delay, () => {
			this._count--;

			if (this._count !== 0) return;
			this.emit("popup", -1, icon);
			timeout(this._closeDelay, () => {
				if (this._count !== 0) return;
				App.closeWindow("osd");
				this._openned = false;
			});
		});
	}

	speaker() {
		const value = ags.Service.Audio.speaker.volume;
		const icon = (value) => {
			const icons = [];
			icons[0] = "audio-volume-muted-symbolic";
			icons[1] = "audio-volume-low-symbolic";
			icons[34] = "audio-volume-medium-symbolic";
			icons[67] = "audio-volume-high-symbolic";
			icons[101] = "audio-volume-overamplified-symbolic";
			if (ags.Service.Audio.speaker.isMuted) return icons[0];
			for (const i of [101, 67, 34, 1, 0]) {
				if (i <= value * 100) return icons[i];
			}
		};
		this.popup(value, icon(value));
	}

	display() {
		// brightness is async, so lets wait a bit
		timeout(10, () => {
			const value = ags.Service.Brightness.screen;
			const icon = (value) => {
				const icons = ["󰛩", "󱩎", "󱩏", "󱩐", "󱩑", "󱩒", "󱩓", "󱩔", "󱩕", "󱩖", "󰛨"];
				return icons[Math.ceil(value * 10)];
			};
			this.popup(value, icon(value));
		});
	}

	kbd() {
		// brightness is async, so lets wait a bit
		timeout(10, () => {
			const value = ags.Service.Brightness.kbd;
			this.popup((value * 33 + 1) / 100, "keyboard-brightness-symbolic");
		});
	}

	connectWidget(widget, callback) {
		connect(this, widget, callback, "popup");
	}
}

export class Indicator {
	static {
		Service.export(this, "Indicator");
	}
	static instance = new IndicatorService();
	static popup(value, icon) {
		Indicator.instance.popup(value, icon);
	}
	static speaker() {
		Indicator.instance.speaker();
	}
	static display() {
		Indicator.instance.display();
	}
	static kbd() {
		Indicator.instance.kbd();
	}
}
