return {
	{
		"ggandor/leap.nvim",
		keys = {
			{ "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
			{ "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
			{ "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
		},
		config = function(_, opts)
			local leap = require("leap")
			for k, v in pairs(opts) do
				leap.opts[k] = v
			end
			leap.add_default_mappings(true)
			vim.keymap.del({ "x", "o" }, "x")
			vim.keymap.del({ "x", "o" }, "X")
		end,
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
			{ "<C-L>", '<cmd>lua require("harpoon.ui").nav_file(4)<CR>', desc = "Navigate to harpoon 4" },
		},
		opts = {
			mark_branch = true,
			menu = {
				width = 100,
			},
		},
	},

	"tpope/vim-unimpaired",
	"tpope/vim-surround",
	"tpope/vim-sleuth",

	{
		"nishigori/increment-activator",
		keys = {
			{ "<C-A>", desc = "Increment" },
			{ "<C-X>", desc = "Decrement" },
		},
	},
}
