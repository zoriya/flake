local previewers = require("telescope.previewers")
local putils = require "telescope.previewers.utils"
local from_entry = require "telescope.from_entry"
local conf = require("telescope.config").values

local function defaulter(f, default_opts)
  default_opts = default_opts or {}
  return {
    new = function(opts)
      if conf.preview == false and not opts.preview then
        return false
      end
      opts.preview = type(opts.preview) ~= "table" and {} or opts.preview
      if type(conf.preview) == "table" then
        for k, v in pairs(conf.preview) do
          opts.preview[k] = vim.F.if_nil(opts.preview[k], v)
        end
      end
      return f(opts)
    end,
    __call = function()
      local ok, err = pcall(f(default_opts))
      if not ok then
        error(debug.traceback(err))
      end
    end,
  }
end

previewers.git_file_diff = defaulter(function(opts)
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
        putils.job_maker({ "git", "--no-pager", "diff", "HEAD", "--", entry.value }, self.state.bufnr, {
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
end, {})
