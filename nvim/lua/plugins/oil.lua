return {
	{
		"oil.nvim",
		lazy = false,
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
				["~"] = false,
				["%"] = "actions.yank_entry",
			},
		},
		after = function(plug)
			require("oil").setup(plug.opts)
			vim.cmd.cabbr({ args = { "<expr>", "%", "&filetype == 'oil' ? bufname('%')[6:] : '%'" } })
		end
	}
}
