vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'

vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.updatetime = 250

vim.opt.mouse = 'a'
vim.opt.sidescrolloff = 8
vim.opt.cursorline = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = 'split'

vim.opt.wrap = false
vim.opt.foldlevelstart = 99
vim.opt.linebreak = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.list = true
vim.opt.listchars = {
	space = "·",
	tab = "▷ ",
	extends = "◣",
	precedes = "◢",
	nbsp = "○",
}

-- for all modes except terminal
vim.keymap.set({ "i", "n", "o", "x", "v", "s", "l", "c" }, "<C-c>", "<esc>")
-- i don't use terminal that much so not having esc is okay
vim.keymap.set("t", "<esc>", "<C-\\><C-N>", { desc = "Normal mode" })
-- Disable builtin sql completions which are bound to <C-c>
vim.g.omni_sql_no_default_maps = 1

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Center screen when navigating search results
vim.keymap.set("n", "n", "nzzzv", { desc = "Next result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous result" })

-- Copy to/from system clipboard
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>Y", '"+y$', { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { desc = "Past from system clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>P", '"+P', { desc = "Past line from system clipboard" })

-- Quickfix list
vim.keymap.set("n", "<leader>q", "<cmd>cclose<cr>", { desc = "Close quickfix" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>zvzz", { desc = "Previous quickfix item" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>zvzz", { desc = "Next quickfix item" })
vim.keymap.set("n", "[l", "<cmd>lprev<cr>zvzz", { desc = "Previous loclist item" })
vim.keymap.set("n", "]l", "<cmd>lnext<cr>zvzz", { desc = "Next loclist item" })

-- Clear snippets with C-l and go to next/prev with C-n & C-p
vim.keymap.set("n", "<C-l>", function()
	if vim.snippet then
		vim.snippet.stop()
	end
	vim.cmd.nohlsearch()
	vim.cmd.diffupdate()
end)
vim.keymap.set({ "i", "s" }, "<C-n>", function()
	if vim.snippet.active({ direction = 1 }) then
		vim.snippet.jump(1)
	end
end)
vim.keymap.set({ "i", "s" }, "<C-p>", function()
	if vim.snippet.active({ direction = -1 }) then
		vim.snippet.jump(-1)
	end
end)


vim.api.nvim_create_autocmd("TextYankPost", {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

require("./lsp")