return {
	{
		"codecompanion",
		keys = {
			{
				"<leader>l",
				"<cmd>CodeCompanionChat Toggle<cr>",
				desc = "Copilot",
				mode = { "n", "v" },
			}
		},
		opts = {
			display = {
				diff = {
					enabled = false,
				},
			},
			strategies = {
				chat = {
					adapter = "copilot",
					model = "claude-3-7-sonnet",
					start_in_insert_mode = true,
					keymaps = {
						send = {
							modes = { n = "<C-s>", i = "<C-s>" },
						},
						close = {
							modes = { n = "q", i = "<C-d>" },
						},
					},
				},
				inline = {
					adapter = "copilot",
					model = "claude-3-7-sonnet",
				},
			},
		},
		after = function(plug)
			require("codecompanion").setup(plug.opts)
		end,
	},

	{
		"render-markdown",
		ft = { "markdown", "codecompanion" },
		opts = {},
		after = function(plug)
			require("render-markdown").setup(plug.opts)
		end,
	},
}
