return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{ "-", "<cmd>Neotree current dir=%:h reveal_force_cwd toggle<CR>", desc = "Toggle explorer", },
			{ "\\", "<cmd>Neotree current dir=%:h reveal_force_cwd toggle<CR>", desc = "Toggle explorer", },
			{ "<leader>e", "<cmd>Neotree left toggle<CR>", desc = "Toggle left explorer", },
		},
		deactivate = function()
			vim.cmd([[Neotree close]])
		end,
		init = function()
			vim.g.neo_tree_remove_legacy_commands = 1
			if vim.fn.argc() == 1 then
				local stat = vim.loop.fs_stat(vim.fn.argv(0))
				if stat and stat.type == "directory" then
					require("neo-tree")
				end
			end
		end,
		opts = {
			close_if_last_window = true,
			sort_case_insensitive = true,
			default_component_configs = {
				git_status = {
					symbols = {
						-- Change type
						added     = "✚",
						deleted   = "",
						modified  = "",
						renamed   = "",
						-- Status type
						untracked = "",
						ignored   = "◌",
						unstaged  = "",
						staged    = "✓",
						conflict  = "",
					},
					align = "left",
				},
			},
			window = {
				mappings = {
					["<space>"] = "none",
					["h"] = function(state)
						local node = state.tree:get_node()
						if node.type == 'directory' and node:is_expanded() then
							require'neo-tree.sources.filesystem'.toggle_directory(state, node)
						else
							require'neo-tree.ui.renderer'.focus_node(state, node:get_parent_id())
						end
					end,
					["l"] = function(state)
						local node = state.tree:get_node()
						if node.type == 'directory' then
							if not node:is_expanded() then
								require'neo-tree.sources.filesystem'.toggle_directory(state, node)
							elseif node:has_children() then
								require'neo-tree.ui.renderer'.focus_node(state, node:get_child_ids()[1])
							end
						end
					end,
				},
			},
			filesystem = {
				bind_to_cwd = false,
				follow_current_file = true,
				hijack_netrw_behavior = "open_current",
				filtered_items = {
					hide_dotfiles = false,
				},
			},
		},
	},
}
