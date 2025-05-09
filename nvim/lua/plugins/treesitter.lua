return {
	{
		"nvim-treesitter",
		load = function()
			vim.cmd.packadd("nvim-treesitter-textobjects")
		end,
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

	-- {
	-- 	"ts-comments.nvim",
	-- 	event = { "BufReadPost", "BufWritePost", "BufNewFile" },
	-- 	after = function()
	-- 		require("ts-comments").setup({})
	-- 	end,
	-- },

	{
		"vim-illuminate",
		load = vim.cmd.packadd,
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			providers = {
				"lsp",
				"treesitter",
			},
			under_cursor = false,
			min_count_to_highlight = 2,
			delay = 200,
			large_file_cutoff = 2000,
			large_file_overrides = {
				providers = { "lsp" },
			},
		},
		after = function(plug)
			require("illuminate").configure(plug.opts)
		end,
	},
}
