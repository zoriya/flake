local function set_cs_catppuccin()
	local f = io.open(os.getenv("HOME") .. "/.local/state/theme")
	if f == nil then
		vim.cmd([[colorscheme catppuccin-mocha]])
		return
	end

	local theme = f:read("*l")
	if theme == "dark" then
		vim.cmd([[colorscheme catppuccin-mocha]])
	else
		vim.cmd([[colorscheme catppuccin-latte]])
	end
end

local function color_scheme_watch()
	local handle = vim.loop.new_fs_event()
	if not handle then
		vim.print("Error, handle could not be created. Colorscheme watch failed")
		return
	end
	vim.loop.fs_event_start(handle, os.getenv("HOME") .. "/.local/state/theme", { watch_entry = false, stat = true, }, function (err)
		if err then
			vim.print("Error could not watch colorscheme: " .. err)
			return
		end
		vim.schedule(set_cs_catppuccin)
	end)
end

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			integrations = {
				which_key = true,
				lsp_trouble = true,
				telescope = true,
				treesitter = true,
				neotree = true,
				noice = true,
				mini = true,
				leap = true,
				cmp = true,
				native_lsp = {
					enabled = true
				},
				navic = true,
				harpoon = true,
				gitsigns = true,
				semantic_tokens = true,
				indent_blankline = {
					enabled = true,
				},
			},
			custom_highlights = function(colors)
				return {
					TelescopeMatching = { fg = colors.flamingo },
					TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },
					TelescopePromptPrefix = { bg = colors.surface0 },
					TelescopePromptNormal = { bg = colors.surface0 },
					TelescopeResultsNormal = { bg = colors.mantle },
					TelescopePreviewNormal = { bg = colors.mantle },
					TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
					TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
					TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
					TelescopePromptTitle = { bg = colors.pink, fg = colors.mantle },
					TelescopeResultsTitle = { fg = colors.mantle },
					TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
				}
			end,
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			set_cs_catppuccin()
			color_scheme_watch()
		end
	},
}
