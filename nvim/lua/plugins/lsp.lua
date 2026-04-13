vim.lsp.enable({
	"lua_ls",
	"hls",
	"rust_analyzer",
	"clangd",
	"basedpyright",
	"nil_ls",
	"ts_ls",
	"yamlls",
	"marksman",
	"texlab",
	"html",
	"cssls",
	"helm_ls",
	"zls",
	"gopls",
	"bashls",
	"jsonls",
	"biome",
	"tailwindcss",
	"sqls",
	"qmlls",
	"roslyn_ls", --we use roslyn.nvim plugin instead.
})

-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	group = vim.api.nvim_create_augroup("lsp-setup", {}),
-- 	callback = function(ev)
-- 		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
-- 		if client:supports_method('textDocument/completion') then
-- 			vim.lsp.completion.enable(true, client.id, ev.buf)
-- 		end
-- 	end,
-- })
vim.lsp.on_type_formatting.enable()
vim.lsp.document_color.enable(true, nil, { style = "virtual" })

return {}
-- return {
-- 	-- see https://github.com/seblyng/roslyn.nvim/pull/178
-- 	{
-- 		"roslyn.nvim",
-- 		ft = { "cs", "vb" },
-- 		opts = {
-- 			broad_search = true,
-- 		},
-- 		after = function(plug)
-- 			vim.lsp.config("roslyn", {
-- 				cmd = {
-- 					'Microsoft.CodeAnalysis.LanguageServer',
-- 					'--logLevel',
-- 					'Information',
-- 					'--extensionLogDirectory',
-- 					vim.fs.joinpath(vim.uv.os_tmpdir(), 'roslyn_ls/logs'),
-- 					'--stdio',
-- 				},
-- 			})
-- 			require("roslyn").setup(plug.opts)
-- 		end,
-- 	},
-- }
