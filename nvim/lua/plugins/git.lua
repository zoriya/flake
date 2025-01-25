-- fugitive keybinds

vim.keymap.set("n", "<leader>gA", "<cmd>Git add -A<CR>", { desc = "Git add all" })
vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gC", "<cmd>Git commit --amend<CR>", { desc = "Git commit amend" })
vim.keymap.set("n", "<leader>gp", "<cmd>Git! push<CR>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gP", "<cmd>Git! push --force-with-lease --force-if-includes<CR>",
	{ desc = "Git push force" })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git fugitive status" })
vim.keymap.set("n", "<leader>gg", vim.cmd.Git, { desc = "Git fugitive status" })

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
				map({ "n", "v" }, "<leader>ha", ":Gitsigns stage_hunk<CR>", "Add Hunk")
				map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
				map("n", "<leader>hu", gs.undo_stage_hunk, "Unstage Hunk")
				map("n", "<leader>ga", gs.stage_buffer, "Add buffer")
				map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
				map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
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
		-- load on enter to detect + highlight conflicts
		-- lazy loading make it not work, idk why
		-- event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			default_mappings = {
				ours = 'c<',
				theirs = 'c>',
				none = 'cd',
				both = 'c=',
				next = ']x',
				prev = '[x',
			},
		},
		after = function(plug)
			require("git-conflict").setup(plug.opts)
		end
	},
}
