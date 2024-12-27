return {
	{
		"noice.nvim",
		lazy = false,
		load = function() end,
		opts = {
			presets = {
				command_palette = true,
			},
			signature = {
				auto_open = {
					enabled = false,
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
							return client == "ltex"
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
