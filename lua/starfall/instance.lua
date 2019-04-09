---------------------------------------------------------------------
-- SF Instance class.
-- Contains the compiled SF script and essential data. Essentially
-- the execution context.
---------------------------------------------------------------------

local dsethook, dgethook = debug.sethook, debug.gethook
if SERVER then
	SF.cpuQuota = CreateConVar("sf_timebuffer", 0.005, FCVAR_ARCHIVE, "The max average the CPU time can reach.")
	SF.cpuBufferN = CreateConVar("sf_timebuffersize", 100, FCVAR_ARCHIVE, "The window width of the CPU time quota moving average.")
	SF.softLockProtection = CreateConVar("sf_timebuffersoftlock", 1, FCVAR_ARCHIVE, "Consumes more cpu, but protects from freezing the game. Only turn this off if you want to use a profiler on your scripts.")
else
	SF.cpuQuota = CreateClientConVar("sf_timebuffer_cl", 0.006, true, false, "The max average the CPU time can reach.")
	SF.cpuOwnerQuota = CreateClientConVar("sf_timebuffer_cl_owner", 0.015, true, false, "The max average the CPU time can reach for your own chips.")
	SF.cpuBufferN = CreateClientConVar("sf_timebuffersize_cl", 100, true, false, "The window width of the CPU time quota moving average.")
	SF.softLockProtection = CreateConVar("sf_timebuffersoftlock_cl", 1, FCVAR_ARCHIVE, "Consumes more cpu, but protects from freezing the game. Only turn this off if you want to use a profiler on your scripts.")
end

SF.Instance = {}
SF.Instance.__index = SF.Instance

--- A set of all instances that have been created. It has weak keys and values.
-- Instances are put here after initialization.
SF.allInstances = {}
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
	if isstring(code) then
		mainfile = mainfile or "generic"
		code = { [mainfile] = code }
	end

	local instance = setmetatable({}, SF.Instance)

	instance.player = player
	instance.env = SF.BuildEnvironment()
	instance.env._G = instance.env
	instance.data = data or {}
	instance.ppdata = {}
	instance.ops = 0
	instance.hooks = {}
	instance.scripts = {}
	instance.source = code
	instance.initialized = false
	instance.mainfile = mainfile
	instance.requires = {}
	instance.requirestack = {string.GetPathFromFilename(mainfile)}
	instance.cpuQuota = (SERVER or LocalPlayer() ~= instance.player) and SF.cpuQuota:GetFloat() or SF.cpuOwnerQuota:GetFloat()
	instance.cpuQuotaRatio = 1 / SF.cpuBufferN:GetInt()
	instance.run = SF.softLockProtection:GetBool() and SF.Instance.runWithOps or SF.Instance.runWithoutOps
	instance.startram = collectgarbage("count")
	if CLIENT and instance.cpuQuota <= 0 then
		return false, { message = "Cannot execute with 0 sf_timebuffer", traceback = "" }
	end

	for filename, source in pairs(code) do
		if not dontpreprocess then
			SF.Preprocessor.ParseDirectives(filename, source, instance.ppdata)
		end

		local serverorclient
		if  instance.ppdata.serverorclient then
			serverorclient = instance.ppdata.serverorclient[filename]
		end

		if string.match(source, "^[%s\n]*$") or (serverorclient == "server" and CLIENT) or (serverorclient == "client" and SERVER) then
			-- Lua doesn't have empty statements, so an empty file gives a syntax error
			instance.scripts[filename] = function() end
		else
			local func = CompileString(source, "SF:"..filename, false)
			if isstring(func) then
				return false, { message = func, traceback = "" }
			end
			debug.setfenv(func, instance.env)
			instance.scripts[filename] = func
		end
	end

	return true, instance
end

--- Overridable hook for pcall-based hook systems
-- Gets called when inside a starfall context
-- @param running Are we executing a starfall context?
function SF.OnRunningOps(running)
	-- override me
end
SF.runningOps = false

--- Internal function - do not call.
-- Runs a function while incrementing the instance ops coutner.
-- This does no setup work and shouldn't be called by client code
-- @param func The function to run
-- @param ... Arguments to func
-- @return True if ok
-- @return A table of values that the hook returned
function SF.Instance:runWithOps(func, ...)

	local function xpcall_callback (err)
		if debug.getmetatable(err)~=SF.Errormeta then
			return SF.MakeError(err, 1)
		end
		return err
	end

	local oldSysTime = SysTime() - self.cpu_total
	local function cpuCheck()
		self.cpu_total = SysTime() - oldSysTime
		local usedRatio = self:movingCPUAverage() / self.cpuQuota

		local function safeThrow(msg, nocatch, force)
			local source = debug.getinfo(3, "S").short_src
			if string.find(source, "SF:", 1, true) or string.find(source, "starfall", 1, true) or force then
				if SERVER and nocatch then
					local consolemsg = "[Starfall] CPU Quota exceeded"
					if self.player:IsValid() then
						consolemsg = consolemsg .. " by " .. self.player:Nick() .. " (" .. self.player:SteamID() .. ")"
					end
					SF.Print(nil, consolemsg .. "\n")
					MsgC(Color(255,0,0), consolemsg .. "\n")
				end
				SF.Throw(msg, 3, nocatch)
			end
		end

		if usedRatio>1 then
			if usedRatio>1.5 then
				safeThrow("CPU Quota exceeded.", true, true)
			else
				safeThrow("CPU Quota exceeded.", true)
			end
		elseif usedRatio > self.cpu_softquota then
			safeThrow("CPU Quota warning.")
		end
	end

	local prevHook, mask, count = dgethook()
	local prev = SF.runningOps
	SF.runningOps = true
	SF.OnRunningOps(true)
	dsethook(cpuCheck, "", 2000)
	local tbl = { xpcall(func, xpcall_callback, ...) }
	dsethook(prevHook, mask, count)
	SF.runningOps = prev
	SF.OnRunningOps(prev)

	if tbl[1] then
		--Do another cpu check in case the debug hook wasn't called
		self.cpu_total = SysTime() - oldSysTime
		local usedRatio = self:movingCPUAverage() / self.cpuQuota
		if usedRatio>1 then
			return {false, SF.MakeError("CPU Quota exceeded.", 1, true, true)}
		elseif usedRatio > self.cpu_softquota then
			return {false, SF.MakeError("CPU Quota warning.", 1, false, true)}
		end
	end

	return tbl
end

--- Internal function - do not call.
-- Runs a function without incrementing the instance ops coutner.
-- This does no setup work and shouldn't be called by client code
-- @param func The function to run
-- @param ... Arguments to func
-- @return True if ok
-- @return A table of values that the hook returned
function SF.Instance:runWithoutOps(func, ...)

	local function xpcall_callback (err)
		if debug.getmetatable(err)~=SF.Errormeta then
			return SF.MakeError(err, 1)
		end
		return err
	end

	return { xpcall(func, xpcall_callback, ...) }
end

--- Internal function - Do not call. Prepares the script to be executed.
-- This is done automatically by Initialize and runScriptHook.
function SF.Instance:prepare(hook)
	assert(self.initialized, "Instance not initialized!")
	--Functions calling this one will silently halt.
	if self.error then return true end

	if SF.instance ~= nil then
		if self.instanceStack then
			self.instanceStack[#self.instanceStack + 1] = SF.instance
		else
			self.instanceStack = {SF.instance}
		end
	end

	SF.instance = self
	self:runLibraryHook("prepare", hook)
end

--- Internal function - Do not call. Cleans up the script.
-- This is done automatically by Initialize and runScriptHook.
function SF.Instance:cleanup(hook, ok, err)
	assert(SF.instance == self)
	self:runLibraryHook("cleanup", hook, ok, err)

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

	SF.allInstances[self] = true
	if SF.playerInstances[self.player] then
		SF.playerInstances[self.player][self] = true
	else
		SF.playerInstances[self.player] = {[self] = true}
	end

	self:runLibraryHook("initialize")
	self:prepare("_initialize")

	local func = self.scripts[self.mainfile]
	local tbl = self:run(func)
	if not tbl[1] then
		self:cleanup("_initialize", true, tbl[2])
		self:Error(tbl[2])
		return false, tbl[2]
	end

	self:cleanup("_initialize", false)
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
		tbl = self:run(func, ...)
		if not tbl[1] then
			tbl[2].message = "Hook '" .. hook .. "' errored with: " .. tbl[2].message
			self:cleanup(hook, true, tbl[2])
			self:Error(tbl[2])
			return tbl
		end
	end
	self:cleanup(hook, false)
	return tbl
end

--- Runs a script hook until one of them returns a true value. Returns those values.
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return True if it executed ok, false if not or if there was no hook
-- @return If the first return value is false then the error message or nil if no hook was registered. Else any values that the hook returned.
-- @return The traceback if the instance errored
function SF.Instance:runScriptHookForResult(hook, ...)
	if not self.hooks[hook] then return {} end
	if self:prepare(hook) then return {} end
	local tbl
	for name, func in pairs(self.hooks[hook]) do
		tbl = self:run(func, ...)
		if tbl[1] then
			if tbl[2]~=nil then
				break
			end
		else
			tbl[2].message = "Hook '" .. hook .. "' errored with: " .. tbl[2].message
			self:cleanup(hook, true, tbl[2])
			self:Error(tbl[2])
			return tbl
		end
	end
	self:cleanup(hook, false)
	return tbl
end

--- Runs a library hook. Alias to SF.CallHook(hook, self, ...).
-- @param hook Hook to run.
-- @param ... Additional arguments.
function SF.Instance:runLibraryHook(hook, ...)
	return SF.CallHook(hook, self, ...)
end

--- Runs an arbitrary function under the SF instance. This can be used
-- to run your own hooks when using the integrated hook system doesn't
-- make sense (ex timers).
-- @param func Function to run
-- @param ... Arguments to pass to func
function SF.Instance:runFunction(func, ...)
	if self:prepare("_runFunction") then return {} end

	local tbl = self:run(func, ...)
	if tbl[1] then
		self:cleanup("_runFunction", false)
	else
		tbl[2].message = "Callback errored with: " .. tbl[2].message
		self:cleanup("_runFunction", true, tbl[2])
		self:Error(tbl[2])
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

hook.Add("Think", "SF_Think", function()

	-- Check and attempt recovery from potential failures
	if SF.runningOps then
		SF.runningOps = false
		SF.OnRunningOps(false)
		ErrorNoHalt("[Starfall] ERROR: This should not happen, bad addons?\n")
	end

	for pl, insts in pairs(SF.playerInstances) do
		local plquota = (SERVER or LocalPlayer() ~= pl) and SF.cpuQuota:GetFloat() or SF.cpuOwnerQuota:GetFloat()
		local cputotal = 0
		for instance, _ in pairs(insts) do
			instance.cpu_average = instance:movingCPUAverage()
			instance.cpu_total = 0
			instance:runScriptHook("think")
			cputotal = cputotal + instance.cpu_average
		end

		if cputotal>plquota then
			local max, maxinst = 0, nil
			for instance, _ in pairs(insts) do
				if instance.cpu_average>=max then
					max = instance.cpu_average
					maxinst = instance
				end
			end

			if maxinst then
				maxinst:Error(SF.MakeError("SF: Player cpu time limit reached!", 1))
			end
		end
	end
end)

if CLIENT then
--- Check if a HUD Component is connected to the SF instance
-- @return true if a HUD Component is connected
	function SF.Instance:isHUDActive()
		local foundlink
		for hud, _ in pairs(SF.ActiveHuds) do
			if hud.link == self.data.entity then
				return true
			end
		end
		return false
	end
end

--- Errors the instance. Should only be called from the tips of the call tree (aka from places such as the hook library, timer library, the entity's think function, etc)
function SF.Instance:Error(err)
	if self.error then return end
	if self.runOnError then -- We have a custom error function, use that instead
		self:runOnError(err)
	else
		-- Default behavior
		self:deinitialize()
	end
end

-- Don't self modify. The average should only the modified per tick.
function SF.Instance:movingCPUAverage()
	return self.cpu_average + (self.cpu_total - self.cpu_average) * self.cpuQuotaRatio
end
