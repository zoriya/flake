import { ArrowToggleButton, Menu } from "../misc/menu.js";

const powerProfiles = await Service.import("powerprofiles");

/** @param {string} x */
const capitalize = (x) => x.charAt(0).toUpperCase() + x.slice(1);

/** @param {Partial<import("misc/menu").ArrowToggleButtonProps>} props */
export const Toggle = (props) =>
	ArrowToggleButton({
		name: "powerprofile",
		icon: Widget.Icon({
			icon: powerProfiles.bind("icon_name"),
			className: "qs-icon",
		}),
		label: Widget.Label({
			label: powerProfiles.bind("active_profile").as(capitalize),
			truncate: "end",
			max_width_chars: 20,
		}),
		activate: () => {},
		deactivate: () => {},
		connection: [powerProfiles, () => false],
		...props,
	});

/** @param {Partial<import("../misc/menu.js").MenuProps>} props */
export const Selection = (props) =>
	Menu({
		name: "powerprofile",
		icon: Widget.Icon({ icon: powerProfiles.bind("icon_name") }),
		title: "Power profile",
		// Hard coding the list of profiles since ags does not give them.
		content: ["power-saver", "balanced", "performance"].map(ProfileItem),
		...props,
	});

/** @param {string} profile */
const ProfileItem = (profile) =>
	Widget.Button({
		onClicked: () => (powerProfiles.active_profile = profile),
		child: Widget.Box({
			children: [
				Widget.Icon({
					icon: `power-profile-${profile}-symbolic`,
				}),
				Widget.Label({
					label: capitalize(profile),
					truncate: "end",
					maxWidthChars: 28,
				}),
				Widget.Icon({
					icon: "object-select-symbolic",
					hexpand: true,
					hpack: "end",
					visible: powerProfiles
						.bind("active_profile")
						.as((x) => x === profile),
				}),
			],
		}),
	});
