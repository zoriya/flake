return {
	{
		"nvim-surround",
		lazy = false,
		load = function() end,
		after = function()
			require("nvim-surround").setup({})
		end,
	}
}
