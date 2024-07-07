const screen = await Utils.execAsync(
	"bash -c 'ls -w1 /sys/class/backlight | head -n 1'",
);
const max = Number(await Utils.execAsync("brightnessctl m"));

class Brightness extends Service {
	static {
		Service.register(this, {}, { screen: ["float", "rw"] });
	}

	#screen = 0;

	get screen() {
		return this.#screen;
	}

	set screen(percent) {
		if (percent < 0) percent = 0;

		if (percent > 1) percent = 1;

		Utils.execAsync(`brightnessctl s ${percent * 100}% -q`)
			.then(() => {
				this.#screen = percent;

				this.emit("changed");
				this.notify("screen");
			})
			.catch(print);
	}

	constructor() {
		super();
		this.#screen = Number(Utils.exec("brightnessctl g")) / max;

		const screenPath = `/sys/class/backlight/${screen}/brightness`;

		Utils.monitorFile(screenPath, async (f) => {
			const v = await Utils.readFileAsync(f);
			this.#screen = Number(v) / max;
			this.changed("screen");
		});
	}
}
export default new Brightness();
