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
}
