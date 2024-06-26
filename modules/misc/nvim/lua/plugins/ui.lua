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
		config = function(_, opts)
			vim.opt["timeoutlen"] = 500

			local wk = require("which-key")
			wk.setup(opts)

			wk.register({
				gx = { name = "+Git conflict" },
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
		"folke/trouble.nvim",
		keys = {
			{ "<leader>ld", "<cmd>Trouble document_diagnostics<cr>",  desc = "Document Diagnostics" },
			{ "<leader>lw", "<cmd>Trouble workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
			{ "<leader>lt", "<cmd>TroubleToggle<CR>",                 desc = "Toogle trouble window" },
		},
		opts = {
			auto_close = true,
			auto_preview = false,
			cycle_results = false,
			use_diagnostic_signs = true,
			severity = vim.diagnostic.severity.ERORR,
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
