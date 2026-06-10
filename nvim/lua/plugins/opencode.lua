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

local claude_cmd = 'claude'
---@type snacks.terminal.Opts
local claude_terminal_opts = {
	win = {
		position = 'right',
		enter = true,
	},
}

local state_file = vim.fn.stdpath("data") .. "/leader_l_mode"

local function get_mode()
	local f = io.open(state_file, "r")
	if f then
		local mode = f:read("*l")
		f:close()
		if mode == "claude" then return "claude" end
	end
	return "opencode"
end

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
					if get_mode() == "claude" then
						require('snacks.terminal').toggle(claude_cmd, claude_terminal_opts)
					else
						require("opencode").toggle()
					end
				end,
				desc = "Toggle AI terminal",
				mode = { "n", "v" },
			},
			{
				"<leader>L",
				function()
					local new_mode = get_mode() == "opencode" and "claude" or "opencode"
					local f = io.open(state_file, "w")
					if f then
						f:write(new_mode)
						f:close()
					end
					vim.notify("leader-l → " .. new_mode, vim.log.levels.INFO)
				end,
				desc = "Switch AI terminal (opencode/claude)",
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
