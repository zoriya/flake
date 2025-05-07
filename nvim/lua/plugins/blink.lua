return {
	{
		"blink-cmp",
		event = "InsertEnter",
		opts = {
			keymap = {
				preset = "default",
				["<C-space>"] = { "show", },
				["<C-e>"] = { "cancel" },
				["<C-h>"] = { "select_and_accept" },
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<Tab>"] = {},
				["S-Tab"] = {},
			},
			completion = {
				trigger = {
					show_in_snippet = false,
					show_on_keyword = false,
					show_on_trigger_character = false,
					show_on_accept_on_trigger_character = false,
					show_on_insert_on_trigger_character = false,
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 0,
				},
				menu = {
					max_height = 15,
					auto_show = false,
				},
				accept = {
					auto_brackets = {
						enabled = false,
					},
				},
			},
			fuzzy = {
				prebuilt_binaries = {
					download = false,
				},
			},
			sources = {
				default = function()
					local success, node = pcall(vim.treesitter.get_node)
					if success and node and (string.find(node:type(), "comment") or string.find(node:type(), "string")) then
						return { "lsp", "path", "buffer" }
					end

					return { "lsp" }
				end,
			},
		},
		after = function(plug)
			require("blink-cmp").setup(plug.opts)
		end,
	},
}
