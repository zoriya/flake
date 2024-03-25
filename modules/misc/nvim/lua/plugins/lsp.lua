local lsp_keymaps = function(buffer)
	local function map(mode, l, r, desc)
		vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
	end

	map("n", "K", '<cmd>lua vim.lsp.buf.hover()<CR>', "See informations")
	map("n", "<C-k>", '<cmd>lua vim.lsp.buf.signature_help()<CR>', "See signature help")

	map("n", "gD", '<cmd>lua vim.lsp.buf.declaration()<CR>', "Go to declaration")
	map("n", "gd", '<cmd>lua vim.lsp.buf.definition()<CR>', "Go to definition")
	map("n", "gI", '<cmd>lua vim.lsp.buf.implementation()<CR>', "Go to implementation")
	map("n", "gr", '<cmd>lua vim.lsp.buf.references()<CR>', "Go to reference(s)")
	map("n", "gs", '<cmd>lua vim.lsp.buf.type_definition()<CR>', "Type definition")

	map("n", "<leader>lr", '<cmd>lua vim.lsp.buf.rename()<CR>', "Rename")
	map("n", "<leader>la", '<cmd>lua vim.lsp.buf.code_action()<CR>', "Code action")
	map("n", "<leader>ll", '<cmd>lua vim.lsp.codelens.run()<CR>', "Run code lens")
	map("n", "<leader>lg", '<cmd>Telescope lsp_document_symbols<CR>', "Go to symbol")

	map("v", "<leader>lf", '<cmd>lua vim.lsp.buf.format({async=true})<CR>', "Range Format")
end

return {
	{
		"dundalek/lazy-lsp.nvim",
		-- dev = true,
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"neovim/nvim-lspconfig",
				dependencies = {
					{ "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
				},
			},
			"cmp-nvim-lsp",
		},
		opts = function()
			local lsp_on_attach = function(client, buffer)
				lsp_keymaps(buffer)
			end
			local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

			local lspconfig = require("lspconfig")

			return {
				experimental_lazy_setup = true,
				excluded_servers = {
					-- Disable generic purpose LSP that I don't care about.
					"efm",
					"diagnosticls",
					-- Slow lsps to configure
					"turtle_ls",
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
				},

				default_config = {
					on_attach = lsp_on_attach,
					capabilities = lsp_capabilities,
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
						settings = {
							robot = {
								codeFormatter = "robotidy",
							},
						}
					},
					nil_ls = {
						settings = {
							["nil"] = {
								formatting = {
									command = { "nix-shell", "-p", "alejandra", "--run", "alejandra -" },
								},
							},
						},
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
			local signs = {
				{ name = "DiagnosticSignError", text = "󰅚" },
				{ name = "DiagnosticSignWarn", text = "" },
				{ name = "DiagnosticSignHint", text = "󰌶" },
				{ name = "DiagnosticSignInfo", text = "" },
			}
			for _, sign in ipairs(signs) do
				vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
			end

			local function map(l, r, desc)
				vim.keymap.set("n", l, r, { desc = desc })
			end
			map("[d", '<cmd>lua vim.diagnostic.goto_prev()<CR>', "Prev diagnostic")
			map("]d", '<cmd>lua vim.diagnostic.goto_next()<CR>', "Next diagnostic")
			map("gl", "<cmd>lua vim.diagnostic.open_float()<CR>", "See diagnostics")
			map("<leader>li", "<cmd>LspInfo<cr>", "Info")

			vim.diagnostic.config({
				virtual_text = false,
				update_in_insert = true,
				float = {
					border = "rounded",
					source = "always",
				},
			})
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
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
		"zbirenbaum/neodim",
		event = "LspAttach",
		opts = {
			alpha = 0.75,
			blend_color = "#000000",
			update_in_insert = {
				enable = true,
				delay = 100,
			},
			hide = {
				virtual_text = true,
				signs = false,
				underline = true,
			}
		}
	},

	{
		"ray-x/lsp_signature.nvim",
		opts = {
			doc_lines = 100,
			fix_pos = true,
			always_trigger = true,
			select_signature_key = "<C-J>",
			toggle_key = "<C-k>",
			toggle_key_flip_floatwin_setting = true,
			floating_window = false,
		}
	},

	{
		"stevearc/conform.nvim",
		keys = {
			{
				"<leader>lf",
				function()
					require("conform").format({ async = true, lsp_fallback = true --[["always"--]] })
				end,
				desc = "Format",
				mode = { "n", "v" },
			},
		},
		opts = {
			formatters_by_ft = {
				python = function(bufnr)
					if require("conform").get_formatter_info("ruff_format", bufnr).available then
						return { "ruff_format" }
					else
						return { "isort", "black" }
					end
				end,
				javascript = { { "prettierd", "prettier" } },
				typescript = { { "prettierd", "prettier" } },
				javascriptreact = { { "prettierd", "prettier" } },
				typescriptreact = { { "prettierd", "prettier" } },
				css = { { "prettierd", "prettier" } },
				html = { { "prettierd", "prettier" } },
				sql = { "pg_format" },
				cs = { "csharpier" },
				["*"] = { "injected" }
			},
			formatters = {
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
		event = { "BufReadPre", "BufNewFile" },
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

			require("lint").linters_by_ft = opts
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
		opts = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
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
