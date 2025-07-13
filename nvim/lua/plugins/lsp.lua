vim.lsp.enable("lua_ls")
vim.lsp.enable("hls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("clangd")
vim.lsp.enable("basedpyright")
vim.lsp.enable("nil_ls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("yamlls")
vim.lsp.enable("marksman")
vim.lsp.enable("texlab")
vim.lsp.enable("html")
vim.lsp.enable("cssls")
vim.lsp.enable("helm_ls")
vim.lsp.enable("zls")
vim.lsp.enable("gopls")
vim.lsp.enable("bashls")
vim.lsp.enable("jsonls")
vim.lsp.enable("hyprls")
vim.lsp.enable("biome")
-- vim.lsp.enable("roslyn_ls")

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Custom lsp attach",
	group = vim.api.nvim_create_augroup("lsp-setup", { clear = true }),
	callback = function(args)
		vim.lsp.document_color.enable(true, args.buf, { style = "virtual" })
	end,
})

return {
	-- see https://github.com/seblyng/roslyn.nvim/pull/178
	{
		"roslyn.nvim",
		ft = { "cs", "vb" },
		opts = {
			broad_search = true,
		},
		after = function(plug)
			vim.lsp.config("roslyn", {
				cmd = {
					'Microsoft.CodeAnalysis.LanguageServer',
					'--logLevel',
					'Information',
					'--extensionLogDirectory',
					vim.fs.joinpath(vim.uv.os_tmpdir(), 'roslyn_ls/logs'),
					'--stdio',
				},
			})
			require("roslyn").setup(plug.opts)
		end,
	},
}
