
-- More efficient timers
-- Made by Divran - 14/01/12
-- Avoids garry crap like unpack({...})

if SERVER then
	AddCSLuaFile("autorun/better_timer_library.lua")
end

-- Create tables
local timers = {}
local timers_lookup = {}
timerx = {}

-- Localize global functions
local CurTime = CurTime
local unpack = unpack
local pcall = pcall
local ErrorNoHalt = ErrorNoHalt
local table_remove = table.remove

--- Creates a new timer and starts it. To create a new timer without starting it, use timer.Adjust.
-- @param name The name of the timer
-- @param delay the length until the timer stops running
-- @param reps how many times the timer should repeat 0 is infinite
-- @param func the callback function the timer calls when it has ended
-- @param ... the paramaters that will be passed to the functione when it is called
-- @returns the created timer.
function timerx.create( name, delay, reps, func, ... )
	local curtimer = timerx.adjust( name, delay, reps, func, ... )
	timerx.start( name )
end

--- Creates a simple timer with no name (Can't be adjusted, stopped, or removed)
-- @param delay the length until the timer stops running
-- @param func the callback function the timer calls when it has ended
-- @param ... the paramaters that will be passed to the functione when it is called
function timerx.simple( delay, func, ... )
	local id = #timers+1
	timers[id] = { stoptime = CurTime() + delay }
	local time = timers[id]
	time.delay = delay
	time.reps = 1
	time.totalreps = 0
	time.func = func
	time.args = {...}
	time.running = true
end

--- Adjusts a timer's settings. Creates a new timer if the specified timer doesn't exist.
-- @param name The name of the timer
-- @param delay the length until the timer stops running
-- @param reps how many times the timer should repeat 0 is infinite
-- @param func the callback function the timer calls when it has ended
-- @param ... the paramaters that will be passed to the functione when it is called
-- @returns the created timer.
function timerx.adjust( name, delay, reps, func, ... )
	if not name then return end
	
	local timerID = timers_lookup[name]
	if timerID then -- Timer already exists. Edit it.
		local curtimer = timers[timerID]
		if delay then
			curtimer.stoptime = CurTime() + delay
			curtimer.starttime = CurTime()
		end
		if reps then curtimer.reps = reps end
		if func then curtimer.func = func end
		
		local t = {...}
		if #t > 0 then curtimer.args = {...} end
		
		return curtimer
	else -- Didn't exist; create new.
		local curtimer = { 	
							name = name,
							starttime = CurTime(),
							stoptime = CurTime() + delay,
							delay = delay,
							reps = reps,
							totalreps = 0,
							func = func,
							args = {...},
							running = false
						}

		timerID = #timers+1
		timers[timerID] = curtimer
		timers_lookup[name] = timerID
	end
end

--- Starts a timer.
-- @param name The name of the timer
-- @returns true if successful, else false.
function timerx.start( name )
	if timerx.exists( name ) then
		local curtimer = timers[timers_lookup[name]]
		if not curtimer.running then
			curtimer.starttime = CurTime()
			
			if curtimer.difference then -- Check if it was paused
				curtimer.stoptime = CurTime() + curtimer.difference -- Use the difference to calculate when the next trigger will be
				curtimer.paused = nil
			end
			
			timers[timers_lookup[name]].running = true
			return true
		end
	end
	return false
end

--- Pauses a timer. The timer's remaining delay time will be paused as well.
-- @param name The name of the timer
-- @returns true if successful, else false.
function timerx.pause( name )
	if timerx.exists( name ) then
		local curtimer = timers[timers_lookup[name]]
		curtimer.difference = curtimer.stoptime - curtimer.starttime -- Save the time difference
		curtimer.running = false
		return true
	end
	return false
end

--- Removes the timer specified
-- @param name The name of the timer
-- @returns true if successful, else false.
function timerx.remove( name )
	if name then
		local timerID = timers_lookup[name]
		if timerID then
			table_remove( timers, timerID )
			timers_lookup[name] = nil
			return true
		end
	end
	return false
end

--- Retrieves the timer table with the specified name
-- @param name The name of the timer
-- @returns the timer specified. If no timer is specified, returns all timers.
function timerx.get( name )
	return timers[timers_lookup[name]]
end

--- Checks if a given timer exists
-- @param name The name of the timer
-- @returns true if the specified timer exists, else false
function timerx.exists( name )
	return timers_lookup[name] and true or false
end

hook.Add( "Think", "timer think", function()
	for i=#timers,1,-1 do -- Loop backwards so that we can remove timers without causing issues.
		local curtimer = timers[i]
		
		local time = CurTime()
		if time >= curtimer.stoptime and curtimer.running then
			curtimer.starttime = time
			curtimer.stoptime = time + curtimer.delay
			curtimer.totalreps = curtimer.totalreps + 1

			local ok, err = pcall(curtimer.func,unpack(curtimer.args))
			
			if not ok then -- The timer errored
				ErrorNoHalt( "Timer error in timer '" .. curtimer.name .. "': " .. err )
			end
			
			if not ok or (curtimer.reps ~= 0 and curtimer.totalreps >= curtimer.reps) then -- Lua error and/or timer repetitions are up. Remove timer.
				if curtimer.name then -- It's a normal timer
					timerx.remove( curtimer.name )
				else -- it's a simple timer
					table_remove( timers, i )
				end
			end
		end
	end
end)

