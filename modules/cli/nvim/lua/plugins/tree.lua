return {
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { {
			"echasnovski/mini.icons",
			config = function(_, opts)
				require("mini.icons").setup(opts);
				MiniIcons.mock_nvim_web_devicons()
			end
		} },
		keys = {
			{ "-",    "<CMD>Oil<CR>", desc = "Open parent directory" },
			{ "<BS>", "<CMD>Oil<CR>", desc = "Open parent directory" },
		},
		opts = {
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
			},
			keymaps = {
				["<BS>"] = "actions.parent",
			},
		},
	},
}
