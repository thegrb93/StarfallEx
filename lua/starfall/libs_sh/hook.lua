-------------------------------------------------------------------------------
-- Hook library
-------------------------------------------------------------------------------

local hook = hook

--- Deals with hooks
-- @shared
local hook_library, _ = SF.Libraries.Register("hook")

--- Sets a hook function
function hook_library.add(hookname, name, func)
	SF.CheckType(hookname,"string")
	SF.CheckType(name,"string")
	if func then SF.CheckType(func,"function") else return end
	
	local inst = SF.instance
	local hooks = inst.hooks[hookname:lower()]
	if not hooks then
		hooks = {}
		inst.hooks[hookname:lower()] = hooks
	end
	
	hooks[name] = func
end

--- Run a hook
-- @shared
-- @param hookname The hook name
-- @param ... arguments
function hook_library.run(hookname, ...)
	SF.CheckType(hookname,"string")
	
	local instance = SF.instance
	local lower = hookname:lower()
	if instance.hooks[lower] then
		for k,v in pairs( instance.hooks[lower] ) do
			local ok, tbl = instance:runFunction( v )
			if not ok and instance.runOnError then
				instance.runOnError( tbl[1] )
				hook_library.remove( hookname, k )
			elseif next(tbl) ~= nil then
				return unpack( tbl )
			end
		end		
	end
end

--- Remove a hook
-- @shared
-- @param hookname The hook name
-- @param name The unique name for this hook
function hook_library.remove( hookname, name )
	SF.CheckType(hookname,"string")
	SF.CheckType(name,"string")
	local instance = SF.instance
	
	local lower = hookname:lower()
	if instance.hooks[lower] then
		instance.hooks[lower][name] = nil
	end
end
