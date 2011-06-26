
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
	SF_Compiler.CheckType(name,"string")
	SF_Compiler.CheckType(delay,"number")
	if reps ~= nil then SF_Compiler.CheckType(reps,"number") end
	
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
	SF_Compiler.CheckType(name,"string")
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