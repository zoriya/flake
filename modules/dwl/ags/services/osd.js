import Service from 'resource:///com/github/Aylur/ags/service.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Brightness from '../services/brightness.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

class Indicator extends Service {
	static {
		Service.register(this, {
			'popup': ['double', 'string'],
		});
	}

	#delay = 1500;
	#count = 0;

	/**
	 * @param {number} value - 0 < v < 1
	 * @param {string} icon
	 */
	popup(value, icon) {
		this.emit('popup', value, icon);
		this.#count++;
		Utils.timeout(this.#delay, () => {
			this.#count--;

			if (this.#count === 0)
				this.emit('popup', -1, icon);
		});
	}

	speaker() {
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

			return icon;
		}
		this.popup(
			Audio.speaker.volume,
			icon(Audio.speaker.volume),
		);
	}

	display() {
		// brightness is async, so lets wait a bit
		Utils.timeout(10, () => this.popup(
			Brightness.screen,
			"display-brightness-symbolic"));
	}

	kbd() {
		// brightness is async, so lets wait a bit
		Utils.timeout(10, () => this.popup(
			(Brightness.kbd * 33 + 1) / 100,
			"keyboard-brightness-symbolic"));
	}

	connect(event = 'popup', callback) {
		return super.connect(event, callback);
	}
}

const indicator = new Indicator();
globalThis.indicator = indicator;
export default indicator;
