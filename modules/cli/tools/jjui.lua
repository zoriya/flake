local function workspace_under_cursor(include_default)
	local rev = context.change_id()
	if not rev then
		flash({ text = "no revision selected", error = true })
		return
	end

	-- --ignore-working-copy: a stale current workspace would fail the query
	local marks = jj("log", "--ignore-working-copy", "-r", rev, "--no-graph", "--color=never", "-T", "working_copies") or ""
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

-- abandon snapshots the workspace before dropping it, forget loses whatever
-- was not snapshotted yet so it asks first
local function remove_workspace(snapshot)
	local target, dir = workspace_under_cursor(false)
	if not target then
		return
	end

	if not snapshot then
		local answer = choose({ options = { "no", "yes" }, title = "forget " .. target .. " without snapshotting it?" })
		if answer ~= "yes" then
			return
		end
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

	if snapshot then
		local _, snap_err = jj("-R", dir, "util", "snapshot")
		if snap_err then
			flash({ text = snap_err, error = true })
			return
		end
	end

	local _, forget_err = jj("workspace", "forget", target)
	if forget_err then
		flash({ text = forget_err, error = true })
		return
	end
	jj("util", "exec", "--", "rm", "-rf", dir)

	flash((snapshot and "abandoned" or "forgot") .. " workspace " .. target .. (dir == here and ", now in default" or ""))
	revisions.refresh({})
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

		local root = (jj("workspace", "root", "--name", "root") or ""):gsub("%s+$", "")
		if root == "" then
			flash({ text = "Run `jj workspace-init` before", error = true })
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

	config.action("update_workspace", function()
		local target, dir
		-- a stale current workspace fails jjui's log, leaving no revision to pick from
		if context.change_id() then
			target, dir = workspace_under_cursor(true)
			if not target then
				return
			end
		else
			target = "current"
			dir = (jj("workspace", "root") or ""):gsub("%s+$", "")
		end

		local _, err = jj("-R", dir, "workspace", "update-stale")
		if err then
			flash({ text = err, error = true })
			return
		end

		flash("updated " .. target .. " workspace")
		revisions.refresh({})
	end, { desc = "Update stale workspace", scope = "revisions", seq = { "w", "u" } })

	config.action("abandon_workspace", function()
		remove_workspace(true)
	end, { desc = "Abandon workspace", scope = "revisions", seq = { "w", "a" } })

	config.action("forget_workspace", function()
		remove_workspace(false)
	end, { desc = "Forget workspace", scope = "revisions", seq = { "w", "f" } })
end
