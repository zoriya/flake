return {
	{
		"harpoon2",
		keys = {
			{ "<leader>a", '<cmd>lua require("harpoon"):list():add()<CR>',                                    desc = "Mark file" },
			{ "<leader>h", '<cmd>lua require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())<CR>', desc = "Harpoon menu" },
			{ "<A-h>",     '<cmd>lua require("harpoon"):list():select(1)<CR>',                                desc = "Navigate to harpoon 1" },
			{ "<A-t>",     '<cmd>lua require("harpoon"):list():select(2)<CR>',                                desc = "Navigate to harpoon 2" },
			{ "<A-n>",     '<cmd>lua require("harpoon"):list():select(3)<CR>',                                desc = "Navigate to harpoon 3" },
			{ "<A-s>",     '<cmd>lua require("harpoon"):list():select(4)<CR>',                                desc = "Navigate to harpoon 4" },

			-- <C-;> is not a valid sequence so use HJKL instead.
			{ "<A-j>",     '<cmd>lua require("harpoon"):list():select(2)<CR>',                                desc = "Navigate to harpoon 2" },
			{ "<A-k>",     '<cmd>lua require("harpoon"):list():select(3)<CR>',                                desc = "Navigate to harpoon 3" },
			-- <C-L> is already taken but since I use harpoon less on querty no worry
		},
		opts = {
			settings = {
				save_on_toggle = true,
			},
		},
		after = function(plug)
			require("harpoon"):setup(plug.otps)
		end,
	},
}
