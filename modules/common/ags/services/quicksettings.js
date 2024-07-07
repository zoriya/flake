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
