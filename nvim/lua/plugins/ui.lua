vim.cmd("packadd nvim.undotree")
vim.keymap.set("n",  "<leader>u", "<cmd>Undotree<cr>", { desc = "Show undotree" })

return {
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
			edit = {
				autosave = true,
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
}
