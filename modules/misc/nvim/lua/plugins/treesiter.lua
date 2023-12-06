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
		},
		main = "nvim-treesitter.configs",
	},

	{
		"echasnovski/mini.comment",
		version = '*',
		dependencies = {
			{
				"JoosepAlviste/nvim-ts-context-commentstring",
				opts = {
					enable_autocmd = false,
				}
			},
		},
		event = "VeryLazy",
		opts = {
			options = {
				custom_commentstring = function()
					local cstr = require("ts_context_commentstring").calculate_commentstring()
					if cstr then
						return cstr
					end
					print(vim.bo.commentstring)
					if vim.bo.commentstring == "/*%s*/" then
						return "// %s"
					end
					return vim.bo.commentstring
				end,
			}
		},
	},
}
