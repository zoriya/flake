return {
	{
		"blink-cmp",
		lazy = false,
		load = function() end,
		opts = {
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
			},
		},
		after = function(plug)
			require("blink-cmp").setup(plug.opts)

			-- config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
		end,
	},
}
