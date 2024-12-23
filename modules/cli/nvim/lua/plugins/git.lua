return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▕" },
				change = { text = "▕" },
				changedelete = { text = "▕" },
				untracked = { text = "▕" },
			},
			on_attach = function(buffer)
				local gs = package.loaded.gitsigns


				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				end

				map("n", "]h", gs.next_hunk, "Next Hunk")
				map("n", "[h", gs.prev_hunk, "Prev Hunk")
				map({ "n", "v" }, "<leader>ga", ":Gitsigns stage_hunk<CR>", "Add Hunk")
				map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
				map("n", "<leader>gu", gs.undo_stage_hunk, "Unstage Hunk")
				map("n", "<leader>gA", gs.stage_buffer, "Add buffer")
				map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
				map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Git Select Hunk")
				map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>", "Git Select Hunk")
			end,
		},
	},

	{
		"akinsho/git-conflict.nvim",
		event = "VeryLazy",
		keys = {
			{ "gxo", "<Plug>(git-conflict-ours)",          desc = "Accept ours" },
			{ "gxt", "<Plug>(git-conflict-theirs)",        desc = "Accept theirs" },
			{ "gxb", "<Plug>(git-conflict-both)",          desc = "Accept both" },
			{ "gx0", "<Plug>(git-conflict-none)",          desc = "Accept none" },
			{ "[x",  "<Plug>(git-conflict-prev-conflict)", desc = "Previous conflict" },
			{ "]x",  "<Plug>(git-conflict-next-conflict)", desc = "Next conflict" },
		},
		opts = {
			default_mappings = false,
		},
		init = function()
			vim.keymap.del("n", "gx")
		end
	},

	{
		-- "FabijanZulj/blame.nvim",
		"zoriya/blame.nvim",
		-- dev = true,
		keys = {
			{ "<leader>gb", "<cmd>ToggleBlame window<CR>", desc = "Git blame" },
		},
		cmd = "ToggleBlame",
		opts = {
			date_format = "%Y/%m/%d",
			width = 50,
			commit_detail_view = "current",
			format = function(blame)
				if string.sub(blame.hash, 0, 8) == "00000000" then
					return "Not Committed Yet"
				end
				return string.format("%s %s %s", blame.author, blame.date, blame.summary)
			end,
		},
	},
}
