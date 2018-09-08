SF.Light = {}

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("light.create", "Create dynamic lights.", "Allows creation of dynamic lights.", { client = {} })
end

--- Light type
-- @shared
local light_methods, light_metamethods = SF.RegisterType("Light")
local wrap, unwrap = SF.CreateWrapper(light_metamethods, true, false)
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

-- @client
local light_library = SF.RegisterLibrary("light")

SF.Light.Wrap = wrap
SF.Light.Unwrap = unwrap
SF.Light.Methods = light_methods
SF.Light.Metatable = light_metamethods

local vec_meta, col_meta
local vwrap, vunwrap, cwrap, cunwrap

SF.AddHook("postload", function()
	vec_meta = SF.Vectors.Metatable
	col_meta = SF.Color.Metatable

	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap
	cwrap = SF.Color.Wrap
	cunwrap = SF.Color.Unwrap
end)

local gSFLights = {}
local gSFLightsQueue = {}
local gGmodLights = {}
local gGmodWireLights = {}

local function getFreeSlot()
	for i=1, 65536 do
		if not gSFLights[i] and not gGmodLights[i] and not gGmodWireLights[i] then
			return i
		end
	end
end

local lightTable = {
	gmod_light = gGmodLights,
	gmod_wire_light = gGmodWireLights
}

hook.Add("NetworkEntityCreated","SF_TrackLights",function(e)
	local index = e:EntIndex()
	local ltable = lightTable[e:GetClass()]
	if ltable and not ltable[index] then
		local sfLight = gSFLights[index]
		if sfLight then
			v.slot = getFreeSlot()
			if v.slot then
				gSFLights[v.slot] = v
			else
				-- Couldn't reallocate, just remove it
				for k, v in pairs(gSFLightsQueue) do
					if v == sfLight then table.remove(gSFLightsQueue, k) break end
				end
			end
			gSFLights[index] = nil
		end
		ltable[index] = e
	end
end)

hook.Add("EntityRemoved","SF_TrackLights",function(e)
	local index = e:EntIndex()
	gGmodLights[index] = nil
	gGmodWireLights[index] = nil
end)

local function processLights()
	local used = 0
	for k, v in pairs(gGmodLights) do
		if v:GetOn() then used = used + 1 end
	end
	for k, v in pairs(gGmodWireLights) do
		if v:GetGlow() then used = used + 1 end
	end
	local curtime = CurTime()
	for i=1, #gSFLightsQueue do
		if used >= 32 then break end
		local light = gSFLightsQueue[i]
		if light.on then
			used = used + 1
			local dynlight = DynamicLight(light.slot)
			if dynlight then
				for k, v in pairs(light.data) do dynlight[k] = v end
				dynlight.dietime = curtime + light.dietime
			end
		end
	end
end

-- Register functions to be called when the chip is initialised and deinitialised
SF.AddHook("initialize", function(inst)
	inst.data.light = {lights={}}
end)

SF.AddHook("deinitialize", function(inst)
	local lights = inst.data.light.lights
	local i = 1
	while i<=#gSFLightsQueue do
		local light = gSFLightsQueue[i]
		if lights[light] then
			table.remove(gSFLightsQueue, i)
			gSFLights[light.slot] = nil
		else
			i = i + 1
		end
	end
	if #gSFLightsQueue == 0 then
		hook.Remove("Think", "SF_ProcessLights")
	end
end)

--- Creates a dynamic light
function light_library.create(pos, size, brightness, color, on)
	local lightCount = #gSFLightsQueue
	if lightCount >= 256 then SF.Throw("Too many lights have already been allocated (max 256)", 2) end
	checkpermission(SF.instance, nil, "light.create")
	checktype(pos, vec_meta)
	checkluatype(size, TYPE_NUMBER)
	checkluatype(brightness, TYPE_NUMBER)
	checktype(color, col_meta)
	checkluatype(on, TYPE_BOOL)
	local slot = getFreeSlot()
	if not slot then SF.Throw("Failed to allocate slot for the light", 2) end

	local col = cunwrap(color)
	local light = {
		data = {pos = vunwrap(pos), size = size, brightness = brightness, r=col.r, g=col.g, b=col.b, decay = 1000},
		slot = slot,
		dietime = 1,
		on = on
	}

	SF.instance.data.light.lights[light] = true
	gSFLights[slot] = light
	gSFLightsQueue[lightCount + 1] = light
	if lightCount == 0 then hook.Add("Think", "SF_ProcessLights", processLights) end

	return wrap(light)
end

--- Sets the light to be on or not
-- @param on Whether the light is on or not
function light_methods:setOn(on)
	checktype(self, light_metamethods)
	checkluatype(on, TYPE_BOOL)
	unwrap(self).on = on
end

--- Sets the light brightness
-- @param brightness The light's brightness
function light_methods:setBrightness(brightness)
	checktype(self, light_metamethods)
	checkluatype(brightness, TYPE_NUMBER)
	unwrap(self).data.brightness = brightness
end

--- Sets the light decay speed in thousandths per second. 1000 lasts for 1 second, 2000 lasts for 0.5 seconds
-- @param decay The light's decay speed
function light_methods:setDecay(decay)
	checktype(self, light_metamethods)
	checkluatype(decay, TYPE_NUMBER)
	unwrap(self).data.decay = decay
end

--- Sets the light lifespan (Required for fade effect i.e. decay)
-- @param dietime The how long the light will stay alive after turning it off.
function light_methods:setDieTime(dietime)
	checktype(self, light_metamethods)
	checkluatype(dietime, TYPE_NUMBER)
	unwrap(self).dietime = math.max(dietime, 0)
end

--- Sets the light direction (used with setInnerAngle and setOuterAngle)
-- @param dir Direction of the light
function light_methods:setDirection(dir)
	checktype(self, light_metamethods)
	checkluatype(dir, vec_meta)
	unwrap(self).data.dir = vunwrap(dir) 
end

--- Sets the light inner angle (used with setDirection and setOuterAngle)
-- @param ang Number inner angle of the light
function light_methods:setInnerAngle(ang)
	checktype(self, light_metamethods)
	checkluatype(ang, TYPE_NUMBER)
	unwrap(self).data.innerangle = ang
end

--- Sets the light outer angle (used with setDirection and setInnerAngle)
-- @param ang Number outer angle of the light
function light_methods:setOuterAngle(ang)
	checktype(self, light_metamethods)
	checkluatype(ang, TYPE_NUMBER)
	unwrap(self).data.outerangle = ang
end

--- Sets the minimum light amount
-- @param min The minimum light
function light_methods:setMinLight(min)
	checktype(self, light_metamethods)
	checkluatype(min, TYPE_NUMBER)
	unwrap(self).data.minlight = min
end

--- Sets whether the light should cast onto the world or not
-- @param on Whether the light shouldn't cast onto the world
function light_methods:setNoWorld(on)
	checktype(self, light_metamethods)
	checkluatype(on, TYPE_BOOL)
	unwrap(self).data.noworld = on
end

--- Sets whether the light should cast onto models or not
-- @param on Whether the light shouldn't cast onto the models
function light_methods:setNoModel(on)
	checktype(self, light_metamethods)
	checkluatype(on, TYPE_BOOL)
	unwrap(self).data.nomodel = on
end

--- Sets the light position
-- @param pos The position of the light
function light_methods:setPos(pos)
	checktype(self, light_metamethods)
	checkluatype(pos, vec_meta)
	unwrap(self).data.pos = vunwrap(pos) 
end

--- Sets the size of the light (max is 1024)
-- @param size The size of the light
function light_methods:setSize(size)
	checktype(self, light_metamethods)
	checkluatype(size, TYPE_NUMBER)
	unwrap(self).data.size = size
end

--- Sets the flicker style of the light https://developer.valvesoftware.com/wiki/Light_dynamic#Appearances
-- @param style The number of the flicker style
function light_methods:setStyle(style)
	checktype(self, light_metamethods)
	checkluatype(style, TYPE_NUMBER)
	unwrap(self).data.style = style
end

--- Sets the color of the light
-- @param color The color of the light
function light_methods:setColor(color)
	checktype(self, light_metamethods)
	checktype(color, col_meta)
	local col = cunwrap(color)
	local data = unwrap(self).data
	data.r = col.r
	data.g = col.g
	data.b = col.b
end

