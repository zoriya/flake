return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			integrations = {
				which_key = true,
				lsp_trouble = true,
				telescope = {
					enabled = true,
					style = "nvchad",
				},
				noice = true,
				mini = true,
				cmp = true,
				native_lsp = {
					enabled = true
				},
				navic = true,
				harpoon = true,
				flash = true,
				gitsigns = true,
				semantic_tokens = true,
				indent_blankline = {
					enabled = true,
				},
				illuminate = true,
			},
			custom_highlights = function (colors)
				return {
					FlashLabel = { fg = colors.red },
					NotCommitedBlame = { fg = "DimGray" },
				}
			end
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd([[colorscheme catppuccin]])
		end
	},

	{
		"vimpostor/vim-lumen",
		lazy = false,
		priority = 1000,
	},
}
