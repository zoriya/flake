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
		"mini.diff",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			view = {
				style = "sign",
				signs = { add = "▕", change = "▕", delete = "▕" },
			},
			source = {
				require("jj-diff").source,
				require("mini.diff").gen_source.git(),
			},
			mappings = {
				apply = "",
				reset = "gH",
				textobject = "ih",
				goto_first = "[H",
				goto_prev = "[h",
				goto_next = "]h",
				goto_last = "]H",
			},
		},
		after = function(plug)
			local diff = require("mini.diff")
			diff.setup(plug.opts)
			require("jj-diff").setup()

			vim.keymap.set("n", "<leader>hr", "gHih", { remap = true, desc = "Reset Hunk" })
			vim.keymap.set("x", "<leader>hr", "gH", { remap = true, desc = "Reset Hunk" })

			vim.keymap.set("n", "<leader>hp", function() diff.toggle_overlay(0) end, { desc = "Preview Hunk (overlay)" })
			vim.keymap.set("n", "<leader>gR", function() diff.do_hunks(0, "reset") end, { desc = "Reset Buffer" })
		end,
	},

	{
		"unclash.nvim",
		-- load on enter to detect + highlight conflicts
		opts = {},
		after = function(plug)
			require("unclash").setup(plug.opts)

			local unclash = require("unclash")
			vim.keymap.set("n", "]x", unclash.next_conflict, { desc = "Next Conflict" })
			vim.keymap.set("n", "[x", unclash.prev_conflict, { desc = "Prev Conflict" })
			vim.keymap.set("n", "co", unclash.open_merge_editor, { desc = "Open Merge Editor" })
			vim.keymap.set("n", "c<", unclash.accept_current, { desc = "Accept Current" })
			vim.keymap.set("n", "c>", unclash.accept_incoming, { desc = "Accept Incoming" })
			vim.keymap.set("n", "c=", unclash.accept_both, { desc = "Accept Both" })
			vim.keymap.set("n", "<leader>x", "<cmd>UnclashQf<cr>", { desc = "Add conflicts in qf" })
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
			vim.keymap.set("n", "<leader>jc", cmd.commit, { desc = "JJ commit" })
		end
	},
}
