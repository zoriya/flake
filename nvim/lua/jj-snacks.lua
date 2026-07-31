local function jj_cwd(from, opts, ctx)
	local cwd
	cwd = (opts and opts.cwd) or from or vim.uv.cwd() or '.'
	cwd = vim.fs.normalize(cwd)
	cwd = vim.fs.root(cwd, '.jj')
	if not cwd then
		Snacks.notify.error 'Cannot find `.jj` folder. To initialize a repository use `jj git init .`'
		ctx.picker.closed = true
		return nil
	end
	return cwd
end

local STATUS_HL = {
	["A"] = "SnacksPickerGitStatusAdded",
	["M"] = "SnacksPickerGitStatusModified",
	["D"] = "SnacksPickerGitStatusDeleted",
	["R"] = "SnacksPickerGitStatusRenamed",
	["C"] = "SnacksPickerGitStatusCopied",
	["?"] = "SnacksPickerGitStatusUntracked",
}

local function status_hl(status)
	return STATUS_HL[status] or "SnacksPickerGitStatus"
end

Snacks.picker.jj_log = function(file)
	local title = "jj log"
	if file then
		title = "jj log file"
	end
	-- Capture the open file before the picker takes over the current buffer, so
	-- we search for the `.jj` root closest to it rather than from nvim's pwd.
	local from = file or vim.api.nvim_buf_get_name(0)
	if from == "" then
		from = nil
	end
	Snacks.picker.pick({
		title = title,
		supports_live = false,
		finder = function(opts, ctx)
			local cwd = jj_cwd(from, opts, ctx)
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
			local cmd = { "jj", "show", "--git", "--no-pager", "-r", ctx.item.change_id }
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
					["<c-s>"] = { "jj_gsplit", mode = { "i" } },
					["<c-v>"] = { "jj_gvsplit", mode = { "i" } },
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
			jj_gsplit = function(picker, item)
				picker:close()
				vim.cmd({ cmd = "Jsplit", args = { item.change_id .. ":" .. file } })
			end,
			jj_gvsplit = function(picker, item)
				picker:close()
				vim.cmd({ cmd = "Jvsplit", args = { item.change_id .. ":" .. file } })
			end,
		},
	})
end

Snacks.picker.jj_log_file = function()
	Snacks.picker.jj_log(vim.fn.expand("%:p"))
end

-- Stage-area style picker: show the combined diff of `@` and `@-`, with a two
-- character status column (`@` first, `@-` second) à la git's staged/unstaged
-- columns, and let <tab> move a file's change between `@` and `@-`.
Snacks.picker.jj_stage = function()
	local from = vim.api.nvim_buf_get_name(0)
	if from == "" then
		from = nil
	end

	local title = "jj stage @ / @-"
	local root = vim.fs.root(vim.fs.normalize(from or vim.uv.cwd() or "."), ".jj")
	if root then
		local function desc(rev)
			local out = vim.system({
				"jj", "log", "--no-graph", "--color=never", "-r", rev, "-T",
				"if(description, description.first_line(), description_placeholder)",
			}, { cwd = root, text = true }):wait()
			return vim.trim(out.stdout or "")
		end
		title = string.format("@ %s   │   @- %s", desc("@"), desc("@-"))
	end

	Snacks.picker.pick({
		title = title,
		supports_live = false,
		finder = function(opts, ctx)
			local cwd = jj_cwd(from, opts, ctx)
			if not cwd then
				return {}
			end

			-- Parse `jj diff --summary` for a revision into { [file] = entry }.
			local function summary(rev)
				local out = vim.system(
					{ "jj", "diff", "--summary", "--color=never", "-r", rev },
					{ cwd = cwd, text = true }
				):wait()
				local files = {}
				for line in vim.gsplit(out.stdout or "", "\n", { trimempty = true }) do
					local status, file = line:match("^(.) (.+)$")
					if status then
						local entry = { status = status, file = file }
						local base, prev, next, suffix = file:match("^(.*){(.*) => (.*)}(.*)$")
						if base ~= nil then
							entry.rename = base .. prev .. suffix
							entry.file = base .. next .. suffix
						end
						files[entry.file] = entry
					end
				end
				return files
			end

			local at = summary("@")
			local parent = summary("@-")

			local order, seen = {}, {}
			for _, map in ipairs({ at, parent }) do
				for k in pairs(map) do
					if not seen[k] then
						seen[k] = true
						order[#order + 1] = k
					end
				end
			end
			table.sort(order)

			local items = {}
			for _, k in ipairs(order) do
				local a, p = at[k], parent[k]
				local at_status = a and a.status or " "
				local parent_status = p and p.status or " "
				items[#items + 1] = {
					text = k,
					cwd = cwd,
					file = k,
					rename = (a and a.rename) or (p and p.rename),
					-- Two status columns, `@` first then `@-`: `MM`, `M `, ` M`, ...
					at_status = at_status,
					parent_status = parent_status,
					in_at = a ~= nil,
				}
			end
			return items
		end,
		format = function(item, picker)
			local ret = {} ---@type snacks.picker.Highlight[]

			table.insert(ret, { item.at_status, status_hl(item.at_status) })
			table.insert(ret, { item.parent_status, status_hl(item.parent_status) })
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
			local cmd = { "jj", "diff", "--git", "--no-pager", "--from", "@--", "--to", "@" }
			table.insert(cmd, string.format("file:'%s'", ctx.item.file))
			Snacks.picker.preview.cmd(cmd, ctx, { ft = "diff" })
		end,
		sort = { fields = { 'score:desc', 'idx' } },
		win = {
			input = {
				keys = {
					["<tab>"] = { "jj_toggle", mode = { "i", "n" } },
					["<c-s>"] = { "jj_gsplit", mode = { "i" } },
					["<c-v>"] = { "jj_gvsplit", mode = { "i" } },
				},
			},
		},
		actions = {
			-- Move a file's change between `@` and `@-`. When it lives in `@`
			-- (`M ` or `MM`) squash it down into `@-`; when it only lives in `@-`
			-- (` M`) move it back up into `@`.
			jj_toggle = function(picker)
				local items = picker:selected({ fallback = true })
				local done = 0
				for _, item in ipairs(items) do
					local paths = { string.format("file:'%s'", item.file) }
					if item.rename then
						table.insert(paths, string.format("file:'%s'", item.rename))
					end
					local cmd
					if item.in_at then
						cmd = { "jj", "squash", "--into", "@-" }
					else
						cmd = { "jj", "squash", "--from", "@-", "--into", "@" }
					end
					vim.list_extend(cmd, paths)
					Snacks.picker.util.cmd(cmd, function()
						done = done + 1
						if done == #items then
							picker:refresh()
						end
					end, { cwd = item.cwd })
				end
			end,
			jj_gsplit = function(picker, item)
				picker:close()
				vim.cmd({ cmd = "Jsplit", args = { "@:" .. item.file } })
			end,
			jj_gvsplit = function(picker, item)
				picker:close()
				vim.cmd({ cmd = "Jvsplit", args = { "@:" .. item.file } })
			end,
		},
	})
end

Snacks.picker.jj_show = function(spec)
	if type(spec) == "string" then
		spec = { ref = spec }
	end
	spec = spec or {}
	local ref = spec.ref
	local range = spec.from ~= nil or spec.to ~= nil
	if not range and ref == nil then
		ref = "@"
	end
	-- Selector args shared by the finder, preview and `jj show` lookups.
	local function selector()
		if range then
			local sel = {}
			if spec.from then
				vim.list_extend(sel, { "--from", spec.from })
			end
			if spec.to then
				vim.list_extend(sel, { "--to", spec.to })
			end
			return sel
		end
		return { "-r", ref }
	end

	local show_ref = ref or spec.to or "@"

	local title = "jj status"
	if range then
		title = "jj diff " .. (spec.from or "@") .. ".." .. (spec.to or "@")
	elseif ref ~= "@" then
		title = "jj diff " .. ref
	end
	-- Capture the open file before the picker takes over the current buffer, so
	-- we search for the `.jj` root closest to it rather than from nvim's pwd.
	local from = vim.api.nvim_buf_get_name(0)
	if from == "" then
		from = nil
	end
	Snacks.picker.pick({
		title = title,
		supports_live = false,
		finder = function(opts, ctx)
			local cwd = jj_cwd(from, opts, ctx)
			local args = { "diff", "--summary" }
			vim.list_extend(args, selector())
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
						local base, prev, next, suffix = file:match("^(.*){(.*) => (.*)}(.*)$")
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

			table.insert(ret, { item.status, status_hl(item.status) })
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
			if ref == "@" and (ctx.item.status == "A" or ctx.item.status == "?") then
				Snacks.picker.preview.file(ctx)
			else
				local cmd = { "jj", "diff", "--git", "--no-pager" }
				vim.list_extend(cmd, selector())
				table.insert(cmd, string.format("file:'%s'", ctx.item.file))
				Snacks.picker.preview.cmd(cmd, ctx, { ft = "diff" })
			end
		end,
		sort = { fields = { 'score:desc', 'idx' } },
		win = {
			input = {
				keys = {
					["<a-s>"] = { "jj_split", mode = { "i" } },
					["<c-s-s>"] = { "jj_squash", mode = { "i" } },
					["<c-s>"] = { "jj_gsplit", mode = { "i" } },
					["<c-v>"] = { "jj_gvsplit", mode = { "i" } },
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
			end,
			jj_squash = function(picker)
				local items = picker:selected({ fallback = true })
				if #items == 0 then
					return
				end
				local cmd = { "jj", "squash", "-r", show_ref }
				for _, item in ipairs(items) do
					table.insert(cmd, string.format("file:'%s'", item.file))
					if item.rename then
						table.insert(cmd, string.format("file:'%s'", item.rename))
					end
				end
				Snacks.picker.util.cmd(cmd, function()
					picker:refresh()
				end, { cwd = items[1].cwd })
			end,
			jj_gsplit = function(picker, item)
				picker:close()
				vim.cmd({ cmd = "Jsplit", args = { show_ref .. ":" .. item.file } })
			end,
			jj_gvsplit = function(picker, item)
				picker:close()
				vim.cmd({ cmd = "Jvsplit", args = { show_ref .. ":" .. item.file } })
			end,
		},
	})
end
