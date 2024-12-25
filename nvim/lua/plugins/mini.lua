return {
	{
		"mini.nvim",
		lazy = false,
		load = function() end,
		after = function()
			require("mini.icons").setup();
			MiniIcons.mock_nvim_web_devicons()
		end,
	},
}
