import Gdk from "gi://Gdk?version=3.0";
import Gtk from "gi://Gtk?version=3.0";
import Lock from "gi://GtkSessionLock";
import AstalAuth from "gi://AstalAuth";

import { Clock } from "./modules/clock.js";

export const DELAY = 500;

export const isLocked = Variable(false);
export const prompt = Variable("");
export const inputVisible = Variable(false);
export const inputNeeded = Variable(false);
export const error = Variable(
	/** @type {{type: "info" | "error" | "fail", message: string} | null} */ (
		null
	),
);

const auth = new AstalAuth.Pam();
let lock;
let windows = [];

let hasInit = false;

function init() {
	if (hasInit) return;
	hasInit = true;
	auth.connect("auth-prompt-visible", (auth, msg) => {
		prompt.setValue(msg);
		inputVisible.setValue(true);
		inputNeeded.setValue(true);
	});
	auth.connect("auth-prompt-hidden", (auth, msg) => {
		prompt.setValue(msg);
		inputVisible.setValue(false);
		inputNeeded.setValue(true);
	});

	auth.connect("auth-error", (_, msg) => {
		error.setValue({ message: msg, type: "error" });
		auth.supply_secret(null);
	});
	auth.connect("auth-info", (_, msg) => {
		error.setValue({ message: msg, type: "info" });
		auth.supply_secret(null);
	});

	auth.connect("success", unlock);
	auth.connect("fail", (p, msg) => {
		error.setValue({ message: msg, type: "fail" });
		auth.start_authenticate();
	});

	const display = Gdk.Display.get_default();
	display?.connect("monitor-added", (disp, monitor) => {
		if (!isLocked.value) return;
		const w = createWindow(monitor);
		lock.new_surface(w.window, w.monitor);
		w.window.show();
	});
	display?.connect("monitor-removed", (disp, monitor) => {
		if (!isLocked.value) return;
		windows.forEach((win) => {
			lock.unmap_lock_window(win.window);
			win.window.destroy();
		});
	});
}

export function lockscreen() {
	init();
	lock = Lock.prepare_lock();
	lock.connect("locked", () => {});
	lock.connect("finished", unlock);

	const display = Gdk.Display.get_default();
	const n = display?.get_n_monitors() || 1;
	for (let m = 0; m < n; m++) {
		const monitor = display?.get_monitor(m);
		// @ts-ignore
		createWindow(monitor);
	}

	lock.lock_lock();
	isLocked.value = true;
	windows.map((w) => {
		lock.new_surface(w.window, w.monitor);
		w.window.show();
	});
	auth.start_authenticate();
}

/**
 * @param {string} password
 */
export function login(password) {
	inputNeeded.setValue(false);
	auth.supply_secret(password);
}

function unlock() {
	isLocked.value = false;

	// Wait for window's hide animations to finish
	Utils.timeout(DELAY, () => {
		windows.forEach((w) => {
			Lock.unmap_lock_window(w.window);
		});
		lock.unlock_and_destroy();
		windows.forEach((w) => {
			w.window.destroy();
		});
		windows = [];
		lock = undefined;

		Gdk.Display.get_default()?.sync();
	});
}

/**
 * @param {Gdk.Monitor} monitor
 */
function createWindow(monitor) {
	const window = LockWindow();
	const win = { window, monitor };
	windows.push(win);
	return win;
}

const LoginBox = () =>
	Widget.Box({
		vertical: true,
		vpack: "center",
		hpack: "center",
		spacing: 16,
		children: [
			Widget.Box({
				hpack: "center",
				className: "avatar",
				css: `background-image: url("/home/${Utils.USER}/.face");`,
			}),
			Widget.Box({
				className: inputNeeded
					.bind()
					.as((n) => `entry-box ${n ? "" : "hidden"}`),
				vertical: true,
				children: [
					Widget.Label({
						label: prompt.bind(),
					}),
					Widget.Separator(),
					Widget.Entry({
						hpack: "center",
						xalign: 0.5,
						visibility: inputVisible.bind(),
						sensitive: inputNeeded.bind(),
						onAccept: (self) => {
							login(self.text || "");
							self.text = "";
						},
					}).on("realize", (entry) => entry.grab_focus()),
					Widget.Label({
						label: error.bind().as((x) => x?.message || ""),
						visible: error.bind().as((x) => !!x),
					}),
				],
			}),
		],
	});

export const LockWindow = () =>
	new Gtk.Window({
		child: Widget.Box({
			hexpand: true,
			vexpand: true,
			children: [
				Widget.Revealer({
					reveal_child: false,
					transition: "crossfade",
					transition_duration: DELAY,
					hexpand: true,
					vexpand: true,
					child: Widget.Box({
						css: `
							background-image: url("/home/${Utils.USER}/.cache/current-wallpaper");
							background-position: center;
							background-size: cover;
						`,
						vertical: true,
						hexpand: true,
						vexpand: true,
						child: LoginBox(),
					}),
				}).on("realize", (self) =>
					Utils.idle(() => {
						self.reveal_child = true;
					}),
				),
			],
		}),
	});
