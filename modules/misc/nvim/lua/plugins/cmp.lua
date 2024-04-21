return {
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ "petertriho/cmp-git", opts = true },
			"hrsh7th/cmp-path",
			"onsails/lspkind.nvim",
		},
		opts = function()
			local cmp = require("cmp")
			return {
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<C-h>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = "git" },
					{ name = "nvim_lsp" },
					{ name = "path" },
				}),
				navigation = {
					documentation = {
						border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
					},
				},
				window = {
					completion = {
						-- winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
						col_offset = -3,
						side_padding = 0,
					},
				},
				formatting = {
					fields = { "kind", "abbr" },
					format = function(entry, vim_item)
						local kind = require("lspkind").cmp_format({
							mode = "symbol",
							maxwidth = 50,
							symbol_map = { TypeParameter = "", },
						})(entry, vim_item)
						kind.kind = " " .. (kind.kind or "?") .. " "
						return kind
					end,
				},
				experimental = {
					ghost_text = false,
				},
			}
		end,
		init = function()
			vim.opt.completeopt = { "menuone", "preview", }
			vim.opt.pumheight = 15
		end
	},
}
