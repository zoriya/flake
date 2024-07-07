import GLib from "gi://GLib?version=2.0"

/**
 * @param {string | null | undefined} name
 * @param {string | null | undefined} fallback
 */
export function icon(name, fallback) {
	if (!name) return fallback || "";

	if (GLib.file_test(name, GLib.FileTest.EXISTS)) return name;

	const sub = substitutes[name];
	if (sub && Utils.lookUpIcon(sub)) return sub;
	if (Utils.lookUpIcon(name)) return name;
	return fallback || "";
}

export const substitutes = {
	"transmission-gtk": "transmission",
	"blueberry.py": "blueberry",
	Caprine: "facebook-messenger",
	"com.raggesilver.BlackBox-symbolic": "terminal-symbolic",
	"org.wezfurlong.wezterm-symbolic": "terminal-symbolic",
	"audio-headset-bluetooth": "audio-headphones-symbolic",
	"audio-card-analog-usb": "audio-speakers-symbolic",
	"audio-card-analog-pci": "audio-card-symbolic",
	"preferences-system": "emblem-system-symbolic",
	"com.github.Aylur.ags-symbolic": "controls-symbolic",
	"com.github.Aylur.ags": "controls-symbolic",
};
