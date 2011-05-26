
local mtime = {}
SF_Compiler.AddModule("time",mtime)

-- ------------------------------------------- --
-- Time                                        --
-- ------------------------------------------- --

function mtime.currTime()
	return CurTime()
end

function mtime.realTime()
	return RealTime()
end

function mtime.sysTime()
	return SysTime()
end

-- ------------------------------------------- --
-- Timers                                      --
-- ------------------------------------------- --

local function timercb(ent, tname, realname)
	if ent and ent:IsValid() then
		ent:RunHook("Timer",tname)
	else
		timer.Destroy(realname)
	end
end

local function mangle_timer_name(context, name)
	return "sftimer_"..context.ent:EntIndex().."_"..name
end

function mtime.timer(name, delay, reps)
	if type(name) ~= "string" then error("Non-string timer name",2) end
	if type(delay) ~= "number" then error("Non-number timer delay",2) end
	if reps == nil then reps = 0
	elseif type(reps) ~= "number" then error("Non-number timer repititions",2) end
	
	local context = SF_Compiler.currentChip
	local timername = mangle_timer_name(context,name)
	
	if timer.IsTimer(timername) then
		timer.Adjust(timername, delay, reps)
	else
		timer.Create(timername, delay, reps, timercb, context.ent, name, timername)
		timer.Start(timername)
		context.data.timers[name] = true
	end
end

function mtime.destroyTimer(name)
	if type(name) ~= "string" then error("Non-string timer name",2) end
	local context = SF_Compiler.currentChip
	local timername = mangle_timer_name(context,name)
	
	if timer.IsTimer(timername) then timer.Destroy(timername) end
	context.data.timers[name] = nil
end

local function init(chip)
	chip.data.timers = {}
end

local function deinit(chip, ok, errmsg)
	if chip.data.timers ~= nil then
		for name,_ in pairs(chip.data.timers) do
			local realname = mangle_timer_name(chip,name)
			timer.Destroy(realname)
		end
	end
	chip.data.timers = nil
end

SF_Compiler.AddInternalHook("init",init)
SF_Compiler.AddInternalHook("deinit",deinit)