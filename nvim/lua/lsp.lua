if vim.g.have_nerd_font then
	vim.diagnostic.config({
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚",
				[vim.diagnostic.severity.WARN] = "",
				[vim.diagnostic.severity.HINT] = "󰌶",
				[vim.diagnostic.severity.INFO] = "",
			},
		},
	})
end
vim.diagnostic.config({
	virtual_text = false,
	update_in_insert = true,
})

-- see https://github.com/neovim/nvim-lspconfig/issues/3494
require("lspconfig").lua_ls.setup({})
require("lspconfig").hls.setup({})
require("lspconfig").rust_analyzer.setup({})
require("lspconfig").clangd.setup({})
require("lspconfig").omnisharp.setup({})
require("lspconfig").pyright.setup({})
require("lspconfig").nil_ls.setup({})
require("lspconfig").ts_ls.setup({})
require("lspconfig").yamlls.setup({})
require("lspconfig").marksman.setup({})
require("lspconfig").ltex.setup({})
require("lspconfig").texlab.setup({})
require("lspconfig").html.setup({})
require("lspconfig").helm_ls.setup({})
require("lspconfig").zls.setup({})

require("lspconfig").jsonls.setup({
	on_new_config = function(new_config)
		new_config.settings.json.schemas = new_config.settings.json.schemas or {}
		vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
	end,
	settings = {
		json = {
			format = {
				enable = true,
			},
			validate = { enable = true },
		},
	},
})

require("lspconfig").gopls.setup({
	settings = {
		-- https://go.googlesource.com/vscode-go/+/HEAD/docs/settings.md#settings-for
		gopls = {
			analyses = {
				nilness = true,
				unusedparams = true,
				unusedwrite = true,
				useany = true
			},
			experimentalPostfixCompletions = true,
			gofumpt = true,
			staticcheck = true,
			usePlaceholders = true,
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true
			}
		}
	}
})
