return {
	{
		"catppuccin-nvim",
		-- colorscheme = "catppuccin",
		priority = 1000,
		opt = {
			integrations = {
				treesitter = true
			},
		},
		after = function(plug)
			require("catppuccin").setup(plug.opt)
			vim.cmd.colorscheme "catppuccin"
		end,
	},
}
