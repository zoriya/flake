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

vim.opt.wrap = true
vim.opt.foldlevelstart = 99
vim.opt.linebreak = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.cmdheight = 0
vim.opt.colorcolumn = '80,120'
vim.opt.list = true
vim.opt.listchars = {
	space = "·",
	tab = "▷ ",
	extends = "◣",
	precedes = "◢",
	nbsp = "○",
}
vim.opt.completeopt = { "menu", "menuone", "popup", "noinsert", "fuzzy" }
vim.opt.completeitemalign = { "kind", "abbr", "menu" }
vim.opt.pumheight = 15

vim.opt.spelloptions = { "camel", "noplainbuffer" }
vim.opt.spelllang = { "en", "cjk", }
vim.opt.spell = true
vim.api.nvim_create_autocmd("FileType", {
	desc = "Disable spellcapcheck",
	group = vim.api.nvim_create_augroup("spell-cap-check", { clear = true }),
	callback = function(evt)
		if evt.file:match(".*%.md") or evt.file:match(".*%.ltex") then
			return
		end
		vim.opt_local.spellcapcheck = ""
	end,
})

-- Can't specify this in wordmotion's config due to race conditions
vim.g.wordmotion_nomap = true
-- Disable builtin sql completions which are bound to <C-c>
vim.g.omni_sql_no_default_maps = 1
-- avoid stupid menu.vim (saves ~100ms) - stolen from justin's config
vim.g.did_install_default_menus = 1

-- for all modes except terminal
vim.keymap.set({ "i", "n", "o", "x", "v", "s", "l", "c" }, "<C-c>", "<esc>")
-- <esc> leaves terminal mode, <C-q> sends a real <esc> to the terminal app
vim.keymap.set("t", "<esc>", "<C-\\><C-N>", { desc = "Normal mode" })
vim.keymap.set("t", "<C-q>", "<esc>", { desc = "Send escape to terminal" })
-- Why is this not the default?
vim.keymap.set("c", "<c-a>", "<home>", { desc = "Begining" })

vim.keymap.set("i", "<a-d>", "<c-o>de")

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Copy to/from system clipboard
vim.g.clipboard = 'osc52'
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>Y", '"+y$', { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { desc = "Past from system clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>P", '"+P', { desc = "Past line from system clipboard" })


-- Quickfix list
vim.keymap.set("n", "<leader>q", "<cmd>cclose<cr>", { desc = "Close quickfix" })
vim.keymap.set("n", "grd", function()
	vim.diagnostic.setqflist({ severity = { min = vim.diagnostic.severity.WARN } })
	local ok, quicker = pcall(require, "quicker")
	if ok then quicker.refresh() end
end, { desc = "Open diagnostics" })
vim.keymap.set("n", "gre", function()
	vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
	local ok, quicker = pcall(require, "quicker")
	if ok then quicker.refresh() end
end, { desc = "List errors" })

-- Next error
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })

-- Center screen after navigating (those are builtin shortcuts)
vim.keymap.set("n", "[q", "<cmd>cprev<cr>zvzz", { desc = "Previous quickfix item" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>zvzz", { desc = "Next quickfix item" })
vim.keymap.set("n", "[l", "<cmd>lprev<cr>zvzz", { desc = "Previous loclist item" })
vim.keymap.set("n", "]l", "<cmd>lnext<cr>zvzz", { desc = "Next loclist item" })
-- Center screen when navigating search results
vim.keymap.set("n", "n", "nzzzv", { desc = "Next result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous result" })

-- Clear snippets with C-l and go to next/prev with C-n & C-p
vim.keymap.set("n", "<C-l>", function()
	if vim.snippet then
		vim.snippet.stop()
	end
	vim.cmd.nohlsearch()
	vim.cmd.diffupdate()

	local ok, noice = pcall(require, "noice")
	if ok then
		noice.cmd("dismiss")
	end

	local sok, sniprun = pcall(require, "sniprun.display")
	if sok then
		sniprun.close_all()
	end
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


-- Lsp mapping that should become defaults
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { desc = "Go to definition" })
vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, { desc = "Go to declaration" })
vim.keymap.set("n", "grs", function() vim.lsp.buf.type_definition() end, { desc = "Go to type definition" })

-- vim.keymap.set({ 'i' }, '<C-Space>', function()
-- 	vim.lsp.completion.get()
-- end, { desc = "Trigger completion" })


vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({
			higroup = "Visual",
		})
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Disable comment continuation (enter or o/O)",
	group = vim.api.nvim_create_augroup("comment-ro", { clear = true }),
	callback = function()
		vim.opt.formatoptions:remove({ "r", "o" })
		vim.opt_local.formatoptions:remove({ "r", "o" })
	end,
})

vim.filetype.add({
	extension = {
		-- appsettings.json.model at work
		model = 'json',
		mdx = "mdx",
	},
})
vim.treesitter.language.register("markdown", "mdx")


vim.cmd.colorscheme("catppuccin")

-- Terminals report their background color asynchronously via OSC 11, often
-- after our UI plugins have already drawn. When the answer arrives, neovim
-- silently flips 'background' and re-sources the colorscheme (mocha <-> latte),
-- which clears every highlight group -- but it does *not* fire ColorScheme or
-- OptionSet, so plugins that rebuild their highlights on those events (lualine,
-- virt-column) get stranded with cleared/stale colors. Fire the missing
-- ColorScheme ourselves so they refresh against the freshly-loaded flavor.
vim.api.nvim_create_autocmd("TermResponse", {
	group = vim.api.nvim_create_augroup("bg-detect-colorscheme-refresh", { clear = true }),
	callback = function(ev)
		local seq = type(ev.data) == "table" and ev.data.sequence or ev.data
		if type(seq) == "string" and seq:find("\27]11;", 1, true) then
			vim.schedule(function()
				vim.api.nvim_exec_autocmds("ColorScheme", { modeline = false })
			end)
		end
	end,
})

-- follow osc7 requests (inner program wants to cd, like jjui)
vim.api.nvim_create_autocmd("TermRequest", {
	group = vim.api.nvim_create_augroup("osc7-follow-cwd", { clear = true }),
	nested = true,
	callback = function(ev)
		local seq = type(ev.data) == "table" and ev.data.sequence or ev.data
		if type(seq) ~= "string" then
			return
		end
		local dir = seq:match("^\27]7;file://[^/]*(/[^\27\7]*)")
		if not dir or vim.fn.isdirectory(dir) == 0 then
			return
		end
		vim.cmd("cd " .. vim.fn.fnameescape(dir))
	end,
})

-- buffer follow jj workspace changes
vim.api.nvim_create_autocmd("DirChanged", {
	group = vim.api.nvim_create_augroup("jj-follow-workspace", { clear = true }),
	callback = function()
		local cwd = vim.v.event.cwd
		-- swapping buffers underneath the `:cd` that got us here upsets both, so
		-- let it finish first
		vim.schedule(function()
			-- two workspaces share a repo when `.jj/repo` resolves to the same
			-- place: it is a directory in the workspace owning it, and everywhere
			-- else a file holding the path to that directory, relative to `.jj/`.
			-- Anything less strict would drag buffers between repos that merely
			-- agree on a path.
			local function repo_of(root)
				local repo = root .. "/.jj/repo"
				local stat = vim.uv.fs_stat(repo)
				if not stat then
					return nil
				end
				if stat.type == "directory" then
					return vim.uv.fs_realpath(repo)
				end
				local f = io.open(repo)
				if not f then
					return nil
				end
				local link = vim.trim(f:read("*a"))
				f:close()
				return vim.uv.fs_realpath(link:sub(1, 1) == "/" and link or root .. "/.jj/" .. link)
			end

			local root = cwd and vim.fs.root(cwd, ".jj")
			local repo = root and repo_of(root)
			if not repo then
				return
			end

			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				local name = vim.api.nvim_buf_get_name(buf)
				-- unsaved work stays put, we have nowhere to carry it over to
				if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and not vim.bo[buf].modified and name ~= "" then
					local path = vim.uv.fs_realpath(name)
					local from = path and vim.fs.root(path, ".jj")
					if from and from ~= root and repo_of(from) == repo then
						local target = root .. "/" .. path:sub(#from + 2)
						if vim.uv.fs_stat(target) then
							local new = vim.fn.bufadd(target)
							vim.fn.bufload(new)
							vim.bo[new].buflisted = true
							for _, win in ipairs(vim.fn.win_findbuf(buf)) do
								-- floats are previews and the like, not ours to steer
								if vim.api.nvim_win_get_config(win).relative == "" then
									local cursor = vim.api.nvim_win_get_cursor(win)
									vim.api.nvim_win_set_buf(win, new)
									pcall(vim.api.nvim_win_set_cursor, win, cursor)
								end
							end
							-- drop what we replaced, so the copy from the workspace we
							-- left cannot sneak back in through the buffer list
							if #vim.fn.win_findbuf(buf) == 0 then
								pcall(vim.api.nvim_buf_delete, buf, {})
							end
						end
					end
				end
			end
		end)
	end,
})

if vim.g.have_nerd_font then
	vim.diagnostic.config({
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚",
				[vim.diagnostic.severity.WARN] = "",
				[vim.diagnostic.severity.HINT] = "󰌶",
				[vim.diagnostic.severity.INFO] = "",
			},
		},
	})
end
vim.diagnostic.config({
	update_in_insert = true,
})
