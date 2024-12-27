return {
	{
		"nvim-lint",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			javascript = { "biomejs", "eslint_d" },
			typescript = { "biomejs", "eslint_d" },
			javascriptreact = { "biomejs", "eslint_d" },
			typescriptreact = { "biomejs", "eslint_d" },
		},
		after = function(plug)
			local override_severity = function(linter)
				local old_parser = linter.parser;
				linter.parser = function(output)
					local diags = old_parser(output);
					for _, d in pairs(diags) do
						d.severity = vim.diagnostic.severity.HINT
					end
					return diags
				end
			end
			override_severity(require("lint").linters.eslint_d)
			override_severity(require("lint").linters.biomejs)

			require("lint").linters_by_ft = plug.opts
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
				desc = "Lint buf",
				group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
				callback = function()
					require("lint").try_lint(nil, { ignore_errors = true })
				end,
			})
		end,
	}
}
