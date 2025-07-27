return {
	{
		"sniprun",
		keys = {
			{ "<leader>r", "<cmd>SnipRun<cr>", desc = "Run code", mode = { "v" } },
			{ "<leader>r", "<Plug>SnipRunOperator", desc = "Run code", mode = { "n" } },
			{ "<leader>rr", "<cmd>SnipRun<cr>", desc = "Run code", mode = { "n" } },
		},
		opts = {
			repl_enable = {},

			display = { "VirtualLine", },
			live_display = { "VirtualTextOk" },
			show_no_output = { "Classic" },

			snipruncolors = {
				SniprunVirtualTextOk = { link = "Delimiter" },
				SniprunVirtualTextErr = { link = "Error" },
			},

			ansi_escape = true,
		},
		after = function(plug)
			require("sniprun").setup(plug.opts)
		end,
	},
}
