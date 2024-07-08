import { getIcon } from "../modules/audio.js";
import brightness from "../services/brightness.js";

const audio = await Service.import("audio");

const DELAY = 1000;

function OnScreenProgress() {
	const indicator = Widget.Icon({
		vpack: "start",
		hpack: "center",
		size: 30,
		css: "padding-right: 12px;",
	});
	const progress = Widget.Slider({
		drawValue: false,
		hexpand: true,
	});
	const revealer = Widget.Revealer({
		transition: "crossfade",
		css: "opacity: 0",
		revealChild: true,
		vpack: "center",
		hpack: "center",
		child: Widget.Box({
			vpack: "center",
			hpack: "center",
			className: "osd bgcount",
			css: "padding: 20px;",
			children: [indicator, progress],
		}),
	});
	// Prevent OSD to be shown when starting ags.
	Utils.timeout(DELAY * 2, () => {
		revealer.css = "opacity: 1";
	});

	let count = 0;
	/**
	 * @param {number} value
	 * @param {string} icon
	 */
	function show(value, icon) {
		revealer.reveal_child = true;
		indicator.icon = icon;
		progress.value = value;
		count++;
		Utils.timeout(DELAY, () => {
			count--;
			if (count === 0) revealer.reveal_child = false;
		});
	}
	return revealer
		.hook(
			brightness,
			() => show(brightness.screen, "display-brightness-symbolic"),
			"notify::screen",
		)
		.hook(
			audio.speaker,
			() => show(audio.speaker.volume, getIcon(audio.speaker.volume * 100)),
			"notify::volume",
		)
		.hook(
			audio.speaker,
			() =>
				show(
					audio.speaker.is_muted ? 0 : audio.speaker.volume,
					audio.speaker.is_muted
						? "audio-volume-muted-symbolic"
						: getIcon(audio.speaker.volume * 100),
				),
			"notify::is-muted",
		);
}

export const OSD = () =>
	Widget.Window({
		name: "osd",
		className: "indicator",
		layer: "overlay",
		clickThrough: true,
		anchor: ["bottom"],
		child: OnScreenProgress(),
	});
