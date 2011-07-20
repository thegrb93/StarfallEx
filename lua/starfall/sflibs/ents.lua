
SF_Entities = {}
local ents_module = {}
SF_Compiler.AddModule("entities",ents_module)
local ents_wrapper = {}
ents_wrapper.__index = ents_wrapper
ents_wrapper.__newindex = function(key,value) end
ents_wrapper.__metatable = "Entity"

local wrapper2real = setmetatable({},{__mode="k"})
local real2wrapper = setmetatable({},{__mode="v"})

SF_Entities.metatable = ents_wrapper
--------------------------- Library ---------------------------

function SF_Entities.UnwrapEntity(wrapper)
	return wrapper2real[wrapper]
end

function SF_Entities.WrapEntity(ent)
	if not ent then return nil end
	if real2wrapper[ent] then return real2wrapper[ent] end
	
	local wrapper = setmetatable({},ents_wrapper)
	wrapper2real[wrapper] = ent
	real2wrapper[ent] = wrapper
	return wrapper
end

function SF_Entities.IsWrappedEntity(ent)
	if not ent then return false end
	return debug.getmetatable(ent) == "Entity"
end

local function postload()
	SF_WireLibrary.AddInputType("ENTITY",function(data)
		return SF_Entities.WrapEntity(data)
	end)

	SF_WireLibrary.AddOutputType("ENTITY", function(data)
		if data == nil then return nil end
		SF_Compiler.CheckType(data,"Entity")
		if not SF_Entities.IsWrappedEntity(data) then error("Tried to output non-entity type to entity output",3) end
		
		return SF_Entities.UnwrapEntity(data)
	end)
end
SF_Compiler.AddInternalHook("postload",postload)

-- returns nil if failed, Owner's entity if one found
function SF_Entities.GetOwner(entity)
	if entity == nil then return end
	
	if entity.IsPlayer and entity:IsPlayer() then
		return entity
	end
	
	if CPPI and _R.Entity.CPPIGetOwner then
		local owner = entity:CPPIGetOwner()
		if ValidEntity(owner) then return owner end
	end
	
	if entity.GetPlayer then
		local ply = entity:GetPlayer()
		if ValidEntity(ply) then return ply end
	end
	
	local OnDieFunctions = entity.OnDieFunctions
	if OnDieFunctions then
		if OnDieFunctions.GetCountUpdate then
			if OnDieFunctions.GetCountUpdate.Args then
				if OnDieFunctions.GetCountUpdate.Args[1] then return OnDieFunctions.GetCountUpdate.Args[1] end
			end
		end
		if OnDieFunctions.undo1 then
			if OnDieFunctions.undo1.Args then
				if OnDieFunctions.undo1.Args[2] then return OnDieFunctions.undo1.Args[2] end
			end
		end
	end
	
	if entity.GetOwner then
		local ply = entity:GetOwner()
		if ValidEntity(ply) then return ply end
	end

	return nil
end

function SF_Entities.IsValid(entity)
	if entity == nil then return false end
	if not entity:IsValid() then return false end
	if entity:IsWorld() then return false end
	return true
end

function SF_Entities.GetPhysObject(entity)
	if not SF_Entities.IsValid(entity) then return nil end
	if entity:GetMoveType() ~= MOVETYPE_VPHYSICS then return nil end
	return entity:GetPhysicsObject()
end

--------------------------- Module ---------------------------
function ents_module:self()
	return SF_Entities.WrapEntity(SF_Compiler.currentChip.ent)
end

function ents_module:owner()
	return SF_Entities.WrapEntity(SF_Compiler.currentChip.ply)
end

--------------------------- Methods ---------------------------

-- -- Internal information -- --

function ents_wrapper:isValid()
	local ent = SF_Entities.UnwrapEntity(self)
	return SF_Entities.IsValid(ent)
end

function ents_wrapper:index()
	local ent = SF_Entities.UnwrapEntity(self)
	if not SF_Entities.IsValid(ent) then return nil end
	return ent:EntIndex()
end

function ents_wrapper:class()
	local ent = SF_Entities.UnwrapEntity(self)
	if not SF_Entities.IsValid(ent) then return nil end
	return ent:GetClass()
end

-- -- Physical information -- --

function ents_wrapper:pos()
	local ent = SF_Entities.UnwrapEntity(self)
	if not SF_Entities.IsValid(ent) then return nil end
	return ent:GetPos()
end

function ents_wrapper:ang()
	local ent = SF_Entities.UnwrapEntity(self)
	if not SF_Entities.IsValid(ent) then return nil end
	return ent:GetAngles()
end

function ents_wrapper:mass()
	local ent = SF_Entities.UnwrapEntity(self)
	if not SF_Entities.IsValid(ent) then return nil end
	return ent:GetPhysicsObject():GetMass()
end

function ents_wrapper:vel()
	local ent = SF_Entities.UnwrapEntity(self)
	if not SF_Entities.IsValid(ent) then return nil end
	return ent:GetVelocity()
end

function ents_wrapper:toWorld(data)
	local ent = SF_Entities.UnwrapEntity(self)
	if not SF_Entities.IsValid(ent) then return nil end
	
	if type(data) == "Vector" then
		return ent:LocalToWorld(data)
	elseif type(data) == "Angle" then
		return ent:LocalToWorldAngles(data)
	else
		SF_Compiler.ThrowTypeError(data,"vector or angle")
	end
end

function ents_wrapper:toLocal(data)
	local ent = SF_Entities.UnwrapEntity(self)
	if not SF_Entities.IsValid(ent) then return nil end
	
	if type(data) == "Vector" then
		return ent:WorldToLocal(data)
	elseif type(data) == "Angle" then
		return ent:WorldToLocalAngles(data)
	else
		SF_Compiler.ThrowTypeError(data,"vector or angle")
	end
end

-- -- Physics -- --

function ents_wrapper:applyForce(vec, offset)
	SF_Compiler.CheckType(vec,"Vector")
	if offset ~= nil then SF_Compiler.CheckType(offset,"Vector") end
	
	local ent = SF_Entities.UnwrapEntity(self)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	
	if offset == nil then
		ent:GetPhysicsObject():ApplyForceCenter(vec)
	else
		ent:GetPhysicsObject():ApplyForceOffset(vec,offset)
	end
	return true
end

function ents_wrapper:applyAngForce(ang)
	SF_Compiler.CheckType(ang,"Vector")
	local ent = SF_Entities.UnwrapEntity(self)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	
	local phys = ent:GetPhysicsObject()
	
	-- assign vectors
	local up = ent:GetUp()
	local left = ent:GetRight() * -1
	local forward = ent:GetForward()
	
	-- apply pitch force
	if ang.p ~= 0 then
		local pitch = up      * (ang.p * 0.5)
		phys:ApplyForceOffset( forward, pitch )
		phys:ApplyForceOffset( forward * -1, pitch * -1 )
	end
	
	-- apply yaw force
	if ang.y ~= 0 then
		local yaw   = forward * (ang.y * 0.5)
		phys:ApplyForceOffset( left, yaw )
		phys:ApplyForceOffset( left * -1, yaw * -1 )
	end
	
	-- apply roll force
	if ang.r ~= 0 then
		local roll  = left    * (ang.r * 0.5)
		phys:ApplyForceOffset( up, roll )
		phys:ApplyForceOffset( up * -1, roll * -1 )
	end
	
	return true
end

function ents_wrapper:applyTorque(tq)
	SF_Compiler.CheckType(tq,"Vector")
	local this = SF_Entities.UnwrapEntity(self)
	if not SF_Entities.IsValid(this) then return false end
	if not SF_Permissions.CanModifyEntity(this) then return false end
	
	local phys = this:GetPhysicsObject()
	
	local torqueamount = tq:Length()
	
	-- Convert torque from local to world axis
	tq = phys:LocalToWorld( tq ) - phys:GetPos()
	
	-- Find two vectors perpendicular to the torque axis
	local off
	if abs(tq.x) > torqueamount * 0.1 or abs(tq.z) > torqueamount * 0.1 then
		off = Vector(-tq.z, 0, tq.x)
	else
		off = Vector(-tq.y, tq.x, 0)
	end
	off = off:GetNormal() * torqueamount * 0.5
	
	local dir = ( tq:Cross(off) ):GetNormal()
	
	phys:ApplyForceOffset( dir, off )
	phys:ApplyForceOffset( dir * -1, off * -1 )
	
	return true
end
