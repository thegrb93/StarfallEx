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
SF.playerInstances = {}

--- Preprocesses and Compiles code and returns an Instance
-- @param code Either a string of code, or a {path=source} table
-- @param mainfile If code is a table, this specifies the first file to parse.
-- @param player The "owner" of the instance
-- @param data The table to set instance.data to. Default is a new table.
-- @param dontpreprocess Set to true to skip preprocessing
-- @return True if no errors, false if errors occured.
-- @return The compiled instance, or the error message.
function SF.Instance.Compile(code, mainfile, player, data, dontpreprocess)
	if type(code) == "string" then
		mainfile = mainfile or "generic"
		code = {[mainfile]=code}
	end
	
	local instance = setmetatable({},SF.Instance)
	
	instance.player = player
	instance.playerid = player:SteamID()
	instance.env = SF.Libraries.BuildEnvironment()
	instance.env._G = instance.env
	instance.data = data or {}
	instance.ppdata = {}
	instance.ops = 0
	instance.hooks = {}
	instance.scripts = {}
	instance.source = code
	instance.initialized = false
	instance.mainfile = mainfile
	
	for filename, source in pairs(code) do
		if not dontpreprocess then
			SF.Preprocessor.ParseDirectives(filename,source,instance.ppdata)
		end
		
		local serverorclient
		if  instance.ppdata.serverorclient then
			serverorclient = instance.ppdata.serverorclient[ filename ]
		end
		
		if string.match(source, "^[%s\n]*$") or (serverorclient == "server" and CLIENT) or (serverorclient == "client" and SERVER) then
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


--- Internal function - do not call.
-- Runs a function while incrementing the instance ops coutner.
-- This does no setup work and shouldn't be called by client code
-- @param func The function to run
-- @param ... Arguments to func
-- @return True if ok
-- @return A table of values that the hook returned
function SF.Instance:runWithOps(func,...)

	local function xpcall_callback ( err )
		if type( err ) == "table" then
			if type( err.message ) == "string" then
				local line= err.line
				local file = err.file

				err = ( file and ( file .. ":" ) or "" ) .. ( line and ( line .. ": " ) or "" ) .. err.message
			end
		end
		return {tostring( err ), debug.traceback( "", 2 )}
	end

	local oldSysTime = SysTime() - self.cpu_total
	local function cpuCheck ()
		self.cpu_total = SysTime() - oldSysTime
		local usedRatio = self:movingCPUAverage()/SF.cpuQuota:GetFloat()
		
		local function safeThrow( msg, nocatch )
			local source = debug.getinfo(3, "S").short_src
			if string.find(source, "SF:", 1, true) or string.find(source, "starfall", 1, true) then
				SF.throw( msg, 3, nocatch )
			end
		end
		
		if usedRatio>1 then
			safeThrow( "CPU Quota exceeded.", true )
		elseif usedRatio > self.cpu_softquota then
			safeThrow( "CPU Quota warning." )
		end
	end
	
	local prevHook, mask, count = debug.gethook()
	debug.sethook( cpuCheck, "", 2000 )
	local tbl = {xpcall( func, xpcall_callback, ... )}
	debug.sethook( prevHook, mask, count )
	
	if tbl[1] then
		-- Need to put the cpuCheck in a lambda so the debug.getinfo doesn't land inside of xpcall
		local tbl2 = {xpcall( function() cpuCheck() end, xpcall_callback )}
		if not tbl2[1] then return tbl2 end
	end
	
	return tbl
end

--- Internal function - Do not call. Prepares the script to be executed.
-- This is done automatically by Initialize and runScriptHook.
function SF.Instance:prepare(hook)
	assert(self.initialized, "Instance not initialized!")
	--Functions calling this one will silently halt.
	if self.error then return true end
	
	if SF.instance != nil then
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

	SF.allInstances[self] = self
	if SF.playerInstances[self.player] then
		SF.playerInstances[self.player][self] = self
	else
		SF.playerInstances[self.player] = {[self]=self}
	end

	self:runLibraryHook("initialize")
	self:prepare("_initialize")

	local func = self.scripts[self.mainfile]
	local tbl = self:runWithOps(func)
	if not tbl[1] then
		self:cleanup("_initialize", true, tbl[2][2])
		self.error = true
		return false, unpack(tbl[2])
	end

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
	local tbl
	for name, func in pairs(self.hooks[hook]) do
		tbl = self:runWithOps(func,...)
		if not tbl[1] then
			self:cleanup(hook,true,tbl[2][2])
			self:Error( "Hook '" .. hook .. "' errored with " .. tbl[2][1], tbl[2][2] )
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
	local tbl
	for name, func in pairs(self.hooks[hook]) do
		tbl = self:runWithOps(func,...)
		if tbl[1] then
			if tbl[2]!=nil then
				break
			end
		else
			self:cleanup(hook,true,tbl[2][2])
			self:Error( "Hook '" .. hook .. "' errored with " .. tbl[2][1], tbl[2][2] )
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
	
	local tbl = self:runWithOps(func,...)
	if tbl[1] then
		self:cleanup("_runFunction",false)
	else
		self:cleanup("_runFunction",true,tbl[2][2])
		self:Error( "Callback errored with " .. tbl[2][1], tbl[2][2] )
	end
	
	return tbl
end

--- Deinitializes the instance. After this, the instance should be discarded.
function SF.Instance:deinitialize()
	self:runLibraryHook("deinitialize")
	SF.allInstances[self] = nil
	SF.playerInstances[self.player][self] = nil
	if not next(SF.playerInstances[self.player]) then
		SF.playerInstances[self.player] = nil
	end
	self.error = true
end

hook.Add("Think","SF_Think",function()
	for pl, insts in pairs(SF.playerInstances) do
		local cputotal = 0
		for instance, _ in pairs(insts) do
			instance.cpu_average = instance:movingCPUAverage()
			instance.cpu_total = 0
			instance:runScriptHook( "think" )
			cputotal = cputotal + instance.cpu_average
		end
		
		if cputotal>SF.cpuQuota:GetFloat() then
			local max, maxinst = 0, nil
			for instance, _ in pairs(insts) do
				if instance.cpu_average>=max then
					max = instance.cpu_average
					maxinst = instance
				end
			end
			
			if maxinst then
				maxinst:Error( "SF: Player cpu time limit reached!" )
			end
		end
	end
end)

if CLIENT then
--- Check if a HUD Component is connected to the SF instance
-- @return true if a HUD Component is connected
	function SF.Instance:isHUDActive()
		local foundlink
		for hud, _ in pairs( SF.ActiveHuds ) do
			if hud.link == self.data.entity then
				return true
			end
		end
		return false
	end
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

-- Don't self modify. The average should only the modified per tick.
function SF.Instance:movingCPUAverage()
	local n = SF.cpuBufferN:GetInt()
	return (self.cpu_average * (n - 1) + self.cpu_total) / n
end
