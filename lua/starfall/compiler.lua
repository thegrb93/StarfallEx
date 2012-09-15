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
	instance.permissions = setmetatable({},context.permissions)
	
	local loaded = {}

	local function recursiveLoad(path)
		if loaded[path] then return end
		loaded[path] = true
		
		if not dontpreprocess then
			SF.Preprocessor.ParseDirectives(path,code[path],context.directives,instance.ppdata)
		end
		
		if instance.ppdata.includes and instance.ppdata.includes[path] then
			local inc = instance.ppdata.includes[path]
			for i=1,#inc do
				recursiveLoad(inc[i])
			end
		end
		
		if code[path] == "" then
			-- Passing an empty string to CompileString returns an error because Lua does not have empty statements (at least in 5.1)
			error(path..": No code.",0)
		end
		
		local func = CompileString(code[path], "SF:"..path, false)
		if type(func) == "string" then
			error(path..": "..func, 0)
		end
		debug.setfenv(func,instance.env)
		
		instance.scripts[#instance.scripts+1] = func
	end
	
	local ok, msg = pcall(recursiveLoad, mainfile)
	if ok then
		instance.permissions:assign(instance)
		return true, instance
	else return false, msg end
end
