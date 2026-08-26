-- noctalia keeps Do Not Disturb in memory only: no file to read, no hook to bind, and
-- `noctalia msg` costs ~70ms of CPU per call, far too much to poll on a timer. So talk
-- to its IPC socket directly (write the command, half-close, read the reply) and publish
-- the result to the plugin's shared state store, which every bar instance reads for free.
-- One service runtime does this for all outputs.

local runtime = noctalia.getenv("XDG_RUNTIME_DIR") or "/tmp"
local display = noctalia.getenv("WAYLAND_DISPLAY")
if display == nil or display == "" then
	display = "wayland-0"
end
local ask = string.format(
	"printf %%s notification-dnd-status | socat - UNIX-CONNECT:%s/noctalia-%s.sock",
	runtime,
	display
)
local ready = noctalia.commandExists("socat")
if not ready then
	noctalia.log("notif-inline: socat missing, the DND indicator will not update")
end

noctalia.setUpdateInterval(2000)

local function readDnd(res)
	return res.exitCode == 0 and string.match(res.stdout, "^%s*(%S*)") == "on"
end

function update()
	if not ready then
		return
	end
	noctalia.runAsync(ask, function(res)
		if res.exitCode ~= 0 then
			return
		end
		noctalia.state.set("dnd", readDnd(res))
	end)
end

-- The bar widget routes its right click here so a single owner flips the state. Read the
-- truth first: the control center has its own DND toggle, so our belief may be stale.
function onIpc(event)
	if event ~= "dnd" then
		return
	end
	if not ready then
		noctalia.runAsync("noctalia msg notification-dnd-toggle")
		return
	end
	noctalia.runAsync(ask, function(res)
		local wanted = not readDnd(res)
		noctalia.state.set("dnd", wanted)
		noctalia.runAsync("noctalia msg notification-dnd-set " .. (wanted and "on" or "off"))
	end)
end
