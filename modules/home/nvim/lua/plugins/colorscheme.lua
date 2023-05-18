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
			},
			custom_highlights = function(colors)
				return {
					TelescopeMatching = { fg = colors.flamingo },
					TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },
					TelescopePromptPrefix = { bg = colors.surface0 },
					TelescopePromptNormal = { bg = colors.surface0 },
					TelescopeResultsNormal = { bg = colors.mantle },
					TelescopePreviewNormal = { bg = colors.mantle },
					TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
					TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
					TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
					TelescopePromptTitle = { bg = colors.pink, fg = colors.mantle },
					TelescopeResultsTitle = { fg = colors.mantle },
					TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
				}
			end,
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
