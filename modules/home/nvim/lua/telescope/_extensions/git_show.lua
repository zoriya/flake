local previewers = require("telescope.previewers")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require "telescope.make_entry"
local utils = require "telescope.utils"
local putils = require "telescope.previewers.utils"
local from_entry = require "telescope.from_entry"
local conf = require("telescope.config").values

local function map(t, f)
	local t1 = {}
	for i = 1, #t do
		t1[i] = f(t[i])
	end
	return t1
end

local git_file_show = function(opts)
	return previewers.new_buffer_previewer {
		title = "Git File Diff Preview",
		get_buffer_by_name = function(_, entry)
			return entry.value
		end,

		define_preview = function(self, entry, status)
			if entry.status and (entry.status == "??" or entry.status == "A ") then
				local p = from_entry.path(entry, true)
				if p == nil or p == "" then
					return
				end
				conf.buffer_previewer_maker(p, self.state.bufnr, {
					bufname = self.state.bufname,
					winid = self.state.winid,
				})
			else
				putils.job_maker({ "git", "--no-pager", "show", opts.ref, entry.value }, self.state.bufnr, {
					value = entry.value,
					bufname = self.state.bufname,
					cwd = opts.cwd,
					callback = function(bufnr)
						if vim.api.nvim_buf_is_valid(bufnr) then
							putils.regex_highlighter(bufnr, "diff")
						end
					end,
				})
			end
		end,
	}
end

local git_show = function(opts)
	opts = opts or { cwd = vim.loop.cwd() }
	opts.ref = opts.ref or "HEAD"

	local gen_new_finder = function()
		local git_cmd = { "git", "show", "--name-status", '--pretty=tformat:', opts.ref }
		local output  = utils.get_os_command_output(git_cmd, opts.cwd)
		output        = map(output, function(x) return string.gsub(x, "\t", "  ", 1) end)

		return finders.new_table {
			results = output,
			entry_maker = make_entry.gen_from_git_status(opts),
		}
	end

	local initial_finder = gen_new_finder()
	if not initial_finder then
		return
	end

	pickers
		.new(opts, {
			prompt_title = "Git show " .. opts.ref,
			finder = initial_finder,
			previewer = git_file_show(opts),
		})
		:find()
end

return require("telescope").register_extension {
	setup = function() end,
	exports = {
		git_show = git_show
	},
}
