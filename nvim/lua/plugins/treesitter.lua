return {
	{
		"nvim-treesitter",
		lazy = false,
		load = function() end,
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
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
		after = function(plug)
			require("nvim-treesitter.configs").setup(plug.opts)
			vim.wo.foldmethod = 'expr'
			vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
		end
	},

	{
		"ts-comments.nvim",
		lazy = false,
		load = function() end,
		after = function()
			require("ts-comments").setup({})
		end,
	},
}
