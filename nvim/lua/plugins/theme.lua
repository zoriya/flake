return {
	{
		"catppuccin-nvim",
		colorscheme = "catppuccin",
		lazy = false,
		priority = 1000,
		load = function() end,
		opt = {
			integrations = {
				telescope = {
					enabled = true,
					style = "nvchad"
				}
			},
		},
		after = function(plug)
			require("catppuccin").setup(plug.opt)
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
