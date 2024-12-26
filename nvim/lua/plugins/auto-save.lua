return {
	{
		"auto-save.nvim",
		lazy = false,
		load = function() end,
		keys = {
			{
				"<leader>w",
				function()
					vim.g.auto_save_state = not vim.g.auto_save_state
				end,
				desc = "Toggle autosave"
			},
		},
		event = { "InsertLeave", "TextChanged", },
		opts = {
			write_all_buffers = true,
			condition = function(buf)
				if not vim.g.auto_save_state then
					return false
				end
				local ft = vim.fn.getbufvar(buf, "&filetype")
				return ft ~= "oil" and ft ~= "harpoon"
			end,
		},
		after = function(plug)
			vim.g.auto_save_state = true
			require("auto-save").setup(plug.opt)
		end,
	},
}
