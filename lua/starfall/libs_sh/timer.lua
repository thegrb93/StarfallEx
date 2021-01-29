-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local timer = timer

local max_timers = CreateConVar("sf_maxtimers", "200", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The max number of timers that can be created")


--- Deals with time and timers.
-- @name timer
-- @class library
-- @libtbl timer_library
SF.RegisterLibrary("timer")


return function(instance)

local timers = {}
local timer_count = 0

instance:AddHook("deinitialize", function()
	for name, _ in pairs(timers) do
		timer.Remove(name)
	end
end)


local timer_library = instance.Libraries.timer

-- ------------------------- Time ------------------------- --

--- Returns the uptime of the server in seconds (to at least 4 decimal places)
function timer_library.curtime()
	return CurTime()
end

--- Returns the uptime of the game/server in seconds (to at least 4 decimal places)
function timer_library.realtime()
	return RealTime()
end

--- Returns a highly accurate time in seconds since the start up, ideal for benchmarking.
function timer_library.systime()
	return SysTime()
end

--- Returns time between frames on client and ticks on server. Same thing as G.FrameTime in GLua
function timer_library.frametime()
	return FrameTime()
end

-- ------------------------- Timers ------------------------- --

local function mangle_timer_name(name)
	return "sftimer_"..tostring(instance).."_"..name
end

local simple_int = 0
local function mangle_simpletimer_name()
	simple_int = simple_int + 1
	return "sftimersimple_"..tostring(instance).."_"..simple_int
end

local function createTimer(name, delay, reps, func, simple)
	if timer_count > max_timers:GetInt() then SF.Throw("Max timers exceeded!", 2) end
	timer_count = timer_count + 1

	local timername
	if simple then
		timername = mangle_simpletimer_name()
	else
		timername = mangle_timer_name(name)
	end
	
	local timerdata = {reps = reps, func = func}
	local function timerCallback()
		if timerdata.reps ~= 0 then
			timerdata.reps = timerdata.reps - 1
			if timerdata.reps<=0 then
				timer_count = timer_count - 1
				timers[timername] = nil
			end
		end
		instance:runFunction(timerdata.func)
	end

	timer.Create(timername, math.max(delay, 0.001), reps, timerCallback)

	timers[timername] = timerdata
end

--- Creates (and starts) a timer
-- @param name The timer name
-- @param delay The time, in seconds, to set the timer to.
-- @param reps The repititions of the timer. 0 = infinte
-- @param func The function to call when the timer is fired
function timer_library.create(name, delay, reps, func)
	checkluatype(name, TYPE_STRING)
	checkluatype(delay, TYPE_NUMBER)
	checkluatype(reps, TYPE_NUMBER)
	checkluatype(func, TYPE_FUNCTION)

	createTimer(name, delay, reps, func, false)
end

--- Creates a simple timer, has no name, can't be stopped, paused, or destroyed.
-- @param delay the time, in second, to set the timer to
-- @param func the function to call when the timer is fired
function timer_library.simple(delay, func)
	createTimer("", delay, 1, func, true)
end

--- Stops and removes the timer.
-- @param name The timer name
function timer_library.remove(name)
	checkluatype(name, TYPE_STRING)

	local timername = mangle_timer_name(name)
	if timers[timername] then
		timer_count = timer_count - 1
		timers[timername] = nil
		timer.Remove(timername)
	end
end

--- Checks if a timer exists
-- @param name The timer name
-- @return bool if the timer exists
function timer_library.exists(name)
	checkluatype(name, TYPE_STRING)
	return timer.Exists(mangle_timer_name(name))
end

--- Stops a timer
-- @param name The timer name
-- @return false if the timer didn't exist or was already stopped, true otherwise.
function timer_library.stop(name)
	checkluatype(name, TYPE_STRING)
	return timer.Stop(mangle_timer_name(name))
end

--- Starts a timer
-- @param name The timer name
-- @return true if the timer exists, false if it doesn't.
function timer_library.start(name)
	checkluatype(name, TYPE_STRING)

	return timer.Start(mangle_timer_name(name))
end

--- Adjusts a timer
-- @param name The timer name
-- @param delay The time, in seconds, to set the timer to.
-- @param reps (Optional) The repititions of the timer. 0 = infinte, nil = 1
-- @param func (Optional) The function to call when the timer is fired
-- @return true if succeeded
function timer_library.adjust(name, delay, reps, func)
	checkluatype(name, TYPE_STRING)
	checkluatype(delay, TYPE_NUMBER)

	local timername = mangle_timer_name(name)
	local data = timers[timername]

	if data then
		if reps~=nil then checkluatype(reps, TYPE_NUMBER) data.reps = reps end
		if func~=nil then checkluatype(func, TYPE_FUNCTION) data.func = func end
		return timer.Adjust(timername, math.max(delay, 0.001), reps)
	else
		return false
	end
end

--- Pauses a timer
-- @param name The timer name
-- @return false if the timer didn't exist or was already paused, true otherwise.
function timer_library.pause(name)
	checkluatype(name, TYPE_STRING)

	return timer.Pause(mangle_timer_name(name))
end

--- Unpauses a timer
-- @param name The timer name
-- @return false if the timer didn't exist or was already running, true otherwise.
function timer_library.unpause(name)
	checkluatype(name, TYPE_STRING)

	return timer.UnPause(mangle_timer_name(name))
end

--- Runs either timer.pause or timer.unpause based on the timer's current status.
-- @param name The timer name
-- @return status of the timer.
function timer_library.toggle(name)
	checkluatype(name, TYPE_STRING)

	return timer.Toggle(mangle_timer_name(name))
end

--- Returns amount of time left (in seconds) before the timer executes its function.
-- @param name The timer name
-- @return The amount of time left (in seconds). If the timer is paused, the amount will be negative. Nil if timer doesnt exist
function timer_library.timeleft(name)
	checkluatype(name, TYPE_STRING)

	return timer.TimeLeft(mangle_timer_name(name))
end

--- Returns amount of repetitions/executions left before the timer destroys itself.
-- @param name The timer name
-- @return The amount of executions left. Nil if timer doesnt exist
function timer_library.repsleft(name)
	checkluatype(name, TYPE_STRING)

	return timer.RepsLeft(mangle_timer_name(name))
end

--- Returns number of available timers
-- @return Number of available timers
function timer_library.getTimersLeft()
	return max_timers:GetInt() - timer_count
end

end
