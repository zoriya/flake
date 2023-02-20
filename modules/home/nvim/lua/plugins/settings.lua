return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				integrations = {
					which_key = true,
					lsp_trouble = true,
					telescope = true,
					treesitter = true,
					neotree = true,
					harpoon = true,
					gitsigns = true,
					semantic_tokens = true,
					indent_blankline = {
						enabled = true,
					},
				}
			})
			vim.cmd([[colorscheme catppuccin-mocha]])
		end
	},
	"tpope/vim-surround",
	"tpope/vim-sleuth",
	{ "tpope/vim-repeat", event = "VeryLazy" },
	{ "tpope/vim-unimpaired", config = function() vim.g.nremap = { ["[u"] = "", ["]u"] = "" } end },
	"nishigori/increment-activator",
}
