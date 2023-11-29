-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local timer = timer

local timer_count = SF.LimitObject("timer", "timer", 200, "The number of concurrent starfall timers")


--- Deals with time and timers.
-- @name timer
-- @class library
-- @libtbl timer_library
SF.RegisterLibrary("timer")


return function(instance)

local timers = {}

instance:AddHook("deinitialize", function()
	for name, _ in pairs(timers) do
		timer.Remove(name)
		timer_count:free(instance.player, 1)
	end
end)


local timer_library = instance.Libraries.timer

-- ------------------------- Time ------------------------- --

--- Returns the uptime of the server in seconds (to at least 4 decimal places)
-- You should not use this for timing real world events as it is synchronized with the server, use realtime instead
-- @return number Curtime in seconds
function timer_library.curtime()
	return CurTime()
end

--- Returns the uptime of the game/server in seconds (to at least 4 decimal places)
-- Ideal for timing real world events since it updates local to the realm thinking, being clientside FPS or server tickrate
-- @return number Realtime in seconds
function timer_library.realtime()
	return RealTime()
end

--- Returns a highly accurate time in seconds since the start up, ideal for benchmarking.
-- @return number The time in seconds since start up
function timer_library.systime()
	return SysTime()
end

--- Returns time between frames on client and ticks on server. Same thing as G.FrameTime in GLua
-- @return number The time between frames / ticks depending on realm
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
	local timername
	if simple then
		timername = mangle_simpletimer_name()
	else
		timername = mangle_timer_name(name)
	end

	if not timers[timername] then
		timer_count:use(instance.player, 1)
	end

	local timerdata = {reps = reps, func = func}
	local function timerCallback()
		if timerdata.reps ~= 0 then
			timerdata.reps = timerdata.reps - 1
			if timerdata.reps<=0 then
				timers[timername] = nil
				timer_count:free(instance.player, 1)
			end
		end
		instance:runFunction(timerdata.func)
	end

	timer.Create(timername, math.max(delay, 0.001), reps, timerCallback)

	timers[timername] = timerdata
end

--- Creates (and starts) a timer
-- @param string name The timer name
-- @param number delay The time, in seconds, to set the timer to.
-- @param number reps The repetitions of the timer. 0 = infinite
-- @param function func The function to call when the timer is fired
function timer_library.create(name, delay, reps, func)
	checkluatype(name, TYPE_STRING)
	checkluatype(delay, TYPE_NUMBER)
	checkluatype(reps, TYPE_NUMBER)
	checkluatype(func, TYPE_FUNCTION)

	createTimer(name, delay, reps, func, false)
end

--- Creates a simple timer, has no name, can't be stopped, paused, or destroyed.
-- @param number delay The time, in second, to set the timer to
-- @param function func The function to call when the timer is fired
function timer_library.simple(delay, func)
	checkluatype(delay, TYPE_NUMBER)
	checkluatype(func, TYPE_FUNCTION)
	createTimer("", delay, 1, func, true)
end

--- Stops and removes the timer.
-- @param string name The timer name
function timer_library.remove(name)
	checkluatype(name, TYPE_STRING)

	local timername = mangle_timer_name(name)
	if timers[timername] then
		timer_count:free(instance.player, 1)
		timers[timername] = nil
		timer.Remove(timername)
	end
end

--- Checks if a timer exists
-- @param string name The timer name
-- @return boolean if the timer exists
function timer_library.exists(name)
	checkluatype(name, TYPE_STRING)
	return timer.Exists(mangle_timer_name(name))
end

--- Stops a timer
-- @param string name The timer name
-- @return boolean False if the timer didn't exist or was already stopped, true otherwise.
function timer_library.stop(name)
	checkluatype(name, TYPE_STRING)
	return timer.Stop(mangle_timer_name(name))
end

--- Starts a timer
-- @param string name The timer name
-- @return boolean True if the timer exists, false if it doesn't.
function timer_library.start(name)
	checkluatype(name, TYPE_STRING)

	return timer.Start(mangle_timer_name(name))
end

--- Adjusts a timer
-- @param string name The timer name
-- @param number delay The time, in seconds, to set the timer to.
-- @param number? reps (Optional) The repetitions of the timer. 0 = infinite, nil = 1
-- @param function? func (Optional) The function to call when the timer is fired
-- @return boolean True if succeeded
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
-- @param string name The timer name
-- @return boolean false if the timer didn't exist or was already paused, true otherwise.
function timer_library.pause(name)
	checkluatype(name, TYPE_STRING)

	return timer.Pause(mangle_timer_name(name))
end

--- Unpauses a timer
-- @param string name The timer name
-- @return boolean false if the timer didn't exist or was already running, true otherwise.
function timer_library.unpause(name)
	checkluatype(name, TYPE_STRING)

	return timer.UnPause(mangle_timer_name(name))
end

--- Runs either timer.pause or timer.unpause based on the timer's current status.
-- @param string name The timer name
-- @return boolean Status of the timer.
function timer_library.toggle(name)
	checkluatype(name, TYPE_STRING)

	return timer.Toggle(mangle_timer_name(name))
end

--- Returns amount of time left (in seconds) before the timer executes its function.
-- @param string name The timer name
-- @return number The amount of time left (in seconds). If the timer is paused, the amount will be negative. Nil if timer doesnt exist
function timer_library.timeleft(name)
	checkluatype(name, TYPE_STRING)

	return timer.TimeLeft(mangle_timer_name(name))
end

--- Returns amount of repetitions/executions left before the timer destroys itself.
-- @param string name The timer name
-- @return number The amount of executions left. Nil if timer doesnt exist
function timer_library.repsleft(name)
	checkluatype(name, TYPE_STRING)

	return timer.RepsLeft(mangle_timer_name(name))
end

--- Returns number of available timers
-- @return number Number of available timers
function timer_library.getTimersLeft()
	return timer_count:check(instance.player)
end

end
