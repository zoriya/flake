---@type opencode.Opts
vim.g.opencode_opts = {
	provider = {
		enabled = "terminal",
	}
}

return {
	{
		"opencode-nvim",
		keys = {
			{
				"<leader>l",
				function() require("opencode").toggle() end,
				desc = "Opencode",
				mode = { "n", "v" },
			},
			{

				"gl",
				function() return require("opencode").operator("@this ") end,
				desc = "Add range to opencode",
				mode = { "n", "x" },
			},
			{
				"gll",
				function() return require("opencode").operator("@this ") .. "_" end,
				desc = "Add line to opencode",
			},
		},
	},
}
