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
			}
		},
		after = function(plug)
			require("nvim-treesitter.configs").setup(plug.opts)
			vim.wo.foldmethod = 'expr'
			vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
		end
	},
}
