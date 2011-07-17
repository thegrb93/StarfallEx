
--------------------------- Lua Functions ---------------------------
SF_Compiler.env_table.Vector = Vector
SF_Compiler.env_table.Angle = Angle
SF_Compiler.env_table.math = setmetatable({},{__index=math,__newindex=function(k,v) end})
SF_Compiler.env_table.string = setmetatable({},{__index=string,__newindex=function(k,v) end})
SF_Compiler.env_table.tostring = tostring
SF_Compiler.env_table.ipairs = ipairs
SF_Compiler.env_table.pairs = pairs

SF_Compiler.env_table.setmetatable = function(obj, metatbl)
	SF_Compiler.CheckType(obj,"table")
	SF_Compiler.CheckType(metatbl,"table")
	if getmetatable(obj) then error("Object already has a metatable",2) end
	return setmetatable(obj,metatbl)
end

--------------------------- Modules ---------------------------

local function loadModule(name)
	if type(name) ~= "string" then error(type(name).."-typed name passed to loadModule",2) end
	if not SF_Permissions.CanLoadModule(name) then error("Cannot load library "..name..": Permission Denied",2) end
	local mod = setmetatable({},SF_Compiler.modules[name])
	return mod
end
SF_Compiler.env_table.loadModule = loadModule

--------------------------- Hooks ---------------------------

local function hook(name, func)
	SF_Compiler.CheckType(name,"string")
	SF_Compiler.CheckType(func,"function")
	
	local hooks = SF_Compiler.hooks
	local context = SF_Compiler.currentChip
	if not hooks[context] then hooks[context] = {} end
	hooks[context][name] = func
end
SF_Compiler.env_table.hook = hook

local function unhook(name)
	SF_Compiler.CheckType(name,"string")
	
	local hooks = SF_Compiler.hooks
	local context = SF_Compiler.currentChip
	if not hooks[context] then return end
	hooks[context][name] = nil
end
SF_Compiler.env_table.unhook = unhook

--------------------------- Output ---------------------------

local function print(msg)
	SF_Compiler.currentChip.ply:PrintMessage(HUD_PRINTTALK, tostring(msg))
end
SF_Compiler.env_table.print = print

local clamp = math.Clamp
local function notify(msg, duration)
	SF_Compiler.CheckType(msg,"string")
	if duration ~= nil then SF_Compiler.CheckType(duration,"number") end
	WireLib.AddNotify(SF_Compiler.currentChip.ply,msg,NOTIFY_GENERIC,clamp(duration or 5,0.7,7),NOTIFYSOUND_DRIP1)
end
SF_Compiler.env_table.notify = notify