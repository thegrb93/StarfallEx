-------------------------------------------------------------------------------
-- Time library
-------------------------------------------------------------------------------

local timer = timer

--- Deals with time and timers.
-- @shared
local timer_library, _ = SF.Libraries.Register("timer")
local max_timers = CreateConVar( "sf_maxtimers", "200", {FCVAR_ARCHIVE,FCVAR_REPLICATED}, "The max number of timers that can be created" )

-- ------------------------- Time ------------------------- --

--- Same as GLua's CurTime()
function timer_library.curtime()
	return CurTime()
end

--- Same as GLua's RealTime()
function timer_library.realtime()
	return RealTime()
end

--- Same as GLua's SysTime()
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
-- @param func The function to call when the tiemr is fired
function timer_library.create(name, delay, reps, func, simple)
	SF.CheckType(name,"string")
	SF.CheckType(delay,"number")
	reps = SF.CheckType(reps,"number",0,1)
	SF.CheckType(func,"function")
	
	local instance = SF.instance
	if instance.data.timer_count > max_timers:GetInt() then SF.throw( "Max timers exceeded!", 2 ) end
	instance.data.timer_count = instance.data.timer_count + 1
	
	local timername
	if simple then
		timername = mangle_simpletimer_name(instance)
	else
		timername = mangle_timer_name(instance,name)
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
	
	timer.Create(timername, math.max(delay, 0.001), reps, timercb )
	
	instance.data.timers[timername] = true
end

--- Creates a simple timer, has no name, can't be stopped, paused, or destroyed.
-- @param delay the time, in second, to set the timer to
-- @param func the function to call when the timer is fired
function timer_library.simple(delay, func)
	timer_library.create("", delay, 1, func, true)
end

--- Removes a timer
-- @param name The timer name
function timer_library.remove(name)
	SF.CheckType(name,"string")
	local instance = SF.instance
	
	local timername = mangle_timer_name(instance,name)
	if instance.data.timers[timername] then
		instance.data.timer_count = instance.data.timer_count - 1
		instance.data.timers[timername] = nil
		timer.Stop(timername)
	end
end

--- Checks if a timer exists
-- @param name The timer name
-- @return bool if the timer exists
function timer_library.exists(name)
	SF.CheckType(name,"string")
	local instance = SF.instance
	
	return timer.Exists(mangle_timer_name(instance,name))
end

--- Stops a timer
-- @param name The timer name
function timer_library.stop(name)
	SF.CheckType(name,"string")
	local instance = SF.instance
	
	local timername = mangle_timer_name(instance,name)
	if instance.data.timers[timername] then
		instance.data.timer_count = instance.data.timer_count - 1
		instance.data.timers[timername] = nil
		timer.Stop(timername)
	end
end

--- Starts a timer
-- @param name The timer name
function timer_library.start(name)
	SF.CheckType(name,"string")
	
	timer.Start(mangle_timer_name(SF.instance,name))
end

--- Adjusts a timer
-- @param name The timer name
-- @param delay The time, in seconds, to set the timer to.
-- @param reps The repititions of the tiemr. 0 = infinte, nil = 1
-- @param func The function to call when the tiemr is fired
function timer_library.adjust(name, delay, reps, func)
	SF.CheckType(name,"string")
	SF.CheckType(delay,"number")
	reps = SF.CheckType(reps,"number",0,1)
	if func then SF.CheckType(func,"function") end
	
	timer.Adjust(mangle_timer_name(SF.instance,name), delay, reps, func)
end

--- Pauses a timer
-- @param name The timer name
function timer_library.pause(name)
	SF.CheckType(name,"string")
	
	timer.Pause(mangle_timer_name(SF.instance,name))
end

--- Unpauses a timer
-- @param name The timer name
function timer_library.unpause(name)
	SF.CheckType(name,"string")
	
	timer.UnPause(mangle_timer_name(SF.instance,name))
end

--- Returns number of available timers
-- @return Number of available timers
function timer_library.getTimersLeft()
	return max_timers:GetInt() - SF.instance.data.timer_count
end


SF.Libraries.AddHook("initialize",function(instance)
	instance.data.timers = {}
	instance.data.timer_count = 0
end)

SF.Libraries.AddHook("deinitialize",function(instance)
	for name,_ in pairs(instance.data.timers) do
		timer.Remove(name)
	end
end)
