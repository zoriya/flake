return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false,
		build = ":TSUpdate",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			ensure_installed = "all",
			sync_install = false,
			matchup = { enable = true },
		},
		main = "nvim-treesitter.configs",
		init = function()
			vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"
		end
	},

	{
		"folke/ts-comments.nvim",
		opts = {},
		event = "VeryLazy",
	},

	{
		"danymat/neogen",
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			languages = {
				cs = {
					template = {
						annotation_convention = "xmldoc",
					},
				},
			},
		},
		keys = {
			{ "<leader>n", "<cmd>Neogen<cr>", desc = "Generate documentation" },
		},
	},

	{
		"andymass/vim-matchup",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		init = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
		config = function()
			vim.keymap.del("o", "z%")
		end
	},

	{
		"echasnovski/mini.ai",
		opts = {
			custom_textobjects = {
				B = { { "%b{}" }, "^.().*().$" }
			},
			n_lines = 500,
		},
		event = "VeryLazy",
	},
}
