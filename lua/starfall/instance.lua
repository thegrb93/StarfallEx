---------------------------------------------------------------------
-- SF Instance class
-- @author Colonel Thirty Two
---------------------------------------------------------------------

SF.Instance = {}
SF.Instance.__index = SF.Instance

--- Instance fields
-- @name Instance
-- @class table
-- @field env Environment table for the script
-- @field data Data that libraries can store.
-- @field ppdata Preprocessor data
-- @field ops Currently used ops.
-- @field hooks Registered hooks
-- @field scripts The compiled script functions.
-- @field initialized True if initialized, nil if not.
-- @field permissions Permissions manager
-- @field error True if instance is errored and should not be executed
-- @field mainfile The main file
-- @field player The "owner" of the instance

-- debug.gethook() returns the string "external hook" instead of a function... |:/
-- (I think) it basically just errors after 500000000 lines
local function infloop_detection_replacement()
	error("Infinite Loop Detected!",2)
end

--- Internal function - do not call.
-- Runs a function while incrementing the instance ops coutner.
-- This does no setup work and shouldn't be called by client code
-- @param func The function to run
-- @param ... Arguments to func
-- @return True if ok
-- @return Any values func returned
function SF.Instance:runWithOps(func,...)
	local maxops = self.context.ops
	
	local function ophook(event)
		self.ops = self.ops + 500
		if self.ops > maxops then
			debug.sethook(nil)
			error("Operations quota exceeded.",0)
		end
	end
	
	--local begin = SysTime()
	--local beginops = self.ops
	
	debug.sethook(ophook,"",500)
	local rt = {pcall(func, ...)}
	debug.sethook(infloop_detection_replacement,"",500000000)
	
	--MsgN("SF: Exectued "..(self.ops-beginops).." instructions in "..(SysTime()-begin).." seconds")
	
	return unpack(rt)
end

--- Internal function - Do not call. Prepares the script to be executed.
-- This is done automatically by Initialize and RunScriptHook.
function SF.Instance:prepare(hook, name)
	assert(self.initialized, "Instance not initialized!")
	assert(not self.error, "Instance is errored!")
	assert(SF.instance == nil)
	
	self:runLibraryHook("prepare",hook, name)
	SF.instance = self
end

--- Internal function - Do not call. Cleans up the script.
-- This is done automatically by Initialize and RunScriptHook.
function SF.Instance:cleanup(hook, name, ok, errmsg)
	assert(SF.instance == self)
	self:runLibraryHook("cleanup",hook, name, ok, errmsg)
	SF.instance = nil
end

--- Runs the scripts inside of the instance. This should be called once after
-- compiling/unpacking so that scripts can register hooks and such. It should
-- not be called more than once.
-- @return True if no script errors occured
-- @return The error message, if applicable
function SF.Instance:initialize()
	assert(not self.initialized, "Already initialized!")
	self.initialized = true
	self:runLibraryHook("initialize")
	self:prepare("_initialize","_initialize")
	
	for i=1,#self.scripts do
		local func = self.scripts[i]
		local ok, err = self:runWithOps(func)
		if not ok then
			self:cleanup("_initialize", true, err)
			self.error = true
			return false, err
		end
	end
	
	SF.allInstances[self] = self
	
	self:cleanup("_initialize","_initialize",false)
	return true
end

--- Runs a script hook. This calls script code.
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return True if it executed ok, false if not or if there was no hook
-- @return If the first return value is false then the error message or nil if no hook was registered
function SF.Instance:runScriptHook(hook, ...)
	for tbl in self:iterTblScriptHook(hook,...) do
		if not tbl[1] then return false, tbl[2] end
	end
	return true
end

--- Runs a script hook until one of them returns a true value. Returns those values.
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return True if it executed ok, false if not or if there was no hook
-- @return If the first return value is false then the error message or nil if no hook was registered. Else any values that the hook returned.
function SF.Instance:runScriptHookForResult(hook,...)
	for tbl in self:iterTblScriptHook(hook,...) do
		if not tbl[1] then return false, tbl[2]
		elseif tbl[2] then
			return unpack(tbl)
		end
	end
	return true
end

-- Some small efficiency thing
local noop = function() end

--- Creates an iterator that calls each registered function for a hook
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return An iterator function returning pcall-like results for each registered function.
function SF.Instance:iterScriptHook(hook,...)
	local hooks = self.hooks[hook:lower()]
	if not hooks then return noop end
	local index = nil
	local args = {...}
	return function()
		if self.error then return end
		local name, func = next(hooks,index)
		if not name then return end
		index = name
		
		self:prepare(hook,name)
		
		local results = {self:runWithOps(func,unpack(args))}
		if not results[1] then
			self:cleanup(hook,name,true,results[2])
			self.error = true
			return false, results[2]
		end
		
		self:cleanup(hook,name,false)
		
		return unpack(results)
	end
end

--- Like SF.Instance:iterSciptHook, except that it returns an array of pcall-like values instead of unpacking them
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return An iterator function returning a table of pcall-like results for each registered function.
function SF.Instance:iterTblScriptHook(hook,...)
	local hooks = self.hooks[hook:lower()]
	if not hooks then return noop end
	local index = nil
	local args = {...}
	return function()
		if self.error then return end
		local name, func = next(hooks,index)
		if not name then return end
		index = name
		
		self:prepare(hook,name)
		
		local results = {self:runWithOps(func,unpack(args))}
		if not results[1] then
			self:cleanup(hook,name,true,results[2])
			self.error = true
			return results
		end
		
		self:cleanup(hook,name,false)
		
		return results
	end
end

--- Runs a library hook. Alias to SF.Libraries.CallHook(hook, self, ...).
-- @param hook Hook to run.
-- @param ... Additional arguments.
function SF.Instance:runLibraryHook(hook, ...)
	return SF.Libraries.CallHook(hook,self,...)
end

--- Runs an arbitrary function under the SF instance. This can be used
-- to run your own hooks when using the integrated hook system doesn't
-- make sense (ex timers).
-- @param func Function to run
-- @param ... Arguments to pass to func
function SF.Instance:runFunction(func,...)
	self:prepare("_runFunction",func)
	
	local ok, err = self:runWithOps(func,...)
	if not ok then
		self:cleanup("_runFunction", true, err)
		self.error = true
		return false, err
	end
	
	self:cleanup("_runFunction",func,false)
	
	return true, err
end

--- Resets the amount of operations used.
function SF.Instance:resetOps()
	self:runLibraryHook("resetOps")
	self.ops = 0
end

--- Deinitializes the instance. After this, the instance should be discarded.
function SF.Instance:deinitialize()
	self:runLibraryHook("deinitialize")
	SF.allInstances[self] = self
	self.error = true
end

-- TODO: Serialization
