---@type vim.lsp.Config
return {
	cmd = { "kotlin-lsp", "--stdio" },
	-- The import needs the gradle root (the one with settings.gradle), a build.gradle alone
	-- gives a module without its classpath. React native libraries ship an `android/` folder
	-- that is only buildable from an app including it, usually `example/android`.
	-- Sources of libraries in node_modules belong to the app's gradle build too.
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local settings = vim.fs.root(fname, { "settings.gradle", "settings.gradle.kts" })
		if settings then
			return on_dir(settings)
		end
		local pkg = fname:match("^(.-)/node_modules/") or vim.fs.root(fname, "package.json")
		for _, app in ipairs({ "example/android", "android" }) do
			local dir = pkg and vim.fs.joinpath(pkg, app)
			if dir and (vim.uv.fs_stat(dir .. "/settings.gradle") or vim.uv.fs_stat(dir .. "/settings.gradle.kts")) then
				return on_dir(dir)
			end
		end
		on_dir(vim.fs.root(fname, { "build.gradle", "build.gradle.kts", "pom.xml" }))
	end,
}
