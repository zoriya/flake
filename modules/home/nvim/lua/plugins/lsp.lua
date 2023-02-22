local old = {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
			"mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		---@class PluginLspOpts
		opts = {
			-- options for vim.diagnostic.config()
			diagnostics = {
				underline = true,
				update_in_insert = true,
				virtual_text = false,
				severity_sort = true,
			},
			-- Automatically format on save
			autoformat = false,
			-- options for vim.lsp.buf.format
			-- `bufnr` and `filter` is handled by the LazyVim formatter,
			-- but can be also overridden when specified
			format = {
				formatting_options = nil,
				timeout_ms = nil,
			},
			-- LSP Server Settings
			---@type lspconfig.options
			servers = {
				jsonls = {},

				lua_ls = {
					-- mason = false, -- set to false if you don't want this server to be installed with mason
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},

				-- omnisharp = {
				-- 	handlers = {
				-- 		["textDocument/definition"] = require('omnisharp_extended').handler,
				-- 	},
				-- 	cmd_env = {
				-- 		["OMNISHARP_FormattingOptions:EnableEditorConfigSupport"] = true,
				-- 		["OMNISHARP_RoslynExtensionsOptions:enableAnalyzersSupport"] = true,
				-- 		["OMNISHARP_RoslynExtensionsOptions:enableImportCompletion"] = true,
				-- 		["OMNISHARP_RoslynExtensionsOptions:enableDecompilationSupport"] = true,
				-- 		["OMNISHARP_msbuild:EnablePackageAutoRestore"] = true,
				-- 	},
				-- },

				robotframework_ls = {
					settings = {
						robot = {
							codeFormatter = "robotidy",
							variables = {
								RESOURCES = vim.fn.getcwd() .. "/tests/robot/",
							},
						},
					}
				},
			},
			-- you can do any additional lsp server setup here
			-- return true if you don't want this server to be setup with lspconfig
			---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
			setup = {
				-- example to setup with typescript.nvim
				-- tsserver = function(_, opts)
				--   require("typescript").setup({ server = opts })
				--   return true
				-- end,
				-- Specify * to use this function as a fallback for any server
				-- ["*"] = function(server, opts) end,
			},
		},
		---@param opts PluginLspOpts
		config = function(plugin, opts)
			-- setup formatting and keymaps
			require("lazyvim.util").on_attach(function(client, buffer)
				require("lazyvim.plugins.lsp.format").on_attach(client, buffer)
				require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
			end)

			-- diagnostics
			for name, icon in pairs(require("lazyvim.config").icons.diagnostics) do
				name = "DiagnosticSign" .. name
				vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
			end
			vim.diagnostic.config(opts.diagnostics)

			local servers = opts.servers
			local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})

				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
						return
					end
				elseif opts.setup["*"] then
					if opts.setup["*"](server, server_opts) then
						return
					end
				end
				require("lspconfig")[server].setup(server_opts)
			end

			-- temp fix for lspconfig rename
			-- https://github.com/neovim/nvim-lspconfig/pull/2439
			local mappings = require("mason-lspconfig.mappings.server")
			if not mappings.lspconfig_to_package.lua_ls then
				mappings.lspconfig_to_package.lua_ls = "lua-language-server"
				mappings.package_to_lspconfig["lua-language-server"] = "lua_ls"
			end

			local mlsp = require("mason-lspconfig")
			local available = mlsp.get_available_servers()

			local ensure_installed = {} ---@type string[]
			for server, server_opts in pairs(servers) do
				if server_opts then
					server_opts = server_opts == true and {} or server_opts
					-- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
					if server_opts.mason == false or not vim.tbl_contains(available, server) then
						setup(server)
					else
						ensure_installed[#ensure_installed + 1] = server
					end
				end
			end

			require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
			require("mason-lspconfig").setup_handlers({ setup })
		end,
	},

	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "mason.nvim" },
		opts = function()
			local nls = require("null-ls")
			local sources = {
				nl.builtins.code_actions.eslint_d,
				nl.builtins.diagnostics.eslint_d,
				nl.builtins.formatting.eslint_d,
				nl.builtins.formatting.prettierd,
				nl.builtins.formatting.black,
			}
			return {
				sources = vim.tbl_map(function(source)
					return source.with({
						diagnostics_postprocess = function(diagnostic)
							diagnostic.severity = vim.diagnostic.severity.HINT
						end,
					})
					end, sources),
			}
		end,
	},

	{

		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>li", "<cmd>Mason<cr>", desc = "Mason" } },
		opts = {
			ensure_installed = { },
		},
		---@param opts MasonSettings | {ensure_installed: string[]}
		config = function(plugin, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			for _, tool in ipairs(opts.ensure_installed) do
				local p = mr.get_package(tool)
				if not p:is_installed() then
					p:install()
				end
			end
		end,
	},
}



return {
	{
		"dundalek/lazy-lsp.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"neovim/nvim-lspconfig"
		},
		opts = {
			excluded_servers = { "efm", "diagnosticls" },
		},
	},
}
