local function scratch()
	local fts = vim.fn.getcompletion("", "filetype")
	vim.ui.select(fts, {
		prompt = "Scratch ft",
	}, function(ft)
		if ft == nil then
			return
		end
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_set_option_value("filetype", ft, { buf = buf })
		vim.api.nvim_set_current_buf(buf)
	end)
end

vim.keymap.set("n", "<leader>s", scratch, { desc = "Scratch" })

return {}
