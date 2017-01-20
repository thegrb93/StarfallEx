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
-- @field error True if instance is errored and should not be executed
-- @field mainfile The main file
-- @field player The "owner" of the instance

--- A set of all instances that have been created. It has weak keys and values.
-- Instances are put here after initialization.
SF.allInstances = setmetatable({},{__mode="kv"})

--- Internal function - do not call.
-- Runs a function while incrementing the instance ops coutner.
-- This does no setup work and shouldn't be called by client code
-- @param func The function to run
-- @param ... Arguments to func
-- @return True if ok
-- @return A table of values that the hook returned
function SF.Instance:runWithOps(func,...)
	local traceback
	local function xpcall_callback ( err )
		if type( err ) == "table" then
			if type( err.message ) == "string" then
				local line= err.line
				local file = err.file

				err = ( file and ( file .. ":" ) or "" ) .. ( line and ( line .. ": " ) or "" ) .. err.message
			end
		end
		err = tostring( err )
		traceback = debug.traceback( err, 2 )
		return err
	end

	local oldSysTime = SysTime() - self.cpu_total
	local function cpuCheck ()
		self.cpu_total = SysTime() - oldSysTime
		local usedRatio = self:movingCPUAverage()/self.context.cpuTime:getMax()
		if usedRatio>1 then
			debug.sethook( nil )
			SF.throw( "CPU Quota exceeded.", 0, true )
		elseif usedRatio > self.cpu_softquota then
			SF.throw( "CPU Quota warning.", 0 )
		end
	end
	
	local tbl = {xpcall( cpuCheck, xpcall_callback )}
	if tbl[1] then
		if self.instanceStack then
			--This prevents premature debug.sethook( nil )
			tbl = {xpcall( func, xpcall_callback, ... )}
		else
			debug.sethook( cpuCheck, "", 2000 )
			tbl = {xpcall( func, xpcall_callback, ... )}
			debug.sethook( nil )
		end
	end
	
	return tbl, traceback
end

--- Internal function - Do not call. Prepares the script to be executed.
-- This is done automatically by Initialize and runScriptHook.
function SF.Instance:prepare(hook)
	assert(self.initialized, "Instance not initialized!")
	--Functions calling this one will silently halt.
	if self.error then return true end
	
	if SF.instance ~= nil then
		self.instanceStack = self.instanceStack or {}
		self.instanceStack[#self.instanceStack + 1] = SF.instance
		SF.instance = nil
	end
	
	self:runLibraryHook("prepare",hook)
	SF.instance = self
end

--- Internal function - Do not call. Cleans up the script.
-- This is done automatically by Initialize and runScriptHook.
function SF.Instance:cleanup(hook, ok, errmsg)
	assert(SF.instance == self)
	self:runLibraryHook("cleanup",hook, ok, errmsg)
	
	if self.instanceStack then
		SF.instance = self.instanceStack[#self.instanceStack]
		if #self.instanceStack == 1 then self.instanceStack = nil
		else self.instanceStack[#self.instanceStack] = nil
		end
	else
		SF.instance = nil
	end
	
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

	self.cpu_total = 0
	self.cpu_average = 0
	self.cpu_softquota = 1

	self:runLibraryHook("initialize")
	self:prepare("_initialize")
	
	local func = self.scripts[self.mainfile]
	local tbl, traceback = self:runWithOps(func)
	if not tbl[1] then
		self:cleanup("_initialize", true, traceback)
		self.error = true
		return false, tbl[2], traceback
	end
	
	SF.allInstances[self] = self
	
	self:cleanup("_initialize",false)
	return true
end

--- Runs a script hook. This calls script code.
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return True if it executed ok, false if not or if there was no hook
-- @return If the first return value is false then the error message or nil if no hook was registered
function SF.Instance:runScriptHook(hook, ...)
	if not self.hooks[hook] then return {} end
	if self:prepare(hook) then return {} end
	local tbl, traceback
	for name, func in pairs(self.hooks[hook]) do
		tbl, traceback = self:runWithOps(func,...)
		if not tbl[1] then
			self:cleanup(hook,true,traceback)
			self:Error( "Hook '" .. hook .. "' errored with " .. tbl[ 2 ], traceback )
			return tbl
		end
	end
	self:cleanup(hook,false)
	return tbl
end

--- Runs a script hook until one of them returns a true value. Returns those values.
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return True if it executed ok, false if not or if there was no hook
-- @return If the first return value is false then the error message or nil if no hook was registered. Else any values that the hook returned.
-- @return The traceback if the instance errored
function SF.Instance:runScriptHookForResult(hook,...)
	if not self.hooks[hook] then return {} end
	if self:prepare(hook) then return {} end
	local tbl, traceback
	for name, func in pairs(self.hooks[hook]) do
		tbl, traceback = self:runWithOps(func,...)
		if tbl[1] then
			if tbl[2]~=nil then
				break
			end
		else
			self:cleanup(hook,true,traceback)
			self:Error( "Hook '" .. hook .. "' errored with " .. tbl[ 2 ], traceback )
			return tbl
		end
	end
	self:cleanup(hook,false)
	return tbl
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
	if self:prepare("_runFunction") then return true end
	
	local tbl, traceback = self:runWithOps(func,...)
	if tbl[1] then
		self:cleanup("_runFunction",false)
	else
		self:cleanup("_runFunction",true,traceback)
		self:Error( "Callback errored with " .. tbl[ 2 ], traceback )
	end
	
	return tbl
end

--- Deinitializes the instance. After this, the instance should be discarded.
function SF.Instance:deinitialize()
	self:runLibraryHook("deinitialize")
	SF.allInstances[self] = nil
	self.error = true
end

--- Errors the instance. Should only be called from the tips of the call tree (aka from places such as the hook library, timer library, the entity's think function, etc)
function SF.Instance:Error(msg,traceback)
	
	if self.runOnError then -- We have a custom error function, use that instead
		self:runOnError( msg, traceback )
	else
		-- Default behavior
		self:deinitialize()
	end
	
end

function SF.Instance:movingCPUAverage()
	local n = self.context.cpuTime:getBufferN()
	return (self.cpu_average * (n - 1) + self.cpu_total) / n
end
