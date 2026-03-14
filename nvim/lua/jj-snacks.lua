local function jj_cwd(opts, ctx)
	local cwd
	cwd = opts and opts.cwd or vim.uv.cwd() or '.'
	cwd = svim.fs.normalize(cwd)
	cwd = vim.fs.root(cwd or 0, '.jj')
	if not cwd then
		Snacks.notify.error 'Cannot find `.jj` folder. To initialize a repository use `jj git init .`'
		ctx.picker.closed = true
		return nil
	end
	return cwd
end

Snacks.picker.jj_log = function(file)
	local title = "jj log"
	if file then
		title = "jj log file"
	end
	Snacks.picker.pick({
		title = title,
		supports_live = false,
		finder = function(opts, ctx)
			local cwd = jj_cwd(opts, ctx)
			local template = [[
			separate("\0",
				self.change_id().shortest(),
				self.change_id().shortest(8),
				commit_timestamp(self).format("%Y-%m-%d %H:%M"),
				commit_id.shortest(),
				commit_id.shortest(8),
				empty,
				if(description,
					description.first_line(),
					if(root, "root()", description_placeholder)
				),
				self.author().name(),
				current_working_copy,
				immutable
			) ++ "\n"
		  ]]
			local args = {
				'log',
				'-r',
				'::@',
				'--color=never',
				'--no-graph',
				'--template=' .. template,
			}
			if opts.reversed then
				table.insert(args, '--reversed')
			end
			if file then
				table.insert(args, string.format('file:"%s"', file))
			end
			vim.list_extend(args, opts.args or {})
			return require('snacks.picker.source.proc').proc(
				ctx:opts({
					cmd = "jj",
					args = args,
					cwd = cwd,
					---@param item snacks.picker.finder.Item
					transform = function(item)
						local data = vim.split(item.text, '\0')
						item.cwd = cwd
						item.change_id_prefix = data[1]
						item.change_id = data[2]
						item.date = data[3]
						item.commit_prefix = data[4]
						item.commit = data[5]
						item.empty = data[6] == "true"
						item.msg = data[7]
						item.author = data[8]
						item.working_copy = data[9] == "true"
						item.immutable = data[10] == "true"
					end,
				}),
				ctx
			)
		end,
		format = function(item, picker)
			local ret = {} ---@type snacks.picker.Highlight[]
			if item.working_copy then
				table.insert(ret, { "@", "SnacksPickerGitCommit" })
			elseif item.immutable then
				table.insert(ret, { "◆", "SnacksPickerGitCommit" })
			else
				table.insert(ret, { "○", "SnacksPickerGitCommit" })
			end
			table.insert(ret, { ' ' })
			table.insert(ret, { item.change_id_prefix, 'SnacksPickerGitCommit' })
			table.insert(ret, { item.change_id:sub(#item.change_id_prefix + 1), 'SnacksPickerDimmed' })
			table.insert(ret, { ' ' })
			table.insert(ret, { item.date, 'SnacksPickerGitDate' })
			table.insert(ret, { ' ' })
			table.insert(ret, { picker.opts.icons.git.commit, "SnacksPickerGitStatusModified" })
			table.insert(ret, { item.commit_prefix, 'SnacksPickerGitStatusModified' })
			table.insert(ret, { item.commit:sub(#item.commit_prefix + 1), 'SnacksPickerDimmed' })
			table.insert(ret, { ' ' })
			if item.empty then
				table.insert(ret, { '(empty) ', 'SnacksPickerDimmed' })
			end
			if item.msg == '(no description set)' then
				table.insert(ret, { item.msg, 'SnacksPickerDimmed' })
			else
				Snacks.picker.highlight.extend(ret, Snacks.picker.format.commit_message(item, picker))
			end
			table.insert(ret, { ' ' })
			table.insert(ret, { item.author, "SnacksPickerGitAuthor" })
			return ret
		end,
		preview = function(ctx)
			if file then
				Snacks.picker.preview.cmd(
					{ "jj", "diff", "--git", "--no-pager", "-r", ctx.item.change_id, string.format("file:'%s'", file) },
					ctx,
					{ ft = "diff" }
				)
				return
			end
			-- local cmd = { 'jj', 'log', '-r=' .. ctx.item.change_id, "--git" }
			local cmd = { "git", "show", ctx.item.commit }
			Snacks.picker.preview.cmd(cmd, ctx, { ft = "git" })
		end,
		confirm = function(picker, item)
			picker:close()
			Snacks.picker.jj_show(item.change_id)
		end,
		sort = { fields = { 'score:desc', 'idx' } },
		win = {
			input = {
				keys = {
					["<a-e>"] = { "jj_edit", mode = { "i" } },
					["<a-s>"] = { "jj_squash", mode = { "i" } },
					["<a-i>"] = { "jj_squash_interactive", mode = { "i" } },
				},
			},
		},
		actions = {
			jj_edit = function(picker, item)
				picker:close()
				vim.cmd(string.format("J edit %s", item.change_id))
			end,
			jj_squash = function(picker, item)
				picker:close()
				vim.cmd(string.format("J squash -r %s", item.change_id))
			end,
			jj_squash_interactive = function(picker, item)
				picker:close()
				vim.cmd(string.format("J squash -i -r %s", item.change_id))
			end,
		},
	})
end

Snacks.picker.jj_log_file = function()
	Snacks.picker.jj_log(vim.fn.expand("%:p"))
end

Snacks.picker.jj_show = function(ref)
	local title = "jj status"
	if ref ~= nil and ref ~= "@" then
		title = "jj show " .. ref
	end
	Snacks.picker.pick({
		title = title,
		supports_live = false,
		finder = function(opts, ctx)
			local cwd = jj_cwd(opts, ctx)
			local args = { "diff", "--summary" }
			if ref then
				table.insert(args, { "-r", ref })
			end
			return require("snacks.picker.source.proc").proc(
				ctx:opts({
					sep = "\n",
					cwd = cwd,
					cmd = "jj",
					args = args,
					---@param item snacks.picker.finder.Item
					transform = function(item)
						local status, file = item.text:match("^(.) (.+)$")
						item.cwd = cwd
						item.status = status
						item.file = file
						local base, prev, next, suffix = file:match("^(.*){(.+) => (.+)}(.*)$")
						if base ~= nil then
							item.rename = base .. prev .. suffix
							item.file = base .. next .. suffix
						end
					end,
				}),
				ctx
			)
		end,
		format = function(item, picker)
			local ret = {} ---@type snacks.picker.Highlight[]

			local hls = {
				["A"] = "SnacksPickerGitStatusAdded",
				["M"] = "SnacksPickerGitStatusModified",
				["D"] = "SnacksPickerGitStatusDeleted",
				["R"] = "SnacksPickerGitStatusRenamed",
				["C"] = "SnacksPickerGitStatusCopied",
				["?"] = "SnacksPickerGitStatusUntracked",
			}
			local hl = hls[item.status] or "SnacksPickerGitStatus"
			table.insert(ret, { item.status, hl })
			table.insert(ret, { " " })
			if item.rename then
				local file = item.file
				item.file = item.rename
				item._path = nil
				vim.list_extend(ret, Snacks.picker.format.filename(item, picker))
				item.file = file
				item._path = nil
				ret[#ret + 1] = { "-> ", "SnacksPickerDelim" }
				ret[#ret + 1] = { " " }
			end
			vim.list_extend(ret, Snacks.picker.format.filename(item, picker))
			return ret
		end,
		preview = function(ctx)
			if ctx.item.status == "A" or ctx.item.status == "?" then
				Snacks.picker.preview.file(ctx)
			else
				Snacks.picker.preview.cmd(
					{ "jj", "diff", "--git", "--no-pager", string.format("file:'%s'", ctx.item.file) },
					ctx,
					{ ft = "diff" }
				)
			end
		end,
		sort = { fields = { 'score:desc', 'idx' } },
		win = {
			input = {
				keys = {
					["<a-s>"] = { "jj_split", mode = { "i" } },
				},
			},
		},
		actions = {
			jj_split = function(picker)
				local items = vim.iter(picker:selected())
					:map(function(i) return i.file end)
					:totable()
				picker:close()
				vim.cmd(string.format(
					'J split "\'%s\'"',
					table.concat(items, "' | '")
				))
			end
		},
	})
end
