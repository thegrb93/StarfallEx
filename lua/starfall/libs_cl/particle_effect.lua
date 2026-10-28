local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local IsValid = IsValid

-- Create permission types.
registerprivilege("particleEffect.attach", "Attach a particle effect", "Allows users to attach particle effects to entities", { client = {}, entities = {} })

local plyCount = SF.LimitObject("particleeffects", "particle effects", 16, "The number of created particle effects via Starfall per client at once")
SF.ResourceCounters.ParticleEffects = {icon = "icon16/asterisk_orange.png", count = function(ply) return plyCount:get(ply) end}

--- ParticleEffect library.
-- @name particleEffect
-- @class library
-- @libtbl particleef_library
SF.RegisterLibrary("particleEffect")

--- ParticleEffect type
-- @name ParticleEffect
-- @class type
-- @libtbl particleef_methods
SF.RegisterType("ParticleEffect", false, false)

local PCFEffectMap
local PCFFile = {
	__index = {
		parse = function(self)
			if self.file == nil then error("Failed to open file!") end
			local header = self:readString()
			local version = tonumber(string.sub(header, 26, 26)) or error("Unknown version found!")
			if version > 5 then error("Incompatible PCF version: "..version) end
		
			local strings
			if version > 1 then
				strings = {}
				for i=1, self:readIndex(version > 3) do
					strings[i] = self:readString()
				end
			end

			for i=1, self:readIndex(true) do
				local typename
				if version > 1 then
					local index = self:readIndex(version > 4)
					typename = strings[index+1] or error("Invalid string index: "..index)
				else
					typename = self:readString()
				end

				local name
				if version > 3 then
					local index = self:readIndex(version > 4)
					name = strings[index+1] or error("Invalid string index: "..index)
				else
					name = self:readString()
				end

				-- Skip UUID
				self:checkload(16)
				self.stream:skip(16)

				if typename == "DmeParticleSystemDefinition" then
					PCFEffectMap.pcfByEffect[string.lower(name)] = self.path
				end
			end

		end,

		readIndex = function(self, wide)
			if wide then
				self:checkload(4)
				return self.stream:readUInt32()
			else
				self:checkload(2)
				return self.stream:readUInt16()
			end
		end,

		readString = function(self)
			local str = nil
			while true do
				local s = self.stream:readUntil(0)
				if #s == 0 then
					self:load()
				elseif string.byte(s, #s) == 0 then
					if str == nil then
						return string.sub(s, 1, -2)
					else
						str[#str+1] = string.sub(s, 1, -2)
						return table.concat(str)
					end
				else
					if str == nil then
						str = {s}
					else
						str[#str+1] = s
					end
					self:load()
				end
			end
		end,

		load = function(self)
			-- Load in 16kb chunks
			if self.file:EndOfFile() then error("Unexpected EOF while reading file!") end
			self.stream[#self.stream + 1] = self.file:Read(16384)
		end,

		checkload = function(self, size)
			if self.stream.index > #self.stream or self.stream.subindex + size > 16384 then
				self:load()
			end
		end,
	},
	__call = function(t, path)
		local self = setmetatable({
			path = path,
			file = file.Open(path, "rb", "GAME"),
			stream = SF.StringStream()
		}, t)

		local ok, err = xpcall(self.parse, debug.traceback, self)
		if not ok then ErrorNoHalt("Error parsing PCF \""..path.."\": "..tostring(err)) end
		if self.file then self.file:Close() end
	end,
}
setmetatable(PCFFile, PCFFile)

PCFEffectMap = {
	initialize = function(self)
		hook.Add("Think", "sf_pcf_map", coroutine.wrap(function()
			local deadline = SysTime() + 0.005
			for _, path in ipairs(file.Find("particles/*.pcf", "GAME")) do
				PCFFile("particles/"..path)

				if SysTime() > deadline then
					coroutine.yield()
					deadline = SysTime() + 0.005
				end
			end
			hook.Remove("Think", "sf_pcf_map")
		end))
		return self
	end,

	getEffect = function(self, name)
		if rawget(self.cachedEffects, name) then return true end
		local pcf = self.pcfByEffect[name]
		return pcf ~= nil and self.cachedPcfs[pcf] and self.cachedEffects[name]
	end,

	pcfByEffect = {},
	cachedPcfs = setmetatable({},{__index = function(t,k) game.AddParticles(k) t[k]=true return true end}),
	cachedEffects = setmetatable({},{__index = function(t,k) PrecacheParticleSystem(k) t[k]=true return true end}),
	blacklistedEffects = {
		["frozen_steam"] = true,
		["portal_rift_01"] = true,
		["explosion_silo"] = true,
		["citadel_shockwave_06"] = true,
		["citadel_shockwave"] = true,
		["choreo_launch_rocket_start"] = true,
		["choreo_launch_rocket_jet"] = true,
	},
}
SF.PCFEffectMap = PCFEffectMap:initialize()

local function checkValid(peff)
	if not peff:IsValid() then
		SF.Throw("ParticleEffect emitter is no longer valid.", 3)
	end
	return peff -- for method chaining (simpler code)
end

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local particleef_library = instance.Libraries.particleEffect
local particleef_methods = instance.Types.ParticleEffect.Methods

local particle_meta, wrap, unwrap = instance.Types.ParticleEffect, instance.Types.ParticleEffect.Wrap, instance.Types.ParticleEffect.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local vunwrap1
local particleEffects = {}
instance:AddHook("initialize", function()
	vunwrap1 = vec_meta.QuickUnwrap1
end)

instance:AddHook("deinitialize", function()
	-- Remove all
	for p in pairs(particleEffects) do
		if p:IsValid() then
			p:StopEmissionAndDestroyImmediately()
		end
		plyCount:free(instance.player, 1)
	end
end)


--- Creates a particle effect (and attaches it to an entity).
-- @param Entity entity The entity to attach the particle effect to (can be world)
-- @param string name The name of the effect to create (e.g. "generic_smoke")
-- @param number pattach See PATTACH enum
-- @param table? options Optional table of tables (indexes 1 to 64) having the following structure:
-- number attachtype - The particle attach type (see PATTACH enum, default: `PATTACH.ABSORIGIN`).
-- Entity entity - The parent entity (default: NULL).
-- Vector position - The offset position for the given control point (default: nil).
-- This only affects the control points of the particle effects, and will do nothing if the effect doesn't use control points.
-- @return ParticleEffect ParticleEffect object.
function particleef_library.attach(entity, name, pattach, options)
	entity = eunwrap(entity)
	checkluatype(name, TYPE_STRING)
	checkluatype(pattach, TYPE_NUMBER)

	checkpermission(instance, entity, "particleEffect.attach")
	plyCount:checkuse(instance.player, 1)

	name = string.gsub(string.lower(name), "\x00.*", "")

	if instance.player ~= SF.Superuser then
		if PCFEffectMap.blacklistedEffects[name] then SF.Throw("Tried to use blacklisted particle effect: "..name, 2) end
		if hook.Run("Starfall_CanParticleEffect", name, instance) == false then SF.Throw("Effect hook blocked using "..name, 2) end
	end
	if not PCFEffectMap:getEffect(name) then
		SF.Throw("Invalid particle effect system name: "..name, 2)
	end

	-- Sanitize the options table.
	local cleanOptions
	if options then
		checkluatype(options, TYPE_TABLE)
		cleanOptions = {}
		for i = 1, math.min(#options, 64) do
			local cp = options[i]
			if cp then
				checkluatype(cp, TYPE_TABLE)
				local clean = {}
				-- All fields are optional
				if cp.attachtype ~= nil then
					checkluatype(cp.attachtype, TYPE_NUMBER)
					clean.attachtype = cp.attachtype
				end
				if cp.entity ~= nil then
					clean.entity = eunwrap(cp.entity)
				end
				if cp.position ~= nil then
					clean.position = vunwrap1(cp.position)
				end
				cleanOptions[i] = clean
			end
		end
	end

	local pEffect = entity:CreateParticleEffect(name, pattach, cleanOptions)
	if not IsValid(pEffect) then
		SF.Throw("Invalid particle effect system.", 2)
	end

	plyCount:free(instance.player, -1)
	particleEffects[pEffect] = true
	return wrap(pEffect)
end

--- Returns a list of particle system names able to be used
-- @return table List of particle system names
function particleef_library.getList()
	local ret = {}
	for name in pairs(PCFEffectMap.pcfByEffect) do
		if not PCFEffectMap.blacklistedEffects[name] then
			ret[#ret+1] = name
		end
	end
	return ret
end

--- Determines whether the particle effect is valid or not.
-- @return boolean Is valid or not
function particleef_methods:isValid()
	return IsValid(particle_meta.sf2sensitive[self])
end

--- Starts emission of the particle effect.
function particleef_methods:startEmission()
	checkValid(unwrap(self)):StartEmission()
end

--- Stops emission of the particle effect.
function particleef_methods:stopEmission()
	checkValid(unwrap(self)):StopEmission()
end

--- Stops emission of the particle effect and destroys the object.
function particleef_methods:destroy()
	local peff = unwrap(self)
	if particleEffects[peff] then
		if peff:IsValid() then
			peff:StopEmissionAndDestroyImmediately()
		end
		particleEffects[peff] = nil
		plyCount:free(instance.player, 1)
		particle_meta.sf2sensitive[self] = nil -- make sure that future unwrap throws an error
	end
end

--- Restarts emission of the particle effect.
function particleef_methods:restart()
	checkValid(unwrap(self)):Restart()
end

--- Determines if the particle effect is finished.
-- @return boolean True if the particle effect is finished
function particleef_methods:isFinished()
	local peff = unwrap(self)
	return not peff:IsValid() or peff:IsFinished()
end

--- Sets the sort origin for the given particle effect system.
-- This is used as a helper to determine which particles are in front of which.
-- @param Vector origin Sort origin
function particleef_methods:setSortOrigin(origin)
	checkValid(unwrap(self)):SetSortOrigin(vunwrap1(origin))
end

--- Sets a value for the given control point.
-- @param number id Control point index (from 0 to 63)
-- @param Vector value Value
function particleef_methods:setControlPoint(id, value)
	checkluatype(id, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPoint(id, vunwrap1(value))
end

--- Essentially makes child control point follow the parent entity.
-- @param number id Child control point index (from 0 to 63)
-- @param Entity entity Entity parent
function particleef_methods:setControlPointEntity(id, entity)
	checkluatype(id, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPointEntity(id, eunwrap(entity))
end

--- Sets the forward direction for the given control point.
-- @param number id Control point index (from 0 to 63)
-- @param Vector value Forward vector
function particleef_methods:setForwardVector(id, value)
	checkluatype(id, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPointForwardVector(id, vunwrap1(value))
end

--- Sets the right direction for the given control point.
-- @param number id Control point index (from 0 to 63)
-- @param Vector value Right vector
function particleef_methods:setRightVector(id, value)
	checkluatype(id, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPointRightVector(id, vunwrap1(value))
end

--- Sets the up direction for the given control point.
-- @param number id Control point index (from 0 to 63)
-- @param Vector value Up vector
function particleef_methods:setUpVector(id, value)
	checkluatype(id, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPointUpVector(id, vunwrap1(value))
end

--- Sets the parent for the given control point.
-- @param number id Child control point index (from 0 to 63)
-- @param number parentid Parent control point index (from 0 to 63)
function particleef_methods:setControlPointParent(id, parentid)
	checkluatype(id, TYPE_NUMBER)
	checkluatype(parentid, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPointParent(id, parentid)
end

end
