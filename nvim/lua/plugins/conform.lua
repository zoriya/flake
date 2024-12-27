return {
	{
		"conform.nvim",
		lazy = false,
		load = function() end,
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>e",
				function()
					require("conform").format()
				end,
				desc = "Format",
				mode = { "n", "v" },
			},
		},
		opts = {
			default_format_opts = { async = true, lsp_format = "fallback" },
			formatters_by_ft = {
				python = function(bufnr)
					if require("conform").get_formatter_info("ruff_format", bufnr).available then
						return { "ruff_format" }
					else
						return { "isort", "black" }
					end
				end,
				javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
				typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
				json = { "biome", "prettierd", "prettier", stop_after_first = true },
				css = { "biome", "prettierd", "prettier", stop_after_first = true },
				html = { "biome", "prettierd", "prettier", stop_after_first = true },
				sql = { "pg_format" },
				cs = { "csharpier" },
				nix = { "alejandra" },
				-- ["_"] = { "injected", lsp_format = "last" },
				["*"] = { "injected" }
			},
			formatters = {
				biome = {
					-- disable node module search since native binaries can't be run from nix
					command = "biome",
				},
				csharpier = function()
					return {
						cwd = require("conform.util").root_file(function(name)
							return name:match('.*%.sln$') or name:match('.*%.csproj$')
						end),
						require_cwd = true,
					}
				end,
			},
		},
		after = function(plug)
			require("conform").setup(plug.opts)
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end
	},
}
