export const Spinner = ({ icon = "process-working-symbolic" }) =>
	Icon({
		icon,
		properties: [["deg", 0]],
		connections: [
			[
				10,
				(w) => {
					w.setStyle(`-gtk-icon-transform: rotate(${w._deg++ % 360}deg);`);
				},
			],
		],
	});
