return {
	{
		"okuuva/auto-save.nvim",
		keys = {
			{ "<leader>w", "<cmd>lua vim.g.auto_save_state = not vim.g.auto_save_state<cr>", desc = "Toggle autosave" },
		},
		event = {
			"InsertLeave",
			"TextChanged",
		},
		opts = {
			write_all_buffers = true,
			execution_message = { enabled = false },
			condition = function(buf)
				if not vim.g.auto_save_state then
					return false
				end
				local ft = vim.fn.getbufvar(buf, "&filetype")
				return ft ~= "oil" and ft ~= "harpoon"
			end,
		},
		init = function() vim.g.auto_save_state = true end,
	},

	{
		"mbbill/undotree",
		keys = {
			{ "<leader>u", vim.cmd.UndotreeToggle, desc = "Show undotree" },
		},
	},
}
