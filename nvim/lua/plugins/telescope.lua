return {
	{
		"telescope.nvim",
		load = vim.cmd.packadd,
		cmd = "Telescope",
		keys = {
			{ "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>F", "<cmd>Telescope ripgrep theme=ivy<cr>", desc = "Grep" },
			{ "<leader>gl", "<cmd>Telescope git_commits<CR>", desc = "Git log" },
			{ "<leader>gh", "<cmd>Telescope git_bcommits<CR>", desc = "Git history" },
			{ "<leader>gB", "<cmd>Telescope git_branches<CR>", desc = "Git branches" },
			{ "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Git status" },
			{ "<leader>zh", "<cmd>Telescope help_tags<CR>", desc = "Read help" },

			-- maybe i should move those elsewhere
			{ "<leader>g.", "<cmd>Git add -A<CR>", desc = "Git add all" },
			{ "<leader>gc", "<cmd>Git commit<CR>", desc = "Git commit" },
			{ "<leader>gC", "<cmd>Git commit --amend<CR>", desc = "Git commit amend" },
			{ "<leader>gp", "<cmd>Git! push<CR>", desc = "Git push" },
			{ "<leader>gP", "<cmd>Git! push --force-with-lease --force-if-includes<CR>", desc = "Git push force" },
		},
		after = function()
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			local function git_show()
				local entry = action_state.get_selected_entry()
				vim.cmd("Telescope git_show ref=" .. entry.value)
			end

			local function git_show_split(bufr)
				actions.close(bufr)
				local entry = action_state.get_selected_entry()
				vim.cmd("Gedit " .. entry.value)
			end


			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					prompt_prefix = " ",
					selection_caret = " ",
					sorting_strategy = "ascending",
					layout_config = {
						horizontal = {
							prompt_position = "top",
						}
					},
					mappings = {
						i = {
							["<esc>"] = actions.close,
							["<C-c>"] = actions.close,
						},
					}
				},
				pickers = {
					find_files = {
						hidden = true,
						-- remove .git directory
						find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "-E", ".git" },
					},
					git_commits = {
						mappings = {
							i = {
								["<CR>"] = git_show,
								["<C-g>"] = git_show_split
							},
						},
					},
					git_bcommits = {
						mappings = {
							i = {
								["<CR>"] = git_show,
								["<C-g>"] = git_show_split
							},
						},
					},
				},
			})

			telescope.load_extension("fzf")
			telescope.load_extension("ripgrep")
			telescope.load_extension("git_show")
		end
	},
}
