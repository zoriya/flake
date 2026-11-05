---@type vim.lsp.Config
return {
	settings = {
		-- lspconfig defaults to fullSolution, which keeps roslyn running analyzers
		-- on every project and floods us with diagnostics (one hidden buffer per
		-- file). compiler errors stay solution-wide so broken callers still show up
		["csharp|background_analysis"] = {
			dotnet_analyzer_diagnostics_scope = "openFiles",
			dotnet_compiler_diagnostics_scope = "fullSolution",
		},
	},
}
