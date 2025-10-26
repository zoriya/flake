vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local client_id = args.data.client_id
		local client = assert(vim.lsp.get_client_by_id(client_id))
		if client.name == 'biome' then
			vim.lsp.on_type_formatting.enable(false, { client_id = client_id })
		end
	end,
})

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
