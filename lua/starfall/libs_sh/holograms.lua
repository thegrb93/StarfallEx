
--- Library for creating and manipulating physics-less models AKA "Holograms".
-- @shared
local holograms_library, _ = SF.Libraries.Register("holograms")

local hologram_methods, hologram_metamethods = SF.Typedef("Hologram")
local wrap, unwrap = SF.CreateWrapper(hologram_metamethods,true,false)

SF.Holograms = {}
SF.Holograms.Wrap = wrap
SF.Holograms.Unwrap = unwrap

SF.Libraries.AddHook("initialize",function(inst)
	inst.data.holograms = {
		holos = {},
		count = 0,
	}
end)

SF.Libraries.AddHook("deinitialize", function(inst)
	local holos = inst.data.holograms.holos
	local holo = next(holos)
	while holo do
		local holoent = unwrap(holo)
		if ValidEntity(holoent) then
			holoent:Remove()
		end
		holos[holo] = nil
		holo = next(holos)
	end
	inst.data.holograms.count = 0
end)

local function hologramOnDestroy(holoent, holodata)
	if not holodata.holos then return end
	local holo = wrap(holoent)
	if holodata.holos[holo] then
		holodata.holos[holo] = nil
		holodata.count = holodata.count - 1
		assert(holodata.count >= 0)
	end
end

-- ------------------------ HOLOGRAM CLASS ------------------------ --

--- Sets the hologram position.
function hologram_methods:setPos(pos)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(pos, "Vector")
	local holo = unwrap(self)
	if holo then holo:SetPos(pos) end
end

--- Sets the hologram angle
function hologram_methods:setAng(ang)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(ang, "Angle")
	local holo = unwrap(self)
	if holo then holo:SetAngles(ang) end
end

--- Sets the hologram linear velocity
function hologram_methods:setVel(vel)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(vel, "Vector")
	local holo = unwrap(self)
	if holo then holo:SetLocalVelocity(vel) end
end

--[[
-- Currently only works in GM13 (maybe)

-- Sets the hologram's angular velocity.
-- @param angvel *Vector* angular velocity.
function hologram_methods:setAngVel(angvel)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(angvel, "Angle")
	local holo = unwrap(self)
	if holo then holo:SetLocalAngularVelocity(angvel) end
end
]]

--- Sets the hologram scale
function hologram_methods:setScale(scale)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(scale, "Vector")
	local holo = unwrap(self)
	if holo then
		holo:SetScale(scale)
	end
end

--- Updates a clip plane
function hologram_methods:setClip(index, enabled, origin, normal, islocal)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(index, "number")
	SF.CheckType(enabled, "boolean")
	SF.CheckType(origin, "Vector")
	SF.CheckType(normal, "Vector")
	SF.CheckType(islocal, "boolean")
	
	local holo = unwrap(self)
	if holo then
		holo:UpdateClip(index, enabled, origin, normal, islocal)
	end
end

--- Returns a table of flexname -> flexid pairs for use in flex functions.
-- These IDs become invalid when the hologram's model changes.
function hologram_methods:getFlexes()
	SF.CheckType(self, hologram_metamethods)
	local holoent = unwrap(self)
	local flexes = {}
	for i=0,holoent:GetFlexNum()-1 do
		flexes[holoent:GetFlexName(i)] = i
	end
	return flexes
end

--- Sets the weight (value) of a flex.
function hologram_methods:setFlexWeight(flexid, weight)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(flexid, "number")
	SF.CheckType(weight, "number")
	flexid = math.floor(flexid)
	if flexid < 0 or flexid >= holoent:GetFlexNum() then
		error("Invalid flex: "..flexid,2)
	end
	local holoent = unwrap(self)
	if ValidEntity(holoent) then
		holoent:SetFlexWeight(self, weight)
	end
end

--- Sets the scale of all flexes of a hologram
function hologram_methods:setFlexScale(scale)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(scale, "number")
	local holoent = unwrap(self)
	if ValidEntity(holoent) then
		holoent:SetFlexScale(scale)
	end
end

--- Checks if the hologram is valid. A hologram may become invalid after
-- it is removed.
function hologram_methods:isValid()
	SF.CheckType(self, hologram_metamethods)
	return ValidEntity(unwrap(self))
end

--- Returns the hologram entity
function hologram_methods:entity()
	SF.CheckType(self, hologram_metamethods)
	return SF.Entities.Wrap(unwrap(self))
end

if SERVER then
	--- Deletes the hologram
	-- @server
	function hologram_methods:remove()
		SF.CheckType(self, hologram_metamethods)
		local holoent = unwrap(self)
		if ValidEntity(holoent) then
			holoent:Remove()
		end
	end
end

-- ------------------------ LIBRARY FUNCTIONS ------------------------ --

if SERVER then
	--- Creates a hologram.
	-- @server
	-- @return The hologram object
	function holograms_library.create(pos, ang, model, scale)
		SF.CheckType(pos, "Vector")
		SF.CheckType(ang, "Angle")
		SF.CheckType(model, "string")
		if scale then SF.CheckType(scale, "Vector") end

		local holodata = SF.instance.data.holograms
		local holoent = ents.Create("gmod_starfall_hologram")
		holoent:SetPos(pos)
		holoent:SetAngles(ang)
		holoent:SetModel(model)
		holoent:CallOnRemove("starfall_hologram_delete", hologramOnDestroy, holodata)
		holoent:Spawn()
		if scale then
			holoent:SetScale(scale)
		end
		
		local holo = wrap(holoent)
		
		holodata.holos[holo] = holo
		holodata.count = holodata.count + 1
		return holo
		-- TODO: Need to fire a umsg here to assign clientside ownership(?)
	end
end

--- Converts an entity (or entity index) to a hologram object.
-- @return The hologram object, or nil if the hologram is invalid
-- or doesn't belong to this instance.
function holograms_library.ent2holo(ent)
	local holoent
	if debug.getmetatable(ent) == SF.Entities.Metatable then
		holoent = SF.Entities.Unwrap(ent)
	elseif type(ent) == "number" then
		holoent = ents.GetByIndex(ent)
	else
		return SF.CheckType(ent, "Entity or Entity ID") -- Force error
	end

	if not ValidEntity(holoent) then return end
	if holoent:GetClass() ~= "gmod_starfall_hologram" then return end

	local holo = wrap(holoent)
	if not SF.instance.data.holograms.holos[holo] then return end
	return holo
end
