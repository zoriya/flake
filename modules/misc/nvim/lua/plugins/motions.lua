return {
	{
		"ggandor/leap.nvim",
		keys = {
			{ "s",  "<Plug>(leap-forward-till)", mode = { "n", "x", }, desc = "Leap forward to" },
			{ "S",  "<Plug>(leap-backward)",     mode = { "n", "x", }, desc = "Leap backward to" },
			{ "z",  "<Plug>(leap-forward-till)", mode = "o",           desc = "Leap forward to" },
			{ "Z",  "<Plug>(leap-backward)",     mode = "o",           desc = "Leap backward to" },
		},
	},

	{
		"ggandor/flit.nvim",
		keys = { "f", "F", "t", "T" },
		opts = true,
	},

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		keys = {
			{ "<leader>a", '<cmd>lua require("harpoon"):list():add()<CR>',                                    desc = "Mark file" },
			{ "<leader>h", '<cmd>lua require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())<CR>', desc = "Harpoon menu" },
			{ "<A-h>",     '<cmd>lua require("harpoon"):list():select(1)<CR>',                                desc = "Navigate to harpoon 1" },
			{ "<A-t>",     '<cmd>lua require("harpoon"):list():select(2)<CR>',                                desc = "Navigate to harpoon 2" },
			{ "<A-n>",     '<cmd>lua require("harpoon"):list():select(3)<CR>',                                desc = "Navigate to harpoon 3" },
			{ "<A-s>",     '<cmd>lua require("harpoon"):list():select(4)<CR>',                                desc = "Navigate to harpoon 4" },

			-- <C-;> is not a valid sequence so use HJKL instead.
			{ "<A-j>",     '<cmd>lua require("harpoon"):list():select(2)<CR>',                                desc = "Navigate to harpoon 2" },
			{ "<A-k>",     '<cmd>lua require("harpoon"):list():select(3)<CR>',                                desc = "Navigate to harpoon 3" },
			-- <C-L> is already taken but since I use harpoon less on querty no worry
		},
		config = function(_, opts)
			require("harpoon"):setup(opts)
		end,
		opts = {
			settings = {
				save_on_toggle = true,
			},
		},
	},

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
			{ "cr",         "<Plug>ReplaceWithRegisterOperator",   desc = "Replace with register" },
			{ "<leader>cr", '"+<Plug>ReplaceWithRegisterOperator', desc = "Replace with system clipboard" },
		},
	},

	{
		"chaoren/vim-wordmotion",
		keys = {
			{ "gw",  "<plug>WordMotion_w",  desc = "Next small world",                mode = { "n", "x", "o" } },
			-- This overrides the default ge but i never used it.
			{ "ge",  "<plug>WordMotion_e",  desc = "Next end of small world",         mode = { "n", "x", "o" } },
			{ "gb",  "<plug>WordMotion_b",  desc = "Previous small world",            mode = { "n", "x", "o" } },
			{ "igw", "<plug>WordMotion_iw", desc = "inner small word",                mode = { "x", "o" } },
			{ "agw", "<plug>WordMotion_aw", desc = "a small word (with white-space)", mode = { "x", "o" } },
		},
		init = function() vim.g.wordmotion_nomap = true end,
	},

	{
		"echasnovski/mini.align",
		keys = {
			{ "ga", desc = "Align" },
			{ "gA", desc = "Align with preview" }
		},
		config = true,
		version = '*',
	},

	{
		"echasnovski/mini.splitjoin",
		keys = {
			{ "gS", desc = "Split arguments" },
			{ "gJ", desc = "Join arguments" },
		},
		opts = {
			mappings = {
				toggle = '',
				split = 'gS',
				join = 'gJ',
			},
		},
		version = '*',
	},
}
