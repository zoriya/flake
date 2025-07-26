return {
	{
		"sniprun",
		keys = {
			{ "<leader>r", "<cmd>SnipRun<cr>", desc = "Run code", mode = { "n", "v" } },
			{ "<leader>r", "<Plug>SnipRunOperator", desc = "Run code", mode = { "o" } },
		},
		opts = {
			repl_enable = {},

			display = { "VirtualLine", },
			live_display = { "VirtualTextOk" },
			show_no_output = { "Classic" },

			ansi_escape = true,
		},
		after = function(plug)
			require("sniprun").setup(plug.opts)
		end,
	},
}
