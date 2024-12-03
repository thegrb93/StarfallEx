---------------------------------------------------------------------
-- SF Instance class.
-- Contains the compiled SF script and essential data. Essentially
-- the execution context.
---------------------------------------------------------------------

local dsethook, dgethook = debug.sethook, debug.gethook
local dgetmeta = debug.getmetatable
local SysTime = SysTime

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
local ramlimit = SF.RamCap:GetInt()
cvars.AddChangeCallback(SF.RamCap:GetName(), function() ramlimit = SF.RamCap:GetInt() end)

SF.Instance = {}
SF.Instance.__index = SF.Instance

--- A set of all instances that have been created. It has weak keys and values.
-- Instances are put here after initialization.
SF.allInstances = {}
if SERVER then
	SF.playerInstances = SF.EntityTable("playerInstances", function(ply, instances)
		for instance in pairs(instances) do
			instance:Error({message = "Player disconnected!", traceback = ""})
			if IsValid(instance.entity) then
				net.Start("starfall_processor_kill")
				net.WriteEntity(instance.entity)
				net.Broadcast()
			end
		end
	end)
	getmetatable(SF.playerInstances).__index = function() return {} end
else
	SF.playerInstances = setmetatable({},{__index = function() return {} end})
end

local plyPrecacheTimeBurst = SF.BurstObject("model_precache_time", "Model precache time", 5, 0.2, "The rate allowed model precache time regenerates.", "Amount of allowed model precache time.")

function SF.Instance.Compile(code, mainfile, player, entity)
	if isstring(code) then
		mainfile = mainfile or "generic"
		code = { [mainfile] = code }
	end
	local ok, message = hook.Run("StarfallCanCompile", code, mainfile, player, entity)
	if ok == false then return false, { message = message, traceback = "" } end

	local instance = setmetatable({}, SF.Instance)
	instance.entity = entity
	instance.data = {}
	instance.cpustatestack = {}
	instance.stackn = 0
	instance.sfhooks = {}
	instance.hooks = {}
	instance.scripts = {}
	instance.source = code
	instance.mainfile = mainfile
	instance.requires = {}
	instance.permissionOverrides = {}

	local ok, ppdata = pcall(SF.Preprocessor, code)
	if not ok then return false, { message = ppdata, traceback = "" } end
	instance.ppdata = ppdata

	if player:IsWorld() then
		player = SF.Superuser
	elseif ppdata.files[mainfile].superuser then
		if not SF.AllowSuperUser:GetBool() then return false, { message = "Can't use --@superuser unless sf_superuserallowed is enabled!", traceback = "" } end
		local ok, message = hook.Run("StarfallCanSuperUser", player)
		if ok == false or (ok == nil and not player:IsSuperAdmin()) then return false, { message = message or "Can't use --@superuser unless you are superadmin!", traceback = "" } end
		player = SF.Superuser
	end
	instance.player = player

	if player == SF.Superuser then
		instance:setCheckCpu(false)
	else
		if SERVER then
			instance:setCheckCpu(SF.softLockProtection:GetBool())
		else
			if SF.BlockedUsers:isBlocked(player:SteamID()) then
				return false, { message = "User has blocked this player's starfalls", traceback = "" }
			end
			instance:setCheckCpu(SF.softLockProtection:GetBool() or (SF.softLockProtectionOwner:GetBool() and LocalPlayer() ~= player))
		end
	end

	local ok, err = xpcall(instance.BuildEnvironment, debug.traceback, instance)
	if not ok then
		return false, { message = "", traceback = err }
	end

	for filename, fdata in pairs(ppdata.files) do
		--includedata directive
		if fdata.datafile then continue end

		--precachemodel directive
		if #fdata.precachemodels>0 then
			local startTime = SysTime()
			for _, model in pairs(fdata.precachemodels) do
				local ok, err = pcall(plyPrecacheTimeBurst.use, plyPrecacheTimeBurst, instance.player, 0) -- Should just check if the burst is negative
				if not ok then return false, err end
				ok, model = pcall(SF.CheckModel, model, instance.player)
				if not ok then return false, model end
				util.PrecacheModel(model)
				local newTime = SysTime()
				local timeUsed = newTime - startTime
				startTime = newTime
				-- Subtract the burst amount left by the time used
				local obj = plyPrecacheTimeBurst:get(instance.player)
				obj.val = obj.val - timeUsed
			end
		end

		--owneronly directive
		if CLIENT and fdata.owneronly and LocalPlayer() ~= player then continue end -- Don't compile owner-only files if not owner
		
		--realm directives
		local serverorclient = fdata.serverorclient
		if (serverorclient == "server" and CLIENT) or (serverorclient == "client" and SERVER) then continue end -- Don't compile files for other realm

		local func = SF.CompileString(fdata.code, "SF:"..filename, false)
		if isstring(func) then
			return false, { message = func, traceback = "" }
		end
		debug.setfenv(func, instance.env)

		instance.scripts[filename] = func
	end

	return true, instance
end

function SF.Instance:AddHook(name, func)
	local hook = self.sfhooks[name]
	if hook then
		hook[#hook + 1] = func
	else
		self.sfhooks[name] = {func}
	end
end

function SF.Instance:RunHook(name, ...)
	local hook = self.sfhooks[name]
	if hook then
		for i = 1, #hook do
			hook[i](...)
		end
	end
end

function SF.RegisterLibrary(name)
	SF.Libraries[name] = true
end

function SF.RegisterType(name, weakwrapper, weaksensitive, target_metatable, supertype, customwrappers)
	SF.Types[name] = {
		weakwrapper = weakwrapper,
		weaksensitive = weaksensitive,
		target_metatable = target_metatable,
		supertype = supertype,
		customwrappers = customwrappers,
	}
end

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

function SF.Instance:BuildEnvironment()
	self.Libraries = {}
	self.Types = {}
	self.env = {}

	local object_wrappers = {}
	local object_unwrappers = {}
	self.object_wrappers = object_wrappers
	self.object_unwrappers = object_unwrappers

	function self.CheckType(val, typ, level)
		local meta = dgetmeta(val)
		if meta ~= typ and (meta == nil or meta.supertype ~= typ or object_unwrappers[meta] == nil) then
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
		-- Clientside holograms don't have a gmod metatype so check manually
		if isentity(object) and object.IsSFHologram then
			return self.Types.Hologram.Wrap(object)
		end
	end
	self.WrapObject = WrapObject

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
	self:DoAliases()
end

-- Backward compatability
function SF.Instance:DoAliases()
	self.env.holograms = self.env.hologram
	self.env.sounds = self.env.sound

	local trace = self.env.trace
	if trace then
		trace.trace = trace.line
		trace.traceHull = trace.hull
	end

	local bass_methods = self.Types.Bass and self.Types.Bass.Methods
	if bass_methods then
		bass_methods.destroy = bass_methods.stop
	end
	local ents_methods = self.Types.Entity and self.Types.Entity.Methods
	if ents_methods then
		ents_methods.unparent = ents_methods.setParent
	end

	self.env.quotaUsed = self.env.cpuUsed
	self.env.quotaAverage = self.env.cpuAverage
	self.env.quotaTotalUsed = self.env.cpuTotalUsed
	self.env.quotaTotalAverage = self.env.cpuTotalAverage
	self.env.quotaMax = self.env.cpuMax
end

--- Overridable hook for pcall-based hook systems
-- Gets called when inside a starfall context
-- @param running Are we executing a starfall context?
function SF.OnRunningOps(running)
	-- override me
end
SF.runningOps = false

local function safeThrow(self, msg, nocatch, force)
	if force or string.find(debug.getinfo(3, "S").short_src, "SF:", 1, true) then
		if SERVER and nocatch then
			local consolemsg = "[Starfall] CPU usage exceeded!"
			if self.player:IsValid() then
				consolemsg = consolemsg .. " by " .. self.player:Nick() .. " (" .. self.player:SteamID() .. ")"
			end
			SF.Print(nil, consolemsg .. "\n")
			MsgC(Color(255,0,0), consolemsg .. "\n")
		end
		SF.Throw(msg, 3, nocatch)
	end
end

local function cpuRatio(instance)
	local t = SysTime()
	instance.cpu_total = instance.cpu_total + t - instance.start_time
	instance.start_time = t
	return instance:movingCPUAverage() / instance.cpuQuota
end

SF.Instance.Ram = 0
SF.Instance.RamAvg = 0
local function ramRatio()
	local ram = collectgarbage("count")
	SF.Instance.Ram = ram
	SF.Instance.RamAvg = SF.Instance.RamAvg + (ram - SF.Instance.RamAvg)*0.001
	return ram / ramlimit
end

function SF.Instance:setCheckCpu(runWithOps)
	if runWithOps then
		self.run = SF.Instance.runWithOps

		function self:checkCpu()
			local ratio = cpuRatio(self)
			if ratio > self.cpu_softquota then
				if ratio>1 then
					safeThrow(self, "CPU usage exceeded!", true, true)
				else
					safeThrow(self, "CPU usage warning!")
				end
			end
			if ramRatio() > 1 then
				safeThrow(self, "RAM usage exceeded!", true, true)
			end
		end

		function self.checkCpuHook() --debug.sethook doesn't pass self, so need it as upvalue
			local ratio = cpuRatio(self)
			if ratio > self.cpu_softquota then
				if ratio>1 then
					safeThrow(self, "CPU usage exceeded!", true, ratio>1.5)
				else
					safeThrow(self, "CPU usage warning!")
				end
			end
			local rratio = ramRatio()
			if rratio > 1 then
				safeThrow(self, "RAM usage exceeded!", true, rratio > 1.05)
			end
		end

		function self:pushCpuCheck(callback)
			self.cpustatestack[#self.cpustatestack + 1] = (dgethook() or false)
			local enabled = callback~=nil
			if SF.runningOps ~= enabled then
				SF.runningOps = enabled
				SF.OnRunningOps(enabled)
			end
			dsethook(callback, "", 2000)
		end
		
		function self:popCpuCheck()
			local callback = (table.remove(self.cpustatestack) or nil)
			dsethook(callback, "", 2000)
			local enabled = callback~=nil
			if SF.runningOps ~= enabled then
				SF.runningOps = enabled
				SF.OnRunningOps(enabled)
			end
		end

		self.cpuQuota = (SERVER or LocalPlayer() ~= self.player) and SF.cpuQuota:GetFloat() or SF.cpuOwnerQuota:GetFloat()
		self.cpuQuotaRatio = 1 / SF.cpuBufferN:GetInt()
	else
		self.run = SF.Instance.runWithoutOps
		function self.checkCpu() end
		function self.checkCpuHook() end
		function self.pushCpuCheck() end
		function self.popCpuCheck() end
		self.cpuQuota = math.huge
		self.cpuQuotaRatio = 0
	end
end

function SF.Instance:runExternal(func, ...)
	self:pushCpuCheck()
	local ok, err = xpcall(func, debug.traceback, ...)
	self:popCpuCheck()
	if ok then return err else ErrorNoHalt(err) end
end

local function xpcall_callback(err)
	if dgetmeta(err)~=SF.Errormeta then
		return SF.MakeError(err, 1)
	end
	return err
end

function SF.Instance:runWithOps(func, ...)
	if self.stackn == 0 then
		self.start_time = SysTime()
	elseif self.stackn == 128 then
		return {false, SF.MakeError("sf stack overflow", 1, true, true)}
	end

	self.stackn = self.stackn + 1
	self:pushCpuCheck(self.checkCpuHook)
	local tbl = { xpcall(func, xpcall_callback, ...) }
	self:popCpuCheck()
	self.stackn = self.stackn - 1

	if tbl[1] then
		if cpuRatio(self)>1 then return {false, SF.MakeError("CPU usage exceeded!", 1, true, true)} end
		if ramRatio()>1 then return {false, SF.MakeError("RAM usage exceeded!", 1, true, true)} end
	end

	return tbl
end

function SF.Instance:runWithoutOps(func, ...)
	return { xpcall(func, xpcall_callback, ...) }
end

function SF.Instance:initialize()
	self.cpu_total = 0
	self.cpu_average = 0
	self.cpu_softquota = 1

	SF.allInstances[self] = true
	if rawget(SF.playerInstances, self.player)==nil then SF.playerInstances[self.player]={} end
	SF.playerInstances[self.player][self] = true

	self:RunHook("initialize")

	local func = self.scripts[self.mainfile]
	if func then
		local tbl = self:run(func)
		if not tbl[1] then
			self:Error(tbl[2])
			return false, tbl[2]
		end
	end

	return true
end

function SF.Instance:runScriptHook(hook, ...)
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

function SF.Instance:runScriptHookForResult(hook, ...)
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

function SF.Instance:runFunction(func, ...)
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

function SF.Instance:deinitialize()
	self:RunHook("deinitialize")
	SF.allInstances[self] = nil
	SF.playerInstances[self.player][self] = nil
	if table.IsEmpty(SF.playerInstances[self.player]) then SF.playerInstances[self.player] = nil end

	self.error = true
	local noop = function() return {} end
	self.runScriptHook = noop
	self.runScriptHookForResult = noop
	self.runFunction = noop
	self.deinitialize = noop
	self.Error = noop
end

hook.Add("Think", "SF_Think", function()

	-- Check and attempt recovery from potential failures
	if SF.runningOps then
		SF.runningOps = false
		SF.OnRunningOps(false)
		ErrorNoHalt("[Starfall] ERROR: This should not happen, bad addons?\n")
	end

	for pl, insts in pairs(SF.playerInstances) do
		local plquota = math.huge
		local cputotal = 0
		for instance in pairs(insts) do
			instance.cpu_average = instance:movingCPUAverage()
			instance.cpu_total = 0
			instance:runScriptHook("think")
			cputotal = cputotal + instance.cpu_average
			plquota = math.min(plquota, instance.cpuQuota)
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

function SF.Instance:Error(err)
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


