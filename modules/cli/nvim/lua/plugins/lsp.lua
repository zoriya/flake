local lsp_keymaps = function(buffer)
	local function map(mode, l, r, desc)
		vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
	end


	map("i", "<C-Space>", '<cmd>lua vim.lsp.completion.trigger()<CR>', "Open completion menu")
	map({ "n", "i" }, "<C-k>", '<cmd>lua vim.lsp.buf.signature_help()<CR>', "See signature help")

	map("n", "gD", '<cmd>lua vim.lsp.buf.declaration()<CR>', "Go to declaration")
	map("n", "gd", '<cmd>lua vim.lsp.buf.definition()<CR>', "Go to definition")
	map("n", "gI", '<cmd>lua vim.lsp.buf.implementation()<CR>', "Go to implementation")
	map("n", "gr", '<cmd>lua vim.lsp.buf.references()<CR>', "Go to reference(s)")
	map("n", "gs", '<cmd>lua vim.lsp.buf.type_definition()<CR>', "Type definition")

	map("n", "<leader>r", '<cmd>lua vim.lsp.buf.rename()<CR>', "Rename")
	map("n", "<leader>la", '<cmd>lua vim.lsp.buf.code_action()<CR>', "Code action")
	map("n", "<leader>ll", '<cmd>lua vim.lsp.codelens.run()<CR>', "Run code lens")
	map("n", "<leader>lg", '<cmd>Telescope lsp_document_symbols<CR>', "Go to symbol")

	map("v", "<leader>e", '<cmd>lua vim.lsp.buf.format({async=true})<CR>', "Range Format")
end

return {
	{
		"dundalek/lazy-lsp.nvim",
		-- dev = true,
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		opts = function()
			local lsp_on_attach = function(client, buffer)
				lsp_keymaps(buffer)
				vim.lsp.completion.enable(true, client.id, buffer)
			end
			local lspconfig = require("lspconfig")

			return {
				excluded_servers = {
					-- Disable generic purpose LSP that I don't care about.
					"efm",
					"diagnosticls",
					-- Slow lsps to configure
					"turtle_ls",
					-- enabled on too many ft
					"zk",
					"tailwindcss",
					-- bugged/deprecated
					"ruby_ls",
					"drools_lsp",
					"mutt_ls",
				},
				prefer_local = true,
				preferred_servers = {
					haskell = { "hls" },
					rust = { "rust_analyzer" },
					c = { "clangd" },
					cpp = { "clangd" },
					cs = { "omnisharp" },
					python = { "pyright" },
					nix = { "nil_ls" },
					typescript = { "tsserver" },
					javascript = { "tsserver" },
					jsx = { "tsserver" },
					tsx = { "tsserver" },
					javascriptreact = { "tsserver" },
					typescriptreact = { "tsserver" },
					go = { "gopls" },
					json = { "jsonls" },
					yaml = { "yamlls" },
					markdown = { "marksman", "ltex" },
					tex = { "texlab", "ltex" },
					html = { "html" },
				},

				default_config = {
					on_attach = lsp_on_attach,
				},
				configs = {
					jsonls = {
						on_new_config = function(new_config)
							new_config.settings.json.schemas = new_config.settings.json.schemas or {}
							vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
						end,
						settings = {
							json = {
								format = {
									enable = true,
								},
								validate = { enable = true },
							},
						},
					},
					tsserver = {
						root_dir = lspconfig.util.root_pattern("yarn.lock", "package-lock.json", ".git"),
						single_file_support = false,
						commands = {
							OrganizeImports = {
								function()
									vim.lsp.buf.execute_command({
										command = "_typescript.organizeImports",
										arguments = { vim.api.nvim_buf_get_name(0) },
										title = ""
									})
								end,
								description = "Organize Imports"
							},
						},
					},
					omnisharp = {
						handlers = {
							["textDocument/definition"] = require('omnisharp_extended').definition_handler,
							["textDocument/references"] = require('omnisharp_extended').references_handler,
							["textDocument/implementation"] = require('omnisharp_extended').implementation_handler,
						},
						enable_editorconfig_support = true,
						enable_roslyn_analyzers = true,
						organize_imports_on_format = true,
						enable_import_completion = true,
						cmd_env = {
							["OMNISHARP_RoslynExtensionsOptions:enableDecompilationSupport"] = true,
							["OMNISHARP_msbuild:EnablePackageAutoRestore"] = true,
						},
						on_new_config = function(new_config, new_root_dir)
							-- lazy-lsp magics for nix
							pcall(require("lspconfig").omnisharp.document_config.default_config.on_new_config,
								new_config, new_root_dir)
							local custom_nix_pkgs = { "omnisharp-roslyn" }
							new_config.cmd = require("lazy-lsp").in_shell(custom_nix_pkgs, new_config.cmd)
						end,
					},
					robotframework_ls = {
						cmd = { "nix-shell", "-p", "python3", "--command",
							"cd /tmp && python3 -m venv venv && . venv/bin/activate && pip install robotframework_lsp RESTInstance && robotframework_ls" },
						filetypes = { "robot" },
						settings = {
							robot = {
								codeFormatter = "robotidy",
							},
						}
					},
					gopls = {
						settings = {
							-- https://go.googlesource.com/vscode-go/+/HEAD/docs/settings.md#settings-for
							gopls = {
								analyses = {
									nilness = true,
									unusedparams = true,
									unusedwrite = true,
									useany = true
								},
								experimentalPostfixCompletions = true,
								gofumpt = true,
								staticcheck = true,
								usePlaceholders = true,
								hints = {
									assignVariableTypes = true,
									compositeLiteralFields = true,
									compositeLiteralTypes = true,
									constantValues = true,
									functionTypeParameters = true,
									parameterNames = true,
									rangeVariableTypes = true
								}
							}
						}
					},
					zls = {
						settings = {
							enable_build_on_save = true,
						},
						-- I think this can be disabled with prefer_local but not tested yet.
						-- on_new_config = function(new_config, new_root_dir)
						-- 	-- Simply disable the nix-shell wrapping and use zls from the shell.nix of the projects
						-- 	-- I use nightly builds of zigs/zls
						-- 	pcall(require("lspconfig").zls.document_config.default_config.on_new_config, new_config,
						-- 		new_root_dir)
						-- end,
					},
				},
			}
		end,
		init = function()
			vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "Info" })

			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚",
						[vim.diagnostic.severity.WARN] = "",
						[vim.diagnostic.severity.HINT] = "󰌶",
						[vim.diagnostic.severity.INFO] = "",
					},
				},
				virtual_text = false,
				update_in_insert = true,
				float = {
					border = "rounded",
					source = true,
				},
			})
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
			})
			vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = 'rounded',
			})
		end,
	},

	{
		"b0o/SchemaStore.nvim",
		lazy = true,
		version = false
	},

	{
		"Hoffs/omnisharp-extended-lsp.nvim",
		lazy = true,
	},

	{
		"folke/lazydev.nvim",
		ft = "lua",
		dependencies = {
			{ "Bilal2453/luvit-meta", lazy = true }
		},
		opts = {
			library = {
				"luvit-meta/library",
			},
		},
	},

	{
		"barreiroleo/ltex_extra.nvim",
		branch = "dev",
		ft = { "markdown", "tex" },
		opts = {
			-- See https://valentjn.github.io/ltex/supported-languages.html#natural-languages
			load_langs = { 'en-US' },
		},
	},

	{
		"stevearc/conform.nvim",
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>e",
				function()
					require("conform").format()
				end,
				desc = "Format",
				mode = { "n", "v" },
			},
		},
		opts = {
			default_format_opts = { async = true, lsp_format = "fallback" },
			formatters_by_ft = {
				python = function(bufnr)
					if require("conform").get_formatter_info("ruff_format", bufnr).available then
						return { "ruff_format" }
					else
						return { "isort", "black" }
					end
				end,
				javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
				typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
				json = { "biome", "prettierd", "prettier", stop_after_first = true },
				css = { "biome", "prettierd", "prettier", stop_after_first = true },
				html = { "biome", "prettierd", "prettier", stop_after_first = true },
				sql = { "pg_format" },
				cs = { "csharpier" },
				nix = { "alejandra" },
				-- ["_"] = { "injected", lsp_format = "last" },
				["*"] = { "injected" }
			},
			formatters = {
				biome = {
					-- disable node module search since native binaries can't be run from nix
					command = "biome",
				},
				csharpier = function()
					return {
						cwd = require("conform.util").root_file(function(name)
							return name:match('.*%.sln$') or name:match('.*%.csproj$')
						end),
						require_cwd = true,
					}
				end,
			},
		},
		init = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end
	},

	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		config = function(_, opts)
			local override_severity = function(linter)
				local old_parser = linter.parser;
				linter.parser = function(output)
					local diags = old_parser(output);
					for _, d in pairs(diags) do
						d.severity = vim.diagnostic.severity.HINT
					end
					return diags
				end
			end
			override_severity(require("lint").linters.eslint_d)
			override_severity(require("lint").linters.biomejs)

			require("lint").linters_by_ft = opts
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
				callback = function()
					require("lint").try_lint(nil, { ignore_errors = true })
				end,
			})
		end,
		opts = {
			javascript = { "biomejs", "eslint_d" },
			typescript = { "biomejs", "eslint_d" },
			javascriptreact = { "biomejs", "eslint_d" },
			typescriptreact = { "biomejs", "eslint_d" },
		},
	},

	{
		"yioneko/nvim-type-fmt",
		event = { "InsertEnter" },
	},

	{
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {
			providers = {
				"lsp",
				"treesitter",
			},
			under_cursor = false,
			min_count_to_highlight = 2,
			delay = 200,
			large_file_cutoff = 2000,
			large_file_overrides = {
				providers = { "lsp" },
			},
		},
		config = function(_, opts) require("illuminate").configure(opts) end,
	},
}
