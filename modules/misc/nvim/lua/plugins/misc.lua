return {
	{
		"okuuva/auto-save.nvim",
		keys = {
			{ "<leader>w", "<cmd>ASToggle<cr>", desc = "Toggle autosave" },
		},
		event = {
			"InsertLeave",
			"TextChanged",
		},
		opts = {
			write_all_buffers = true,
			execution_message = { enabled = false },
			callbacks = {
				enabling = function() vim.g.auto_save_state = true end,
				disabling = function() vim.g.auto_save_state = false end,
			},
			condition = function(buf)
				return vim.fn.getbufvar(buf, "&filetype") ~= "oil"
			end,
		},
		init = function() vim.g.auto_save_state = true end,
	},

	-- {
	-- 	"kkoomen/vim-doge",
	-- 	build = ":call doge#install()",
	-- 	keys = {
	-- 		{ "<leader>d", "<cmd>DogeGenerate<CR>", desc = "Generate documentation" },
	-- 	},
	-- 	init = function()
	-- 		vim.g.doge_enable_mappings = false
	-- 		vim.g.doge_comment_interactive = false
	-- 	end
	-- }
}
