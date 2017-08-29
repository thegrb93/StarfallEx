-------------------------------------------------------------------------------
-- Serverside Entity functions
-------------------------------------------------------------------------------

assert(SF.Entities)

local huge = math.huge
local abs = math.abs

local ents_lib = SF.Entities.Library
local ents_metatable = SF.Entities.Metatable

--- Entity type
--@class class
--@name Entity
local ents_methods = SF.Entities.Methods
local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap
local vwrap = SF.WrapObject
local vunwrap = SF.UnwrapObject

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("entities.parent", "Parent", "Allows the user to parent an entity to another entity", { ["CanTool"] = {} })
	P.registerPrivilege("entities.unparent", "Unparent", "Allows the user to remove the parent of an entity", { ["CanTool"] = {} })
	P.registerPrivilege("entities.applyDamage", "Apply damage", "Allows the user to apply damage to an entity", { ["CanTool"] = {} })
	P.registerPrivilege("entities.applyForce", "Apply force", "Allows the user to apply force to an entity", { ["CanPhysgun"] = {} })
	P.registerPrivilege("entities.setPos", "Set Position", "Allows the user to teleport an entity to another location", { ["CanPhysgun"] = {} })
	P.registerPrivilege("entities.setAngles", "Set Angles", "Allows the user to teleport an entity to another orientation", { ["CanPhysgun"] = {} })
	P.registerPrivilege("entities.setVelocity", "Set Velocity", "Allows the user to change the velocity of an entity", { ["CanPhysgun"] = {} })
	P.registerPrivilege("entities.setFrozen", "Set Frozen", "Allows the user to freeze and unfreeze an entity", { ["CanPhysgun"] = {} })
	P.registerPrivilege("entities.setSolid", "Set Solid", "Allows the user to change the solidity of an entity", { ["CanTool"] = {} })
	P.registerPrivilege("entities.setMass", "Set Mass", "Allows the user to change the mass of an entity", { ["CanTool"] = {} })
	P.registerPrivilege("entities.setInertia", "Set Inertia", "Allows the user to change the inertia of an entity", { ["CanTool"] = {} })
	P.registerPrivilege("entities.enableGravity", "Enable gravity", "Allows the user to change whether an entity is affected by gravity", { ["CanTool"] = {} })
	P.registerPrivilege("entities.enableMotion", "Set Motion", "Allows the user to disable an entity's motion", { ["CanTool"] = {} })
	P.registerPrivilege("entities.enableDrag", "Set Drag", "Allows the user to disable an entity's air resistence", { ["CanTool"] = {} })
	P.registerPrivilege("entities.remove", "Remove", "Allows the user to remove entities", { ["CanTool"] = {} })
	P.registerPrivilege("entities.ignite", "Ignite", "Allows the user to ignite entities", { ["CanTool"] = {} })
	P.registerPrivilege("entities.emitSound", "Emitsound", "Allows the user to play sounds on entities", { ["CanTool"] = {} })
	P.registerPrivilege("entities.setRenderPropery", "RenderProperty", "Allows the user to change the rendering of an entity", { ["CanTool"] = {} })
	P.registerPrivilege("entities.canTool", "CanTool", "Whether or not the user can use the toolgun on the entity", { ["CanTool"] = {} })
end

local function fix_nan (v)
	if v < huge and v > -huge then return v else return 0 end
end

local isValid = IsValid

-- ------------------------- Internal Library ------------------------- --

--- Gets the entity's owner
-- TODO: Optimize this!
-- @return The entities owner, or nil if not found
function SF.Entities.GetOwner (entity)
	if not isValid(entity) then return end

	if entity.IsPlayer and entity:IsPlayer() then
		return entity
	end

	if CPPI then
		local owner = entity:CPPIGetOwner()
		if isValid(owner) then return owner end
	end

	if entity.GetPlayer then
		local ply = entity:GetPlayer()
		if isValid(ply) then return ply end
	end

	if entity.owner and isValid(entity.owner) and entity.owner:IsPlayer() then
		return entity.owner
	end

	local OnDieFunctions = entity.OnDieFunctions
	if OnDieFunctions then
		if OnDieFunctions.GetCountUpdate and OnDieFunctions.GetCountUpdate.Args and OnDieFunctions.GetCountUpdate.Args[1] then
			return OnDieFunctions.GetCountUpdate.Args[1]
		elseif OnDieFunctions.undo1 and OnDieFunctions.undo1.Args and OnDieFunctions.undo1.Args[2] then
			return OnDieFunctions.undo1.Args[2]
		end
	end

	if entity.GetOwner then
		local ply = entity:GetOwner()
		if isValid(ply) then return ply end
	end

	return nil
end

local getPhysObject = SF.Entities.GetPhysObject
local getOwner = SF.Entities.GetOwner

--- Gets the owner of the entity
-- @return Owner
function ents_methods:getOwner ()
	SF.CheckType(self, ents_metatable)
	local ent = unwrap(self)
	return wrap(getOwner(ent))
end

local function check (v)
	return 	-math.huge < v[1] and v[1] < math.huge and
			-math.huge < v[2] and v[2] < math.huge and
			-math.huge < v[3] and v[3] < math.huge
end

--- Parents the entity to another entity
-- @param ent Entity to parent to
-- @param attachment Optional string attachment name to parent to
function ents_methods:setParent (ent, attachment)
	SF.CheckType(self, ents_metatable)
	SF.CheckType(ent, ents_metatable)

	local ent = unwrap(ent)
	local this = unwrap(self)

	SF.Permissions.check(SF.instance.player, this, "entities.parent")
	if ent:IsPlayer() then
		if this:GetClass()~="starfall_hologram" then
			SF.Throw("Insufficient permissions", 2)
		end
	else
		SF.Permissions.check(SF.instance.player, ent, "entities.parent")
	end

	this:SetParent(ent)
	if attachment then
		SF.CheckLuaType(attachment, TYPE_STRING)
		this:Fire("SetParentAttachmentMaintainOffset", attachment, 0.01)
	end
end

--- Unparents the entity from another entity
function ents_methods:unparent ()
	local this = unwrap(self)
	SF.Permissions.check(SF.instance.player, this, "entities.unparent")
	this:SetParent(nil)
end

--- Links starfall components to a starfall processor or vehicle. Screen can only connect to processor. HUD can connect to processor and vehicle.
-- @param e Entity to link the component to. nil to clear links.
function ents_methods:linkComponent (e)
	SF.CheckType(self, ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.canTool")
	
	if e then
		SF.CheckType(e, ents_metatable)
		local link = unwrap(e)
		if not isValid(link) then SF.Throw("Entity is not valid", 2) end
		SF.Permissions.check(SF.instance.player, link, "entities.canTool")
		
		if link:GetClass()=="starfall_processor" and (ent:GetClass()=="starfall_screen" or ent:GetClass()=="starfall_hud") then
			ent:LinkEnt(link)
		elseif link:IsVehicle() and ent:GetClass()=="starfall_hud" then
			ent:LinkVehicle(link)
		else
			SF.Throw("Invalid Link Entity", 2)
		end
	else
		if ent:GetClass()=="starfall_screen" then
			ent:LinkEnt(nil)
		elseif ent:GetClass()=="starfall_hud" then
			ent:LinkEnt(nil)
			ent:LinkVehicle(nil)
		else
			SF.Throw("Invalid Link Entity", 2)
		end
	end
end


--- Plays a sound on the entity
-- @param snd string Sound path
-- @param lvl number soundLevel=75
-- @param pitch pitchPercent=100
-- @param volume volume=1
-- @param channel channel=CHAN_AUTO
function ents_methods:emitSound (snd, lvl, pitch, volume, channel)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(snd, TYPE_STRING)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.emitSound")

	ent:EmitSound(snd, lvl, pitch, volume, channel)
end

--- Applies damage to an entity
-- @param amt damage amount
-- @param attacker damage attacker
-- @param inflictor damage inflictor
function ents_methods:applyDamage(amt, attacker, inflictor)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(amt, TYPE_NUMBER)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.applyDamage")

	if attacker then
		SF.CheckType(attacker, ents_metatable)
		attacker = unwrap(attacker)
		if not isValid(attacker) then SF.Throw("Entity is not valid", 2) end
	end
	if inflictor then
		SF.CheckType(inflictor, ents_metatable)
		inflictor = unwrap(inflictor)
		if not isValid(inflictor) then SF.Throw("Entity is not valid", 2) end
	end

	ent:TakeDamage(amt, attacker, inflictor)
end


--- Applies linear force to the entity
-- @param vec The force vector
function ents_methods:applyForceCenter (vec)
	SF.CheckType(self, ents_metatable)
	SF.CheckType(vec, SF.Types["Vector"])
	local vec = vunwrap(vec)
	if not check(vec) then SF.Throw("infinite vector", 2) end

	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end

	SF.Permissions.check(SF.instance.player, ent, "entities.applyForce")

	phys:ApplyForceCenter(vec)
end

--- Applies linear force to the entity with an offset
-- @param vec The force vector
-- @param offset An optional offset position
function ents_methods:applyForceOffset (vec, offset)
	SF.CheckType(self, ents_metatable)
	SF.CheckType(vec, SF.Types["Vector"])
	SF.CheckType(offset, SF.Types["Vector"])

	local vec = vunwrap(vec)
	local offset = vunwrap(offset)

	if not check(vec) or not check(offset) then SF.Throw("infinite vector", 2) end

	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end

	SF.Permissions.check(SF.instance.player, ent, "entities.applyForce")

	phys:ApplyForceOffset(vec, offset)
end

--- Applies angular force to the entity
-- @param ang The force angle
function ents_methods:applyAngForce (ang)
	SF.CheckType(self, ents_metatable)
	SF.CheckType(ang, SF.Types["Angle"])
	
	local ang = SF.UnwrapObject(ang)
	local ent = unwrap(self)
	
	if not check(ang) then SF.Throw("infinite angle", 2) end
	
	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end

	SF.Permissions.check(SF.instance.player, ent, "entities.applyForce")

	-- assign vectors
	local up = ent:GetUp()
	local left = ent:GetRight() * -1
	local forward = ent:GetForward()

	-- apply pitch force
	if ang.p ~= 0 then
		local pitch = up * (ang.p * 0.5)
		phys:ApplyForceOffset(forward, pitch)
		phys:ApplyForceOffset(forward * -1, pitch * -1)
	end

	-- apply yaw force
	if ang.y ~= 0 then
		local yaw = forward * (ang.y * 0.5)
		phys:ApplyForceOffset(left, yaw)
		phys:ApplyForceOffset(left * -1, yaw * -1)
	end

	-- apply roll force
	if ang.r ~= 0 then
		local roll = left * (ang.r * 0.5)
		phys:ApplyForceOffset(up, roll)
		phys:ApplyForceOffset(up * -1, roll * -1)
	end
end

--- Applies torque
-- @param torque The torque vector
function ents_methods:applyTorque (torque)
	SF.CheckType(self, ents_metatable)
	SF.CheckType(torque, SF.Types["Vector"])

	local torque = vunwrap(torque)

	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end

	SF.Permissions.check(SF.instance.player, ent, "entities.applyForce")

	local torqueamount = torque:Length()
	if torqueamount < 1.192093e-07 then return end
	-- Convert torque from local to world axis
	torque = phys:LocalToWorldVector(torque / torqueamount)

	-- Find two vectors perpendicular to the torque axis
	local off
	if abs(torque.x) > 0.1 or abs(torque.z) > 0.1 then
		off = Vector(-torque.z, 0, torque.x):GetNormalized()
	else
		off = Vector(-torque.y, torque.x, 0):GetNormalized()
	end
	local dir = torque:Cross(off)
	off = off * torqueamount * 0.5

	phys:ApplyForceOffset(dir, off)
	phys:ApplyForceOffset(dir * -1, off * -1)
end

--- Allows detecting collisions on an entity. You can only do this once for the entity's entire lifespan so use it wisely.
-- @param func The callback function with argument, table collsiondata, http://wiki.garrysmod.com/page/Structures/CollisionData
function ents_methods:addCollisionListener (func)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(func, TYPE_FUNCTION)
	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.canTool")
	if ent.SF_CollisionCallback then SF.Throw("The entity is already listening to collisions!", 2) end

	local instance = SF.instance
	ent.SF_CollisionCallback = ent:AddCallback("PhysicsCollide", function(ent, data)
		instance:runFunction(func, setmetatable({}, {
			__index = function(t, k)
				return SF.WrapObject(data[k])
			end,
			__metatable = ""
		}))
	end)
end

--- Removes a collision listening hook from the entity so that a new one can be added
function ents_methods:removeCollisionListener ()
	SF.CheckType(self, ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.canTool")
	if not ent.SF_CollisionCallback then SF.Throw("The entity isn't listening to collisions!", 2) end
	ent:RemoveCallback("PhysicsCollide", ent.SF_CollisionCallback)
	ent.SF_CollisionCallback = nil
end

--- Set's the entity to collide with nothing but the world
-- @param nocollide Whether to collide with nothing except world or not.
function ents_methods:setNocollideAll (nocollide)
	SF.CheckType(self, ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setSolid")
	
	ent:SetCollisionGroup (nocollide and COLLISION_GROUP_WORLD or COLLISION_GROUP_NONE)
end

util.AddNetworkString("sf_setentityrenderproperty")

local renderProperties = {
	[1] = function(clr) --Color
		net.WriteUInt(clr.r, 8)
		net.WriteUInt(clr.g, 8)
		net.WriteUInt(clr.b, 8)
		net.WriteUInt(clr.a, 8)
	end,
	[2] = function(draw) --Nodraw
		net.WriteBit(draw)
	end,
	[3] = function(material) --Material
		net.WriteString(material)
	end,
	[4] = function(index, material) --Submaterial
		net.WriteUInt(index, 16)
		net.WriteString(material)
	end,
	[5] = function(bodygroup, value) --Bodygroup
		net.WriteUInt(bodygroup, 16)
		net.WriteUInt(value, 16)
	end,
	[6] = function(skin) --Skin
		net.WriteUInt(skin, 16)
	end,
	[7] = function(mode) --Rendermode
		net.WriteUInt(mode, 8)
	end,
	[8] = function(fx) --Renderfx
		net.WriteUInt(fx, 8)
	end,
	[9] = function(draw) --DrawShadow
		net.WriteBit(draw)
	end
}

local function sendRenderPropertyToClient(ply, ent, func, ...)
	local meta = debug.getmetatable(ply)
	if meta == SF.Types["Player"] then 
		ply = unwrap(ply)
		if not (IsValid(ply) and ply:IsPlayer()) then
			SF.Throw("Tried to use invalid player", 3)
		end
	elseif meta == nil and type(ply) == "table" then
		local ply2 = ply
		ply = {}
		for k, v in pairs(ply2) do
			local p = unwrap(v)
			if IsValid(p) and p:IsPlayer() then
				ply[k] = p
			else
				SF.Throw ("Invalid player object in table of players", 3)
			end
		end
	else
		SF.Throw("Expected player or table of players.", 3)
	end
	
	net.Start("sf_setentityrenderproperty")
	net.WriteEntity(ent)
	net.WriteUInt(func, 4)
	renderProperties[func](...)
	net.Send(ply)
end

--- Sets the color of the entity
-- @server
-- @param clr New color
-- @param ply Optional player argument to set only for that player. Can also be table of players.
function ents_methods:setColor (clr, ply)
	SF.CheckType(self, ents_metatable)
	SF.CheckType(clr, SF.Types["Color"])

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setRenderPropery")

	if ply then
		sendRenderPropertyToClient(ply, ent, 1, clr)
	else
		local rendermode = (clr.a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
		ent:SetColor(clr)
		ent:SetRenderMode(rendermode)
		duplicator.StoreEntityModifier(ent, "colour", { Color = clr, RenderMode = rendermode })
	end

end

--- Sets the whether an entity should be drawn or not
-- @server
-- @param draw Whether to draw the entity or not.
-- @param ply Optional player argument to set only for that player. Can also be table of players.
function ents_methods:setNoDraw (draw, ply)
	SF.CheckType(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setRenderPropery")

	if ply then
		sendRenderPropertyToClient(ply, ent, 2, draw and true or false)
	else
		ent:SetNoDraw(draw and true or false)
	end
end

local shaderBlacklist = {
	["LightmappedGeneric"] = true,
}
local function invalidMaterial(material)
	if string.find(string.lower(material) , "pp[%./\\]+copy") then return true end
	local mat = Material(material)
	if mat and shaderBlacklist[mat:GetShader()] then return true end
end

--- Sets an entities' material
-- @server
-- @class function
-- @param material, string, New material name.
-- @param ply Optional player argument to set only for that player. Can also be table of players.
function ents_methods:setMaterial (material, ply)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(material, TYPE_STRING)
	if invalidMaterial(material) then SF.Throw("This material has been blacklisted", 2) end

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setRenderPropery")

	if ply then
		sendRenderPropertyToClient(ply, ent, 3, material)
	else
		ent:SetMaterial(material)
		duplicator.StoreEntityModifier(ent, "material", { MaterialOverride = material })
	end
end

--- Sets an entities' submaterial
-- @server
-- @class function
-- @param index, number, submaterial index.
-- @param material, string, New material name.
-- @param ply Optional player argument to set only for that player. Can also be table of players.
function ents_methods:setSubMaterial (index, material, ply)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(material, TYPE_STRING)
	if invalidMaterial(material) then SF.Throw("This material has been blacklisted", 2) end

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setRenderPropery")

	if ply then
		sendRenderPropertyToClient(ply, ent, 4, index, material)
	else
		ent:SetSubMaterial(index, material)
	end
end

--- Sets an entities' bodygroup
-- @server
-- @class function
-- @param bodygroup Number, The ID of the bodygroup you're setting.
-- @param value Number, The value you're setting the bodygroup to.
-- @param ply Optional player argument to set only for that player. Can also be table of players.
function ents_methods:setBodygroup (bodygroup, value, ply)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(bodygroup, TYPE_NUMBER)
	SF.CheckLuaType(value, TYPE_NUMBER)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setRenderPropery")

	if ply then
		sendRenderPropertyToClient(ply, ent, 5, bodygroup, value)
	else
		ent:SetBodygroup(bodygroup, value)
	end
end

--- Sets the skin of the entity
-- @server
-- @class function
-- @param skinIndex Number, Index of the skin to use.
-- @param ply Optional player argument to set only for that player. Can also be table of players.
function ents_methods:setSkin (skinIndex, ply)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(skinIndex, TYPE_NUMBER)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setRenderPropery")

	if ply then
		sendRenderPropertyToClient(ply, ent, 6, skinIndex)
	else
		ent:SetSkin(skinIndex)
	end
end

--- Sets the rende mode of the entity
-- @server
-- @class function
-- @param rendermode Number, rendermode to use. http://wiki.garrysmod.com/page/Enums/RENDERMODE
-- @param ply Optional player argument to set only for that player. Can also be table of players.
function ents_methods:setRenderMode (rendermode, ply)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(rendermode, TYPE_NUMBER)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setRenderPropery")

	if ply then
		sendRenderPropertyToClient(ply, ent, 7, rendermode)
	else
		ent:SetRenderMode(rendermode)
		duplicator.StoreEntityModifier(ent, "colour", { RenderMode = rendermode })
	end
end

--- Sets the renderfx of the entity
-- @server
-- @class function
-- @param renderfx Number, renderfx to use. http://wiki.garrysmod.com/page/Enums/kRenderFx
-- @param ply Optional player argument to set only for that player. Can also be table of players.
function ents_methods:setRenderFX (renderfx, ply)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(renderfx, TYPE_NUMBER)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setRenderPropery")

	if ply then
		sendRenderPropertyToClient(ply, ent, 8, renderfx)
	else
		ent:SetRenderFX(renderfx)
		duplicator.StoreEntityModifier(ent, "colour", { RenderFX = renderfx })
	end
end

--- Sets whether an entity's shadow should be drawn
-- @param ply Optional player argument to set only for that player. Can also be table of players.
function ents_methods:setDrawShadow (draw, ply)
	SF.CheckType(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setRenderPropery")

	if ply then
		sendRenderPropertyToClient(ply, ent, 9, draw and true or false)
	else
		ent:DrawShadow(draw and true or false)
	end
end

--- Sets the entitiy's position
-- @param vec New position
function ents_methods:setPos (vec)
	SF.CheckType(self, ents_metatable)
	SF.CheckType(vec, SF.Types["Vector"])

	local vec = vunwrap(vec)
	local ent = unwrap(self)

	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setPos")

	SF.setPos(ent, vec)
end

--- Sets the entity's angles
-- @param ang New angles
function ents_methods:setAngles (ang)
	SF.CheckType(self, ents_metatable)
	SF.CheckType(ang, SF.Types["Angle"])
	local ang = SF.UnwrapObject(ang)

	local ent = unwrap(self)

	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setAngles")

	SF.setAng(ent, ang)
end

--- Sets the entity's linear velocity
-- @param vel New velocity
function ents_methods:setVelocity (vel)
	SF.CheckType(self, ents_metatable)
	SF.CheckType(vel, SF.Types["Vector"])

	local vel = vunwrap(vel)
	local ent = unwrap(self)
	
	if not check(vel) then SF.Throw("infinite vector", 2) end

	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end

	SF.Permissions.check(SF.instance.player, ent, "entities.setVelocity")

	phys:SetVelocity(vel)
end

--- Removes an entity
function ents_methods:remove ()
	SF.CheckType(self, ents_metatable)

	local ent = unwrap(self)
	if not ent:IsValid() or ent:IsPlayer() then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.remove")

	ent:Remove()
end

--- Invokes the entity's breaking animation and removes it.
function ents_methods:breakEnt ()
	SF.CheckType(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) or ent:IsPlayer() or ent:IsFlagSet(FL_KILLME) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.remove")

	ent:AddFlags(FL_KILLME)
	ent:Fire("break", 1, 0)
end

--- Ignites an entity
-- @param length How long the fire lasts
-- @param radius (optional) How large the fire hitbox is (entity obb is the max)
function ents_methods:ignite(length, radius)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(length, TYPE_NUMBER)

	local ent = unwrap(self)
	if not isValid(ent) or ent:IsPlayer() then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.ignite")

	if radius then
		SF.CheckLuaType(radius, TYPE_NUMBER)
		local obbmins, obbmaxs = ent:OBBMins(), ent:OBBMaxs()
		radius = math.Clamp(radius, 0, (obbmaxs.x - obbmins.x + obbmaxs.y - obbmins.y) / 2)
	end

	ent:Ignite(length, radius)
end

--- Extinguishes an entity
function ents_methods:extinguish()
	SF.CheckType(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) or ent:IsPlayer() then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.ignite")

	ent:Extinguish()
end

--- Sets the entity frozen state
-- @param freeze Should the entity be frozen?
function ents_methods:setFrozen (freeze)
	SF.CheckType(self, ents_metatable)

	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end

	SF.Permissions.check(SF.instance.player, ent, "entities.setFrozen")

	phys:EnableMotion(not (freeze and true or false))
	phys:Wake()
end

--- Checks the entities frozen state
-- @return True if entity is frozen
function ents_methods:isFrozen ()
	SF.CheckType(self, ents_metatable)

	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end
	if phys:IsMoveable() then return false else return true end
end

--- Sets the entity to be Solid or not.
-- For more information please refer to GLua function http://wiki.garrysmod.com/page/Entity/SetNotSolid
-- @param solid Boolean, Should the entity be solid?
function ents_methods:setSolid (solid)
	SF.CheckType(self, ents_metatable)
	local ent = unwrap(self)

	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setSolid")

	ent:SetNotSolid(not solid)
end

--- Sets the entity's mass
-- @param mass number mass
function ents_methods:setMass (mass)
	SF.CheckType(self, ents_metatable)
	local ent = unwrap(self)

	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end

	SF.Permissions.check(SF.instance.player, ent, "entities.setMass")

	phys:SetMass(math.Clamp(mass, 1, 50000))
end

--- Sets the entity's inertia
-- @param vec Inertia tensor
function ents_methods:setInertia (vec)
	SF.CheckType(self, ents_metatable)
	SF.CheckType(vec, SF.Types["Vector"])

	local ent = unwrap(self)
	SF.Permissions.check(SF.instance.player, ent, "entities.setInertia")
	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end
	
	local vec = vunwrap(vec)
	if not check(vec) then SF.Throw("infinite vector", 2) end
	vec[1] = math.Clamp(vec[1], 1, 100000)
	vec[2] = math.Clamp(vec[2], 1, 100000)
	vec[3] = math.Clamp(vec[3], 1, 100000)

	phys:SetInertia(vec)
end

--- Sets the physical material of the entity
-- @param mat Material to use
function ents_methods:setPhysMaterial(mat)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(mat, TYPE_STRING)
	local ent = unwrap(self)

	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end

	SF.Permissions.check(SF.instance.player, ent, "entities.setMass")

	construct.SetPhysProp(nil, ent, 0, phys, { Material = mat }) 
end

--- Checks whether entity has physics
-- @return True if entity has physics
function ents_methods:isValidPhys()
	SF.CheckType(self, ents_metatable)
	
	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	return phys ~= nil
end

--- Sets entity gravity
-- @param grav Bool should the entity respect gravity?
function ents_methods:enableGravity (grav)
	SF.CheckType(self, ents_metatable)

	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end

	SF.Permissions.check(SF.instance.player, ent, "entities.enableGravity")

	phys:EnableGravity(grav and true or false)
	phys:Wake()
end

--- Sets the entity drag state
-- @param drag Bool should the entity have air resistence?
function ents_methods:enableDrag (drag)
	SF.CheckType(self, ents_metatable)

	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end

	SF.Permissions.check(SF.instance.player, ent, "entities.enableDrag")

	phys:EnableDrag(drag and true or false)
end

--- Sets the entity movement state
-- @param move Bool should the entity move?
function ents_methods:enableMotion (move)
	SF.CheckType(self, ents_metatable)

	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end

	SF.Permissions.check(SF.instance.player, ent, "entities.enableMotion")

	phys:EnableMotion(move and true or false)
	phys:Wake()
end


--- Sets the physics of an entity to be a sphere
-- @param enabled Bool should the entity be spherical?
function ents_methods:enableSphere (enabled)
	SF.CheckType(self, ents_metatable)

	local ent = unwrap(self)
	
	if ent:GetClass() ~= "prop_physics" then SF.Throw("This function only works for prop_physics", 2) end
	local phys = getPhysObject(ent)
	if not phys then SF.Throw("Entity has no physics object or is not valid", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.enableMotion")
	
	local ismove = phys:IsMoveable()
	local mass = phys:GetMass()
	
	if enabled then
		if ent:GetMoveType() == MOVETYPE_VPHYSICS then
			local OBB = ent:OBBMaxs() - ent:OBBMins()
			local radius = math.max(OBB.x, OBB.y, OBB.z) / 2 
			ent:PhysicsInitSphere(radius, phys:GetMaterial())
			ent:SetCollisionBounds(Vector(-radius, -radius, -radius) , Vector(radius, radius, radius))
		end
	else
		if ent:GetMoveType() ~= MOVETYPE_VPHYSICS then
			ent:PhysicsInit(SOLID_VPHYSICS)
			ent:SetMoveType(MOVETYPE_VPHYSICS)
			ent:SetSolid(SOLID_VPHYSICS)
		end
	end
	
	-- New physobject after applying spherical collisions
	local phys = ent:GetPhysicsObject()
	phys:SetMass(mass)
	phys:EnableMotion(ismove)
	phys:Wake()
end


local function ent1or2 (ent, con, num)
	if not con then return nil end
	if num then
		con = con[num]
		if not con then return nil end
	end
	if con.Ent1 == ent then return con.Ent2 end
	return con.Ent1
end

--- Gets what the entity is welded to
function ents_methods:isWeldedTo ()
	local this = unwrap(self)
	if not constraint.HasConstraints(this) then return nil end

	return vwrap(ent1or2(this, constraint.FindConstraint(this, "Weld")))
end


--- Adds a trail to the entity with the specified attributes.
-- @param startSize The start size of the trail
-- @param endSize The end size of the trail
-- @param length The length size of the trail
-- @param material The material of the trail
-- @param color The color of the trail
-- @param attachmentID Optional attachmentid the trail should attach to
-- @param additive If the trail's rendering is additive
function ents_methods:setTrails(startSize, endSize, length, material, color, attachmentID, additive)
	SF.CheckType(self, ents_metatable)
	SF.CheckLuaType(material, TYPE_STRING)
	
	local ent = unwrap(self)

	if string.find(material, '"', 1, true) then SF.Throw("Invalid Material", 2) end
	if not IsValid(ent) then SF.Throw("Invalid Entity", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setRenderPropery")

	local Data = {
		Color = SF.Color.Unwrap(color),
		Length = length,
		StartSize = math.Clamp(startSize, 0, 128),
		EndSize = math.Clamp(endSize, 0, 128),
		Material = material,
		AttachmentID = attachmentID,
		Additive = additive,
	}

	duplicator.EntityModifiers.trail(SF.instance.player, ent, Data)
end

--- Removes trails from the entity
function ents_methods:removeTrails()
	SF.CheckType(self, ents_metatable)
	local ent = unwrap(self)

	if not IsValid(ent) then SF.Throw("Invalid Entity", 2) end
	SF.Permissions.check(SF.instance.player, ent, "entities.setRenderPropery")

	duplicator.EntityModifiers.trail(SF.instance.player, ent, nil)
end
