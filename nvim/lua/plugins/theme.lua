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
				which_key = true,
				navic = true,
				leap = true,

				fidget = false,
				noice = false,
			},
		},
		after = function(plug)
			require("catppuccin").setup(plug.opt)
			vim.cmd.colorscheme("catppuccin")
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
