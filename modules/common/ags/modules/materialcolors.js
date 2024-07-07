/** @param {import("types/service/mpris").MprisPlayer} player */
export const getMaterialColors = (player) => {
	const ret = Variable({
		primary: "#222222",
		onPrimary: "#ffffff",
		background: "#222222",
		onBackground: "#ffffff",
		coverPath: "",
	});

	player.bind("cover_path").as((cover) => {
		Utils.timeout(100, () => {
			Utils.execAsync(["covercolors", cover])
				.then((colors) => {
					const col = JSON.parse(colors);
					if (!col) return;
					col.coverPath = cover;
					ret.setValue(col);
				})
				.catch(print);
		});
	});

	return ret;
};

