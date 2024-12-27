return {
	{
		"statuscol.nvim",
		lazy = false,
		load = function() end,
		after = function()
			local builtin = require("statuscol.builtin")
			require("statuscol").setup({
				relculright = false,
				segments = {
					{
						sign = {
							name = { ".*" },
							namespace = { ".*" },
							maxwidth = 1,
						},
						click = "v:lua.ScSa"
					},
					{ text = { builtin.lnumfunc }, click = "v:lua.ScLa", },
					{
						sign = { namespace = { "gitsign" }, maxwidth = 1, colwidth = 1 },
						click = "v:lua.ScSa"
					},
				}
			})
		end
	},
}
