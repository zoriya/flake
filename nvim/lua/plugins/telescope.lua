return {
	{
		"telescope.nvim",
		load = vim.cmd.packadd,
		cmd = "Telescope",
		keys = {
			{ "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>F", "<cmd>Telescope ripgrep theme=ivy<cr>", desc = "Grep" },
			-- { "<leader>gl", "<cmd>Telescope git_commits<cr>", desc = "Git log" },
			-- { "<leader>gh", "<cmd>Telescope git_bcommits<cr>", desc = "Git history" },
			-- { "<leader>gB", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
			-- { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
			{
				"<leader>gl",
				function()
					require("telescope.builtin").git_commits({ cwd = vim.fs.root(0, ".git") })
				end,
				desc = "Git log"
			},
			{
				"<leader>gh",
				function()
					require("telescope.builtin").git_bcommits({ cwd = vim.fs.root(0, ".git") })
				end,
				desc = "Git history"
			},
			{
				"<leader>gB",
				function()
					require("telescope.builtin").git_branches({ cwd = vim.fs.root(0, ".git") })
				end,
				desc = "Git branches"
			},
			{
				"<leader>gs",
				function()
					require("telescope.builtin").git_status({ cwd = vim.fs.root(0, ".git") })
				end,
				desc = "Git status"
			},
			{ "<leader>zh", "<cmd>Telescope help_tags<CR>", desc = "Read help" },
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

			local function git_fixup(bufr)
				actions.close(bufr)
				local entry = action_state.get_selected_entry()
				vim.cmd("G commit --fixup=" .. entry.value)
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
							["<C-a>"] = function() vim.cmd "normal! I" end,
							["<C-e>"] = function() vim.cmd "startinsert!" end,
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
						-- use_file_path = true,
						mappings = {
							i = {
								["<CR>"] = git_show,
								["<C-g>"] = git_show_split,
								["<C-f>"] = git_fixup,
							},
						},
					},
					git_bcommits = {
						-- use_file_path = true,
						mappings = {
							i = {
								["<CR>"] = git_show,
								["<C-g>"] = git_show_split,
								["<C-f>"] = git_fixup,
								["<C-v>"] = function(bufr)
									actions.close(bufr)
									local entry = action_state.get_selected_entry()
									vim.cmd("Gvsplit " .. entry.value .. ":" .. entry.current_file)
								end,
								["<C-s>"] = function(bufr)
									actions.close(bufr)
									local entry = action_state.get_selected_entry()
									vim.cmd("Gsplit " .. entry.value .. ":" .. entry.current_file)
								end,
							},
						},
					},
					git_branches = {
						-- use_file_path = true,
						show_remote_tracking_branches = false,
						mappings = {
							i = {
								["<CR>"] = actions.git_switch_branch
							},
						}
					},
					git_status = {
						-- use_file_path = true,
					},
				},
			})

			telescope.load_extension("fzf")
			telescope.load_extension("ripgrep")
			telescope.load_extension("git_show")
			telescope.load_extension("ui-select")
		end
	},
}
