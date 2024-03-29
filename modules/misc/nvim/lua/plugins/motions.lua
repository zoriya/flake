return {
	{

		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			search = {
				multi_window = false,
			},
			modes = {
				search = { enabled = false, },
				char = { highlight = { backdrop = false } },
			}
		},
		keys = {
			{ "s", mode = { "n", "x" }, function() require("flash").jump() end, desc = "Flash" },
			{ "z", mode = "o",          function() require("flash").jump() end, desc = "Flash" },
			"f",
			"F",
			"t",
			"T",
		},

	},

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		keys = {
			{ "<leader>a", '<cmd>lua require("harpoon"):list():append()<CR>',                                 desc = "Mark file" },
			{ "<leader>h", '<cmd>lua require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())<CR>', desc = "Harpoon menu" },
			{ "<C-H>",     '<cmd>lua require("harpoon"):list():select(1)<CR>',                                desc = "Navigate to harpoon 1" },
			{ "<C-T>",     '<cmd>lua require("harpoon"):list():select(2)<CR>',                                desc = "Navigate to harpoon 2" },
			{ "<C-N>",     '<cmd>lua require("harpoon"):list():select(3)<CR>',                                desc = "Navigate to harpoon 3" },
			{ "<C-S>",     '<cmd>lua require("harpoon"):list():select(4)<CR>',                                desc = "Navigate to harpoon 4" },

			-- <C-;> is not a valid sequence so use HJKL instead.
			{ "<C-H>",     '<cmd>lua require("harpoon"):list():select(1)<CR>',                                desc = "Navigate to harpoon 1" },
			{ "<C-J>",     '<cmd>lua require("harpoon"):list():select(2)<CR>',                                desc = "Navigate to harpoon 2" },
			{ "<C-K>",     '<cmd>lua require("harpoon"):list():select(3)<CR>',                                desc = "Navigate to harpoon 3" },
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
		as = "mini.align",
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
		as = "mini.splitjoin",
		version = '*',
	},
}
