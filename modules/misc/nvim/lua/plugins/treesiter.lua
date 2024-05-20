return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false,
		build = ":TSUpdate",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects"
		},
		opts = {
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			ensure_installed = "all",
			sync_install = false,
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
			matchup = { enable = true },
		},
		main = "nvim-treesitter.configs",
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
	}
}
