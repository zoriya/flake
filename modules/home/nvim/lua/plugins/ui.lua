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
				autocmd FileType * if index(["netrw", "NvimTree", "neo-tree", "UltestAttach", "dap-float", "Trouble", "lspinfo", "qf", "harpoon", "toggleterm", "packer"], &ft) == -1 | lua require("virt-column").setup_buffer({ virtcolumn = "80,120", char = "▏" })
			augroup end
			]]
		end,
	},

	{
		"petertriho/nvim-scrollbar",
		event = "VeryLazy",
		-- TODO: Add colors highlights.
		config = true;
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

			wk.register({
				gc = {
					name = "Comment",
				},
				ys = { name = "Add Surroundings" },
				ds = { name = "Delete Surroundings" },
				cs = { name = "Change Surroundings" },
				yS = { name = "Add Surroundings" },
				dS = { name = "Delete Surroundings" },
				cS = { name = "Change Surroundings" },
			}, {
				noremap = false,
			})

			wk.register({
				mode = { "n", "v" },
				["g"] = { name = "+goto" },
				["]"] = { name = "+next" },
				["["] = { name = "+prev" },
				["<leader>g"] = { name = "+git" },
				["<leader>l"] = { name = "+lsp" },
			})

			local uwk = require("unimpaired-which-key")
			wk.register(uwk.normal_mode)
			wk.register(uwk.normal_and_visual_mode, { mode = { "n", "v" } })
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
			{ "<leader>ld", "<cmd>Trouble document_diagnostics<cr>", "Document Diagnostics" },
			{ "<leader>lw", "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
			{ "<leader>lt", "<cmd>TroubleToggle<CR>", "Toogle trouble window" },
		},
		opts = {
			auto_close = true,
			min_severity = "Warning",
		},
	},
}
