return {
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
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
			scope = { show_start = false },
		},
	},

	{
		"xiyaowong/virtcolumn.nvim",
		event = "VeryLazy",
		init = function()
			vim.g.virtcolumn_char = '▕'
			vim.opt.colorcolumn = { 80, 120 }
		end,
	},

	{
		"petertriho/nvim-scrollbar",
		event = "VeryLazy",
		-- TODO: Add colors highlights.
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
			lsp = {
				signature = {
					enabled = false,
				},
				hover = {
					enabled = false,
				},
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = false,
					["vim.lsp.util.stylize_markdown"] = false,
					["cmp.entry.get_documentation"] = false,
				},
			},
			views = {
				mini = {
					timeout = 5000,
					reverse = false,
				},
			},
		},
	},

	{
		"luukvbaal/statuscol.nvim",
		event = "VeryLazy",
		config = function()
			local builtin = require("statuscol.builtin")
			require("statuscol").setup({
				relculright = false,
				segments = {
					{
						sign = { name = { ".*" }, maxwidth = 1, },
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
			operators = {
				gc = "Comments",
				ys = "Add Surroundings",
				yS = "Add Surroundings",
			}
		},
		dependencies = {
			"afreakk/unimpaired-which-key.nvim",
		},
		config = function(_, opts)
			vim.opt["timeoutlen"] = 500

			local wk = require("which-key")
			wk.setup(opts)

			local uwk = require("unimpaired-which-key")
			wk.register(uwk.normal_mode)
			wk.register(uwk.normal_and_visual_mode, { mode = { "n", "v" } })

			wk.register({
				gx = "Git conflict",
			})
			wk.register({
				mode = { "n", "v" },
				["g"] = { name = "+goto" },
				["]"] = { name = "+next" },
				["["] = { name = "+prev" },
				["<leader>g"] = { name = "+git" },
				["<leader>l"] = { name = "+lsp" },
			})
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
				RGB = true,
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
		"cormacrelf/trouble.nvim",
		branch = "cascading-sev-2",
		keys = {
			{ "<leader>ld", "<cmd>Trouble document_diagnostics<cr>",  desc = "Document Diagnostics" },
			{ "<leader>lw", "<cmd>Trouble workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
			{ "<leader>lt", "<cmd>TroubleToggle<CR>",                 desc = "Toogle trouble window" },
		},
		opts = {
			auto_close = true,
			min_severity = "Warning",
		},
	},

	{
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		config = true,
		event = "VeryLazy",
		keys = {
			{ "<leader>t", "<cmd>TodoQuickFix<cr>", desc = "Open todo list" },
		}
	},

	{
		"https://gitlab.com/yorickpeterse/nvim-pqf.git",
		event = "VeryLazy",
		config = true,
	},
}
