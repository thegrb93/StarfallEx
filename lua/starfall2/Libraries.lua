---------------------------------------------------------------------
-- SF Global Library management
-- @author Colonel Thirty Two
---------------------------------------------------------------------

SF.Libraries = {}

SF.Libraries.libraries = {}
SF.Libraries.hooks = {}

--- Registers a global library. The library will be accessible from any Starfall Instance, regardless of context.
-- This will automatically set __index and __metatable.
-- @param name The library name
-- @param lib The table containing the library functions.
function SF.Libraries.Register(name, lib)
	SF.Typedef("Library: "..name,lib)
	SF.Libraries.libraries[name] = lib
end

--- Gets a global library by name
-- @param name The name of the library
-- @return A metatable proxy of the library
function SF.Libraries.Get(name)
	if not SF.Libraries.libraries[name] then return nil end
	return setmetatable({},SF.Libraries.libraries[name])
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
