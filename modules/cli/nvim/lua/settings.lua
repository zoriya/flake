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

	completeopt = { "menuone", "popup", "noinsert", "fuzzy" },
	pumheight = 15,

	foldcolumn = "1",
	foldlevel = 99,
	foldlevelstart = 99,
	foldenable = true,
}

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- Disable comment continuations (enter or o/O)
vim.cmd("autocmd BufEnter * set formatoptions-=ro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=ro")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- for all modes except terminal
vim.keymap.set({"i", "n", "o", "x", "v", "s", "l", "c"}, "<C-c>", "<esc>")

vim.keymap.set("i", "<C-BS>", "<C-w>")
vim.keymap.set("c", "<C-BS>", "<C-w>")
-- vim.keymap.set("i", "<C-H>", "<C-w>") -- Keymap for CTRL-BACKSPACE on some termial emulators.
-- vim.keymap.set("c", "<C-H>", "<C-w>")

-- Center screen when navigating search results
vim.keymap.set("n", "n", "nzzzv", { desc = "Next result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous result" })

vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>Y", '"+y$', { desc = "Yank line to system clipboard" })

vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { desc = "Past from system clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>P", '"+P', { desc = "Past line from system clipboard" })

vim.keymap.set("n", "<C-.>", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
vim.keymap.set("n", "<C-,>", "<cmd>cprev<CR>zz", { desc = "Prev quickfix" })
vim.keymap.set("n", "<leader>q", "<cmd>cclose<cr>", { desc = "Close quickfix" })
vim.keymap.set('n', '[q', '<cmd>cprev<cr>zvzz', { desc = 'Previous quickfix item' })
vim.keymap.set('n', ']q', '<cmd>cnext<cr>zvzz', { desc = 'Next quickfix item' })
vim.keymap.set('n', '[l', '<cmd>lprev<cr>zvzz', { desc = 'Previous loclist item' })
vim.keymap.set('n', ']l', '<cmd>lnext<cr>zvzz', { desc = 'Next loclist item' })


vim.keymap.set("t", "<esc>", "<C-\\><C-N>", { desc = "Normal mode" })

vim.keymap.set({ "n", "x" }, "gq", "gw", { desc = "Reformat using textwidth (tw)", noremap = true })

-- Clear snippets with C-l and go to next/prev with C-n & C-p
vim.keymap.set("n", "<C-l>", function()
	if vim.snippet then
		vim.snippet.stop()
	end
	return "<cmd>nohlsearch<cr><cmd>diffupdate<cr><C-l>"
end, { expr = true })
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

vim.cmd("autocmd FileType qf setl nolist")

vim.api.nvim_create_autocmd('TextYankPost', {
	group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
	desc = "highlight on yank",
	callback = function()
		vim.highlight.on_yank({
			higroup = 'Visual',
			timeout = 200,
		})
	end,
})

vim.g.zig_fmt_autosave = 0
vim.g.omni_sql_no_default_maps = 1
