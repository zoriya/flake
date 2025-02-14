return {
	{
		"nvim-surround",
		event = "DeferredUIEnter",
		after = function()
			require("nvim-surround").setup({})
		end,
	},

	{
		"vim-wordmotion",
		keys = {
			-- This overrides the default ge & gw but i never used them.
			{ "gw", "<plug>WordMotion_w", desc = "Next small world", mode = { "n", "x", "o" } },
			{ "ge", "<plug>WordMotion_e", desc = "Next end of small world", mode = { "n", "x", "o" } },
			{ "gb", "<plug>WordMotion_b", desc = "Previous small world", mode = { "n", "x", "o" } },
			{ "igw", "<plug>WordMotion_iw", desc = "inner small word", mode = { "x", "o" } },
			{ "agw", "<plug>WordMotion_aw", desc = "a small word (with white-space)", mode = { "x", "o" } },
		},
		before = function()
			-- This never gets applied (ordering issue with wordmotion's autoload)
			-- This is also set in `settings.lua` but kept here for documentation purposes
			vim.g.wordmotion_nomap = true
		end,
	},

	{
		"increment-activator",
		keys = {
			{ "<C-A>", desc = "Increment" },
			{ "<C-X>", desc = "Decrement" },
		},
	},

	{
		"leap.nvim",
		keys = {
			{ "s", "<Plug>(leap-forward-till)", mode = { "n", "x", }, desc = "Leap forward to" },
			{ "S", "<Plug>(leap-backward)", mode = { "n", "x", }, desc = "Leap backward to" },
			{ "z", "<Plug>(leap-forward-till)", mode = "o", desc = "Leap forward to" },
			{ "Z", "<Plug>(leap-backward)", mode = "o", desc = "Leap backward to" },
		},
	},

	{
		"flit.nvim",
		keys = { "f", "F", "t", "T" },
		after = function()
			require("flit").setup()
		end,
	},
}
