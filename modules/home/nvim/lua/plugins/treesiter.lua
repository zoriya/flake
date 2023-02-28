return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false,
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects"
		},
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			context_commentstring = { enable = true, enable_autocmd = false },
			ensure_installed = "all",
			textobjects = {
				select = {
					enable = true,
					lookahead = false,

					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						["ia"] = "@parameter.inner",
						["aa"] = "@parameter.outer",
					},
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},

	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		opts = function()
			return {
				pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
			}
		end
	},

	{
		"windwp/nvim-ts-autotag",
		config = true,
		ft = {
			'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'tsx', 'jsx',
			'rescript', 'xml', 'php', 'markdown', 'glimmer', 'handlebars', 'hbs'
		},
	},

	{
		"echasnovski/mini.pairs",
		version = '*',
		opts = {
			mappings = {
				-- Disable pairs if the next char is not a whitespace
				['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\][%s]' },
				['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\][%s]' },
				['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\][%s]' },
				['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\][%s]', register = { cr = false } },
				["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\][%s]', register = { cr = false } },
				['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\][%s]', register = { cr = false } },
			},
		},
		config = function(_, opts) require('mini.pairs').setup(opts) end,
	},
}
