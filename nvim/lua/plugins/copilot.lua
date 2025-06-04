return {
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
			model = "gemini-2.5-pro",
			chat_autocomplete = false,
			auto_insert_mode = true,
			mappings = {
				complete = {
					insert = "<Tab>",
				},
				close = {
					normal = "q",
					insert = "",
				},
			}
		},
		after = function(plug)
			require("CopilotChat").setup(plug.opts)
		end,
	},
}
