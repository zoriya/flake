return {
	{
		"lualine.nvim",
		event = "DeferredUIEnter",
		opts = {
			options = {
				theme = "auto",
				component_separators = '|',
				section_separators = { left = '', right = '' },
				always_divide_middle = true,
				globalstatus = true,
				disabled_filetypes = {},
			},
			sections = {
				lualine_a = {
					{
						'mode',
						fmt = function(str) return string.format("%7s", str) end
					},
				},
				lualine_b = {
					{
						"diagnostics",
						sources = {
							function()
								local diag_severity = vim.diagnostic.severity

								local function workspace_diag(severity)
									local count = vim.diagnostic.get(nil, { severity = severity })
									return vim.tbl_count(count)
								end

								return {
									error = workspace_diag(diag_severity.ERROR),
									warn = workspace_diag(diag_severity.WARN),
									info = workspace_diag(diag_severity.INFO),
									hint = workspace_diag(diag_severity.HINT)
								}
							end,
						},
						sections = { "error", "warn" },
						symbols = { error = "󰅚 ", warn = " " },
						always_visible = false,
					}
				},
				lualine_c = {
					{
						function()
							return ""
						end,
						color = "ErrorMsg",
						cond = function() return not vim.g.auto_save_state end,
					},
					{
						'filetype',
						colored = true,
						icon_only = true,
						separator = "",
						padding = { left = 1, right = 0 }
					},
					{
						'filename',
						separator = '>',
						path = 0,
						symbols = {
							modified = '',
							readonly = '[-]',
							unnamed = '[No Name]',
						},
					},
					{
						"navic",
						color_correction = "static",
					},
				},
				lualine_x = {
					{
						require("noice").api.status.mode.get,
						cond = require("noice").api.status.mode.has,
						color = { fg = "#ff9e64" },
					},
					'fileformat',
				},
				lualine_y = { 'branch', 'progress' },
				lualine_z = {
					{
						'location',
					},
				},
			},
			tabline = {},
			extensions = {
				"quickfix",
				"oil",
			},
		},
		after = function(plug)
			vim.opt.showmode = false
			require("lualine").setup(plug.opts)
		end,
	},

	{
		"nvim-navic",
		event = "DeferredUIEnter",
		opts = {
			highlight = true,
			lsp = {
				auto_attach = true,
			},
		},
		after = function(plug)
			require("nvim-navic").setup(plug.opts)
		end,
	},
}
