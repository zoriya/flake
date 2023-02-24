return {
	{
		"zoriya/auto-save.nvim",
		keys = {
			{"<leader>w", "<cmd>ASToggle<cr>", desc = "Toggle autosave" },
		},
		event = {
			"InsertLeave",
			"TextChanged",
		},
		opts = {
			write_all_buffers = true,
			print_enabled = false,
			callbacks = {
				enabling = function() vim.g.auto_save_state = true end,
				disabling = function() vim.g.auto_save_state = false end,
			}
		},
		init = function () vim.g.auto_save_state = true end
	},
}
