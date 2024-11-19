return {
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		main = "ibl",
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
	},

	{
		"zoriya/virtcolumn.nvim",
		-- "xiyaowong/virtcolumn.nvim",
		event = "VeryLazy",
		init = function()
			vim.g.virtcolumn_char = '▕'
			vim.opt.colorcolumn = { 80, 120 }
		end,
	},

	{
		"petertriho/nvim-scrollbar",
		event = "VeryLazy",
		config = true,
	},

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		opts = {
			presets = {
				command_palette = true,
				inc_rename = true,
			},
			messages = { enabled = true },
			notify = { enabled = false },
			lsp = {
				progress = { enabled = false },
				signature = { enabled = false },
				hover = { enabled = false },
				message = { enabled = false },
			},
			views = {
				mini = {
					timeout = 2000,
					reverse = false,
				},
			},
			-- routes = {
			-- 	-- Remove Checking document notifications from ltx-ls
			-- 	{
			-- 		filter = { event = "lsp", kind = "progress", find = "Checking document" },
			-- 		opts = { skip = true },
			-- 	},
			-- },
		},
	},

	{
		"j-hui/fidget.nvim",
		event = "VeryLazy",
		opts = {
			progress = {
				ignore = { "ltex" },
				display = {
					render_limit = 5,
				},
			},
			notification = {
				override_vim_notify = true,
				window = {
					winblend = 0,
				},
			},
		},
		init = function()
			vim.opt.cmdheight = 0
		end,
	},

	{
		"luukvbaal/statuscol.nvim",
		branch = "0.10",
		event = "VeryLazy",
		config = function()
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

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			plugins = { spelling = true },
		},
		init = function()
			vim.opt["timeoutlen"] = 500
		end,
	},

	{
		"NvChad/nvim-colorizer.lua",
		event = "VeryLazy",
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
		}
	},

	{
		"stevearc/dressing.nvim",
		lazy = true,
		init = function()
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.select(...)
			end
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.input = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.input(...)
			end
		end,
	},

	{
		"folke/trouble.nvim",
		keys = {
			{ "<leader>lw", "<cmd>Trouble cascade<cr>", desc = "Diagnostics" },
			{
				"<leader>q",
				"<cmd>Trouble close<cr><cmd>cclose<cr>",
				desc = "Close quickfix",
			},
		},
		opts = {
			auto_close = true,
			auto_preview = false,
			cycle_results = false,
			use_diagnostic_signs = true,
			follow = false,
			icons = {
				indent = {
					middle = " ",
					last = " ",
					top = " ",
					ws = "│  ",
				},
			},
			modes = {
				diagnostics = {
					groups = {
						{ "filename", format = "{file_icon} {basename:Title} {count}" },
					},
				},
				cascade = {
					mode = "diagnostics", -- inherit from diagnostics mode
					filter = function(items)
						local severity = vim.diagnostic.severity.HINT
						for _, item in ipairs(items) do
							severity = math.min(severity, item.severity)
						end
						return vim.tbl_filter(function(item)
							return item.severity == severity
						end, items)
					end,
				},
			}
		},
	},

	{
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		config = true,
		event = "VeryLazy",
	},

	{
		"yorickpeterse/nvim-pqf",
		event = "VeryLazy",
		config = true,
	},

	{
		"folke/zen-mode.nvim",
		keys = {
			{ "<leader>z", "<cmd>ZenMode<cr>", desc = "Toogle zen mode" },
		},
		cmd = "ZenMode",
		config = true
	},
}
