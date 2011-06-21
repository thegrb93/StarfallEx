
SF_Entities = {}
local ents_module = {}
local ents_wrapper = {}
ents_wrapper.__index = ents_wrapper

SF_Entities.wrapper2real = setmetatable({},{__mode="k"})
SF_Entities.real2wrapper = setmetatable({},{__mode="v"})

--------------------------- Library ---------------------------

function SF_Entities.UnwrapEntity(wrapper)
	return SF_Entities.wrapper2real[wrapper]
end

function SF_Entities.WrapEntity(ent)
	if not ent then return nil end
	if SF_Entities.real2wrapper[ent] then return SF_Entities.real2wrapper[ent] end
	
	local wrapper = setmetatable({},ents_wrapper)
	SF_Entities.wrapper2real[wrapper] = ent
	SF_Entities.real2wrapper[ent] = wrapper
	return wrapper
end

local function postload()
	SF_WireLibrary.AddInputType("ENTITY",function(data)
		return SF_Entities.WrapEntity(data)
	end)

	SF_WireLibrary.AddOutputType("ENTITY", function(data)
		if data == nil then return nil end
		if type(data) ~= "table" then error("Tried to output non-entity type to entity output",3) end
		if getmetatable(data) ~= ents_wrapper then error("Tried to output non-entity type to entity output",3) end
		
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

-- TODO: Real permissions system (?)
function SF_Entities.CanAffect( ply, ent )
	ply = SF_Entities.GetOwner(ply)
	if ply == nil then return false end
	
	if ply:IsSuperAdmin() then return true end
	
	if not SF_Entities.IsValid(ent) then return false end
	
	local owner = SF_Entities.GetOwner(ent)
	if not SF_Entities.IsValid(owner) then return false end
	if owner == ply then return true end
	
	if _R.Player.CPPIGetFriends then
		local friends = owner:CPPIGetFriends()
		if type( friends ) != "table" then return false end

		for _,friend in pairs(friends) do
			if ply == friend then return true end
		end
	end
	
	return false
end

--------------------------- Methods ---------------------------

-- -- Internal information -- --

function ents_wrapper:isValid()
	local ent = SF_Entities.UnwrapEntity(self)
	return ent and ent:IsValid()
end

function ents_wrapper:index()
	local ent = SF_Entities.UnwrapEntity(self)
	if not ent:IsValid() then return nil end
	return ent:EntIndex()
end

function ents_wrapper:class()
	local ent = SF_Entities.UnwrapEntity(self)
	if not ent:IsValid() then return nil end
	return ent:GetClass()
end

-- -- Physical information -- --

function ents_wrapper:pos()
	local ent = SF_Entities.UnwrapEntity(self)
	if not ent:IsValid() then return nil end
	return ent:GetPos()
end

function ents_wrapper:ang()
	local ent = SF_Entities.UnwrapEntity(self)
	if not ent:IsValid() then return nil end
	return ent:GetAngles()
end

function ents_wrapper:mass()
	local ent = SF_Entities.UnwrapEntity(self)
	if not ent:IsValid() then return nil end
	return ent:GetPhysicsObject():GetMass()
end

function ents_wrapper:vel()
	local ent = SF_Entities.UnwrapEntity(self)
	if not ent:IsValid() then return nil end
	return ent:GetVelocity()
end

function ents_wrapper:toWorld(data)
	local ent = SF_Entities.UnwrapEntity(self)
	if not ent:IsValid() then return nil end
	
	if type(data) == "Vector" then
		return ent:LocalToWorld(data)
	elseif type(data) == "Angle" then
		return ent:LocalToWorldAngles(data)
	else
		error("Passed bad argument to toWorld (must be angle or vector)",2)
	end
end

function ents_wrapper:toLocal(data)
	local ent = SF_Entities.UnwrapEntity(self)
	if not ent:IsValid() then return nil end
	
	if type(data) == "Vector" then
		return ent:WorldToLocal(data)
	elseif type(data) == "Angle" then
		return ent:WorldToLocalAngles(data)
	else
		error("Passed "..type(data).." to toLocal (must be angle or vector)",2)
	end
end
