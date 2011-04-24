--[[

Starfall Context Structure:
{
	softQuotaUsed   (num) Soft quota used
	original        (str) Source code
	environment     (tbl) Variables, functions
	func            (fn)  The compiled script
	ent             (ent) The SF entity
	data            (tbl) Data used by modules
	ply             (ent) Person who owns the chip
}

SF_Compiler variables:
{
	softQuota       (convar) Amount of ops before the overflow is added into the soft quota
	hardQuota       (convar) Amount of ops to be used in a single execution before the processor shuts down
	softQuotaAmount (convar) Total quota for the soft quota

	envTable        (tbl) Metatable for context.environment
	currentChip     (tbl) Context of the chip currently running, or nil if no chip is running
}

]]

local min = math.min

SF_Compiler = SF_Compiler or {}

--SF_Compiler.softQuota = CreateConVar("starfall_quota", "10000", {FCVAR_ARCHIVE,FCVAR_REPLICATED})
SF_Compiler.hardQuota = CreateConVar("starfall_hardquota", "20000", {FCVAR_ARCHIVE,FCVAR_REPLICATED})
--SF_Compiler.softQuotaAmount = CreateConVar("starfall_softquota", "10000", {FCVAR_ARCHIVE,FCVAR_REPLICATED})

local env_table = {}
SF_Compiler.envTable = env_table
env_table.__index = env_table
--[[env_table.__index = function(self, index)
	if index == "___sf_private" and debug.getinfo(2,"s").source == "Starfall" then
		error("Script tried to access protected variable ___sf_private.",0)
	end
	return rawget(self,index) or env_table[index]
end]]

-- Runs a function inside of a Starfall context.
-- Throws an error if you try to run this inside of func.
-- Returns (ok, msg or whatever func returns)
function SF_Compiler.RunStarfallFunction(context, func, ...)
	if SF_Compiler.currentChip ~= nil then
		error("Tried to execute multiple SF processors, or RunStarfallFunction did not clean up properly", 0)
	end
	SF_Compiler.currentChip = context
	local ok, ops, rt = pcall(SF_Compiler.RunFuncWithOpsQuota, func,
		--min(SF_Compiler.hardQuota:GetInt(), SF_Compiler.softQuota:GetInt() + SF_Compiler.softQuotaAmount:GetInt() - context.softQuotaUsed), ...)
		SF_Compiler.hardQuota:GetInt(), ...)
	--local ok, rt = pcall(func, ...)
	--local ops = 0
	SF_Compiler.currentChip = nil
	if not ok then return false, ops end
	
	--local softops = ops - SF_Compiler.softQuota:GetInt()
	--if softops > 0 then context.softQuotaUsed = context.softQuotaUsed + softops end
	return true, rt
end

-- Calls a function while counting the number of lines executed. Only counts lines that share
-- the same source file as the function called.
function SF_Compiler.RunFuncWithOpsQuota(func, max, ...)
	if max == nil then max = 1000000 end
	local used = 0
	
	local source = debug.getinfo(func,"S").source
	
	local function SF_OpHook(event, lineno)
		if event ~= "line" then return end
		if debug.getinfo(2,"S").source ~= source then return end
		used = used + 1
		if used > max then
			debug.sethook(nil)
			error("Ops quota exceeded",3)
		end
	end
	
	debug.sethook(SF_OpHook,"l")
	local rt = func(...)
	debug.sethook(nil)
	
	return used, rt
end

function SF_Compiler.AddFunction(name, func)
	SF_Compiler.envTable[name] = func
end

function SF_Compiler.Compile(code, ply, ent)
	local sf = {}
	sf.softQuotaUsed = 0
	sf.original = code
	sf.environment = {}
	sf.ent = ent
	sf.ply = ply
	sf.data = {}
	
	func = CompileString(code, "Starfall")
	if func == nil or type(func) == "string" then
		return false, "Unknown Error (Probably syntax)"
	end
	sf.func = func
	
	SF_Compiler.Reset(sf)
	return true, sf
end

function SF_Compiler.Reset(sf)
	sf.environment = setmetatable({},env_table)
	debug.setfenv(sf.func,sf.environment)
end

SF_Compiler.modules = {}
function SF_Compiler.AddModule(name,tbl)
	print("SF: Adding module "..name)
	SF_Compiler.modules[name] = tbl
end

SF_Compiler.hooks = {}
function SF_Compiler.CallHook(name, context, ...)
	if SF_Compiler.hooks[context] and SF_Compiler.hooks[context][name] then
		return SF_Compiler.RunStarfallFunction(context, SF_Compiler.hooks[context][name], ...)
	end
	return nil
end

function SF_Compiler.ReloadLibraries()
	print("SF: Loading libraries...")
	do
		local list = file.FindInLua("autorun/sflibs/*.lua")
		for _,filename in pairs(list) do
			print("SF: Including sflibs/"..filename)
			include("sflibs/"..filename)
		end
	end
	print("SF: End loading libraries")
end
--concommand.Add("sf_reload_libraries",SF_Compiler.ReloadLibraries,nil,"Reloads starfall libraries")
SF_Compiler.ReloadLibraries()