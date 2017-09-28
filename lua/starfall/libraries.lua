---------------------------------------------------------------------
-- SF Global Library management
---------------------------------------------------------------------

SF.Libraries = {}

SF.Libraries.libraries = {}
SF.Libraries.hooks = {}

--- Creates and registers a global library. The library will be accessible from any Starfall Instance, regardless of context.
-- This will automatically set __index and __metatable.
-- @param name The library name
function SF.Libraries.Register(name)
	local methods = {}
	SF.Libraries.libraries[name] = methods
	return methods
end

--- Builds an environment table
-- @return The environment
function SF.Libraries.BuildEnvironment()
	local function deepCopy(src, dst, done)
		if done[src] then return end
		done[src] = true

		-- Copy the values
		for k, v in pairs(src) do
			if type(v)=="table" then
				local t = {}
				deepCopy(v, t, done)
				dst[k] = t
			else
				dst[k] = v
			end
		end

		-- Copy the metatable
		local meta = debug.getmetatable(src)
		if meta then
			local t = {}
			for k, v in pairs(meta) do
				t[k] = v
			end
			setmetatable(dst, t)
		end

		done[src] = nil
	end

	local env = {}
	deepCopy(SF.DefaultEnvironment, env, {})

	for k, v in pairs(SF.Libraries.libraries) do
		local t = {}
		deepCopy(v, t, {})
		env[k] = t
	end
	return env
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

	hook[#hook + 1] = func
end

--- Calls a library hook.
-- @param hookname The name of the hook.
-- @param ... The arguments to the functions that are called.
function SF.Libraries.CallHook(hookname, ...)
	local hook = SF.Libraries.hooks[hookname]
	if not hook then return end

	for i = 1, #hook do
		hook[i](...)
	end
end
