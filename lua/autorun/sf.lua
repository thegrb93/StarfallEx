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

SF_Compiler.softQuota = CreateConVar("starfall_quota", "10000", {FCVAR_ARCHIVE,FCVAR_REPLICATED})
SF_Compiler.hardQuota = CreateConVar("starfall_hardquota", "20000", {FCVAR_ARCHIVE,FCVAR_REPLICATED})
SF_Compiler.softQuotaAmount = CreateConVar("starfall_softquota", "10000", {FCVAR_ARCHIVE,FCVAR_REPLICATED})

local env_table = {}
SF_Compiler.envTable = env_table
env_table.__index = function(self, index)
	if index == "___sf_private" and debug.getinfo(2,"s").source == "Starfall" then
		error("Script tried to access protected variable ___sf_private.",0)
	end
	return rawget(self,index) or env_table[index]
end


SF_Compiler.envTable.print = print


-- Runs a function inside of a Starfall context.
-- Throws an error if you try to run this inside of func.
-- Returns (ok, msg or whatever func returns)
function SF_Compiler.RunStarfallFunction(context, func, ...)
	if SF_Compiler.currentChip ~= nil then
		error("Tried to execute multiple SF processors, or RunStarfallFunction did not clean up properly", 0)
	end
	SF_Compiler.currentChip = context
	--local ok, ops, rt = pcall(SF_Compiler.RunFuncWithOpsQuota, func,
	--	min(SF_Compiler.hardQuota:GetInt(), SF_Compiler.softQuota:GetInt() + SF_Compiler.softQuotaAmount:GetInt() - context.softQuotaUsed), ...)
	local ok, rt = pcall(func, ...)
	local ops = 0
	SF_Compiler.currentChip = nil
	if not ok then return ok, ops end
	
	local softops = ops - SF_Compiler.softQuota:GetInt()
	if softops > 0 then context.softQuotaUsed = context.softQuotaUsed + softops end
	return ok, rt
end

-- Calls a function while counting the number of lines executed. Only counts lines that share
-- the same source file as the function called.
function SF_Compiler.RunFuncWithOpsQuota(func, max, ...)
	if max == nil then max = 1000000 end
	local used = 0
	
	local source = debug.getinfo(func,"s").source
	
	local function SF_OpHook(event, lineno)
		if event ~= "line" then return end
		if debug.getinfo(2,"s").source ~= source then return end
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
		return false, "Unknown"
	end
	sf.func = func
	
	SF_Compiler.Reset(sf)
	return true, sf
end

function SF_Compiler.Reset(sf)
	sf.environment = setmetatable({},env_table)
	debug.setfenv(sf.func,sf.environment)
end