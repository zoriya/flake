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

-- Adds `@file#from-to` to the prompt of every claude/opencode connected to claudecode's ide server.
local function mention(from, to)
	local server = require("claudecode.server.init")
	if not server.state.server or next(server.state.server.clients) == nil then
		vim.notify("No claude/opencode connected", vim.log.levels.WARN)
		return
	end
	local path = vim.api.nvim_buf_get_name(0)
	for _, client in pairs(server.state.server.clients) do
		if client.opencode then
			-- opencode can't mention a whole file from the ide and uses lines as-is.
			server.send(client, "at_mentioned", {
				filePath = path,
				lineStart = from or 1,
				lineEnd = to or vim.api.nvim_buf_line_count(0),
			})
		else
			-- The protocol is 0-indexed, claude adds 1.
			server.send(client, "at_mentioned", {
				filePath = path,
				lineStart = from and from - 1,
				lineEnd = to and to - 1,
			})
		end
	end
end

function _G.ai_mention_operator()
	mention(vim.api.nvim_buf_get_mark(0, "[")[1], vim.api.nvim_buf_get_mark(0, "]")[1])
end

return {
	{
		"claudecode.nvim",
		event = "DeferredUIEnter",
		after = function()
			-- Not `claudecode.server`, claudecode requires it with `.init` so it's a different module instance.
			local server = require("claudecode.server.init")
			local register_handlers = server.register_handlers
			server.register_handlers = function()
				register_handlers()
				local initialize = server.state.handlers.initialize
				server.state.handlers.initialize = function(client, params)
					client.opencode = params.clientInfo and params.clientInfo.name == "opencode"
					return initialize(client, params)
				end
			end

			require("claudecode").setup({ terminal = { provider = "none" } })
		end,
		keys = {
			{
				"<leader>l",
				function()
					if get_mode() == "claude" then
						require("snacks.terminal").toggle("claude-mux", termops)
					else
						-- Connect opencode to this nvim, see the patch in modules/cli/ai/opencode.nix.
						local server = require("claudecode.server.init").state
						require("snacks.terminal").toggle("opencode", vim.tbl_extend("force", termops, {
							env = {
								OPENCODE_EDITOR_SSE_PORT = tostring(server.port),
								OPENCODE_EDITOR_AUTH_TOKEN = server.auth_token,
							},
						}))
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
					vim.o.operatorfunc = "v:lua.ai_mention_operator"
					return "g@"
				end,
				desc = "Add range to AI",
				mode = { "n", "x" },
				expr = true,
			},
			{
				"gll",
				function()
					vim.o.operatorfunc = "v:lua.ai_mention_operator"
					return "g@_"
				end,
				desc = "Add line to AI",
				expr = true,
			},
			{
				"gL",
				function()
					mention()
				end,
				desc = "Add buffer to AI"
			},
		},
	},
}
