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
	"roslyn_ls",
	"astro",
	"mdx_analyzer",
})

vim.lsp.on_type_formatting.enable()
vim.lsp.document_color.enable(true, nil, { style = "virtual" })

return {}
