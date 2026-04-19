vim.keymap.set({ "n", "x" }, "s", "<Plug>(leap-forward-till)", { desc = "Leap forward to" })
vim.keymap.set({ "n", "x" }, "S", "<Plug>(leap-backward)", { desc = "Leap backward to" })
vim.keymap.set("o", "z", "<Plug>(leap-forward-till)", { desc = "Leap forward to" })
vim.keymap.set("o", "Z", "<Plug>(leap-backward)", { desc = "Leap backward to" })

local function ft(key_specific_args)
	require('leap').leap(
		vim.tbl_deep_extend('keep', key_specific_args, {
			inputlen = 1,
			inclusive = true,
			opts = {
				-- Force autojump.
				labels = '',
				-- Match the modes where you don't need labels (`:h mode()`).
				safe_labels = vim.fn.mode(1):match('o') and '' or nil,
			},
		})
	)
end

local clever = require('leap.user').with_traversal_keys
local clever_f, clever_t = clever('f', 'F'), clever('t', 'T')

vim.keymap.set({ 'n', 'x', 'o' }, 'f', function()
	ft { opts = clever_f }
end)
vim.keymap.set({ 'n', 'x', 'o' }, 'F', function()
	ft { backward = true, opts = clever_f }
end)
vim.keymap.set({ 'n', 'x', 'o' }, 't', function()
	ft { offset = -1, opts = clever_t }
end)
vim.keymap.set({ 'n', 'x', 'o' }, 'T', function()
	ft { backward = true, offset = 1, opts = clever_t }
end)


return {
	{
		"vim-wordmotion",
		keys = {
			-- This overrides the default ge & gw but i never used them.
			{ "gw",  "<plug>WordMotion_w",  desc = "Next small world",                mode = { "n", "x", "o" } },
			{ "ge",  "<plug>WordMotion_e",  desc = "Next end of small world",         mode = { "n", "x", "o" } },
			{ "gb",  "<plug>WordMotion_b",  desc = "Previous small world",            mode = { "n", "x", "o" } },
			{ "igw", "<plug>WordMotion_iw", desc = "inner small word",                mode = { "x", "o" } },
			{ "agw", "<plug>WordMotion_aw", desc = "a small word (with white-space)", mode = { "x", "o" } },
		},
		before = function()
			-- This never gets applied (ordering issue with wordmotion's autoload)
			-- This is also set in `settings.lua` but kept here for documentation purposes
			vim.g.wordmotion_nomap = true
		end,
	},
}
