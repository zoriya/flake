local function scratch()
	local fts = vim.fn.getcompletion("", "filetype")
	vim.ui.select(fts, {
		prompt = "Scratch ft",
	}, function(ft)
		if ft == nil then
			return
		end

		if vim.loop.fs_stat("/tmp/scratch") == nil then
			vim.loop.fs_mkdir("/tmp/scratch", 448) -- 0o700
		end

		local buf = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_buf_set_name(buf, "/tmp/scratch/" .. tostring(os.time()) .. "." .. ft)
		vim.api.nvim_set_option_value("filetype", ft, { buf = buf })
		vim.api.nvim_set_current_buf(buf)
	end)
end

vim.keymap.set("n", "<leader>s", scratch, { desc = "Scratch" })

return {}
