-------------------------------------------------------------------------------
-- Time library
-------------------------------------------------------------------------------

local timer = timer

--- Deals with time and timers.
-- @shared
local time_library, _ = SF.Libraries.Register("time")

-- ------------------------- Time ------------------------- --

--- Same as GLua's CurTime()
function time_library.curTime()
	return CurTime()
end

--- Same as GLua's RealTime()
function time_library.realTime()
	return RealTime()
end

--- Same as GLua's SysTime()
function time_library.sysTime()
	return SysTime()
end

-- ------------------------- Timers ------------------------- --

local function timercb(instance, tname, realname, func)
	if not instance.error then
		instance:runFunction(func)
	else
		timerx.remove(realname)
	end
end

local function mangle_timer_name(instance, name)
	return string.format("sftimer_%s_%s",tostring(instance),name)
end

--- Creates a timer
-- @param name The timer name
-- @param delay The time, in seconds, to set the timer to.
-- @param reps The repititions of the tiemr. 0 = infinte, nil = 1
-- @param func The function to call when the tiemr is fired
-- @param ... Arguments to func
function time_library.timer(name, delay, reps, func, ...)
	SF.CheckType(name,"string")
	SF.CheckType(delay,"number")
	reps = SF.CheckType(reps,"number",0,1)
	SF.CheckType(func,"function")
	
	local instance = SF.instance
	local timername = mangle_timer_name(instance,name)
	
	timerx.create(timername, delay, reps, timercb, instance, name, timername, func)
	instance.data.timers[name] = true
end

--- Creates a simple timer, has no name, can't be stopped, paused, or destroyed.
-- @param delay the time, in second, to set the timer to
-- @param func the function to call when the timer is fired
-- @param ... Arguments passed to the function
function time_library.stimer( delay, func, ... )
	SF.CheckType( delay, "number" )
	SF.CheckType( func, "function" )

	timerx.simple( delay, simplecb, SF.instance, func, {...} )
end

--- Removes a timer
-- @param name Timer name
function time_library.destroyTimer(name)
	SF.CheckType(name,"string")
	local instance = SF.instance
	local timername = mangle_timer_name(instance,name)
	
	if timerx.exists(timername) then timerx.remove(timername) end
	instance.data.timers[name] = nil
end

local function init(instance)
	instance.data.timers = {}
end

local function deinit(instance)
	if instance.data.timers ~= nil then
		for name,_ in pairs(instance.data.timers) do
			local realname = mangle_timer_name(instance,name)
			timerx.remove(realname)
		end
	end
	instance.data.timers = nil
end

SF.Libraries.AddHook("initialize",init)
SF.Libraries.AddHook("deinitialize",deinit)
