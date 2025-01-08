return {
	{
		"mini.icons",
		enabled = vim.g.have_nerd_font,
		after = function()
			require("mini.icons").setup();
			MiniIcons.mock_nvim_web_devicons()
		end,
	},

	{
		"mini.operators",
		opts = {
			replace = {
				prefix = "cr",
				reindent_linewise = true,
			},
		},
		keys = {
			{ "gx" },
			{ "cr",         desc = "Replace with register" },
			{ "<leader>cr", '"+cr',                        remap = true, desc = "Replace with system clipboard" },
		},
		after = function(plug)
			require("mini.operators").setup(plug.opts)
		end,
	},

	{
		"mini.splitjoin",
		keys = {
			{ "gS", desc = "Split arguments" },
			{ "gJ", desc = "Join arguments" },
		},
		opts = {
			mappings = {
				toggle = '',
				split = 'gS',
				join = 'gJ',
			},
		},
		after = function(plug)
			require("mini.splitjoin").setup(plug.opts)
		end
	},
}
