return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{
				"airtonix/telescope-fzf-native.nvim",
				branch = 'feature/69-prebuilt-release-binaries',
				build = function()
					require('telescope-fzf-native').download_library()
				end
			},
			"nvim-lua/plenary.nvim",
		},
		cmd = "Telescope",
		version = false, -- telescope did only one release, so use HEAD for now
		keys = {
			{ "<leader>f",  "<cmd>Telescope find_files<cr>",          desc = "Find Files" },
			{ "<leader>F",  "<cmd>Telescope live_grep theme=ivy<cr>", desc = "Grep" },
			{ "<leader>gl", "<cmd>Telescope git_commits<CR>",         desc = "Git log" },
			{ "<leader>gh", "<cmd>Telescope git_bcommits<CR>",        desc = "Git history" },
			{ "<leader>gB", "<cmd>Telescope git_branches<CR>",        desc = "Git branches" },
			{ "<leader>gs", "<cmd>Telescope git_status<CR>",          desc = "Git status" },
			{ "<leader>gc", "<cmd>Telescope git_show<CR>",            desc = "Show last commit" },
		},
		opts = function()
			local actions = require "telescope.actions"
			local action_state = require "telescope.actions.state"

			local function git_show()
				local entry = action_state.get_selected_entry()
				vim.cmd("Telescope git_show ref=" .. entry.value)
			end

			return {
				defaults = {
					prompt_prefix = " ",
					selection_caret = " ",
					sorting_strategy = "ascending",
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							prompt_position = "top",
						}
					},
					path_display = { "truncate" },
					mappings = {
						i = {
							["<esc>"]  = actions.close,
							["<C-h>"]  = function() vim.api.nvim_input("<C-w>") end,
							["<C-BS>"] = function() vim.api.nvim_input("<C-w>") end,
							["<A-k>"]  = actions.move_selection_previous,
							["<A-j>"]  = actions.move_selection_next,
							["<c-t>"]  = function()
								local has_trouble, trouble_action = pcall(require, "trouble.providers.telescope")
								if has_trouble then
									trouble_action.open_with_trouble()
								end
							end
						},
					},
				},
				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
					}
				},
				pickers = {
					find_files = {
						hidden = true,
						find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "-E", ".git" },
					},
					git_commits = {
						mappings = {
							i = {
								["<CR>"] = git_show,
							},
						},
					},
					git_bcommits = {
						mappings = {
							i = {
								["<CR>"] = git_show,
							},
						},
					},
					git_status = {
						mappings = {
							i = {
								-- ["<c-c>"] = local_actions.commit,
							},
						},
					},
				},
			}
		end,
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			telescope.load_extension("fzf")
			telescope.load_extension("git_show")
		end,
	}
}
