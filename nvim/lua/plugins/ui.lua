return {
	{
		"undotree",
		keys = {
			{ "<leader>u", vim.cmd.UndotreeToggle, desc = "Show undotree" },
		},
	},

	{
		"which-key.nvim",
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
		after = function()
			require("pqf").setup()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "qf" },
				desc = "Set nolist on quickfix",
				group = vim.api.nvim_create_augroup("qf-nolist", { clear = true }),
				callback = function()
					-- or setl nolist
					vim.opt_local.list = false
				end,
			})
			vim.cmd("autocmd FileType qf setl nolist")
		end,
	},

	{
		"virt-column.nvim",
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

	{
		"zen-mode.nvim",
		keys = {
			{ "<leader>zz", "<cmd>ZenMode<cr>", desc = "Toogle zen mode" },
		},
		cmd = "ZenMode",
		after = function()
			require("zen-mode").setup()
		end,
	},
}
