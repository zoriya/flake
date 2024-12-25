return {
	{
		"catppuccin-nvim",
		-- colorscheme = "catppuccin",
		load = function() end,
		priority = 1000,
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
			vim.cmd.colorscheme "catppuccin"
		end,
	},
}
