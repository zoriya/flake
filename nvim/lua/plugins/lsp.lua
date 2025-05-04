vim.lsp.enable("lua_ls")
vim.lsp.enable("hls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("clangd")
vim.lsp.enable("pyright")
vim.lsp.enable("nil_ls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("yamlls")
vim.lsp.enable("marksman")
vim.lsp.enable("texlab")
vim.lsp.enable("html")
vim.lsp.enable("helm_ls")
vim.lsp.enable("zls")
vim.lsp.enable("gopls")
vim.lsp.enable("bashls")
vim.lsp.enable("jsonls")

return {
	-- see https://github.com/seblyng/roslyn.nvim/pull/178
	{
		"roslyn.nvim",
		ft = { "cs", "vb" },
		opts = {
			exe = "Microsoft.CodeAnalysis.LanguageServer",
			broad_search = true,
		},
		after = function(plug)
			require("roslyn").setup(plug.opts)
		end,
	},
}
