return {
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			char = "▏",
			filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
			show_trailing_blankline_indent = true,
			use_treesitter = true,
			show_current_context = true,
		},
	},

	{
		"lukas-reineke/virt-column.nvim",
		lazy = true,
		config = true,
		init = function()
			vim.cmd [[
			augroup virtcolumn
				autocmd!
				autocmd FileType * if index(["netrw", "NvimTree", "neo-tree", "TelescopePrompt", "TelescopeResults", "UltestAttach", "dap-float", "Trouble", "lspinfo", "qf", "harpoon", "toggleterm", "packer"], &ft) == -1 | lua require("virt-column").setup_buffer({ virtcolumn = "80,120", char = "▏" })
			augroup end
			]]
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
