import Service from 'resource:///com/github/Aylur/ags/service.js';
import { exec, execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

class BrightnessService extends Service {
	static {
		Service.register(this, {}, { "screen": ["float", "rw"]});
	}

	_screen = 0;

	get screen() { return this._screen; }

	set screen(percent) {
		if (percent < 0)
			percent = 0;

		if (percent > 1)
			percent = 1;

		execAsync(`brightnessctl s ${percent * 100}% -q`)
			.then(() => {
				this._screen = percent;

				this.emit('changed');
				this.notify('screen');
			})
			.catch(print);
	}

	constructor() {
		super();
		const current = Number(exec('brightnessctl g'));
		const max = Number(exec('brightnessctl m'));
		this._screen = current / max;
	}
}

export const Brightness = new BrightnessService();
export default Brightness;
globalThis.brightness = Brightness;
