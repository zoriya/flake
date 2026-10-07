---@type snacks.terminal.Opts
local termops = {
	cwd = vim.fs.root(vim.fn.getcwd(), ".wsp-root")
		or vim.fs.root(vim.fn.getcwd(), { ".jj", ".git" })
		or vim.fn.getcwd(),
	-- Pinned so a stray count (`3<leader>l`) asks for the same terminal rather
	-- than a second one.
	count = 1,
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
			require('snacks.terminal').open("opencode", termops)
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
						require("snacks.terminal").toggle("claude-mux", termops)
					else
						require("snacks.terminal").toggle("opencode", termops)
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
