import App from 'resource:///com/github/Aylur/ags/app.js';
import Service from 'resource:///com/github/Aylur/ags/service.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Brightness from '../services/brightness.js';
import { timeout } from 'resource:///com/github/Aylur/ags/utils.js';

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
		const value = Audio.speaker.volume;
		const icon = (value) => {
			const icons = [];
			icons[0] = "audio-volume-muted-symbolic";
			icons[1] = "audio-volume-low-symbolic";
			icons[34] = "audio-volume-medium-symbolic";
			icons[67] = "audio-volume-high-symbolic";
			icons[101] = "audio-volume-overamplified-symbolic";
			if (Audio.speaker.isMuted) return icons[0];
			for (const i of [101, 67, 34, 1, 0]) {
				if (i <= value * 100) return icons[i];
			}
		};
		this.popup(value, icon(value));
	}

	display() {
		// brightness is async, so lets wait a bit
		timeout(10, () => {
			const value = Brightness.screen;
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
			const value = Brightness.kbd;
			this.popup((value * 33 + 1) / 100, "keyboard-brightness-symbolic");
		});
	}
	//
	// connectWidget(widget, callback) {
	// 	connect(this, widget, callback, "popup");
	// }
}

export const Indicator = new IndicatorService();
export default Indicator;
globalThis.indicator = Indicator;
