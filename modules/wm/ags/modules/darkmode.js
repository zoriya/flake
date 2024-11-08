import Gio from "gi://Gio";
import { SimpleToggleButton } from "../misc/menu.js";

const interfaceXml = `
<node name="/nl/whynothugo/darkman">
   <interface name="nl.whynothugo.darkman">
      <signal name="ModeChanged">
         <arg name="NewMode" type="s" />
      </signal>
      <property name="Mode" type="s" access="readwrite">
         <annotation name="org.freedesktop.DBus.Property.EmitsChangedSignal" value="true" />
      </property>
   </interface>
</node>
`;
const Darkman = Gio.DBusProxy.makeProxyWrapper(interfaceXml);

const theme = Variable(/** @type {"light" | "dark"} */ ("light"));

/** @param {Partial<import("../misc/menu.js").SimpleToggleButtonProps>} props */
export const Toggle = ({ ...props } = {}) =>
	SimpleToggleButton({
		icon: Widget.Icon({
			className: "qs-icon",
			icon: theme
				.bind()
				.as((x) =>
					x === "light"
						? "weather-clear-symbolic"
						: "weather-clear-night-symbolic",
				),
		}),
		label: Widget.Label({
			label: theme.bind().as((x) => (x === "light" ? "Light" : "Dark")),
		}),
		activate: () => theme.setValue("dark"),
		deactivate: () => theme.setValue("light"),
		connection: [theme, () => theme.value === "dark"],
		...props,
	});

function init() {
	const darkman = Darkman(
		Gio.DBus.session,
		"nl.whynothugo.darkman",
		"/nl/whynothugo/darkman",
	);

	theme.value = darkman.Mode;
	theme.connect("changed", () => {
		darkman.Mode = theme.value;
	});
	darkman.connectSignal("ModeChanged", (_proxy, _senderName, nTheme) => {
		theme.value = nTheme[0];
	});
}
init();
