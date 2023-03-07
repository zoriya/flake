return {
	{
		"ggandor/leap.nvim",
		keys = {
			{ "s", "<Plug>(leap-forward-till)", mode = { "n", "x", }, desc = "Leap forward to" },
			{ "S", "<Plug>(leap-backward-till)", mode = { "n", "x", }, desc = "Leap backward to" },
			{ "z", "<Plug>(leap-forward-till)", mode = "o", desc = "Leap forward to" },
			{ "Z", "<Plug>(leap-backward-till)", mode = "o", desc = "Leap backward to" },
		},
	},
	{ "tpope/vim-repeat", event = "VeryLazy" },

	{
		"ThePrimeagen/harpoon",
		keys = {
			{ "<leader>a", '<cmd>lua require("harpoon.mark").add_file()<CR>', desc = "Mark file" },
			{ "<leader>h", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>', desc = "Harpoon menu" },

			{ "<C-H>", '<cmd>lua require("harpoon.ui").nav_file(1)<CR>', desc = "Navigate to harpoon 1" },
			{ "<C-T>", '<cmd>lua require("harpoon.ui").nav_file(2)<CR>', desc = "Navigate to harpoon 2" },
			{ "<C-N>", '<cmd>lua require("harpoon.ui").nav_file(3)<CR>', desc = "Navigate to harpoon 3" },
			{ "<C-S>", '<cmd>lua require("harpoon.ui").nav_file(4)<CR>', desc = "Navigate to harpoon 4" },

			-- <C-;> is not a valid sequence so use HJKL instead.
			{ "<C-H>", '<cmd>lua require("harpoon.ui").nav_file(1)<CR>', desc = "Navigate to harpoon 1" },
			{ "<C-J>", '<cmd>lua require("harpoon.ui").nav_file(2)<CR>', desc = "Navigate to harpoon 2" },
			{ "<C-K>", '<cmd>lua require("harpoon.ui").nav_file(3)<CR>', desc = "Navigate to harpoon 3" },
			-- <C-L> is already taken but since I use harpoon less on querty no worry
		},
		opts = {
			mark_branch = true,
			menu = {
				width = 100,
			},
		},
	},

	"tpope/vim-unimpaired",
	"tpope/vim-sleuth",

	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = true,
	},

	{
		"nishigori/increment-activator",
		keys = {
			{ "<C-A>", desc = "Increment" },
			{ "<C-X>", desc = "Decrement" },
		},
	},

	{
		"vim-scripts/ReplaceWithRegister",
		keys = {
			{ "cr", "<Plug>ReplaceWithRegisterOperator", desc = "Replace with register" },
			{ "cR", '"+cr', desc = "Replace with system clipboard" },
		},
	},

	{
		"chaoren/vim-wordmotion",
		keys = {
			{ "gw", "<plug>WordMotion_w", desc = "Next small world", mode = { "n", "x", "o" } },
			-- This overrides the default ge but i never used it.
			{ "ge", "<plug>WordMotion_e", desc = "Next end of small world", mode = { "n", "x", "o" } },
			{ "gb", "<plug>WordMotion_b", desc = "Previous small world", mode = { "n", "x", "o" } },

			{ "igw", "<plug>WordMotion_iw", desc = "inner small word", mode = { "x", "o" } },
			{ "agw", "<plug>WordMotion_aw", desc = "a small word (with white-space)", mode = { "x", "o" } },
		},
		init = function () vim.g.wordmotion_nomap = true end,
	},

	{
		"echasnovski/mini.align",
		keys = {
			{"ga", desc = "Align" },
			{"gA", desc = "Align with preview" }
		},
		config = function() require('mini.align').setup() end,
		version = '*',
	},
}
