---------------------------------------------------------------------
-- SF Global Library management
---------------------------------------------------------------------

SF.Libraries = {}

SF.Libraries.libraries = {}
SF.Libraries.hooks = {}

--- Creates and registers a global library. The library will be accessible from any Starfall Instance, regardless of context.
-- This will automatically set __index and __metatable.
-- @param name The library name
function SF.Libraries.Register ( name )
	local methods, metamethods = SF.Typedef( "Library: " .. name )
	SF.Libraries.libraries[ name ] = metamethods
	SF.DefaultEnvironment[ name ] = setmetatable( {}, metamethods )
	return methods, metamethods
end

--- Gets a global library by name
-- @param name The name of the library
-- @return A metatable proxy of the library
function SF.Libraries.Get(name)
	return SF.Libraries.libraries[name] and setmetatable({},SF.Libraries.libraries[name])
end

--- Registers a library hook. These hooks are only available to SF libraries,
-- and are called by Libraries.CallHook.
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
