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
				},
				blink_cmp = true,
				harpoon = true,
				nvim_surround = true,
			},
		},
		after = function(plug)
			require("catppuccin").setup(plug.opt)
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
