---@diagnostic disable: lowercase-global, undefined-global
local inner_gaps = 10
local outer_gaps = 15
local smart_gaps = true

local outputs = {}

local default_output = {
	mfact = 0.65,
	mcount = 1,
	layout = "tiling",
	alayout = "monocle"
}

function _get_output(name)
	local output = outputs[name]
	if output ~= nil then
		return output
	end
	outputs[name] = default_output
	return outputs[name]
end

function inspect(tbl)
	local result = "{"
	for k, v in pairs(tbl) do
		-- Check the key type (ignore any numerical keys - assume its an array)
		if type(k) == "string" then
			result = result .. "[\"" .. k .. "\"]" .. "="
		end

		-- Check the value type
		if type(v) == "table" then
			result = result .. inspect(v)
		elseif type(v) == "boolean" then
			result = result .. tostring(v)
		else
			result = result .. "\"" .. v .. "\""
		end
		result = result .. ","
	end
	-- Remove leading commas from the result
	if result ~= "" then
		result = result:sub(1, result:len() - 1)
	end
	return result .. "}"
end

-- The most important function - the actual layout generator
--
-- The argument is a table with:
--  * Focused tags (`args.tags`)
--  * Window count (`args.count`)
--  * Output width (`args.width`)
--  * Output height (`args.height`)
--  * Output name (`args.output`)
--
-- The return value must be a table with exactly `count` entries. Each entry is a table with four
-- numbers:
--  * X coordinate
--  * Y coordinate
--  * Window width
--  * Window height
--
-- This example is a simplified version of `rivertile`
function handle_layout(args)
	local output = _get_output(args.output)
	print(inspect(output))

	-- Prevent mcount from growing too much. We can't do that in the set function.
	output.mcount = math.min(output.mcount, args.count)

	local ret = {}

	if args.count == 1 or output.layout == "monocle" then
		if smart_gaps then
			for _ = 0, (args.count - 1) do
				table.insert(ret, { 0, 0, args.width, args.height })
			end
		else
			for _ = 0, (args.count - 1) do
				table.insert(ret, { outer_gaps, outer_gaps, args.width - outer_gaps * 2, args.height - outer_gaps * 2 })
			end
		end
		print("monocle", inspect(ret), args.count)
		return ret
	end

	local width = args.width - outer_gaps * 2
	local height = args.height - outer_gaps * 2
	local mcount = math.min(output.mcount, args.count)
	local scount = math.max(args.count - mcount, 0)

	local main_w = (width * output.mfact) - (inner_gaps / 2)
	local side_w = (width * (1 - output.mfact)) - (inner_gaps / 2)
	local main_h = (height - (inner_gaps * (mcount - 1))) / mcount
	local side_h = (height - (inner_gaps * (scount - 1))) / scount

	if args.count <= output.mcount then
		main_w = width
	end

	for i = 0, (mcount - 1) do
		table.insert(ret, {
			outer_gaps,
			outer_gaps + i * (main_h + inner_gaps),
			main_w,
			main_h,
		})
	end
	for i = 0, (scount - 1) do
		table.insert(ret, {
			main_w + outer_gaps * 2,
			outer_gaps + i * (side_h + inner_gaps),
			side_w,
			side_h,
		})
	end
	print("tiling", inspect(ret), args.count)
	return ret
end

-- This optional function returns the metadata for the current layout.
-- Currently only `name` is supported, the name of the layout. It get's passed
-- the same `args` as handle_layout()
function handle_metadata(args)
	local output = _get_output(args.output)

	if output.layout == "tiling" then
		return { name = "[]=" }
	elseif output.layout == "monocle" then
		return { name = string.format("[%d]", args.count) }
	else
		return { name = "><>" }
	end
end

-- IMPORTANT: User commands send via `riverctl send-layout-cmd` are treated as lua code.
-- Active tags are stored in `CMD_TAGS` global variable.
-- Output name is stored in `CMD_OUTPUT` global variable.

-- Here is an example of a function that can be mapped to some key
-- Run with `riverctl send-layout-cmd luatile "toggle_gaps()"`
function set_mfact(diff)
	local output = _get_output(CMD_OUTPUT)
	output.mfact = math.max(0, math.min(output.mfact + diff, 1))
end

function set_mcount(diff)
	local output = _get_output(CMD_OUTPUT)
	-- we don't have the number of clients so we can't set a max value there.
	output.mcount = math.max(0, output.mcount + diff)
end

function set_layout(name)
	local output = _get_output(CMD_OUTPUT)
	if output.layout == name then
		output.layout = output.alayout
		output.alayout = name
	else
		output.alayout = output.layout
		output.layout = name
	end
end
