return {
	{
		"nvim-surround",
		lazy = false,
		load = function() end,
		after = function()
			require("nvim-surround").setup({})
		end,
	},

	{
		"vim-wordmotion",
		lazy = false,
		load = function() end,
		keys = {
			-- This overrides the default ge & gw but i never used them.
			{ "gw",  "<plug>WordMotion_w",  desc = "Next small world",                mode = { "n", "x", "o" } },
			{ "ge",  "<plug>WordMotion_e",  desc = "Next end of small world",         mode = { "n", "x", "o" } },
			{ "gb",  "<plug>WordMotion_b",  desc = "Previous small world",            mode = { "n", "x", "o" } },
			{ "igw", "<plug>WordMotion_iw", desc = "inner small word",                mode = { "x", "o" } },
			{ "agw", "<plug>WordMotion_aw", desc = "a small word (with white-space)", mode = { "x", "o" } },
		},
		after = function()
			vim.g.wordmotion_nomap = true
		end,
	},

	{
		"increment-activator",
		lazy = false,
		load = function() end,
		keys = {
			{ "<C-A>", desc = "Increment" },
			{ "<C-X>", desc = "Decrement" },
		},
	},
}
