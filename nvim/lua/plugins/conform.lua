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
				sql = { "pg_format" },
				cs = { "csharpier" },
				nix = { "alejandra" },
				-- ["*"] = { "injected" },
				-- ["_"] = { "injected", lsp_format = "last" },
				["_"] = { lsp_format = "last" },
			},
			formatters = {
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
