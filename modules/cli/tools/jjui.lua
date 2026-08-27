local function workspace_under_cursor(include_default)
	local rev = context.change_id()
	if not rev then
		flash({ text = "no revision selected", error = true })
		return
	end

	local marks = jj("log", "-r", rev, "--no-graph", "--color=never", "-T", "working_copies") or ""
	local names = {}
	for name in marks:gmatch("([^%s]+)@") do
		if name ~= "root" and (include_default or name ~= "default") then
			names[#names + 1] = name
		end
	end
	if #names == 0 then
		flash({ text = "no workspace on this revision", error = true })
		return
	end

	local target = names[1]
	if #names > 1 then
		target = choose({ options = names, title = "workspace" })
		if not target then
			return
		end
	end

	local dir = (jj("workspace", "root", "--name", target) or ""):gsub("%s+$", "")
	if dir == "" then
		flash({ text = "cannot find the root of workspace " .. target, error = true })
		return
	end
	return target, dir
end

function setup(config)
	config.action("new_workspace", function()
		local rev = context.change_id()
		if not rev then
			flash({ text = "no revision selected", error = true })
			return
		end

		local name = input({ title = "new workspace", prompt = "name" })
		if not name then
			return
		end
		name = name:gsub("%s", "")
		if name == "" then
			flash({ text = "a workspace needs a name", error = true })
			return
		end

		local root = jj("workspace", "root", "--name", "root")
		if root == "" then
			flash({ text = "Run `jj workspace-init before", error = true })
			return
		end
		local dir = root .. "/" .. name
		local _, err = jj("workspace", "add", "-r", rev, dir)
		if err then
			flash({ text = err, error = true })
			return
		end

		flash("created workspace " .. name)
		revisions.refresh({})
	end, { desc = "New workspace", scope = "revisions", seq = { "w", "n" } })

	config.action("edit_workspace", function()
		local target, dir = workspace_under_cursor(true)
		if not target then
			return
		end

		local here = (jj("workspace", "root") or ""):gsub("%s+$", "")
		if dir == here then
			flash("already in " .. target)
			return
		end
		local ok, err = change_workspace(dir)
		if not ok then
			flash({ text = err, error = true })
			return
		end

		jj("util", "exec", "--", "sh", "-c",
			[[printf '\033]7;file://%s\033\\' "$1" 2>/dev/null >/dev/tty || true]], "sh", dir)

		flash("now in " .. target)
		revisions.refresh({})
	end, { desc = "Work in workspace", scope = "revisions", seq = { "w", "e" } })

	config.action("abandon_workspace", function()
		local target, dir = workspace_under_cursor(false)
		if not target then
			return
		end

		local here = (jj("workspace", "root") or ""):gsub("%s+$", "")
		if dir == here then
			local def = (jj("workspace", "root", "--name", "default") or ""):gsub("%s+$", "")
			if def == "" then
				flash({ text = "no default workspace to fall back to", error = true })
				return
			end
			local ok, err = change_workspace(def)
			if not ok then
				flash({ text = err, error = true })
				return
			end
			jj("util", "exec", "--", "sh", "-c",
				[[printf '\033]7;file://%s\033\\' "$1" 2>/dev/null >/dev/tty || true]], "sh", def)
		end

		local _, snap_err = jj("-R", dir, "util", "snapshot")
		if snap_err then
			flash({ text = snap_err, error = true })
			return
		end

		local _, forget_err = jj("workspace", "forget", target)
		if forget_err then
			flash({ text = forget_err, error = true })
			return
		end
		jj("util", "exec", "--", "rm", "-rf", dir)

		flash("abandoned workspace " .. target .. (dir == here and ", now in default" or ""))
		revisions.refresh({})
	end, { desc = "Abandon workspace", scope = "revisions", seq = { "w", "a" } })
end
