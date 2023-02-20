return {
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			char = "▏",
			filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
			show_trailing_blankline_indent = true,
			use_treesitter = true,
			show_current_context = true,
		},
	},

	{
		"lukas-reineke/virt-column.nvim",
		lazy = true,
		config = true,
		init = function()
			vim.cmd [[
			augroup virtcolumn
				autocmd!
				autocmd FileType * if index(["netrw", "NvimTree", "neo-tree", "UltestAttach", "dap-float", "Trouble", "lspinfo", "qf", "harpoon", "toggleterm", "packer"], &ft) == -1 | lua require("virt-column").setup_buffer({ virtcolumn = "80,120", char = "▏" })
			augroup end
			]]
		end,
	},

	{
		"petertriho/nvim-scrollbar",
		-- TODO: Add colors highlights.
		config = true;
	},
}
