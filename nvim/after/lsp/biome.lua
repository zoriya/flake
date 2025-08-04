return {
	-- Disable lunching from node_modules (no nix binary)
	cmd = { "biome", "lsp-proxy" },
	-- Inline package.json (remove check for biome installed)
	root_dir = function(_, on_dir)
		-- To support monorepos, biome recommends starting the search for the root from cwd
		-- https://biomejs.dev/guides/big-projects/#use-multiple-configuration-files
		local cwd = vim.fn.getcwd()
		local root_files = { 'biome.json', 'biome.jsonc', 'package.json', 'package.json5' }
		local root_dir = vim.fs.dirname(vim.fs.find(root_files, { path = cwd, upward = true })[1])
		on_dir(root_dir)
	end,
}
