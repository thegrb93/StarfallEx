
--------------------------- Variables ---------------------------

SF_Compiler = {}
SF_Compiler.indexReplacements = {} -- Stores tables:function pairs that we need to replace __index with
SF_Compiler.indexOriginals = {}
SF_Compiler.hooks = {}
SF_Compiler.modules = {}

SF_Compiler.hardQuota = CreateConVar("starfall_hardquota", "20000", {FCVAR_ARCHIVE,FCVAR_REPLICATED})

local env_table = {}
SF_Compiler.env_table = env_table
env_table.__index = env_table

--------------------------- Local Functions ---------------------------

-- debug.gethook() returns the string "external hook" instead of a function... |:/
-- (I think) it basically just errors after like 500,000 lines
local function infloop_detection_replacement()
	error("Infinite Loop Detected!",2)
end

--------------------------- Compiling ---------------------------

function SF_Compiler.CreateContext(ent, ply, includes, mainfile)
	local context = {}
	context.original = includes
	context.originalmain = mainfile
	context.environment = setmetatable({},env_table)
	context.ent = ent
	context.ply = ply
	context.data = {}
	return context
end

function SF_Compiler.Compile(ent)
	local context = ent.context
	local includes = context.original
	local mainfile = context.originalmain
	local loaded = {}
	local ops = 0

	local function recursiveLoad(path)
		if loaded[path] then return end
		loaded[path] = true
		for _,nextpath in ipairs(includes[path].includes) do
			recursiveLoad(nextpath)
		end
		
		local func = CompileString(includes[path].code, "SF:"..path, false)
		if type(func) == "string" then
			error(path..": "..func, 0)
		end
		
		local ok, aops, msg = SF_Compiler.RunStarfallFunction(context, debug.setfenv(func,context.environment), ops)
		if not ok then error(msg,0) end
		ops = ops + aops
	end
	
	local ok, msg = pcall(recursiveLoad, mainfile)
	return ok, msg
end

--------------------------- Execution ---------------------------

-- Runs a function inside of a Starfall context.
-- Throws an error if you try to run this inside of func.
-- Returns (ok, ops used,s msg or whatever func returns)
function SF_Compiler.RunStarfallFunction(context, func, ops, ...)
	if SF_Compiler.currentChip ~= nil then
		error("Tried to execute multiple SF processors simultaneously, or RunStarfallFunction did not clean up properly", 0)
	end
	
	SF_Compiler.currentChip = context
	
	for lib, func in pairs(SF_Compiler.indexReplacements) do
		lib.__index = func
	end
	
	local ok, ops, rt = pcall(SF_Compiler.RunFuncWithOpsQuota, func, SF_Compiler.hardQuota:GetInt(), ops or 0, ...)
	
	for lib, func in pairs(SF_Compiler.indexOriginals) do
		lib.__index = func
	end
	
	SF_Compiler.currentChip = nil
	if not ok then return false, 0, ops end
	
	return true, ops, rt
end

-- Calls a function while counting the number of lines executed. Only counts lines that share
-- the same source file as the function called.
function SF_Compiler.RunFuncWithOpsQuota(func, max, start, ...)
	if not max then max = 1000000 end
	local used = 0
	
	local oldhookfunc, oldhookmask, oldhookcount = debug.gethook()
	
	-- TODO: Optimize
	local function SF_OpHook(event, lineno)
		if event ~= "line" then return end
		used = used + 10
		if used > max then
			debug.sethook(infloop_detection_replacement,oldhookmask)
			error("Ops quota exceeded",3)
		end
	end
	
	debug.sethook(SF_OpHook,"l",10)
	local rt = func(...)
	debug.sethook(infloop_detection_replacement,oldhookmask,oldhookcount)
	
	return used, rt
end

--------------------------- Modules ---------------------------
function SF_Compiler.AddModule(name,tbl)
	print("SF: Adding module "..name)
	if not tbl.__index then
		tbl.__index = tbl
	end
	tbl.__metatable = "Module"
	SF_Compiler.modules[name] = tbl
end

--------------------------- Hooks ---------------------------

function SF_Compiler.AddInternalHook(name, func)
	if not SF_Compiler.hooks[name] then SF_Compiler.hooks[name] = {} end
	SF_Compiler.hooks[name][func] = true
end

function SF_Compiler.RunInternalHook(name, ...)
	if not SF_Compiler.hooks[name] then return end
	for func,_ in pairs(SF_Compiler.hooks[name]) do
		func(...)
	end
end

function SF_Compiler.CallHook(name, context, ...)
	name = string.lower(name)
	if SF_Compiler.hooks[context] and SF_Compiler.hooks[context][name] then
		local ok, ops, rt = SF_Compiler.RunStarfallFunction(context, SF_Compiler.hooks[context][name], 0, ...)
		return ok, rt
	end
	return false, nil
end

--------------------------- Library Functions ---------------------------

-- Returns the type of an object, also checking the "type" index of a table
function SF_Compiler.GetType(obj)
	local typ = type(obj)
	if typ == "table" and type(getmetatable(obj)) == "string" then return getmetatable(obj)
	else return typ end
end

local dgetmetatable = debug.getmetatable

-- Checks the type of an object using SF_Compiler.GetType. Throws a formatted error on mismatch.
-- desired = a metatable or a a type() string (note that getmetatable("<any string>") ~= string)
-- level = amount of levels away from the library function (0 or nil = the library function, 1 = a function inside of that, etc.)
function SF_Compiler.CheckType(obj, desired, level)
	if type(obj) == desired then return obj
	elseif dgetmetatable(obj) == desired then return obj
	else
		level = level or 0
		
		local typname
		if type(desired) == "table" then
			typname = desired.type or "table"
		else
			typname = type(desired)
		end
		
		local funcname = debug.getinfo(2+level, "n").name or "<unnamed>"
		error("Type mismatch (Expected "..typname..", got "..SF_Compiler.GetType(typ)..") in function "..funcname,3+level)
	end
end

-- Throws an error due to type mismatch. Exported because some functions take multiple types
function SF_Compiler.ThrowTypeError(obj, desired, level)
	level = level or 0
	local funcname = debug.getinfo(2+level, "n").name or "<unnamed>"
	error("Type mismatch (Expected "..desired..", got "..SF_Compiler.GetType(obj)..") in function "..funcname,3+level)
end


--------------------------- Misc ---------------------------

function SF_Compiler.ReloadLibraries()
	print("SF: Loading libraries...")
	SF_Compiler.modules = {}
	SF_Compiler.hooks = {}
	do
		local l = file.FindInLua("starfall/sflibs/*.lua")
		for _,filename in pairs(l) do
			if string.sub(filename,-7,-1) == "_cl.lua" then
				MsgN("SF: Adding sflibs/"..filename.." to Clientside list")
				AddCSLuaFile(filename)
			else
				MsgN("SF: Including sflibs/"..filename)
				include("sflibs/"..filename)
			end
		end
	end
	print("SF: End loading libraries")
	SF_Compiler.RunInternalHook("postload")
end
--concommand.Add("sf_reload_libraries",SF_Compiler.ReloadLibraries,nil,"Reloads starfall libraries")
SF_Compiler.ReloadLibraries()