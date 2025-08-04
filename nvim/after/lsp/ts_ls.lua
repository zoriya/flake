-- use biome for formatting
return {
	---@param client vim.lsp.Client
	on_init = function(client, _)
		if client.server_capabilities then
			client.server_capabilities["documentFormattingProvider"] = false
			client.server_capabilities["documentRangeFormattingProvider"] = false
			client.server_capabilities["documentOnTypeFormattingProvider"] = false
		end
	end,
}
