local options = {
	fileencoding = "utf-8",
	expandtab = false,
	shiftwidth = 4,
	tabstop = 4,
	cinoptions = {
		"(1s",
		"m1",
	},

	hlsearch = true,
	ignorecase = true,
	smartcase = true,

	mouse = "a",
	splitbelow = true,
	splitright = true,
	cursorline = true,
	sidescrolloff = 8,
	wrap = false,

	termguicolors = true,
	swapfile = false,
	undofile = true,
	updatetime = 300,                        -- faster completion (4000ms default)

	number = true,
	relativenumber = true,
	numberwidth = 4,
	signcolumn = "yes",

	list = true,
	listchars = {
		space = "·",
		tab = "▷ ",
		extends = "◣",
		precedes = "◢",
		nbsp = "○",
	},
	fillchars = {
		diff = "╱",
	},
}

for k, v in pairs(options) do
	vim.opt[k] = v
end
vim.cmd("set formatoptions-=ro")

local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move in insert mode --
keymap("i", "<A-j>", "<Down>", opts)
keymap("i", "<A-k>", "<Up>", opts)
keymap("i", "<A-h>", "<Left>", opts)
keymap("i", "<A-l>", "<Right>", opts)

keymap("i", "<C-BS>", "<C-w>", opts)
keymap("c", "<C-BS>", "<C-w>", opts)
keymap("i", "<C-H>", "<C-w>", opts) -- Keymap for CTRL-BACKSPACE on some termial emulators.
keymap("c", "<C-H>", "<C-w>", opts)

keymap("n", "<leader>y", '"+y', opts)
keymap("x", "<leader>y", '"+y', opts)
keymap("n", "<leader>Y", '"+y$', opts)
keymap("x", "<leader>Y", '"+y$', opts)

keymap("n", "<leader>p", '"+p', opts)
keymap("x", "<leader>p", '"+p', opts)
keymap("n", "<leader>P", '"+P', opts)
keymap("x", "<leader>P", '"+P', opts)


keymap("t", "<C-W>", "<C-\\><C-N><C-W>", opts)

vim.cmd("autocmd FileType qf setl nolist")
vim.cmd("syntax on")
vim.cmd [[
	augroup highlight_yank
		autocmd!
		autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200}) 
	augroup end
]]

