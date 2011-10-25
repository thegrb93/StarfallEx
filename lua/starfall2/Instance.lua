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
-- It counts in increments of 10. This does no setup work and shouldn't
-- be called by client code
-- @param func The function to run
-- @param ... Arguments to func
-- @return True if ok
-- @return Any values func returned
function SF.Instance:runWithOps(func,...)
	local maxops = self.context.ops
	
	local function ophook(event)
		--if event ~= "line" then return end
		self.ops = self.ops + 1
		if self.ops > maxops then
			maxops = 0/0 -- Prevent the hook from being triggered again outside of the pcall
			error("Ops quota exceeded.",0)
		end
	end
	
	--local begin = SysTime()
	--local beginops = self.ops
	
	debug.sethook(ophook,"",1)
	local rt = {pcall(func, ...)}
	--debug.sethook(infloop_detection_replacement,"",500000000) -- TODO: Fix this so that it doesn't break stuff. Is it the "l"?
	debug.sethook(nil)
	
	--MsgN("SF: Exectued "..(self.ops-beginops).." instructions in "..(SysTime()-begin).." seconds")
	
	return unpack(rt)
end

--- Internal function - Do not call. Prepares the script to be executed.
-- This is done automatically by Initialize and RunScriptHook.
function SF.Instance:prepare(hook)
	assert(self.initialized, "Instance not initialized!")
	assert(not self.error, "Instance is errored!")
	assert(not SF.instance)
	
	self:runLibraryHook("prepare",hook)
	SF.instance = self
end

--- Internal function - Do not call. Cleans up the script.
-- This is done automatically by Initialize and RunScriptHook.
function SF.Instance:cleanup(hook, ok, errmsg)
	assert(SF.instance == self)
	
	self:runLibraryHook("cleanup",hook, ok, errmsg)
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
	self:prepare("_initialize")
	
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
	
	self:cleanup("_intialize",false)
	return true
end

--- Runs a script hook. This calls script code.
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return True if it executed ok, false if not or if there was no hook
-- @return Either the function return values, the error message, or nil if no hook was registered
function SF.Instance:runScriptHook(hook, ...)
	hook = hook:lower()
	local hookfunc = self.hooks[hook]
	if not hookfunc then return false, nil end
	
	self:prepare(hook)
	
	local ok, err = self:runWithOps(hookfunc,...)
	if not ok then
		self:cleanup(hook, true, err)
		self.error = true
		return false, err
	end
	
	self:cleanup(hook,false)
	
	return true, err
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
	self:prepare("_runFunction")
	
	local ok, err = self:runWithOps(func,...)
	if not ok then
		self:cleanup("_runFunction", true, err)
		self.error = true
		return false, err
	end
	
	self:cleanup("_runFunction",false)
	
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
