const { App, Service } = ags;
const { Box, Button, Icon } = ags.Widget;
const { timeout } = ags.Utils;

export class QSMenu extends Service {
	static {
		Service.register(this);
	}
	static instance = new QSMenu();
	static opened = "";
	static toggle(menu) {
		QSMenu.opened = QSMenu.opened === menu ? "" : menu;
		QSMenu.instance.emit("changed");
	}

	constructor() {
		super();
		App.instance.connect("window-toggled", (_a, name, visible) => {
			if (name === "quicksettings" && !visible) {
				QSMenu.opened = "";
				QSMenu.instance.emit("changed");
			}
		});
	}
}

export const ArrowToggle = ({ icon, label, toggle, name, expand, ...props }) => {
	icon.className = `${icon.className} qs-icon`;
	return Box({
		className: "qs-button surface",
		children: [
			Button({
				hexpand: true,
				onClicked: toggle,
				child: Box({
					children: [icon, label],
				}),
			}),
			Arrow({ name, expand }),
		],
		...props,
	});
};

export const Arrow = ({ name, expand, ...props }) =>
	Button({
		...props,
		className: "qs-icon",
		onClicked: () => {
			QSMenu.toggle(name);
			if (expand && QSMenu.openned == name) expand();
		},
		connections: [
			[
				QSMenu,
				(button) => {
					button.toggleClassName("opened", QSMenu.opened === name);
				},
			],
		],
		child: Icon({
			icon: "pan-end-symbolic",
			properties: [
				["deg", 0],
				["opened", false],
			],
			connections: [
				[
					QSMenu,
					(icon) => {
						if ((QSMenu.opened === name && !icon._opened) || (QSMenu.opened !== name && icon._opened)) {
							const step = QSMenu.opened === name ? 10 : -10;
							icon._opened = !icon._opened;
							for (let i = 0; i < 9; ++i) {
								timeout(5 * i, () => {
									icon._deg += step;
									icon.setStyle(`-gtk-icon-transform: rotate(${icon._deg}deg);`);
								});
							}
						}
					},
				],
			],
		}),
	});
