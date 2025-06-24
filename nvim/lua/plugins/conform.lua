return {
	{
		"conform.nvim",
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
			default_format_opts = { async = true },
			formatters_by_ft = {
				python = { "ruff_format", "ruff_organize_imports" },
				javascript = { "biome-check", "prettierd", "prettier", stop_after_first = true },
				typescript = { "biome-check", "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "biome-check", "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "biome-check", "prettierd", "prettier", stop_after_first = true },
				json = { "biome-check", "prettierd", "prettier", stop_after_first = true },
				css = { "biome-check", "prettierd", "prettier", stop_after_first = true },
				html = { "biome-check", "prettierd", "prettier", stop_after_first = true },
				sql = { "pg_format" },
				cs = { "csharpier" },
				nix = { "alejandra" },
				["*"] = { "injected" },
				["_"] = { "injected", lsp_format = "last" },
			},
			formatters = {
				["biome-check"] = {
					-- disable node module search since native binaries can't be run from nix
					command = "biome",
				},
				csharpier = function()
					return {
						command = "csharpier",
						args = { "format" },
						stdin = true,
						--- @diagnostic disable: param-type-mismatch
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
