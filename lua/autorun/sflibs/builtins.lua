
--------------------------- Base ---------------------------
SF_Compiler.AddFunction("Vector",Vector)
SF_Compiler.AddFunction("Angle",Angle)
SF_Compiler.AddFunction("math",math)
SF_Compiler.AddFunction("string",string)
SF_Compiler.AddFunction("tostring",tostring)
SF_Compiler.AddFunction("ipairs",ipairs)
SF_Compiler.AddFunction("pairs",pairs)

--------------------------- Modules ---------------------------

SF_Compiler.AddFunction("loadModule", function(name)
	if type(name) ~= "string" then error("Invalid arguments to loadModule",2) end
	local mod = setmetatable({},SF_Compiler.modules[name])
	--if mod.__initialize then mod.__initialize(SF_Compiler.currentChip) end
	return mod
end)

--------------------------- Hooks ---------------------------

SF_Compiler.AddFunction("hook", function(name, func)
	if name == nil or type(name) ~= "string" or not (func == nil or type(func) == "function") then error("Illegal arguments to hook()",2) end
	
	local hooks = SF_Compiler.hooks
	local context = SF_Compiler.currentChip
	if not hooks[context] then hooks[context] = {} end
	hooks[context][name] = func
end)

SF_Compiler.AddFunction("unhook", function(name)
	if name == nil or type(name) ~= "string" then error("Illegal arguments to hook()",2) end
	
	local hooks = SF_Compiler.hooks
	local context = SF_Compiler.currentChip
	if not hooks[context] then return end
	hooks[context][name] = nil
end)

--------------------------- Output ---------------------------

SF_Compiler.AddFunction("print",function(msg)
	nmsg = tostring(msg)
	if type(nmsg) ~= "string" then error(type(msg).."-typed message passed to print() (no tostring available)",2) end
	
	SF_Compiler.currentChip.ply:PrintMessage(HUD_PRINTTALK, nmsg)
end)

local clamp = math.Clamp
SF_Compiler.AddFunction("notify",function(msg, duration)
	if msg == nil or type(msg) ~= "string" or
		duration == nil or type(duration) ~= "number" then error("notify() called with illegal arguments.") end
	WireLib.AddNotify(SF_Compiler.currentChip.ply,msg,NOTIFY_GENERIC,clamp(duration,0.7,7),NOTIFYSOUND_DRIP1)
end)