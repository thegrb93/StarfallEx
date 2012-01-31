
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

-- Localize
local Create
local Simple
local Adjust
local Start
local Pause
local Remove
local Get
local Exists

------------------------------------------------------
-- timer.Create
-- Creates a new timer and starts it. To create a new timer without starting it, use timer.Adjust.
-- Returns the created timer.
------------------------------------------------------
function Create( name, delay, reps, func, ... )
	local curtimer = Adjust( name, delay, reps, func, ... )
	Start( name )
	return curtimer
end


------------------------------------------------------
-- timer.Simple
-- Creates a simple timer with no name (Can't be adjusted, stopped, or removed).
------------------------------------------------------
function Simple( delay, func, ... )
	timers[#timers+1] = {
							stoptime = CurTime() + delay,
							delay = delay,
							reps = 1,
							totalreps = 0,
							func = func,
							args = {...},
							running = true
						}
end

------------------------------------------------------
-- timer.Adjust
-- Adjusts a timer's settings. Creates a new timer if the specified timer doesn't exist.
-- Returns the created timer.
------------------------------------------------------
function Adjust( name, delay, reps, func, ... )
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
		
		return curtimer
	end
end

------------------------------------------------------
-- timer.Start
-- Starts a timer.
-- Returns true if successful, else false.
------------------------------------------------------
function Start( name )
	if Exists( name ) then
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

------------------------------------------------------
-- timer.Pause
-- Pauses a timer. The timer's remaining delay time will be paused as well.
-- Returns true if successful, else false.
------------------------------------------------------
function Pause( name )
	if Exists( name ) then
		local curtimer = timers[timers_lookup[name]]
		curtimer.difference = curtimer.stoptime - curtimer.starttime -- Save the time difference
		curtimer.running = false
		return true
	end
	return false
end

------------------------------------------------------
-- timer.Remove
-- Removes the timer specified
-- Returns true if successful, else false.
------------------------------------------------------
function Remove( name )
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

------------------------------------------------------
-- timer.Get
-- Returns the timer specified. If no timer is specified, returns all timers.
------------------------------------------------------
function Get( name )
	if Exists( name ) then
		return timers[timers_lookup[name]]
	else
		return timers
	end
end

------------------------------------------------------
-- timer.Exists
-- Returns true if the specified timer exists, else false
------------------------------------------------------
function Exists( name )
	return (name and timers_lookup[name])
end

------------------------------------------------------
-- Check
-- Triggers the timers.
------------------------------------------------------
local function Check()
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
					Remove( curtimer.name )
				else -- it's a simple timer
					table_remove( timers, i )
				end
			end
		end
	end
end
hook.Add( "Think", "timer think", Check )

------------------------------------------------------
-- Store in global table
------------------------------------------------------
timerx.Create = Create
timerx.Simple = Simple
timerx.Adjust = Adjust
timerx.Start  = Start
timerx.Pause  = Pause
timerx.Remove = Remove
timerx.Get    = Get
timerx.Exists = Exists
