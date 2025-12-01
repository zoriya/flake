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
				chat = {
					window = {
						opts = {
							conceallevel = 3,
						},
					},
				},
			},
			strategies = {
				chat = {
					adapter = "copilot",
					start_in_insert_mode = true,
					keymaps = {
						send = {
							modes = { n = "<C-s>", i = "<C-s>" },
						},
						close = {
							modes = { n = "q", i = "<C-d>" },
						},
					},
					tools = {
						opts = {
							auto_submit_success = true,
							auto_submit_errors = true,
						},

					}
				},
				inline = {
					adapter = "copilot",
				},
			},
		},
		after = function(plug)
			require("codecompanion").setup(plug.opts)
		end,
	},
}
