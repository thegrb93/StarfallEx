---------------------------------------------------------------------
-- SF Global Library management
-- @author Colonel Thirty Two
---------------------------------------------------------------------

SF.Libraries = {}

SF.Libraries.libraries = {}
SF.Libraries.hooks = {}

--- Place to store local libraries
-- @name SF.Libraries.Local
-- @class table
SF.Libraries.Local = {}

--- Registers a global library. The library will be accessible from any Starfall Instance, regardless of context.
-- This will automatically set __index and __metatable if none exist.
-- @param name The library name
-- @param lib The table containing the library functions.
function SF.Libraries.Register(name, lib)
	SF.Typedef("Library: "..name,lib)
	SF.Libraries.libraries[name] = lib
end

--- Registers a local library. The library must be added to the context's
-- local libraries field.
function SF.Libraries.RegisterLocal(name, lib)
	SF.Typedef("Library: "..name,lib)
	SF.Libraries.Local[name] = lib
end

--- Gets a global library by name
-- @param name The name of the library
-- @return A metatable proxy of the library
function SF.Libraries.Get(name)
	return SF.Libraries.libraries[name] and setmetatable({},SF.Libraries.libraries[name])
end

--- Gets a local library by name
-- @param name The name of the library
-- @return The library (not a metatable proxy!)
function SF.Libraries.GetLocal(name)
	return SF.Libraries.Local[name]
end

--- Creates a table for use in SF.CreateContext containing all of the
-- local libraries in arr.
-- @param arr Array of local libraries to load
function SF.Libraries.CreateLocalTbl(arr)
	local tbl = {}
	for i=1,#arr do
		local lib = arr[i]
		tbl[lib] = SF.Libraries.Local[lib] or error(string.format("Requested nonexistant library '%s'",lib),2)
	end
	return tbl
end

--- Registers a library hook. These hooks are only available to SF libraries,
-- and are called by Libraries.RunHook.
-- @param hookname The name of the hook.
-- @param func The function to call
function SF.Libraries.AddHook(hookname, func)
	local hook = SF.Libraries.hooks[hookname]
	if not hook then
		hook = {}
		SF.Libraries.hooks[hookname] = hook
	end
	
	hook[#hook+1] = func
end

--- Calls a library hook.
-- @param hookname The name of the hook.
-- @param ... The arguments to the functions that are called.
function SF.Libraries.CallHook(hookname, ...)
	local hook = SF.Libraries.hooks[hookname]
	if not hook then return end
	
	for i=1,#hook do
		hook[i](...)
	end
end
