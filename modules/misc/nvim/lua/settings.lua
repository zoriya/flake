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
	linebreak = true, -- When using set wrap, do not break in the middle of a word.
	spell = false,

	termguicolors = true,
	swapfile = false,
	undofile = true,
	updatetime = 300, -- faster completion (4000ms default)

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
		eob = " ",
		fold = " ",
		foldopen = "",
		foldsep = " ",
		foldclose = "",
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

-- Center screen when navigating search results
keymap("n", "n", "nzz")
keymap("n", "N", "Nzz")

keymap({ "n", "x" }, "<leader>y", '"+y', "Yank to system clipboard")
keymap({ "n", "x" }, "<leader>Y", '"+y$', "Yank line to system clipboard")

keymap({ "n", "x" }, "<leader>p", '"+p', "Past from system clipboard")
keymap({ "n", "x" }, "<leader>P", '"+P', "Past line from system clipboard")

keymap("n", "<C-.>", "<cmd>cnext<CR>zz", "Next quickfix")
keymap("n", "<C-,>", "<cmd>cprev<CR>zz", "Prev quickfix")
keymap("n", "<leader>c", "<cmd>cclose<cr>", "Close quickfix")

keymap("t", "<C-W>", "<C-\\><C-N><C-W>", "+windows")
keymap("t", "<C-W>", "<C-\\><C-N>", "Normal mode")

vim.keymap.set({"n", "x"}, "gq", "gw", { desc = "Reformat using textwidth (tw)", noremap = true })

vim.cmd("autocmd FileType qf setl nolist")
vim.cmd("syntax on")

vim.api.nvim_create_autocmd('TextYankPost', {
	group = vim.api.nvim_create_augroup("HighlightYank", {}),
	pattern = '*',
	callback = function()
		vim.highlight.on_yank({
			higroup = 'Visual',
			timeout = 200,
		})
	end,
})


if vim.call("has", "wsl") == 1 then
	-- Lumen takes 170ms on windows and I only use the windows laptop at work, with light mode.
	vim.g.lumen_startup_overwrite = 0
	vim.opt.background = "light"
end
