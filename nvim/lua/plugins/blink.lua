return {
	{
		"blink-cmp",
		event = "InsertEnter",
		opts = {
			keymap = {
				preset = "default",
				['<C-space>'] = { 'show', },
				['<C-h>'] = { 'select_and_accept' },
				['<Up>'] = { 'select_prev', 'fallback' },
				['<Down>'] = { 'select_next', 'fallback' },
				['<Tab>'] = {},
				['<S-Tab>'] = {},
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
				},
			},
			fuzzy = {
				prebuilt_binaries = {
					download = false,
				},
			},
		},
		after = function(plug)
			require("blink-cmp").setup(plug.opts)
			vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
		end,
	},
}
