return {
	{
		"oil.nvim",
		lazy = false,
		load = function() end,
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
		after = function(plug)
			require("oil").setup(plug.opts)
		end
	}
}
