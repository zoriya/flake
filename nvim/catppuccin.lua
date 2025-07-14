require("catppuccin").setup({
	compile_path = vim.env.out .. "/lua/colors",
	integrations = {
		blink_cmp = true,
		harpoon = true,
		nvim_surround = true,
		which_key = true,
		navic = true,
		leap = true,
		noice = true,
		snacks = {
			enabled = true,
		},
	},
	custom_highlights = function(C)
		return {
			SnacksPickerMatch = { fg = C.mauve, style = { 'italic' } },
			SnacksPickerInput = { fg = C.text, bg = C.crust },
			SnacksPickerInputTitle = { fg = C.crust, bg = C.mauve },
			SnacksPickerInputBorder = { fg = C.text, bg = C.crust },
			SnacksPickerList = { bg = C.base },
			SnacksPickerListCursorLine = { bg = C.crust },
			SnacksPickerPreview = { bg = C.mantle },
			SnacksPickerPreviewBorder = { fg = C.mantle, bg = C.mantle },
			SnacksPickerPreviewTitle = { fg = C.mantle, bg = C.red },
		}
	end
})
