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

			local colors = require("catppuccin.palettes").get_palette()
			local TelescopeColor = {
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

			for hl, col in pairs(TelescopeColor) do
				vim.api.nvim_set_hl(0, hl, col)
			end
			vim.cmd([[colorscheme catppuccin-mocha]])
		end
	},
}
