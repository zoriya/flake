return {
	{
		"opencode-nvim",
		keys = {
			{
				"<leader>l",
				function() require("opencode").toggle() end,
				desc = "Opencode",
				mode = { "n", "v" },
			}
		},
		---@type opencode.Opts
		opts = {
			provider = {
				enabled = "terminal",
			}
		},
		after = function(plug)
			vim.g.opencode_opts = plug.opts
		end,
	},
}
