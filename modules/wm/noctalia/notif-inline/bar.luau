-- Toasts are filtered out in config.toml, so the live notification has nowhere to go:
-- this widget is the bell and the notification itself. It polls the history store
-- noctalia persists on every change and shows the newest entry still flagged active --
-- exactly the window a toast would have been on screen for -- fading it in and back out.

local POLL_MS = 100 -- history re-read cadence, and the idle tick: this is the appear latency
local FRAME_MS = 16 -- tick while a fade runs
local ANIM_MS = 180
local MAX_WIDTH = 420 -- label budget in logical px, noctalia ellipsizes past it
local LATCH_MS = 3000 -- keep the bell put after a click marks everything read

local stateHome = noctalia.getenv("NOCTALIA_STATE_HOME")
if stateHome == nil or stateHome == "" then
	stateHome = noctalia.getenv("XDG_STATE_HOME")
end
if stateHome == nil or stateHome == "" then
	stateHome = (noctalia.getenv("HOME") or "") .. "/.local/state"
end
local historyPath = stateHome .. "/noctalia/notification_history.json"
local hasNiri = noctalia.commandExists("niri")

local shown = nil -- history entry on screen
local phase = "idle" -- idle | in | hold | out
local phaseStart = 0
local unread = false
local lastPoll = 0
local latchUntil = 0
local interval = 0

function update()
	local now = noctalia.nowMs()

	if now - lastPoll >= POLL_MS then
		lastPoll = now
		local raw = noctalia.readFile(historyPath)
		local history = nil
		if raw ~= nil then
			history = noctalia.json.decode(raw)
		end
		local newest = nil
		unread = false
		if history ~= nil and type(history.entries) == "table" then
			for _, entry in ipairs(history.entries) do
				if entry.seen ~= true then
					unread = true
				end
				if entry.active == true and (newest == nil or (entry.event_serial or 0) > (newest.event_serial or 0)) then
					newest = entry
				end
			end
		end

		if newest ~= nil then
			if shown == nil or (shown.event_serial or 0) ~= (newest.event_serial or 0) or phase == "out" then
				phase = "in"
				phaseStart = now
			end
			shown = newest
		elseif shown ~= nil and phase ~= "out" then
			phase = "out"
			phaseStart = now
		end
	end

	local reveal = 0
	if phase == "in" or phase == "out" then
		local p = (now - phaseStart) / ANIM_MS
		if p >= 1 then
			if phase == "in" then
				phase = "hold"
				reveal = 1
			else
				phase = "idle"
				shown = nil
			end
		else
			local inv = 1 - p
			local eased = 1 - inv * inv * inv
			reveal = phase == "in" and eased or 1 - eased
		end
	elseif phase == "hold" then
		reveal = 1
	end

	local wanted = (phase == "in" or phase == "out") and FRAME_MS or POLL_MS
	if interval ~= wanted then
		interval = wanted
		noctalia.setUpdateInterval(wanted)
	end

	-- published by the dnd service entry, shared across every bar instance
	local dnd = noctalia.state.get("dnd") == true

	if shown == nil and not unread and not dnd and now >= latchUntil then
		barWidget.setTooltip(nil)
		barWidget.setVisible(false)
		return
	end

	local children = {ui.glyph({name = dnd and "bell-off" or "bell", color = "on_surface"})}
	if shown ~= nil then
		local n = shown.notification or {}
		local summary = n.summary or ""
		local body = n.body or ""
		local line = summary
		if body ~= "" then
			line = (summary ~= "" and summary .. " · " or "") .. body
		end
		table.insert(children, ui.label({
			text = string.gsub(line, "%s+", " "),
			color = n.urgency == "critical" and "error" or "on_surface",
			maxWidth = math.max(1, MAX_WIDTH * reveal),
			maxLines = 1,
			opacity = reveal,
		}))
		local rows = {{key = n.app_name or "", value = summary}}
		if body ~= "" then
			table.insert(rows, {key = "", value = body})
		end
		barWidget.setTooltip(rows)
	else
		if unread then
			table.insert(children, ui.box({fill = "primary", radius = 3, width = 6, height = 6}))
		end
		barWidget.setTooltip(nil)
	end

	barWidget.render(ui.row({gap = 6, align = "center"}, children))
	barWidget.setVisible(true)
end

function onIpc(event)
	if event ~= "click" then
		return
	end
	latchUntil = noctalia.nowMs() + LATCH_MS

	local n = nil
	if shown ~= nil then
		n = shown.notification
	end
	if n == nil then
		noctalia.runAsync("noctalia msg panel-toggle control-center notifications")
		return
	end

	-- A default action is the notification's intent; invoking it makes the source app
	-- raise itself, and noctalia dismisses the notification for us.
	if type(n.actions) == "table" and #n.actions >= 2 and n.actions[1] == "default" then
		noctalia.runAsync("noctalia msg notification-invoke-latest")
		return
	end

	-- Nothing to invoke (notify-send and friends carry no actions), so focus the window
	-- it came from instead: best app-id match, most recently focused one wins a tie.
	local needles = {}
	if type(n.desktop_entry) == "string" and n.desktop_entry ~= "" then
		table.insert(needles, string.lower(n.desktop_entry))
	end
	if type(n.app_name) == "string" and n.app_name ~= "" then
		table.insert(needles, string.lower(n.app_name))
	end
	if not hasNiri or #needles == 0 then
		return
	end

	noctalia.runAsync("niri msg --json windows", function(res)
		if res.exitCode ~= 0 then
			return
		end
		local windows = noctalia.json.decode(res.stdout)
		if type(windows) ~= "table" then
			return
		end
		local best, bestScore, bestSeen = nil, 0, -1
		for _, w in ipairs(windows) do
			local appId = string.lower(w.app_id or "")
			local score = 0
			for _, needle in ipairs(needles) do
				if appId == needle then
					score = math.max(score, 2)
				elseif #needle >= 3 and string.find(appId, needle, 1, true) ~= nil then
					score = math.max(score, 1)
				elseif #appId >= 3 and string.find(needle, appId, 1, true) ~= nil then
					score = math.max(score, 1)
				end
			end
			local seen = 0
			if type(w.focus_timestamp) == "table" then
				seen = w.focus_timestamp.secs or 0
			end
			if score > bestScore or (score > 0 and score == bestScore and seen > bestSeen) then
				best, bestScore, bestSeen = w, score, seen
			end
		end
		if best ~= nil then
			noctalia.runAsync(string.format("niri msg action focus-window --id %d", best.id))
		end
	end)
end
