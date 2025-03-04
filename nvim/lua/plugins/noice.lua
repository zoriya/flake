return {
	{
		"noice.nvim",
		event = "DeferredUIEnter",
		keys = {
			{ "<leader>zl", "<cmd>Noice<cr>", desc = "List messages" },
		},
		opts = {
			presets = {
				command_palette = true,
			},
			lsp = {
				signature = {
					auto_open = {
						enabled = false,
					},
				},
			},
			views = {
				mini = {
					timeout = 5000,
					reverse = false,
				},
			},
			routes = {
				-- ignore ltex messages
				{
					filter = {
						event = "lsp",
						kind = "progress",
						cond = function(message)
							local client = vim.tbl_get(message.opts, "progress", "client")
							return client == "ltex" or client == "lua_ls"
						end,
					},
					opts = { skip = true },
				},

			},
		},
		after = function(plug)
			require("noice").setup(plug.opts)
		end,
	},
}
