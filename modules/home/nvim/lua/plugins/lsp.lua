local nullls = {
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
}


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
	map("n", "<leader>lf", '<cmd>lua vim.lsp.buf.format({async=true})<CR>', "Format")

	map("v", "<leader>lf", '<cmd>lua vim.lsp.buf.format({async=true})<CR>', "Range Format")
end


local kind_icons = {
	Text = "",
	Method = "",
	Function = "",
	Constructor = "",
	Field = "ﰠ",
	Variable = "",
	Class = "",
	Interface = "",
	Module = "",
	Property = "",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "פּ",
	Event = "",
	Operator = "",
	TypeParameter = "",
}


return {
	{
		"dundalek/lazy-lsp.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"neovim/nvim-lspconfig",
				dependencies = {
					{ "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
				},
			},
		},
		opts = {
			excluded_servers = {
				-- Disable generic purpose LSP that I don't care about.
				"efm",
				"diagnosticls"
			},
			default_config = {
				on_attach = function(client, buffer)
					lsp_keymaps(buffer)

					local ok, navic = pcall(require, "nvim-navic")
					if ok then
						navic.attach(client, buffer)
					end
				end,
			},
		},
		init = function()
			local signs = {
				{ name = "DiagnosticSignError", text = "" },
				{ name = "DiagnosticSignWarn",  text = "" },
				{ name = "DiagnosticSignHint",  text = "" },
				{ name = "DiagnosticSignInfo",  text = "" },
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
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
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
					ghost_text = {
						hl_group = true,
					},
				},
			}
		end,
	},
}
