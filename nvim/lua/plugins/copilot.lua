return {
	-- {
	-- 	"avante.nvim",
	-- 	keys = {
	-- 		{
	-- 			"<leader>l",
	-- 			"<cmd>AvanteToggle<cr>",
	-- 			desc = "Copilot",
	-- 			mode = { "n", "v" },
	-- 		}
	-- 	},
	-- 	opts = {
	-- 		provider = "copilot",
	-- 		dual_boost = {
	-- 			enabled = false,
	-- 		},
	-- 		behaviour = {
	-- 			auto_suggestions = false,
	-- 		},
	-- 		mappings = {
	-- 			diff = false,
	-- 		},
	-- 		hints = {
	-- 			enabled = false,
	-- 		},
	-- 	},
	-- 	after = function(plug)
	-- 		require("avante").setup(plug.opts)
	-- 	end,
	-- },

	{
		"CopilotChat.nvim",
		keys = {
			{
				"<leader>l",
				"<cmd>CopilotChatToggle<cr>",
				desc = "Copilot",
				mode = { "n", "v" },
			}
		},
		opts = {
			auto_insert_mode = true,
			mappings = {
				complete = {
					insert = "<C-space>",
				},
				close = {
					normal = "q",
					insert = "",
				},
			}
		},
		after = function(plug)
			local select = require("CopilotChat.select")
			plug.opts.selection = function(source)
				return select.visual(source) or select.buffer(source)
			end
			require("CopilotChat").setup(plug.opts)
		end,
	},
}
