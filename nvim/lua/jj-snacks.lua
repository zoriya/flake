Snacks.picker.jj_log = function()
	Snacks.picker.pick({
		title = 'jj log',
		supports_live = false,
		finder = function(opts, ctx)
			local cwd
			cwd = opts and opts.cwd or vim.uv.cwd() or '.'
			cwd = svim.fs.normalize(cwd)
			cwd = vim.fs.root(cwd or 0, '.jj')
			if not cwd then
				Snacks.notify.error 'Cannot find `.jj` folder. To initialize a repository use `jj git init .`'
				ctx.picker.closed = true
				return {}
			end
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
			local M = require 'snacks.picker.preview'
			-- local cmd = { 'jj', 'log', '-r=' .. ctx.item.change_id, "--git" }
			local cmd = { "git", "show", ctx.item.commit }
			M.cmd(cmd, ctx, { ft = "git" })
		end,
		confirm = function(picker, item)
			picker:close()
		end,
		sort = { fields = { 'score:desc', 'idx' } },
	})
end
