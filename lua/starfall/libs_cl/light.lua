-- Global to each starfall
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

-- Register privileges
registerprivilege("light.create", "Create dynamic lights.", "Allows creation of dynamic lights.", { client = {} })

local maxSize = CreateClientConVar( "sf_light_maxsize", "1024", true, false, "Max size lights can be" )

SF.ResourceCounters.Lights = {icon = "icon16/lightbulb.png", count = function(ply)
	local instances = SF.playerInstances[ply]
	if not instances then return 0 end
	local total = 0
	for instance in pairs(instances) do
		total = total + table.Count(instance.data.light.lights)
	end
	return total
end}

local gSFLights = {}
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
			sfLight.slot = getFreeSlot()
			if sfLight.slot then
				gSFLights[sfLight.slot] = sfLight
			end
			gSFLights[index] = nil
		end
		ltable[index] = e
	end
end)

hook.Add("EntityRemoved","SF_TrackLights",function(e)
	local EntIndex = e.EntIndex
	if EntIndex then
		local index = EntIndex(e)
		gGmodLights[index] = nil
		gGmodWireLights[index] = nil
	end
end)

local lastProcess
local lightsUsed = 0
local function processLights(curtime)
	if lastProcess == curtime then return end
	lastProcess = curtime
	lightsUsed = 0
	for k, v in pairs(gGmodLights) do
		if v:GetOn() then lightsUsed = lightsUsed + 1 end
	end
	for k, v in pairs(gGmodWireLights) do
		if v:GetGlow() then lightsUsed = lightsUsed + 1 end
	end
end

--- Light library.
-- @name light
-- @class library
-- @libtbl light_library
SF.RegisterLibrary("light")

--- Light type
-- @name Light
-- @class type
-- @libtbl light_methods
SF.RegisterType("Light", true, false)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local lights = {}
instance.data.light = {lights = lights}
instance:AddHook("deinitialize", function()
	for light in pairs(lights) do
		gSFLights[light.slot] = nil
	end
end)


local light_library = instance.Libraries.light
local light_methods, light_meta, wrap, unwrap = instance.Types.Light.Methods, instance.Types.Light, instance.Types.Light.Wrap, instance.Types.Light.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap


--- Creates a dynamic light (make sure to draw it)
-- @param Vector pos The position of the light
-- @param number size The size of the light. Must be lower than sf_light_maxsize
-- @param number brightness The brightness of the light
-- @param Color color The color of the light
-- @return Light Dynamic light
function light_library.create(pos, size, brightness, color)
	if table.Count(lights) >= 256 then SF.Throw("Too many lights have already been allocated (max 256)", 2) end
	if maxSize:GetFloat() == 0 then SF.Throw("sf_light_maxsize is set to 0", 2) end
	checkpermission(instance, nil, "light.create")
	checkluatype(size, TYPE_NUMBER)
	checkluatype(brightness, TYPE_NUMBER)
	local slot = getFreeSlot()
	if not slot then SF.Throw("Failed to allocate slot for the light", 2) end

	local col = cunwrap(color)
	local light = {
		data = {pos = vunwrap(pos), size = math.Clamp(size, 0, maxSize:GetFloat()), brightness = brightness, r=col.r, g=col.g, b=col.b, decay = 1000},
		slot = slot,
		dietime = 1
	}

	lights[light] = true
	gSFLights[slot] = light

	return wrap(light)
end

--- Draws the light. Typically used in the think hook. Will throw an error if it fails (use pcall)
function light_methods:draw()
	local curtime = CurTime()
	processLights(curtime)
	if lightsUsed >= 32 then SF.Throw("Max number of dynamiclights reached", 2) end
	lightsUsed = lightsUsed + 1
	
	local light = unwrap(self)
	if not light.slot then
		light.slot = getFreeSlot()
		if not light.slot then SF.Throw("Failed to allocate slot for the light", 2) end
	end

	local dynlight = DynamicLight(light.slot)
	if dynlight then
		for k, v in pairs(light.data) do dynlight[k] = v end
		dynlight.dietime = curtime + light.dietime
	end
end

--- Sets the light brightness
-- @param number brightness The light's brightness
function light_methods:setBrightness(brightness)
	checkluatype(brightness, TYPE_NUMBER)
	unwrap(self).data.brightness = brightness
end

--- Sets the light decay speed in thousandths per second. 1000 lasts for 1 second, 2000 lasts for 0.5 seconds
-- @param number decay The light's decay speed
function light_methods:setDecay(decay)
	checkluatype(decay, TYPE_NUMBER)
	unwrap(self).data.decay = decay
end

--- Sets the light lifespan (Required for fade effect i.e. decay)
-- @param number dietime The how long the light will stay alive after turning it off.
function light_methods:setDieTime(dietime)
	checkluatype(dietime, TYPE_NUMBER)
	unwrap(self).dietime = math.max(dietime, 0)
end

--- Sets the light direction (used with setInnerAngle and setOuterAngle)
-- @param Vector dir Direction of the light
function light_methods:setDirection(dir)
	unwrap(self).data.dir = vunwrap(dir)
end

--- Sets the light inner angle (used with setDirection and setOuterAngle)
-- @param number ang Inner angle of the light
function light_methods:setInnerAngle(ang)
	checkluatype(ang, TYPE_NUMBER)
	unwrap(self).data.innerangle = ang
end

--- Sets the light outer angle (used with setDirection and setInnerAngle)
-- @param number ang Outer angle of the light
function light_methods:setOuterAngle(ang)
	checkluatype(ang, TYPE_NUMBER)
	unwrap(self).data.outerangle = ang
end

--- Sets the minimum light amount
-- @param number min The minimum light
function light_methods:setMinLight(min)
	checkluatype(min, TYPE_NUMBER)
	unwrap(self).data.minlight = min
end

--- Sets whether the light should cast onto the world or not
-- @param boolean on Whether the light shouldn't cast onto the world
function light_methods:setNoWorld(on)
	checkluatype(on, TYPE_BOOL)
	unwrap(self).data.noworld = on
end

--- Sets whether the light should cast onto models or not
-- @param boolean on Whether the light shouldn't cast onto the models
function light_methods:setNoModel(on)
	checkluatype(on, TYPE_BOOL)
	unwrap(self).data.nomodel = on
end

--- Sets the light position
-- @param Vector pos The position of the light
function light_methods:setPos(pos)
	unwrap(self).data.pos = vunwrap(pos)
end

--- Sets the size of the light (max is sf_light_maxsize)
-- @param number size The size of the light
function light_methods:setSize(size)
	checkluatype(size, TYPE_NUMBER)
	unwrap(self).data.size = math.Clamp(size, 0, maxSize:GetFloat())
end

--- Sets the flicker style of the light https://developer.valvesoftware.com/wiki/Light_dynamic#Appearances
-- @param number style The number of the flicker style
function light_methods:setStyle(style)
	checkluatype(style, TYPE_NUMBER)
	unwrap(self).data.style = style
end

--- Sets the color of the light
-- @param Color col The color of the light
function light_methods:setColor(color)
	local col = cunwrap(color)
	local data = unwrap(self).data
	data.r = col.r
	data.g = col.g
	data.b = col.b
end

end
