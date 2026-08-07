-- mini.diff source backed by jj.

local M = {}

local function resolve(buf_id)
	local name = vim.api.nvim_buf_get_name(buf_id)
	if name == "" then
		return nil
	end

	local change_id, rel = name:match("^jj://([^/]+)/(.+)$")
	if change_id then
		-- The path in the uri is repo-relative; jj resolves it from anywhere in
		-- the repo, so run from the current working directory.
		return { rev = change_id .. "-", file = rel, cwd = vim.fn.getcwd() }
	end

	local path = vim.uv.fs_realpath(name)
	if path == nil then
		return nil
	end
	return { rev = "@-", file = path, cwd = vim.fs.dirname(path) }
end

local function set_ref_text(buf_id)
	if not vim.api.nvim_buf_is_valid(buf_id) then
		return
	end
	local target = resolve(buf_id)
	if target == nil then
		return
	end
	vim.system(
		{ "jj", "file", "show", "--ignore-working-copy", "-r", target.rev, target.file },
		{ cwd = target.cwd, text = true },
		vim.schedule_wrap(function(obj)
			if not vim.api.nvim_buf_is_valid(buf_id) then
				return
			end
			local text = obj.code == 0 and obj.stdout or ""
			pcall(MiniDiff.set_ref_text, buf_id, text)
		end)
	)
end

local function group_name(buf_id)
	return "MiniDiffSourceJj" .. buf_id
end

-- One filesystem watcher per repo root, tracking the buffers attached to it.
-- jj rewrites `.jj/repo/op_heads/heads/` on every operation (edit, squash, …),
-- so watching it lets us refresh signs when jj state changes out from under us.
local watchers = {}

local function refresh_watcher(root)
	local watcher = watchers[root]
	if watcher == nil then
		return
	end
	for buf_id in pairs(watcher.buffers) do
		if vim.api.nvim_buf_is_valid(buf_id) then
			set_ref_text(buf_id)
		else
			watcher.buffers[buf_id] = nil
		end
	end
end

local function start_watcher(root)
	local watcher = { buffers = {} }
	local heads = root .. "/.jj/repo/op_heads/heads"
	local handle = vim.uv.new_fs_event()
	if handle ~= nil then
		local ok = handle:start(heads, {}, function(err)
			if err then
				return
			end
			-- Debounce: an operation removes the old head and adds the new one,
			-- firing several events; coalesce them into a single refresh.
			if watcher.timer == nil then
				watcher.timer = vim.uv.new_timer()
				watcher.timer:start(
					50,
					0,
					vim.schedule_wrap(function()
						if watcher.timer ~= nil then
							watcher.timer:close()
							watcher.timer = nil
						end
						refresh_watcher(root)
					end)
				)
			end
		end)
		if ok then
			watcher.handle = handle
		else
			handle:close()
		end
	end
	watchers[root] = watcher
	return watcher
end

local function stop_watcher(root)
	local watcher = watchers[root]
	if watcher == nil then
		return
	end
	if watcher.timer ~= nil then
		watcher.timer:close()
		watcher.timer = nil
	end
	if watcher.handle ~= nil then
		watcher.handle:stop()
		watcher.handle:close()
	end
	watchers[root] = nil
end

local buf_roots = {}

local function attach(buf_id)
	local target = resolve(buf_id)
	if target == nil then
		return false
	end

	local root = vim.fs.root(target.cwd, ".jj")
	if root == nil then
		return false
	end

	local group = vim.api.nvim_create_augroup(group_name(buf_id), { clear = true })
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "BufEnter", "FocusGained", "FileChangedShellPost" }, {
		group = group,
		buffer = buf_id,
		desc = "Refresh jj diff reference",
		callback = function()
			set_ref_text(buf_id)
		end,
	})

	local watcher = watchers[root] or start_watcher(root)
	watcher.buffers[buf_id] = true
	buf_roots[buf_id] = root

	set_ref_text(buf_id)
end

local function detach(buf_id)
	pcall(vim.api.nvim_del_augroup_by_name, group_name(buf_id))

	local root = buf_roots[buf_id]
	buf_roots[buf_id] = nil
	local watcher = root and watchers[root]
	if watcher ~= nil then
		watcher.buffers[buf_id] = nil
		if next(watcher.buffers) == nil then
			stop_watcher(root)
		end
	end
end

M.source = {
	name = "jj",
	attach = attach,
	detach = detach,
}

-- support jj:// buffers
function M.setup()
	local group = vim.api.nvim_create_augroup("MiniDiffJjRevisionBuffers", { clear = true })
	vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost" }, {
		group = group,
		desc = "Enable mini.diff on jj revision buffers",
		callback = function(ev)
			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(ev.buf) then
					return
				end
				if vim.api.nvim_buf_get_name(ev.buf):match("^jj://") then
					pcall(require("mini.diff").enable, ev.buf)
				end
			end)
		end,
	})
end

return M
