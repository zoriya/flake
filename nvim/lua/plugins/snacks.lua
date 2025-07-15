local function git_show(ref)
	local git_root = Snacks.git.get_root()
	local function finder(opts, ctx)
		return require("snacks.picker.source.proc").proc({
			opts,
			{
				cmd = "git",
				args = { "show", "--name-status", "--pretty=tformat:", ref },
				transform = function(item)
					item.cwd = git_root
					item.file = string.sub(item.text, 3)
					item.commit = ref
				end,
			},
		}, ctx)
	end

	Snacks.picker.pick({
		title = "Git show " .. ref,
		finder = finder,
		preview = "git_show",
		name = "git_show",
		confirm = function(picker, item)
			picker:close()
			vim.cmd("Gedit " .. ref .. ":" .. item.file)
		end,
		actions = {
			edit_split = function(picker, item)
				picker:close()
				vim.cmd("Gsplit " .. ref .. ":" .. item.file)
			end,
			edit_vsplit = function(picker, item)
				picker:close()
				vim.cmd("Gvsplit " .. ref .. ":" .. item.file)
			end,
		}

	})
end

return {
	{
		"snacks-nvim",
		event = "DeferredUIEnter",
		opts = {
			input = {
				enabled = true,
			},
			indent = {
				enabled = true,
				indent = {
					char = "▏",
				},
				animate = {
					enabled = false,
				},
				scope = {
					char = "▏",
				},
				chunk = {
					char = {
						vertical = "▏",
					},
				},
			},
			zen = {
				toggles = {
					dim = false,
				},
				show = {
					statusline = true,
				},
			},
			styles = {
				input = {
					relative = "cursor",
					row = -3,
					col = 0,
					keys = {
						i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true },
					},
				},
				zen = {
					width = 200,
					backdrop = {
						transparent = false,
						blend = 0,
					},
				},
			},
			picker = {
				win = {
					input = {
						keys = {
							["<Esc>"] = { "close", mode = { "n", "i" } },
							["<c-c>"] = { "close", mode = { "n", "i" } },
							["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
							["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
							["<c-a>"] = function() vim.cmd "normal! I" end,
							["<c-e>"] = function() vim.cmd "startinsert!" end,
						},
					},
				},
				sources = {
					files = {
						hidden = true,
					},
					grep = {
						layout = "bottom",
						hidden = true,
					},
					git_branches = {
						all = true,
					},
					git_log = {
						confirm = "git_show",
						win = {
							input = {
								keys = {
									["<c-f>"] = { "git_fixup", mode = { "i", "n" } },
								},
							},
						},
					},
					git_log_file = {
						confirm = "git_show",
						win = {
							input = {
								keys = {
									["<c-f>"] = { "git_fixup", mode = { "i", "n" } },
								},
							},
						},
					},
				},
				actions = {
					git_show = function(picker, item)
						picker:close()
						git_show(item.commit)
					end,
					git_fixup = function(picker, item)
						picker:close()
						vim.cmd("G commit --fixup=" .. item.commit)
					end
				},
				layouts = {
					default = {
						layout = {
							box = 'horizontal',
							backdrop = false,
							width = 0.8,
							height = 0.9,
							border = 'none',
							{
								box = 'vertical',
								{
									win = 'input',
									title = ' {source} {live} ',
									title_pos = 'center',
									border = 'solid',
									height = 1,
								},
								{
									win = 'list',
									border = 'solid',
								},
							},
							{
								win = 'preview',
								width = 0.5,
								title = '  {preview}  ',
								title_pos = 'center',
								border = "top",
							},
						},
					},
					vertical = {
						layout = {
							backdrop = false,
							width = 0.5,
							min_width = 80,
							height = 0.8,
							min_height = 30,
							box = "vertical",
							border = "none",
							{
								win = "input",
								height = 1,
								border = "solid",
								title = " {title} {live} ",
							},
							{ win = "list", border = "solid" },
							{
								win = "preview",
								title = "{preview}",
								height = 0.4,
								border = "top"
							},
						},
					},
					ivy = {
						layout = {
							box = "horizontal",
							backdrop = false,
							width = 0,
							height = 0.5,
							border = "none",
							{
								box = "vertical",
								border = "none",
								{
									win = "input",
									title = " {title} {live} ",
									height = 1,
									border = "solid"
								},
								{ win = "list", border = "solid" },
							},
							{
								win = "preview",
								title = "  {preview}  ",
								border = "top",
								width = vim.o.columns <= 125 and 0.7 or 0.55,
							},
						},
					},
					select = {
						preview = false,
						layout = {
							backdrop = false,
							width = 0.5,
							min_width = 80,
							height = 0.4,
							min_height = 3,
							box = "vertical",
							border = "none",
							{
								win = "input",
								height = 1,
								border = "solid",
								title = " {title} ",
							},
							{ win = "list", border = "solid" },
						},
					}
				},
			},
		},
		after = function(plug)
			require("snacks").setup(plug.opts)

			Snacks.picker.git_show = git_show

			vim.keymap.set("n", "<leader>zz", function() Snacks.zen() end, { desc = "Toggle zen mode" })

			vim.keymap.set("n", "<leader>f", function()
				Snacks.picker.files()
			end, { desc = "Find files" })

			vim.keymap.set("n", "<leader>F", function()
				Snacks.picker.grep()
			end, { desc = "Grep" })

			vim.keymap.set("n", "<leader>gl", function()
				Snacks.picker.git_log()
			end, { desc = "Git log" })

			vim.keymap.set("n", "<leader>gh", function()
				Snacks.picker.git_log_file()
			end, { desc = "Git logs buffer" })

			vim.keymap.set("n", "<leader>gB", function()
				Snacks.picker.git_branches()
			end, { desc = "Git branches" })

			vim.keymap.set("n", "<leader>gs", function()
				Snacks.picker.git_status()
			end, { desc = "Git status" })
		end,
	},
}
