---------------------------------------------------------------------
-- SF Instance class.
-- Contains the compiled SF script and essential data. Essentially
-- the execution context.
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
-- @return A table of values that the hook returned
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
	
	local args = {...}
	local traceback
	local wrapperfunc = function()
		return {func(unpack(args))}
	end
	local function xpcall_callback(err)
		traceback = debug.traceback(err, 2)
		return err
	end
	
	debug.sethook(ophook,"",500)
	local ok, rt = xpcall(wrapperfunc, xpcall_callback)
	debug.sethook(nil)
	
	--MsgN("SF: Exectued "..(self.ops-beginops).." instructions in "..(SysTime()-begin).." seconds")
	
	if ok then
		return true, rt
	else
		return false, rt, traceback
	end
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
-- @return The error traceback, if applicable
function SF.Instance:initialize()
	assert(not self.initialized, "Already initialized!")
	self.initialized = true
	self:runLibraryHook("initialize")
	self:prepare("_initialize","_initialize")
	
	local func = self.scripts[self.mainfile]
	local ok, err, traceback = self:runWithOps(func)
	if not ok then
		self:cleanup("_initialize", true, err, traceback)
		self.error = true
		return false, err, traceback
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
	for ok,err,traceback in self:iterTblScriptHook(hook,...) do
		if not ok then return false,err,traceback end
	end
	return true
end

--- Runs a script hook until one of them returns a true value. Returns those values.
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return True if it executed ok, false if not or if there was no hook
-- @return If the first return value is false then the error message or nil if no hook was registered. Else any values that the hook returned.
-- @return The traceback if the instance errored
function SF.Instance:runScriptHookForResult(hook,...)
	for ok,tbl,traceback in self:iterTblScriptHook(hook,...) do
		if not ok then return false, tbl, traceback
		elseif tbl and tbl[1] then
			return true, unpack(tbl)
		end
	end
	return true
end

-- Some small efficiency thing
local noop = function() end

--- Creates an iterator that calls each registered function for a hook.
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return An iterator function returning the ok status, and then either the hook
-- results or the error message and traceback
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
		
		local ok, tbl, traceback = self:runWithOps(func,unpack(args))
		if not ok then
			self:cleanup(hook,name,true,tbl,traceback)
			self.error = true
			return false, tbl, traceback
		end
		
		self:cleanup(hook,name,false)
		return true, unpack(tbl)
	end
end

--- Like SF.Instance:iterSciptHook, except that it doesn't unpack the hook results.
-- @param ... Arguments to pass to the hook's registered function.
-- @return An iterator function returning the ok status, then either the table of
-- hook results or the error message and traceback
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
		
		local ok, tbl, traceback = self:runWithOps(func,unpack(args))
		if not ok then
			self:cleanup(hook,name,true,tbl,traceback)
			self.error = true
			return false, tbl, traceback
		end
		
		self:cleanup(hook,name,false)
		return true, tbl
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
	
	local ok, tbl, traceback = self:runWithOps(func,...)
	if not ok then
		self:cleanup("_runFunction",func,true,tbl,traceback)
		self.error = true
		return false, tbl, traceback
	end
	
	self:cleanup("_runFunction",func,false)
	return true, unpack(tbl)
end

--- Resets the amount of operations used.
function SF.Instance:resetOps()
	self:runLibraryHook("resetOps")
	self.ops = 0
end

--- Deinitializes the instance. After this, the instance should be discarded.
function SF.Instance:deinitialize()
	self:runLibraryHook("deinitialize")
	SF.allInstances[self] = nil
	self.error = true
end
