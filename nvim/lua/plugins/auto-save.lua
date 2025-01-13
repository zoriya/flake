return {
	{
		"auto-save.nvim",
		event = { "InsertLeave", "TextChanged", },
		keys = {
			{
				"<leader>w",
				function()
					vim.g.auto_save_state = not vim.g.auto_save_state
				end,
				desc = "Toggle autosave"
			},
		},
		opts = {
			write_all_buffers = true,
			condition = function(buf)
				if not vim.g.auto_save_state then
					return false
				end
				local ft = vim.fn.getbufvar(buf, "&filetype")
				return ft ~= "oil" and ft ~= "harpoon" and ft ~= "qf"
			end,
		},
		beforeAll = function()
			vim.g.auto_save_state = true
		end,
		after = function(plug)
			require("auto-save").setup(plug.opts)
		end,
	},
}
