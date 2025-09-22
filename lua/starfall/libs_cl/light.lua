-- Global to each starfall
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

-- Register privileges
registerprivilege("light.create", "Create dynamic lights.", "Allows creation of dynamic lights.", { client = {} })

local maxSize = CreateClientConVar( "sf_light_maxsize", "1024", true, false, "Max size lights can be" )

SF.ResourceCounters.Lights = {icon = "icon16/lightbulb.png", count = function(ply)
	local total = 0
	for instance in pairs(SF.playerInstances[ply]) do
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

local ENT_META = FindMetaTable("Entity")
local Ent_EntIndex = ENT_META.EntIndex
hook.Add("EntityRemoved","SF_TrackLights",function(e)
	local index = Ent_EntIndex(e)
	gGmodLights[index] = nil
	gGmodWireLights[index] = nil
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

local projectedLights = SF.EntManager("projectedlights", "projected lights", 20, "The number of projected light objects allowed to spawn via Starfall", 1, true)

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

--- Projected Texture type
-- @name ProjectedTexture
-- @class type
-- @libtbl projectedtexture_methods
SF.RegisterType("ProjectedTexture", true, false)



return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local light_library = instance.Libraries.light
local light_methods, light_meta, wrap, unwrap = instance.Types.Light.Methods, instance.Types.Light, instance.Types.Light.Wrap, instance.Types.Light.Unwrap
local projectedtexture_methods, projectedtexture_meta, ptwrap, ptunwrap = instance.Types.ProjectedTexture.Methods, instance.Types.ProjectedTexture, instance.Types.ProjectedTexture.Wrap, instance.Types.ProjectedTexture.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap

local numlights = 0
local lights = {}
local function registerLight(light)
	lights[light] = true
	gSFLights[light.slot] = light
	numlights = numlights + 1
end
local function destroyLight(light)
	if lights[light] then
		lights[light] = nil
		gSFLights[light.slot] = nil
		numlights = numlights - 1
	end
end

local vunwrap1
instance:AddHook("initialize", function()
	vunwrap1 = vec_meta.QuickUnwrap1
end)

instance.data.light = {lights = lights}
instance:AddHook("deinitialize", function()
	for light in pairs(lights) do
		gSFLights[light.slot] = nil
	end
	projectedLights:deinitialize(instance, true)
end)

--- Creates a dynamic light (make sure to draw it)
-- @param Vector pos The position of the light
-- @param number size The size of the light. Must be lower than sf_light_maxsize
-- @param number brightness The brightness of the light
-- @param Color color The color of the light
-- @return Light Dynamic light
function light_library.create(pos, size, brightness, color)
	if numlights >= 256 then SF.Throw("Too many lights have already been allocated (max 256)", 2) end
	if maxSize:GetFloat() == 0 then SF.Throw("sf_light_maxsize is set to 0", 2) end
	checkpermission(instance, nil, "light.create")
	checkluatype(size, TYPE_NUMBER)
	checkluatype(brightness, TYPE_NUMBER)
	local slot = getFreeSlot()
	if not slot then SF.Throw("Failed to allocate slot for the light", 2) end

	local light = {
		data = {pos = vunwrap(pos), size = math.Clamp(size, 0, maxSize:GetFloat()), brightness = brightness, r=tonumber(color[1]), g=tonumber(color[2]), b=tonumber(color[3]), decay = 1000, dir=Vector()},
		slot = slot,
		dietime = 1
	}

	registerLight(light)
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
	unwrap(self).data.dir:SetUnpacked(dir[1], dir[2], dir[3])
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
	unwrap(self).data.pos:SetUnpacked(pos[1], pos[2], pos[3])
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
function light_methods:setColor(col)
	local data = unwrap(self).data
	data.r = tonumber(col[1])
	data.g = tonumber(col[2])
	data.b = tonumber(col[3])
end

--- Destroys the light object freeing up whatever slot it was using
function light_methods:destroy()
	local light = unwrap(self)
	destroyLight(light)
	light_meta.sf2sensitive[self] = nil
	light_meta.sensitive2sf[light] = nil
end


--- Creates a projected texture
-- @return ProjectedTexture Projected Texture
function light_library.createProjected()
	projectedLights:checkuse(instance.player, 1)

	local light = ProjectedTexture()
	projectedLights:register(instance, light)

	return ptwrap(light)
end

--- Gets the angles of the Projected Texture
-- @return Angle Angles
function projectedtexture_methods:getAngles()
	return awrap(ptunwrap(self):GetAngles())
end

--- Gets the brightness of the Projected Texture
-- @return number brightness
function projectedtexture_methods:getBrightness()
	return ptunwrap(self):GetBrightness()
end

--- Gets the color of the Projected Texture
-- @return Color col
function projectedtexture_methods:getColor()
	return cwrap(ptunwrap(self):GetColor())
end

--- Gets the constant attenuation of the Projected Texture
-- @return number attenuation
function projectedtexture_methods:getConstantAttenuation()
	return ptunwrap(self):GetConstantAttenuation()
end

--- Gets if the Projected Texture is casting shadows
-- @return boolean enabled
function projectedtexture_methods:getEnableShadows()
	return ptunwrap(self):GetEnableShadows()
end

--- Gets the distance at which the Projected Texture ends
-- @return number farZ
function projectedtexture_methods:getFarZ()
	return ptunwrap(self):GetFarZ()
end

--- Gets the horizontal FOV of the Projected Texture
-- @return number fov
function projectedtexture_methods:getHorizontalFOV()
	return ptunwrap(self):GetHorizontalFOV()
end

--- Gets whether the Projected Texture is lighting world geometry or not
-- @return boolean Lighting
function projectedtexture_methods:getLightWorld()
	return ptunwrap(self):GetLightWorld()
end

--- Gets the linear attenuation of the Projected Texture
-- @return number attenuation
function projectedtexture_methods:getLinearAttentuation()
	return ptunwrap(self):GetLinearAttentuation()
end

--- Gets the linear attenuation of the Projected Texture
-- @return number attenuation
function projectedtexture_methods:getLinearAttentuation()
	return ptunwrap(self):GetLinearAttentuation()
end

--- Gets the near z of the Projected Texture
-- @return number nearZ
function projectedtexture_methods:getNearZ()
	return ptunwrap(self):GetNearZ()
end

--- Gets the culling of the Projected Texture
-- @return boolean nocull
function projectedtexture_methods:getNoCull()
	return ptunwrap(self):GetNoCull()
end

--- Gets the orthographic settings of the Projected Texture
-- @return boolean orthographic Whether or not the Projected Texture is actually orthographic. If false, then the other value are not returned.
-- @return number left
-- @return number top
-- @return number right
-- @return number botom
function projectedtexture_methods:getOrthographic()
	return ptunwrap(self):GetOrthographic()
end

--- Gets the position of the Projected Texture
-- @return Vector Pos
function projectedtexture_methods:getPos()
	return vwrap(ptunwrap(self):GetPos())
end

--- Gets the quadratic attenuation of the Projected Texture
-- @return number Attenuation
function projectedtexture_methods:getQuadraticAttentuation()
	return ptunwrap(self):GetQuadraticAttentuation()
end

--- Gets the shadow depth bias of the Projected Texture
-- @return number bias
function projectedtexture_methods:getShadowDepthBias()
	return ptunwrap(self):GetShadowDepthBias()
end

--- Gets the shadow filter size of the Projected Texture
-- @return number filter
function projectedtexture_methods:getShadowFilter()
	return ptunwrap(self):GetShadowFilter()
end

--- Gets the Projected Texture's shadow depth slope scale bias
-- @return number bias
function projectedtexture_methods:getShadowSlopeScaleDepthBias()
	return ptunwrap(self):GetShadowSlopeScaleDepthBias()
end

--- Gets the target entity of the Projected Texture
-- @return Entity target
function projectedtexture_methods:getTargetEntity()
	return ewrap(ptunwrap(self):GetTargetEntity())
end

--- Gets the texture frame of the Projected Texture
-- @return number frame
function projectedtexture_methods:getTextureFrame()
	return ptunwrap(self):GetTextureFrame()
end

--- Gets the vertical FOV of the Projected Texture
-- @return number fov
function projectedtexture_methods:getVerticalFOV()
	return ptunwrap(self):GetVerticalFOV()
end

--- Returns whether this Projected Texture is valid or not.
-- @return boolean valid
function projectedtexture_methods:isValid()
	return ptunwrap(self):IsValid()
end

--- Removes the Projected Texture
function projectedtexture_methods:remove()
	local light = ptunwrap(self)
	projectedLights:remove(light)
	projectedtexture_meta.sf2sensitive[self] = nil
	projectedtexture_meta.sensitive2sf[light] = nil
end

--- Sets the Projected Texture's angles
-- Will not take effect until ProjectedTexture:update() is called.
--@param Angle ang New angles
function projectedtexture_methods:setAngles(ang)
	ptunwrap(self):SetAngles(aunwrap(ang))
end

--- Sets the Projected Texture's brightness
-- Will not take effect until ProjectedTexture:update() is called.
--@param number brightness
function projectedtexture_methods:setBrightness(brightness)
	ptunwrap(self):SetBrightness(brightness)
end

--- Sets the Projected Texture's color
-- Will not take effect until ProjectedTexture:update() is called.
--@param Color col
function projectedtexture_methods:setColor(col)
	ptunwrap(self):SetColor(cunwrap(col))
end

--- Sets the Projected Texture's constant attenuation
-- Will not take effect until ProjectedTexture:update() is called.
--@param number attenuation
function projectedtexture_methods:setConstantAttenuation(attenuation)
	ptunwrap(self):SetConstantAttenuation(attenuation)
end

--- Sets if the Projected Texture should draw shadows
-- Will not take effect until ProjectedTexture:update() is called.
-- Enabling shadows is expensive. Use sparingly.
--@param boolean enabled
function projectedtexture_methods:setEnableShadows(enabled)
	ptunwrap(self):SetEnableShadows(enabled)
end

--- Sets the distance at which the Projected Texture ends
-- Will not take effect until ProjectedTexture:update() is called.
--@param number farZ
function projectedtexture_methods:setFarZ(farZ)
	ptunwrap(self):SetFarZ(farZ)
end

--- Sets the FOV of the Projected texture
-- Clamped between 0 and 180
-- Will not take effect until ProjectedTexture:update() is called.
--@param number fov
function projectedtexture_methods:setFOV(fov)
	ptunwrap(self):SetFOV(fov)
end

--- Sets the horizontal FOV of the Projected texture
-- Clamped between 0 and 180
-- Will not take effect until ProjectedTexture:update() is called.
--@param number fov
function projectedtexture_methods:setHorizontalFOV(fov)
	ptunwrap(self):SetHorizontalFOV(fov)
end

--- Sets whether or not the Projected Texture lights world geometry
-- Will not take effect until ProjectedTexture:update() is called.
--@param boolean enable
function projectedtexture_methods:setLightWorld(enable)
	ptunwrap(self):SetLightWorld(enable)
end

--- Sets the Projected Texture's linear attenuation
-- Will not take effect until ProjectedTexture:update() is called.
--@param number attenuation
function projectedtexture_methods:setLinearAttenuation(attenuation)
	ptunwrap(self):SetLinearAttenuation(attenuation)
end

--- Sets the distance at which the Projected Texture ends
-- A value of 0 will disable the Projected Texture
-- Will not take effect until ProjectedTexture:update() is called.
--@param number nearZ
function projectedtexture_methods:setNearZ(nearZ)
	ptunwrap(self):SetNearZ(nearZ)
end

--- Sets the view-frustum culling of the Projected Texture
-- Will not take effect until ProjectedTexture:update() is called.
--@param boolean enable
function projectedtexture_methods:setNoCull(enable)
	ptunwrap(self):SetNoCull(enable)
end

--- Sets the orthographic settings of the Projected Texture
-- Does not work with shadows
-- Will not take effect until ProjectedTexture:update() is called.
--@param boolean orthographic
--@param number left
--@param number top
--@param number right
--@param number bottom
function projectedtexture_methods:setOrthographic(orthographic, left, top, right, bottom)
	ptunwrap(self):SetOrthographic(orthographic, left, top, right, bottom)
end

--- Sets the Projected Texture's position
-- Will not take effect until ProjectedTexture:update() is called.
--@param Vector pos
function projectedtexture_methods:setPos(pos)
	ptunwrap(self):SetPos(SF.clampPos(vunwrap1(pos)))
end

--- Sets the Projected Texture's quadratic attenuation
-- Will not take effect until ProjectedTexture:update() is called.
--@param number attenuation
function projectedtexture_methods:setQuadraticAttenuation(attenuation)
	ptunwrap(self):SetQuadraticAttenuation(attenuation)
end

--- Sets the Projected Texture's shadow depth bias
-- Will not take effect until ProjectedTexture:update() is called.
--@param number bias
function projectedtexture_methods:setShadowDepthBias(bias)
	ptunwrap(self):SetShadowDepthBias(bias)
end

--- Sets the Projected Texture's shadow filter size
-- 0 looks pixelated, higher values increase blur
-- Will not take effect until ProjectedTexture:update() is called.
--@param number filter
function projectedtexture_methods:setShadowFilter(filter)
	ptunwrap(self):SetShadowFilter(filter)
end

--- Sets the Projected Texture's shadow slope scale depth bias
-- Will not take effect until ProjectedTexture:update() is called.
--@param number bias
function projectedtexture_methods:setShadowSlopeScaleDepthBias(bias)
	ptunwrap(self):SetShadowSlopeScaleDepthBias(bias)
end

--- Sets the Projected Texture's target entity
-- If set, this will be the only entity that is lit, as well as the world
-- Will not take effect until ProjectedTexture:update() is called.
--@param Entity ent
function projectedtexture_methods:setTargetEntity(ent)
	ptunwrap(self):SetTargetEntity(eunwrap(ent))
end

--- Sets the Projected Texture's texture
-- Will not take effect until ProjectedTexture:update() is called.
--@param string texture
function projectedtexture_methods:setTexture(texture)
	ptunwrap(self):SetTexture(texture)
end

--- Sets the Projected Texture's texture frame
-- Will not take effect until ProjectedTexture:update() is called.
--@param number frame
function projectedtexture_methods:setTextureFrame(frame)
	ptunwrap(self):SetTextureFrame(frame)
end

--- Sets the Projected Texture's vertical FOV
-- Clamped between 0 and 180
-- Will not take effect until ProjectedTexture:update() is called.
--@param number fov
function projectedtexture_methods:setVerticalFOV(fov)
	ptunwrap(self):SetVerticalFOV(fov)
end

--- Updates the Projected Texture with whatever paremeters were previously set
function projectedtexture_methods:update()
	ptunwrap(self):Update()
end

end
