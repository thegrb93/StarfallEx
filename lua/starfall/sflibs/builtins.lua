
local function createRefMtbl(target)
	local tbl = {}
	tbl.__index = target
	function tbl:__newindex(k,v) end
	tbl.__metatable = "Module"
	return tbl
end

--------------------------- Lua Functions ---------------------------
SF_Compiler.env_table.Vector = Vector
SF_Compiler.env_table.Angle = Angle
SF_Compiler.env_table.tostring = tostring
SF_Compiler.env_table.ipairs = ipairs
SF_Compiler.env_table.pairs = pairs
SF_Compiler.env_table.setmetatable = function(tbl, meta)
	SF_Compiler.CheckType(tbl,"table")
	SF_Compiler.CheckType(meta,"table") -- Prevent setmetatable(""), etc
	if debug.getmetatable(tbl).__metatable then error("cannot change a protected metatable",2) end
	return setmetatable(tbl,meta)
end
SF_Compiler.env_table.getmetatable = function(tbl)
	SF_Compiler.CheckType(tbl,"table") -- Prevent getmetatable(""), etc
	return getmetatable(tbl)
end
	

-- The below modules have the Gmod functions removed (the ones that begin with a capital letter),
-- as requested by Divran

-- Filters Gmod Lua files based on Garry's naming convention.
local function filterGmodLua(lib)
	local original, gm = {}, {}
	for name, func in pairs(lib) do
		local char = name:sub(1,1)
		if char:upper() == char then
			gm[name] = func
		else
			original[name] = func
		end
	end
	return original, gm
end

-- String library
local str_orig, str_gm = filterGmodLua(string)
local str_index_orig = getmetatable("").__index
SF_Compiler.env_table.string = setmetatable({},createRefMtbl(str_orig))
local function str_index_repl(self,k)
	if not str_gm[k] then return str_index_orig(self,k) end
end

SF_Compiler.indexReplacements[getmetatable("")] = str_index_repl
SF_Compiler.indexOriginals[getmetatable("")] = str_index_orig

-- Math library
local math_orig, math_gm = filterGmodLua(math)
math_orig.clamp = math.Clamp
math_orig.round = math.Round
math_orig.randfloat = math.Rand
math_orig.calcBSplineN = nil

SF_Compiler.env_table.math = setmetatable({},createRefMtbl(math_orig))

--------------------------- Modules ---------------------------

local function loadModule(name)
	SF_Compiler.CheckType(name,"string")
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