-- fugitive keybinds

vim.keymap.set("n", "<leader>gA", "<cmd>Git add -A<CR>", { desc = "Git add all" })
vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gC", "<cmd>Git commit --amend<CR>", { desc = "Git commit amend" })
vim.keymap.set("n", "<leader>gp", "<cmd>Git! push<CR>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gP", "<cmd>Git! push --force-with-lease --force-if-includes<CR>",
	{ desc = "Git push force" })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git fugitive status" })
vim.keymap.set("n", "<leader>gg", vim.cmd.Git, { desc = "Git fugitive status" })

vim.api.nvim_create_autocmd("FileType", {
	desc = "Fix fold method",
	group = vim.api.nvim_create_augroup("git-fold-method", { clear = true }),
	callback = function(evt)
		-- this seems to trigger a bit late & we need to :e to make it work. idk why
		if evt.match == "git" then
			vim.wo.foldmethod = "syntax"
		else
			vim.wo.foldmethod = "expr"
		end
	end,
})

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

				map('n', ']h', function() gs.nav_hunk("next", { target = "all" }) end, "Next Hunk")
				map('n', '[h', function() gs.nav_hunk("prev", { target = "all" }) end, "Prev Hunk")

				map({ "n", "v" }, "<leader>ha", gs.stage_hunk, "Add Hunk")
				map({ "n", "v" }, "<leader>hr", gs.reset_hunk, "Reset Hunk")
				map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")

				map("n", "<leader>ga", gs.stage_buffer, "Add buffer")
				map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")

				map({ "o", "x" }, "ih", gs.select_hunk, "Git Select Hunk")
				map({ "o", "x" }, "ah", gs.select_hunk, "Git Select Hunk")
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

	{
		"jj",
		event = "DeferredUIEnter",
		opts = {},
		after = function(plug)
			require("jj").setup(plug.opt)

			local cmd = require("jj.cmd")
			vim.keymap.set("n", "<leader>jd", cmd.describe, { desc = "JJ describe" })
			vim.keymap.set("n", "<leader>jl", cmd.log, { desc = "JJ log" })
			vim.keymap.set("n", "<leader>jL", function()
				cmd.log({ revisions = "'all()'" })
			end, { desc = "JJ log all" })
			vim.keymap.set("n", "<leader>je", cmd.edit, { desc = "JJ edit" })
			vim.keymap.set("n", "<leader>jn", cmd.new, { desc = "JJ new" })
			vim.keymap.set("n", "<leader>jsq", cmd.squash, { desc = "JJ squash" })
			vim.keymap.set("n", "<leader>ju", cmd.undo, { desc = "JJ undo" })
			vim.keymap.set("n", "<leader>jy", cmd.redo, { desc = "JJ redo" })
			vim.keymap.set("n", "<leader>jr", cmd.rebase, { desc = "JJ rebase" })
			vim.keymap.set("n", "<leader>jbc", cmd.bookmark_create, { desc = "JJ bookmark create" })
			vim.keymap.set("n", "<leader>jbd", cmd.bookmark_delete, { desc = "JJ bookmark delete" })
			vim.keymap.set("n", "<leader>jbm", cmd.bookmark_move, { desc = "JJ bookmark move" })
			vim.keymap.set("n", "<leader>ja", cmd.abandon, { desc = "JJ abandon" })
			vim.keymap.set("n", "<leader>jf", cmd.fetch, { desc = "JJ fetch" })
			vim.keymap.set("n", "<leader>jp", cmd.push, { desc = "JJ push" })
			vim.keymap.set("n", "<leader>jpr", cmd.open_pr, { desc = "JJ PR" })
			vim.keymap.set("n", "<leader>jpl", function()
				cmd.open_pr({ list_bookmarks = true })
			end, { desc = "JJ PR list" })
			vim.keymap.set("n", "<leader>jt", function()
				cmd.j("tug")
				cmd.log()
			end, { desc = "JJ tug" })
		end
	},
}
