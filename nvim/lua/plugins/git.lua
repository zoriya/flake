return {
	{
		"gitsigns.nvim",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▕" },
				change = { text = "▕" },
				changedelete = { text = "▕" },
				untracked = { text = "▕" },
			},
			signs_staged = {
				add = { text = "▕" },
				change = { text = "▕" },
				changedelete = { text = "▕" },
				untracked = { text = "▕" },
			},
			on_attach = function(buffer)
				local gs = require("gitsigns")
				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				end

				map('n', ']h', function() gs.nav_hunk('next') end, "Next Hunk")
				map('n', '[h', function() gs.nav_hunk('prev') end, "Prev Hunk")
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
		after = function(plug)
			require("gitsigns").setup(plug.opts)
		end,
	},

	{
		"git-conflict.nvim",
		lazy = false,
		keys = {
			{ "<leader>gxo", "<Plug>(git-conflict-ours)",          desc = "Accept ours" },
			{ "<leader>gxt", "<Plug>(git-conflict-theirs)",        desc = "Accept theirs" },
			{ "<leader>gxb", "<Plug>(git-conflict-both)",          desc = "Accept both" },
			{ "<leader>gx0", "<Plug>(git-conflict-none)",          desc = "Accept none" },
			{ "[x",          "<Plug>(git-conflict-prev-conflict)", desc = "Previous conflict" },
			{ "]x",          "<Plug>(git-conflict-next-conflict)", desc = "Next conflict" },
		},
		opts = {
			default_mappings = false,
		},
		after = function(plug)
			require("git-conflict").setup(plug.opts)
		end
	},
}
