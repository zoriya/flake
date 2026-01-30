---@type vim.lsp.Config
return {
	settings = {
		sqls = {
			lowercaseKeywords = true,
			connections = {
				{
					driver = "postgresql",
					dataSourceName = os.getenv("DATABASEURL"),
					proto = "tcp",
					user = os.getenv("PGUSER"),
					passwd = os.getenv("PGPASSWORD"),
					host = os.getenv("PGHOST"),
					port = 5432,
					dbName = os.getenv("PGDATABASE"),
				},
			},
		},
	},
}
