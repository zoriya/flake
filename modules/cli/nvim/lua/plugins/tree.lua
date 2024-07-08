return {
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
			{ "<BS>", "<CMD>Oil<CR>", desc = "Open parent directory" },
		},
		opts = {
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
			},
			keymaps = {
				["<BS>"] = "actions.parent",

				-- Disable default mappings that conflict with harpoon.
				["<C-h>"] = false,
				["<C-t>"] = false,
			},
		},
	},
}
