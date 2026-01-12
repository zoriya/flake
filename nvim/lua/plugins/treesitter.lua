vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter-config", { clear = true }),
	callback = function()
		pcall(vim.treesitter.start)
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
		vim.wo[0][0].foldmethod = 'expr'
	end,
})

return {
	{
		"nvim-treesitter-textobjects",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			select = {
				lookahead = true,
			},
		},
		after = function(plug)
			require("nvim-treesitter-textobjects").setup(plug.opts)
			local select = require("nvim-treesitter-textobjects.select")
			vim.keymap.set({ "x", "o" }, "af", function()
				select.select_textobject("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "if", function()
				select.select_textobject("@function.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ac", function()
				select.select_textobject("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ic", function()
				select.select_textobject("@class.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "aa", function()
				select.select_textobject("@parameter.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ia", function()
				select.select_textobject("@parameter.inner", "textobjects")
			end)
		end
	},

	{
		"vim-illuminate",
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
