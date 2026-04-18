local opencode_cmd = 'opencode --port'
---@type snacks.terminal.Opts
local snacks_terminal_opts = {
	win = {
		position = 'right',
		enter = true,
		on_win = function(win)
			require('opencode.terminal').setup(win.win)
		end,
	},
}
---@type opencode.Opts
vim.g.opencode_opts = {
	server = {
		start = function()
			require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts)
		end,
		stop = function()
			require('snacks.terminal').get(opencode_cmd, snacks_terminal_opts):close()
		end,
		toggle = function()
			require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
		end,
	},
}

return {
	{
		"opencode-nvim",
		keys = {
			{
				"<leader>l",
				function()
					require("opencode").toggle()
				end,
				desc = "Opencode",
				mode = { "n", "v" },
			},
			{

				"gl",
				function()
					return require("opencode").operator("@this ")
				end,
				desc = "Add range to opencode",
				mode = { "n", "x" },
				expr = true,
			},
			{
				"gll",
				function()
					return require("opencode").operator("@this ") .. "_"
				end,
				desc = "Add line to opencode",
				expr = true,
			},
			{
				"gL",
				function()
					return require("opencode").prompt("@buffer ")
				end,
				desc = "Add buffer to opencode"
			},
		},
	},
}
