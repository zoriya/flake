---@type vim.lsp.Config
return {
	settings = {
		tailwindCSS = {
			classAttributes = {
				"class",
				"className",
				"class:list",
				"classList",
				"ngClass",
				".+ClassName"
			},
			classFunctions = {
				"tw",
				"clsx",
				"tw\\.[a-z-]+",
				"cn"
			}
		},
	},
}
