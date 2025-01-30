local conf = require("telescope.config").values
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")

local ripgrep = function(opts)
	opts = opts or {}
	opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
	opts.pattern = opts.pattern or "%s"

	local custom_grep = finders.new_async_job {
		command_generator = function(prompt)
			if not prompt or prompt == "" then
				return nil
			end

			local split = vim.split(prompt, "  ")
			local search = split[1]
			local glob = {}

			if not search or search == "" then
				return nil
			end

			if split[2] ~= nil and #split[2] > 0 then
				local g = split[2]

				local glob_flag = "--iglob"
				-- switch to case sensitive glob if there's an uppercase letter.
				if g:match("%u") then
					glob_flag = "--glob"
				end

				if g:match("^[%w/%._-]") then
					g = "*" .. g
				elseif g:sub(1, 1) == "^" then
					g = g:sub(2)
				end
				if g:match("[%w/%._-]$") then
					g = g .. "*"
				elseif g:sub(#g) == "$" then
					g = g:sub(1, #g - 1)
				end

				glob = { glob_flag, g }
			end

			return vim.iter({
				{ "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", },
				{ "--hidden", "--smart-case", },
				glob,
				{ "--", search },
			}):flatten():totable()
		end,
		entry_maker = make_entry.gen_from_vimgrep(opts),
		cwd = opts.cwd,
	}

	pickers
		.new(opts, {
			debounce = 100,
			prompt_title = "Live Grep",
			finder = custom_grep,
			previewer = conf.grep_previewer(opts),
			sorter = require("telescope.sorters").empty(),
		})
		:find()
end

return require("telescope").register_extension {
	setup = function() end,
	exports = {
		ripgrep = ripgrep,
	},
}
