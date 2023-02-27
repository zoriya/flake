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
	mousemodel = "extend",
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

-- Disable comment continuations (enter or o/O)
vim.cmd("autocmd BufEnter * set formatoptions-=ro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=ro")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function keymap(mode, l, r, desc)
	vim.keymap.set(mode, l, r, { noremap = true, silent = true, desc = desc })
end


-- Stay in indent mode
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Move in insert mode --
keymap("i", "<A-j>", "<Down>")
keymap("i", "<A-k>", "<Up>")
keymap("i", "<A-h>", "<Left>")
keymap("i", "<A-l>", "<Right>")

keymap("i", "<C-BS>", "<C-w>")
keymap("c", "<C-BS>", "<C-w>")
keymap("i", "<C-H>", "<C-w>") -- Keymap for CTRL-BACKSPACE on some termial emulators.
keymap("c", "<C-H>", "<C-w>")

keymap({"n", "x"}, "<leader>y", '"+y', "Yank to system clipboard")
keymap({"n", "x"}, "<leader>Y", '"+y$', "Yank line to system clipboard")

keymap({"n", "x"}, "<leader>p", '"+p', "Past from system clipboard")
keymap({"n", "x"}, "<leader>P", '"+P', "Past line from system clipboard")

keymap("t", "<C-W>", "<C-\\><C-N><C-W>", "+windows")
keymap("t", "<C-W>", "<C-\\><C-N>", "Normal mode")

vim.cmd("autocmd FileType qf setl nolist")
vim.cmd("syntax on")
vim.cmd [[
	augroup highlight_yank
		autocmd!
		autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200}) 
	augroup end
]]

