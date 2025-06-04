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
		"snacks-nvim",
		event = "DeferredUIEnter",
		opts = {
			input = {
				enabled = true,
			},
			indent = {
				enabled = true,
				indent = {
					char = "▏",
				},
				animate = {
					enabled = false,
				},
				scope = {
					char = "▏",
				},
				chunk = {
					char = {
						vertical = "▏",
					},
				},
			},
			zen = {
				toggles = {
					dim = false,
				},
				show = {
					statusline = true,
				},
			},
			styles = {
				input = {
					relative = "cursor",
					row = -3,
					col = 0,
					keys = {
						i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true },
					},
				},
				zen = {
					width = 200,
					backdrop = {
						transparent = false,
						blend = 0,
					},
				},
			},
		},
		after = function(plug)
			require("snacks").setup(plug.opts)

			vim.keymap.set("n", "<leader>zz", function() require("snacks").zen() end, { desc = "Toggle zen mode" })
		end,
	},
}
