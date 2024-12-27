return {
	{
		"undotree",
		load = function() end,
		lazy = false,
		keys = {
			{ "<leader>u", vim.cmd.UndotreeToggle, desc = "Show undotree" },
		},
	},

	{
		"which-key.nvim",
		load = function() end,
		lazy = false,
		opts = {
			plugins = { spelling = true },
		},
		after = function(plug)
			require("which-key").setup(plug.opts)
			vim.opt.timeoutlen = 500
		end,
	},

	{
		"nvim-colorizer.lua",
		load = function() end,
		lazy = false,
		event = "BufReadPre",
		opts = {
			filetypes = {
				'*',
				html = { names = true },
				css = { names = true },
			},
			user_default_options = {
				mode = "virtualtext",
				RGB = false,
				RRGGBB = true,
				names = false,
				RRGGBBAA = true,
				AARRGGBB = true,
				rgb_fn = true,
				hsl_fn = true,
				tailwind = true,
			},
		},
		after = function(plug)
			require("colorizer").setup(plug.opts)
		end
	},

	{
		"nvim-pqf",
		load = function() end,
		lazy = false,
		ft = "qf",
		after = function()
			require("pqf").setup()
		end,
	},

	{
		"virt-column.nvim",
		lazy = false,
		load = function() end,
		opts = {
			char = "▕",
		},
		after = function(plug)
			require("virt-column").setup(plug.opts)
		end,
	},

	{
		"indent-blankline.nvim",
		lazy = false,
		load = function() end,
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			indent = {
				char = "▏",
				tab_char = "▏",
			},
			exclude = {
				filetypes = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"lazy",
					"lspinfo",
					"packer",
					"checkhealth",
					"help",
					"man",
					"",
				}
			},
			scope = { show_start = false, show_end = false, },
		},
		after = function(plug)
			require("ibl").setup(plug.opts)
		end,
	},
}
