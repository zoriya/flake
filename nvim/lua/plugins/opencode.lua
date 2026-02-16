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
			vim.keymap.set({ "n", "x" }, "gl", function() return require("opencode").operator("@this ") end,
				{ desc = "Add range to opencode", expr = true })
			vim.keymap.set("n", "gll", function() return require("opencode").operator("@this ") .. "_" end,
				{ desc = "Add line to opencode", expr = true })
		end,
	},
}
