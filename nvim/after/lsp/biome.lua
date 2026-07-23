vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local client_id = args.data.client_id
		local client = assert(vim.lsp.get_client_by_id(client_id))
		if client.name == 'biome' then
			vim.lsp.on_type_formatting.enable(false, { client_id = client_id })
		end
	end,
})

---@type vim.lsp.Config
return {
	-- Disable lunching from node_modules (no nix binary)
	cmd = { "biome", "lsp-proxy" },
	-- for json files
	workspace_required = false,
	-- The default lspconfig root_dir only starts biome when a biome.json exists,
	-- so it never attaches for config-less projects or standalone files. Always
	-- resolve a root so biome attaches everywhere
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local root_files = { "biome.json", "biome.jsonc" }
		-- biome recommends searching from cwd for monorepos
		local found = vim.fs.find(root_files, { path = vim.fn.getcwd(), upward = true })[1]
			or vim.fs.find(root_files, { path = fname, upward = true })[1]
		-- fall back to the file's own dir so a standalone json still gets a workspace
		on_dir(found and vim.fs.dirname(found) or vim.fs.dirname(fname))
	end,
}
