import Gtk from "gi://Gtk?version=3.0";
import * as audio from "../modules/audio.js";
import * as brightness from "../modules/brightness.js";
import * as network from "../modules/network.js";
import * as bluetooth from "../modules/bluetooth.js";
import * as darkmode from "../modules/darkmode.js";
import * as powerprofile from "../modules/powerprofile.js";
// import * as nightmode from "../modules/nightmode.js";
import * as mpris from "../modules/mpris.js";
import * as systray from "../modules/systray.js";
import PopupWindow from "../misc/popup.js";
import { opened, Menu } from "../misc/menu.js";

const mprisService = await Service.import("mpris");

/**
 * @param {Array<Gtk.Widget>} toggles
 * @param {Array<Gtk.Widget>} menus
 */
const Row = (toggles = [], menus = []) =>
	Widget.Box({
		vertical: true,
		children: [
			Widget.Box({
				homogeneous: true,
				children: toggles,
			}),
			...menus,
		],
	});

const Header = () =>
	Widget.Box({
		vertical: true,
		children: [
			Widget.Box({
				css: "margin-bottom: 12px",
				children: [
					Widget.Box({
						className: "avatar",
						css: `background-image: url("/home/${Utils.USER}/.face");`,
					}),
					Widget.Box({ hexpand: true }),
					Widget.Button({
						child: Widget.Icon("emblem-system-symbolic"),
						onClicked: () => {
							Utils.execAsync("gnome-control-center");
							App.closeWindow("quicksettings");
						},
						vpack: "center",
						className: "surface sys-button",
					}),
					Widget.Button({
						child: Widget.Icon("system-log-out-symbolic"),
						onClicked: () => {
							opened.value = opened.value === "sleep" ? "" : "sleep";
						},
						vpack: "center",
						css: "margin: 12px",
						className: "surface sys-button",
					}),
					Widget.Button({
						child: Widget.Icon("system-shutdown-symbolic"),
						onClicked: () => {
							opened.value = opened.value === "shutdown" ? "" : "shutdown";
						},
						vpack: "center",
						className: "surface sys-button",
					}),
				],
			}),
			VerificationMenu({
				name: "sleep",
				icon: "system-log-out-symbolic",
				title: "Hybernate?",
				command: "systemctl suspend --now",
			}),
			VerificationMenu({
				name: "shutdown",
				icon: "system-shutdown-symbolic",
				title: "Shutdown?",
				command: "shutdown now",
			}),
		],
	});

/** @param {{
 *    name: string,
 *    icon: string,
 *    title: string,
 *    command: string,
 * }} props */
const VerificationMenu = ({ name, icon, title, command }) =>
	Menu({
		name,
		icon: Widget.Icon(icon),
		title: title,
		content: [
			Widget.Button({
				onClicked: () => {
					opened.value = "";
					Utils.execAsync(command);
				},
				child: Widget.Label({
					label: "Yes",
					hpack: "start",
					css: "margin-left: 12px",
				}),
			}),
			Widget.Button({
				onClicked: () => {
					opened.value = "";
				},
				child: Widget.Label({
					label: "No",
					hpack: "start",
					css: "margin-left: 12px",
				}),
			}),
		],
	});

export const Quicksettings = () =>
	PopupWindow({
		name: "quicksettings",
		exclusivity: "exclusive",
		transition: "slide_down",
		layout: "top-right",
		duration: 300,
		child: Widget.Box({
			vertical: true,
			className: "bgcont qs-container",
			children: [
				Header(),
				Row(
					[audio.Volume({ type: "speaker" })],
					[audio.SinkSelector({}), audio.AppMixer({})],
				),
				brightness.Brightness({}),
				Row(
					[network.Toggle({}), bluetooth.Toggle({})],
					[network.Selection({}), bluetooth.Selection({})],
				),
				Widget.Box({
					homogeneous: true,
					children: [darkmode.Toggle(), audio.MuteToggle({})],
				}),
				Row(
					[systray.Toggle({}), powerprofile.Toggle({})],
					[systray.Selection({}), powerprofile.Selection({})],
				),
				Widget.Box({
					children: mprisService
						.bind("players")
						.as((x) => x.map((player) => mpris.MprisPlayer({ player }))),
				}),
			],
		}),
	});
