---------------------------------------------------------------------
-- SF Instance class.
-- Contains the compiled SF script and essential data. Essentially
-- the execution context.
---------------------------------------------------------------------

local dsethook, dgethook = debug.sethook, debug.gethook
local dgetmeta = debug.getmetatable

if SERVER then
	SF.cpuQuota = CreateConVar("sf_timebuffer", 0.005, FCVAR_ARCHIVE, "The max average the CPU time can reach.")
	SF.cpuBufferN = CreateConVar("sf_timebuffersize", 100, FCVAR_ARCHIVE, "The window width of the CPU time quota moving average.")
	SF.softLockProtection = CreateConVar("sf_timebuffersoftlock", 1, FCVAR_ARCHIVE, "Consumes more cpu, but protects from freezing the game. Only turn this off if you want to use a profiler on your scripts.")
	SF.RamCap = CreateConVar("sf_ram_max", 1500000, FCVAR_ARCHIVE, "If ram exceeds this limit (in kB), starfalls will be terminated")
	SF.AllowSuperUser = CreateConVar("sf_superuserallowed", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Whether the starfall superuser feature is allowed")
else
	SF.cpuQuota = CreateConVar("sf_timebuffer_cl", 0.006, FCVAR_ARCHIVE, "The max average the CPU time can reach.")
	SF.cpuOwnerQuota = CreateConVar("sf_timebuffer_cl_owner", 0.015, FCVAR_ARCHIVE, "The max average the CPU time can reach for your own chips.")
	SF.cpuBufferN = CreateConVar("sf_timebuffersize_cl", 100, FCVAR_ARCHIVE, "The window width of the CPU time quota moving average.")
	SF.softLockProtection = CreateConVar("sf_timebuffersoftlock_cl", 1, FCVAR_ARCHIVE, "Consumes more cpu, but protects from freezing the game. Only turn this off if you want to use a profiler on your scripts.")
	SF.softLockProtectionOwner = CreateConVar("sf_timebuffersoftlock_cl_owner", 1, FCVAR_ARCHIVE, "If sf_timebuffersoftlock_cl is 0, this enabled will make it only your own chips will be affected.")
	SF.RamCap = CreateConVar("sf_ram_max_cl", 1500000, FCVAR_ARCHIVE, "If ram exceeds this limit (in kB), starfalls will be terminated")
	SF.AllowSuperUser = CreateConVar("sf_superuserallowed", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Whether the starfall superuser feature is allowed")
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
-- @param Player The "owner" of the instance
-- @param data The table to set instance.data to. Default is a new table.
-- @return True if no errors, false if errors occured.
-- @return The compiled instance, or the error message.
function SF.Instance.Compile(code, mainfile, player, entity)
	if isstring(code) then
		mainfile = mainfile or "generic"
		code = { [mainfile] = code }
	end

	local instance = setmetatable({}, SF.Instance)
	instance.entity = entity
	instance.data = {}
	instance.stackn = 0
	instance.sfhooks = {}
	instance.hooks = {}
	instance.scripts = {}
	instance.source = code
	instance.mainfile = mainfile
	instance.requires = {}

	instance.ppdata = {}
	for filename, source in pairs(code) do
		local ok, err = pcall(SF.Preprocessor.ParseDirectives, filename, source, instance.ppdata)
		if not ok then
			return false, { message = err, traceback = "" }
		end
	end

	if player:IsWorld() then
		player = SF.Superuser
	elseif instance.ppdata.superuser and instance.ppdata.superuser[mainfile] then
		if not SF.AllowSuperUser:GetBool() then return false, { message = "Can't use --@superuser unless sf_superuserallowed is enabled!", traceback = "" } end
		if not player:IsSuperAdmin() then return false, { message = "Can't use --@superuser unless you are superadmin!", traceback = "" } end
		player = SF.Superuser
	end
	instance.player = player

	local quotaRun
	if player == SF.Superuser then
		quotaRun = SF.Instance.runWithoutOps
	else
		if SERVER then
			if SF.softLockProtection:GetBool() then
				quotaRun = SF.Instance.runWithOps
			else
				quotaRun = SF.Instance.runWithoutOps
			end
		else
			if SF.BlockedUsers:isBlocked(player:SteamID()) then
				return false, { message = "User has blocked this player's starfalls", traceback = "" }
			end

			if SF.softLockProtection:GetBool() then
				quotaRun = SF.Instance.runWithOps
			elseif SF.softLockProtectionOwner:GetBool() and LocalPlayer() ~= player then
				quotaRun = SF.Instance.runWithOps
			else
				quotaRun = SF.Instance.runWithoutOps
			end
		end
	end
	instance.run = quotaRun
	
	if quotaRun == SF.Instance.runWithOps then
		instance.cpuQuota = (SERVER or LocalPlayer() ~= player) and SF.cpuQuota:GetFloat() or SF.cpuOwnerQuota:GetFloat()
		instance.cpuQuotaRatio = 1 / SF.cpuBufferN:GetInt()

		if CLIENT and instance.cpuQuota <= 0 then
			return false, { message = "Cannot execute with 0 sf_timebuffer", traceback = "" }
		end
	else
		instance.cpuQuota = math.huge
		instance.cpuQuotaRatio = 0
	end

	local ok, err = xpcall(instance.BuildEnvironment, debug.traceback, instance)
	if not ok then
		return false, { message = "", traceback = err }
	end

	local doNotRun = {}
	local includesdata = instance.ppdata.includesdata
	if includesdata then
		for filename, t in pairs(includesdata) do
			for _, datapath in ipairs(t) do
				local codepath = SF.ChoosePath(datapath, string.GetPathFromFilename(filename), function(testpath)
					return instance.source[testpath]
				end)
				if codepath then doNotRun[codepath] = true end
			end
		end
	end

	local serverorclientpp = instance.ppdata.serverorclient or {}
	for filename, source in pairs(code) do
		if doNotRun[filename] then continue end -- Don't compile data files
		local serverorclient = serverorclientpp[filename]
		if (serverorclient == "server" and CLIENT) or (serverorclient == "client" and SERVER) then
			instance.scripts[filename] = function() end
		else
			local func = SF.CompileString(source, "SF:"..filename, false)
			if isstring(func) then
				return false, { message = func, traceback = "" }
			end
			debug.setfenv(func, instance.env)
			instance.scripts[filename] = func
		end
	end

	instance.startram = collectgarbage("count")

	return true, instance
end

--- Adds a hook to the instance
-- @param name The hook name
-- @param func The hook function
function SF.Instance:AddHook(name, func)
	local hook = self.sfhooks[name]
	if hook then
		hook[#hook + 1] = func
	else
		self.sfhooks[name] = {func}
	end
end

--- Runs a library hook.
-- @param name Hook to run.
-- @param ... Additional arguments.
function SF.Instance:RunHook(name, ...)
	local hook = self.sfhooks[name]
	if hook then
		for i = 1, #hook do
			hook[i](...)
		end
	end
end

--- Creates and registers a library.
-- @param name The library name
-- @return methods The library's methods
function SF.RegisterLibrary(name)
	SF.Libraries[name] = true
end

--- Registers a type.
-- @param name The library name
-- @param weakwrapper Make the wrapper weak inside the internal lookup table. Default: True
-- @param weaksensitive Make the sensitive data weak inside the internal lookup table. Default: True
-- @param target_metatable (optional) The metatable of the object that will get
-- 		wrapped by these wrapper functions.  This is required if you want to
-- 		have the object be auto-recognized by the generic self.WrapObject
--		function.
-- @param super Optional type name that this will inherit from
-- @return methods The type's methods
-- @return metamethods The type's metamethods
function SF.RegisterType(name, weakwrapper, weaksensitive, target_metatable, supertype, customwrappers)
	SF.Types[name] = {
		weakwrapper = weakwrapper,
		weaksensitive = weaksensitive,
		target_metatable = target_metatable,
		supertype = supertype,
		customwrappers = customwrappers,
	}
end

--- Creates wrap/unwrap functions for sensitive values, by using a lookup table
-- (which is set to have weak keys and values)
-- @param metatable The metatable to assign the wrapped value.
-- @return The function to wrap sensitive values to a SF-safe table
-- @return The function to unwrap the SF-safe table to the sensitive table
function SF.Instance:CreateWrapper(metatable, typedata)
	
	local wrap, unwrap
	-- If the type already has wrappers, dont re-assign
	if typedata.weakwrapper==nil or typedata.weaksensitive==nil then
		if typedata.customwrappers then
			wrap, unwrap = typedata.customwrappers(self.CheckType, metatable)
		else
			return true
		end
	else

		local sf2sensitive = setmetatable({}, { __mode = (typedata.weakwrapper and "k" or "") .. (typedata.weaksensitive and "v" or "") })
		local sensitive2sf = setmetatable({}, { __mode = (typedata.weaksensitive and "k" or "") .. (typedata.weakwrapper and "v" or "") })
		metatable.sensitive2sf = sensitive2sf
		metatable.sf2sensitive = sf2sensitive

		if metatable.supertype then
			local supersensitive2sf = metatable.supertype.sensitive2sf
			local supersf2sensitive = metatable.supertype.sf2sensitive

			if not supersensitive2sf then return false end --Need to try again since baseclass hasn't been created yet

			function wrap(value)
				if value == nil then return nil end
				if sensitive2sf[value] then return sensitive2sf[value] end
				local tbl = setmetatable({}, metatable)
				sensitive2sf[value] = tbl
				sf2sensitive[tbl] = value
				supersensitive2sf[value] = tbl
				supersf2sensitive[tbl] = value
				return tbl
			end
		else
			function wrap(value)
				if value == nil then return nil end
				if sensitive2sf[value] then return sensitive2sf[value] end
				local tbl = setmetatable({}, metatable)
				sensitive2sf[value] = tbl
				sf2sensitive[tbl] = value
				return tbl
			end
		end
		function unwrap(value)
			local ret = sf2sensitive[value]
			return ret or self.CheckType(value, metatable, 2) or SF.Throw("Object no longer valid", 3)
		end
	end

	if typedata.target_metatable then
		self.object_wrappers[typedata.target_metatable] = wrap
	end
	self.object_unwrappers[metatable] = unwrap

	metatable.Wrap = wrap
	metatable.Unwrap = unwrap
	return true
end

--- Builds an environment table
-- @return The environment
function SF.Instance:BuildEnvironment()
	self.Libraries = {}
	self.Types = {}
	self.env = {}

	local object_wrappers = {}
	local object_unwrappers = {}
	self.object_wrappers = object_wrappers
	self.object_unwrappers = object_unwrappers

	--- Checks the starfall type of val. Errors if the types don't match
	-- @param val The value to be checked.
	-- @param typ A metatable.
	-- @param level Level at which to error at. 2 is added to this value. Default is 1.
	function self.CheckType(val, typ, level)
		local meta = dgetmeta(val)
		if meta == typ or (meta and meta.supertype == typ and object_unwrappers[meta]) then
			return val
		else
			assert(istable(typ) and typ.__metatable and isstring(typ.__metatable))
			level = (level or 1) + 2
			SF.ThrowTypeError(typ.__metatable, SF.GetType(val), level)
		end
	end

	function self.IsSFType(val)
		local metatable = dgetmeta(val)
		return metatable and object_unwrappers[metatable]~=nil
	end

	-- A list of safe data types
	local safe_types = {
		[TYPE_NUMBER] = true,
		[TYPE_STRING] = true,
		[TYPE_BOOL] = true,
		[TYPE_NIL] = true,
	}

	--- Wraps the given object so that it is safe to pass into starfall
	-- It will wrap it as long as we have the metatable of the object that is
	-- getting wrapped.
	-- @param object the object needing to get wrapped as it's passed into starfall
	-- @return returns nil if the object doesn't have a known wrapper,
	-- or returns the wrapped object if it does have a wrapper.
	local function WrapObject(object)
		local metatable = dgetmeta(object)
		if metatable then
			local wrap = object_wrappers[metatable]
			if wrap then
				return wrap(object)
			else
				-- Check if the object is already an SF type
				if object_unwrappers[metatable] then
					return object
				end
			end
		end
		-- Do not elseif here because strings do have a metatable.
		if safe_types[TypeID(object)] then
			return object
		end
	end
	self.WrapObject = WrapObject

	--- Takes a wrapped starfall object and returns the unwrapped version
	-- @param object the wrapped starfall object, should work on any starfall
	-- wrapped object.
	-- @return the unwrapped starfall object
	local function UnwrapObject(object)
		local metatable = dgetmeta(object)
		if metatable then
			local unwrap = object_unwrappers[metatable]
			if unwrap then
				return unwrap(object)
			end
		end
		if safe_types[TypeID(object)] then
			return object
		end
	end
	self.UnwrapObject = UnwrapObject

	--- Sanitizes and returns its argument list.
	-- Basic types are returned unchanged. Non-object tables will be
	-- recursed into and their keys and values will be sanitized. Object
	-- types will be wrapped if a wrapper is available. When a wrapper is
	-- not available objects will be replaced with nil, so as to prevent
	-- any possiblitiy of leakage. Functions will always be replaced with
	-- nil as there is no way to verify that they are safe.
	function self.Sanitize(original)
		local completed_tables = {}

		local function RecursiveSanitize(tbl)
			local return_list = {}
			completed_tables[tbl] = return_list
			for key, value in pairs(tbl) do
				local keyt = TypeID(key)
				local valuet = TypeID(value)
				if not safe_types[keyt] then
					key = WrapObject(key) or (keyt == TYPE_TABLE and (completed_tables[key] or RecursiveSanitize(key)) or nil)
				end
				if not safe_types[valuet] then
					value = WrapObject(value) or (valuet == TYPE_TABLE and (completed_tables[value] or RecursiveSanitize(value)) or nil)
				end
				return_list[key] = value
			end
			return return_list
		end

		return RecursiveSanitize(original)
	end

	--- Takes output from starfall and does it's best to make the output
	-- fully usable outside of starfall environment
	function self.Unsanitize(original)
		local completed_tables = {}

		local function RecursiveUnsanitize(tbl)
			local return_list = {}
			completed_tables[tbl] = return_list
			for key, value in pairs(tbl) do
				if TypeID(key) == TYPE_TABLE then
					key = UnwrapObject(key) or completed_tables[key] or RecursiveUnsanitize(key)
				end
				if TypeID(value) == TYPE_TABLE then
					value = UnwrapObject(value) or completed_tables[value] or RecursiveUnsanitize(value)
				end
				return_list[key] = value
			end
			return return_list
		end

		return RecursiveUnsanitize(original)
	end
	
	for name, _ in pairs(SF.Libraries) do
		self.Libraries[name] = {}
	end
	
	for name, typedata in pairs(SF.Types) do
		local methods = {}
		local metatable = {__metatable = name, __index = methods, supertype = typedata.supertype, Methods = methods}
		self.Types[name] = metatable
	end

	for name, meta in pairs(self.Types) do
		if meta.supertype then
			local supermeta = self.Types[meta.supertype] or error("Failed to find supertype, "..tostring(meta.supertype))
			meta.supertype = supermeta
			setmetatable(meta.Methods, {__index = supermeta.Methods})
		end
	end

	local typesToCreate = self.Types
	while true do
		local numCreated = 0
		local newTypesToCreate = {}
		for name, meta in pairs(typesToCreate) do
			if self:CreateWrapper(meta, SF.Types[name]) then
				numCreated = numCreated + 1
			else
				newTypesToCreate[name] = meta
			end
		end
		if next(newTypesToCreate)==nil then break end
		if numCreated==0 then error("Failed to create types due to missing subclass: " .. next(newTypesToCreate)) end
		typesToCreate = newTypesToCreate
	end

	for name, mod in pairs(SF.Modules) do
		for filename, data in pairs(mod) do
			if data.init then
				local ok, err = xpcall(function() data.init(self) end, debug.traceback)
				if not ok then ErrorNoHalt(err) end
			end
		end
	end
	table.Inherit( self.env, self.Libraries ) 
	self.env._G = self.env
end

--- Overridable hook for pcall-based hook systems
-- Gets called when inside a starfall context
-- @param running Are we executing a starfall context?
function SF.OnRunningOps(running)
	-- override me
end
SF.runningOps = false

local function safeThrow(self, msg, nocatch, force)
	local source = debug.getinfo(3, "S").short_src
	if string.find(source, "SF:", 1, true) or force then
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

function SF.Instance:checkCpu()
	if self.run ~= self.runWithOps then return end
	self.cpu_total = SysTime() - self.start_time
	local usedRatio = self:movingCPUAverage() / self.cpuQuota
	if usedRatio>1 then
		safeThrow(self, "CPU Quota exceeded.", true, true)
	elseif usedRatio > self.cpu_softquota then
		safeThrow(self, "CPU Quota warning.")
	end
end

local function xpcall_callback(err)
	if dgetmeta(err)~=SF.Errormeta then
		return SF.MakeError(err, 1)
	end
	return err
end

--- Internal function - do not call.
-- Runs a function while incrementing the instance ops coutner.
-- This does no setup work and shouldn't be called by client code
-- @param func The function to run
-- @param ... Arguments to func
-- @return True if ok
-- @return A table of values that the hook returned
function SF.Instance:runWithOps(func, ...)
	if self.stackn == 0 then
		self.start_time = SysTime() - self.cpu_total
	elseif self.stackn == 128 then
		return {false, SF.MakeError("sf stack overflow", 1, true, true)}
	end

	local function checkCpu()
		self.cpu_total = SysTime() - self.start_time
		local usedRatio = self:movingCPUAverage() / self.cpuQuota
		if usedRatio>1 then
			if usedRatio>1.5 then
				safeThrow(self, "CPU Quota exceeded.", true, true)
			else
				safeThrow(self, "CPU Quota exceeded.", true)
			end
		elseif usedRatio > self.cpu_softquota then
			safeThrow(self, "CPU Quota warning.")
		end
	end

	local prevHook, mask, count = dgethook()
	local prev = SF.runningOps
	SF.runningOps = true
	SF.OnRunningOps(true)
	dsethook(checkCpu, "", 2000)
	self.stackn = self.stackn + 1
	local tbl = { xpcall(func, xpcall_callback, ...) }
	self.stackn = self.stackn - 1
	dsethook(prevHook, mask, count)
	SF.runningOps = prev
	SF.OnRunningOps(prev)

	if tbl[1] then
		--Do another cpu check in case the debug hook wasn't called
		self.cpu_total = SysTime() - self.start_time
		local usedRatio = self:movingCPUAverage() / self.cpuQuota
		if usedRatio>1 then
			return {false, SF.MakeError("CPU Quota exceeded.", 1, true, true)}
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
	return { xpcall(func, xpcall_callback, ...) }
end

--- Runs the scripts inside of the instance. This should be called once after
-- compiling/unpacking so that scripts can register hooks and such. It should
-- not be called more than once.
-- @return True if no script errors occured
-- @return The error message, if applicable
-- @return The error traceback, if applicable
function SF.Instance:initialize()
	self.cpu_total = 0
	self.cpu_average = 0
	self.cpu_softquota = 1

	SF.allInstances[self] = true
	if SF.playerInstances[self.player] then
		SF.playerInstances[self.player][self] = true
	else
		SF.playerInstances[self.player] = {[self] = true}
	end

	self:RunHook("initialize")

	local func = self.scripts[self.mainfile]
	local tbl = self:run(func)
	if not tbl[1] then
		self:Error(tbl[2])
		return false, tbl[2]
	end

	return true
end

--- Runs a script hook. This calls script code.
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return True if it executed ok, false if not or if there was no hook
-- @return If the first return value is false then the error message or nil if no hook was registered
function SF.Instance:runScriptHook(hook, ...)
	if self.error then return {} end
	local hooks = self.hooks[hook]
	if not hooks then return {} end
	local tbl
	for name, func in hooks:pairs() do
		tbl = self:run(func, ...)
		if not tbl[1] then
			tbl[2].message = "Hook '" .. hook .. "' errored with: " .. tbl[2].message
			self:Error(tbl[2])
			return tbl
		end
	end
	return tbl
end

--- Runs a script hook until one of them returns a true value. Returns those values.
-- @param hook The hook to call.
-- @param ... Arguments to pass to the hook's registered function.
-- @return True if it executed ok, false if not or if there was no hook
-- @return If the first return value is false then the error message or nil if no hook was registered. Else any values that the hook returned.
-- @return The traceback if the instance errored
function SF.Instance:runScriptHookForResult(hook, ...)
	if self.error then return {} end
	local hooks = self.hooks[hook]
	if not hooks then return {} end
	local tbl
	for name, func in hooks:pairs() do
		tbl = self:run(func, ...)
		if tbl[1] then
			if tbl[2]~=nil then
				break
			end
		else
			tbl[2].message = "Hook '" .. hook .. "' errored with: " .. tbl[2].message
			self:Error(tbl[2])
			return tbl
		end
	end
	return tbl
end

--- Runs an arbitrary function under the SF instance. This can be used
-- to run your own hooks when using the integrated hook system doesn't
-- make sense (ex timers).
-- @param func Function to run
-- @param ... Arguments to pass to func
function SF.Instance:runFunction(func, ...)
	if self.error then return {} end

	local tbl = self:run(func, ...)
	if not tbl[1] then
		tbl[2].message = "Callback errored with: " .. tbl[2].message
		self:Error(tbl[2])
	end

	return tbl
end

local requireSentinel = {}
function SF.Instance:require(path)
	local loaded = self.requires
	if loaded[path] == requireSentinel then
		SF.Throw("Cyclic require loop detected!", 3)
	elseif loaded[path] then
		return loaded[path]
	else
		local func = self.scripts[path] or SF.Throw("Can't find file '" .. path .. "' (did you forget to --@include it?)", 3)
		loaded[path] = requireSentinel
		local ret = func()
		loaded[path] = ret or true
		return ret
	end
end

--- Deinitializes the instance. After this, the instance should be discarded.
function SF.Instance:deinitialize()
	self:RunHook("deinitialize")
	SF.allInstances[self] = nil
	local playerInstances = SF.playerInstances[self.player]
	if playerInstances then
		playerInstances[self] = nil
		if not next(playerInstances) then
			SF.playerInstances[self.player] = nil
		end
	end
	self.error = true
end

hook.Add("Think", "SF_Think", function()

	local ram = collectgarbage("count")
	if SF.Instance.Ram then
		if ram > SF.RamCap:GetInt() then
			local doClean = false
			for instance, _ in pairs(SF.allInstances) do
				doClean = true
				instance:Error(SF.MakeError("Global RAM usage limit exceeded!!", 1))
			end
			if doClean then collectgarbage() end
		end
		SF.Instance.Ram = ram
		SF.Instance.RamAvg = SF.Instance.RamAvg*0.999 + ram*0.001
	else
		SF.Instance.Ram = ram
		SF.Instance.RamAvg = ram
	end

	-- Check and attempt recovery from potential failures
	if SF.runningOps then
		SF.runningOps = false
		SF.OnRunningOps(false)
		ErrorNoHalt("[Starfall] ERROR: This should not happen, bad addons?\n")
	end

	for pl, insts in pairs(SF.playerInstances) do
		local plquota
		local cputotal = 0
		for instance, _ in pairs(insts) do
			instance.cpu_average = instance:movingCPUAverage()
			instance.cpu_total = 0
			instance:runScriptHook("think")
			cputotal = cputotal + instance.cpu_average
			plquota = instance.cpuQuota
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

--- Errors the instance. Should only be called from the tips of the call tree (aka from places such as the hook library, timer library, the entity's think function, etc)
function SF.Instance:Error(err)
	if self.error then return end
	if self.runOnError then -- We have a custom error function, use that instead
		self.runOnError(err)
	else
		-- Default behavior
		self:deinitialize()
	end
end

-- Don't self modify. The average should only be modified per tick.
function SF.Instance:movingCPUAverage()
	return self.cpu_average + (self.cpu_total - self.cpu_average) * self.cpuQuotaRatio
end


