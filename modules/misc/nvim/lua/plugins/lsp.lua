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

local function lsp_highlight_document(client)
	if client.server_capabilities.documentHighlightProvider then
		vim.cmd [[
		augroup lsp_document_highlight
		autocmd! * <buffer>
		autocmd! CursorHold <buffer> lua vim.lsp.buf.document_highlight()
		autocmd! CursorMoved <buffer> lua vim.lsp.buf.clear_references()
		augroup END
		]]
	end
end


local kind_icons = {
	Text = "󰉿",
	Method = "󰆧",
	Function = "󰊕",
	Constructor = "",
	Field = "󰜢",
	Variable = "󰀫",
	Class = "󰠱",
	Interface = "",
	Module = "",
	Property = "󰜢",
	Unit = "󰑭",
	Value = "󰎠",
	Enum = "",
	Keyword = "󰌋",
	Snippet = "",
	Color = "󰏘",
	File = "󰈙",
	Reference = "󰈇",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰏿",
	Struct = "󰙅",
	Event = "",
	Operator = "󰆕",
	TypeParameter = "",
}


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
			"b0o/SchemaStore.nvim",
			"Hoffs/omnisharp-extended-lsp.nvim",
			"cmp-nvim-lsp",
		},
		opts = function()
			local lsp_on_attach = function(client, buffer)
				lsp_keymaps(buffer)
				lsp_highlight_document(client)

				local ok, navic = pcall(require, "nvim-navic")
				if ok then
					navic.attach(client, buffer)
				end
			end
			local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

			local lspconfig = require("lspconfig")

			return {
				excluded_servers = {
					-- Disable generic purpose LSP that I don't care about.
					"efm",
					"diagnosticls",
					-- Bugged servers
					"sqls"
				},
				preferred_servers = {
					haskell = { "hls" },
					rust = { "rust_analyzer" },
					c = { "clangd" },
					cpp = { "clangd" },
					python = { "pyright" },
					nix = { "nil_ls" },
					typescript = { "tsserver" },
					javascript = { "tsserver" },
					jsx = { "tsserver" },
					tsx = { "tsserver" },
					javascriptreact = { "tsserver" },
					typescriptreact = { "tsserver" },
					go = { "gopls" },
				},

				default_config = {
					on_attach = lsp_on_attach,
					capabilities = lsp_capabilities,
				},
				configs = {
					jsonls = {
						settings = {
							json = {
								schemas = require('schemastore').json.schemas(),
								validate = { enable = true },
							},
						},
					},
					tsserver = {
						root_dir = lspconfig.util.root_pattern("yarn.lock", "package-lock.json", ".git"),
						single_file_support = false,
					},
					omnisharp = {
						handlers = {
							["textDocument/definition"] = require('omnisharp_extended').handler,
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
		"L3MON4D3/LuaSnip",
		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
		-- I'm never using snippets and it only bother me so for now I am disabling it.
		-- keys = {
		-- 	{
		-- 		"<tab>",
		-- 		function()
		-- 			return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
		-- 		end,
		-- 		expr = true, silent = true, mode = "i",
		-- 	},
		-- 	{ "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
		-- 	{ "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
		-- },
	},

	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"LuaSnip",
		},
		opts = function()
			local cmp = require("cmp")
			return {
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				}),
				formatting = {
					fields = { "abbr", "kind" },
					format = function(_, vim_item)
						vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
						return vim_item
					end,
				},
				navigation = {
					documentation = {
						border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
					},
				},
				experimental = {
					ghost_text = true,
				},
			}
		end,
		init = function()
			vim.opt.completeopt = { "menuone", "preview", }
			vim.opt.pumheight = 15
		end
	},

	{
		"ray-x/lsp_signature.nvim",
		opts = {
			doc_lines = 100,
			fix_pos = true,
			always_trigger = true,
			toggle_key = "<C-k>",
			floating_window = false,
		}
	},

	{
		"stevearc/conform.nvim",
		keys = {
			{
				"<leader>lf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				desc = "Format",
				mode = { "n", "v" },
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
		opts = {
			formatters_by_ft = {
				python = { "black" },
				javascript = { { "prettierd", "prettier" } },
				typescript = { { "prettierd", "prettier" } },
				javascriptreact = { { "prettierd", "prettier" } },
				typescriptreact = { { "prettierd", "prettier" } },
				css = { { "prettierd", "prettier" } },
				html = { { "prettierd", "prettier" } },
				sql = { "pg_format" },
			},
		}
	},

	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function(_, opts)
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
		"kosayoda/nvim-lightbulb",
		event = { "CursorHold", "CursorHoldI" },
		opts = {
			sign = {
				enable = false,
			},
			float = {
				enable = true,
				text = ""
			},
			autocmd = {
				enabled = true,
			},
		},
	}
}
