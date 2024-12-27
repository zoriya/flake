require("catppuccin").setup({
	compile_path = vim.env.out .. "/lua/colors",
	integrations = {
		telescope = {
			enabled = true,
			style = "nvchad"
		},
		blink_cmp = true,
		harpoon = true,
		nvim_surround = true,
		which_key = true,
		navic = true,
		leap = true,
		noice = true,
	},
})
