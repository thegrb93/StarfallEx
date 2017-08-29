-------------------------------------------------------------------------------
-- Time library
-------------------------------------------------------------------------------

local timer = timer

--- Deals with time and timers.
-- @shared
local timer_library = SF.Libraries.Register("timer")
local max_timers = CreateConVar("sf_maxtimers", "200", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The max number of timers that can be created")

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

local function mangle_timer_name(instance, name)
	return "sftimer_"..tostring(instance).."_"..name
end

local simple_int = 0
local function mangle_simpletimer_name(instance)
	simple_int = simple_int + 1
	return "sftimersimple_"..tostring(instance).."_"..simple_int
end

--- Creates (and starts) a timer
-- @param name The timer name
-- @param delay The time, in seconds, to set the timer to.
-- @param reps The repititions of the tiemr. 0 = infinte, nil = 1
-- @param func The function to call when the timer is fired
function timer_library.create(name, delay, reps, func, simple)
	SF.CheckLuaType(name, TYPE_STRING)
	SF.CheckLuaType(delay, TYPE_NUMBER)
	reps = SF.CheckLuaType(reps, TYPE_NUMBER, 0, 1)
	SF.CheckLuaType(func, TYPE_FUNCTION)
	
	local instance = SF.instance
	if instance.data.timer_count > max_timers:GetInt() then SF.Throw("Max timers exceeded!", 2) end
	instance.data.timer_count = instance.data.timer_count + 1
	
	local timername
	if simple then
		timername = mangle_simpletimer_name(instance)
	else
		timername = mangle_timer_name(instance, name)
	end
	
	local function timercb()
		if reps ~= 0 then
			reps = reps - 1
			if reps==0 then
				instance.data.timer_count = instance.data.timer_count - 1
				instance.data.timers[timername] = nil
			end
		end
		
		instance:runFunction(func)
	end
	
	timer.Create(timername, math.max(delay, 0.001), reps, timercb)
	
	instance.data.timers[timername] = true
end

--- Creates a simple timer, has no name, can't be stopped, paused, or destroyed.
-- @param delay the time, in second, to set the timer to
-- @param func the function to call when the timer is fired
function timer_library.simple(delay, func)
	timer_library.create("", delay, 1, func, true)
end

--- Stops and removes the timer. 
-- @param name The timer name
function timer_library.remove(name)
	SF.CheckLuaType(name, TYPE_STRING)
	local instance = SF.instance
	
	local timername = mangle_timer_name(instance, name)
	if instance.data.timers[timername] then
		instance.data.timer_count = instance.data.timer_count - 1
		instance.data.timers[timername] = nil
		timer.Remove(timername)
	end
end

--- Checks if a timer exists
-- @param name The timer name
-- @return bool if the timer exists
function timer_library.exists(name)
	SF.CheckLuaType(name, TYPE_STRING)
	return timer.Exists(mangle_timer_name(SF.instance, name))
end

--- Stops a timer
-- @param name The timer name
-- @return false if the timer didn't exist or was already stopped, true otherwise.
function timer_library.stop(name)
	SF.CheckLuaType(name, TYPE_STRING)
	return timer.Stop(mangle_timer_name(SF.instance, name))
end

--- Starts a timer
-- @param name The timer name
-- @return true if the timer exists, false if it doesn't.
function timer_library.start(name)
	SF.CheckLuaType(name, TYPE_STRING)
	
	return timer.Start(mangle_timer_name(SF.instance, name))
end

--- Adjusts a timer
-- @param name The timer name
-- @param delay The time, in seconds, to set the timer to.
-- @param reps The repititions of the tiemr. 0 = infinte, nil = 1
-- @param func The function to call when the tiemr is fired
-- @return true if succeeded
function timer_library.adjust(name, delay, reps, func)
	SF.CheckLuaType(name, TYPE_STRING)
	SF.CheckLuaType(delay, TYPE_NUMBER)
	reps = SF.CheckLuaType(reps, TYPE_NUMBER, 0, 1)
	if func then SF.CheckLuaType(func, TYPE_FUNCTION) end
	
	return timer.Adjust(mangle_timer_name(SF.instance, name), delay, reps, func)
end

--- Pauses a timer
-- @param name The timer name
-- @return false if the timer didn't exist or was already paused, true otherwise.
function timer_library.pause(name)
	SF.CheckLuaType(name, TYPE_STRING)
	
	return timer.Pause(mangle_timer_name(SF.instance, name))
end

--- Unpauses a timer
-- @param name The timer name
-- @return false if the timer didn't exist or was already running, true otherwise.
function timer_library.unpause(name)
	SF.CheckLuaType(name, TYPE_STRING)
	
	return timer.UnPause(mangle_timer_name(SF.instance, name))
end

--- Runs either timer.pause or timer.unpause based on the timer's current status. 
-- @param name The timer name
-- @return status of the timer.
function timer_library.toggle(name)
	SF.CheckLuaType(name, TYPE_STRING)
	
	return timer.Toggle(mangle_timer_name(SF.instance, name))
end

--- Returns amount of time left (in seconds) before the timer executes its function. 
-- @param The timer name
-- @return The amount of time left (in seconds). If the timer is paused, the amount will be negative. Nil if timer doesnt exist
function timer_library.timeleft(name)
	SF.CheckLuaType(name, TYPE_STRING)
	
	return timer.TimeLeft(mangle_timer_name(SF.instance, name))
end

--- Returns amount of repetitions/executions left before the timer destroys itself. 
-- @param The timer name
-- @return The amount of executions left. Nil if timer doesnt exist
function timer_library.repsleft(name)
	SF.CheckLuaType(name, TYPE_STRING)
	
	return timer.RepsLeft(mangle_timer_name(SF.instance, name))
end

--- Returns number of available timers
-- @return Number of available timers
function timer_library.getTimersLeft()
	return max_timers:GetInt() - SF.instance.data.timer_count
end


SF.Libraries.AddHook("initialize", function(instance)
	instance.data.timers = {}
	instance.data.timer_count = 0
end)

SF.Libraries.AddHook("deinitialize", function(instance)
	for name, _ in pairs(instance.data.timers) do
		timer.Remove(name)
	end
end)
