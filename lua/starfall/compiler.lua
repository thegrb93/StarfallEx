---------------------------------------------------------------------
-- SF Compiler.
-- Compiles code into an uninitialized Instance.
---------------------------------------------------------------------

SF.Compiler = {}

--- Preprocesses and Compiles code and returns an Instance
-- @param code Either a string of code, or a {path=source} table
-- @param context The context to use in the resulting Instance
-- @param mainfile If code is a table, this specifies the first file to parse.
-- @param player The "owner" of the instance
-- @param data The table to set instance.data to. Default is a new table.
-- @param dontpreprocess Set to true to skip preprocessing
-- @return True if no errors, false if errors occured.
-- @return The compiled instance, or the error message.
function SF.Compiler.Compile(code, context, mainfile, player, data, dontpreprocess)
	if type(code) == "string" then
		mainfile = mainfile or "generic"
		code = {mainfile=code}
	end
	
	local instance = setmetatable({},SF.Instance)
	
	data = data or {}
	
	instance.player = player
	instance.env = setmetatable({},context.env)
	instance.env._G = instance.env
	instance.data = data
	instance.ppdata = {}
	instance.ops = 0
	instance.hooks = {}
	instance.scripts = {}
	instance.source = code
	instance.initialized = false
	instance.context = context
	instance.mainfile = mainfile

	-- Add local libraries
	for k, v in pairs( context.libs ) do instance.env[ k ] = setmetatable( {}, v ) end

	-- Call onLoad functions
	for k, v in pairs( context.env.__index ) do
		if type( v ) == "table" then
			local meta = debug.getmetatable( v )
			if meta.onLoad then meta.onLoad( instance ) end
		end
	end
	for k, v in pairs( context.libs ) do
		if type( v ) == "table" then
			if v.onLoad then v.onLoad( instance ) end
		end
	end
	
	for filename, source in pairs(code) do
		if not dontpreprocess then
			SF.Preprocessor.ParseDirectives( filename, source, context.directives, instance.ppdata, instance )
		else
			print( "No preprocess" )
		end
		
		if string.match(source, "^[%s\n]*$") then
			-- Lua doesn't have empty statements, so an empty file gives a syntax error
			instance.scripts[filename] = function() end
		else
			local func = CompileString(source, "SF:"..filename, false)
			if type(func) == "string" then
				return false, func
			end
			debug.setfenv(func, instance.env)
			instance.scripts[filename] = func
		end
	end
	
	return true, instance
end
