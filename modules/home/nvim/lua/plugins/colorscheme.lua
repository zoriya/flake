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
					noice = true,
					mini = true,
					leap = true,
					cmp = true,
					native_lsp = {
						enabled = true
					},
					navic = true,
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
}
