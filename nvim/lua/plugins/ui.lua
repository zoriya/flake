return {
	{
		"undotree",
		keys = {
			{ "<leader>u", vim.cmd.UndotreeToggle, desc = "Show undotree" },
		},
	},

	{
		"which-key.nvim",
		event = "DeferredUIEnter",
		opts = {
			plugins = { spelling = true },
			icons = {
				mappings = vim.g.have_nerd_font,
			},
		},
		after = function(plug)
			require("which-key").setup(plug.opts)
			vim.opt.timeoutlen = 500
		end,
	},

	{
		"nvim-colorizer.lua",
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
		"quicker.nvim",
		ft = "qf",
		opts = {
			opts = {
				list = false,
				spell = false,
			},
			highlight = {
				load_buffers = false,
			},
			max_filename_width = function()
				return math.floor(math.min(50, vim.o.columns / 2))
			end
		},
		after = function(plug)
			local signs = vim.diagnostic.config().signs.text
			plug.opts.type_icons = {
				E = signs[vim.diagnostic.severity.ERROR],
				W = signs[vim.diagnostic.severity.WARN],
				I = signs[vim.diagnostic.severity.INFO],
				N = signs[vim.diagnostic.severity.INFO],
				H = signs[vim.diagnostic.severity.HINT],
			}
			require("quicker").setup(plug.opts)
		end,
	},

	{
		"virt-column.nvim",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			char = "▕",
		},
		after = function(plug)
			require("virt-column").setup(plug.opts)
		end,
	},

	{
		"indent-blankline.nvim",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			indent = {
				char = "▏",
				tab_char = "▏",
			},
			exclude = {
				filetypes = {
					"help",
					"checkhealth",
					"help",
					"man",
					"qf",
					"",
				}
			},
			scope = { show_start = false, show_end = false, },
		},
		after = function(plug)
			require("ibl").setup(plug.opts)
		end,
	},

	{
		"zen-mode.nvim",
		keys = {
			{ "<leader>zz", "<cmd>ZenMode<cr>", desc = "Toogle zen mode" },
		},
		after = function()
			require("zen-mode").setup()
		end,
	},


	{
		"areyoulockedin",
		event = "DeferredUIEnter",
		after = function()
			require("areyoulockedin").setup({
				session_key = "3689e546-b1a4-4cc3-8209-f612e7428528",
			})
		end,
	}
}
