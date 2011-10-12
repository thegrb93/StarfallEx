
SF.Entities = {}

local ents = SF.Entities
local ents_lib = {}
local ents_metatable = SF.Typedef("Entity")
SF.Libraries.Register("ents",ents_lib)

SF.Permissions:registerPermission({
	name = "Modify All Entities",
	desc = "Allow modification of entities not created by the owner",
	level = 1,
	value = false,
})

-- ------------------------- Internal Library ------------------------- --

local wrap, unwrap = SF.CreateWrapper(ents_metatable)

--- Wraps a real entity to an entity wrapper
-- @name SF.Entities.Wrap
-- @class function
-- @param ent
ents.Wrap = wrap
--- Unwraps an entity wrapper to a real entity
-- @name SF.Entities.Unwrap
-- @class function
-- @param wrapped
ents.Unwrap = unwrap
--- The entity wrapper metatable
-- @name SF.Entities.Metatable
-- @class table
ents.Metatable = ents_metatable

--- Returns true if valid, false if not
function SF.Entities.IsValid(entity)
	if entity == nil then return false end
	if not entity:IsValid() then return false end
	if entity:IsWorld() then return false end
	return true
end

--- Gets the entity's owner
-- TODO: Optimize this!
-- @return The entities owner, or nil if not found
function SF.Entities.GetOwner(entity)
	if not entity then return end
	
	if entity.IsPlayer and entity:IsPlayer() then
		return entity
	end
	
	if CPPI and _R.Entity.CPPIGetOwner then
		local owner = entity:CPPIGetOwner()
		if isValid(owner) then return owner end
	end
	
	if entity.GetPlayer then
		local ply = entity:GetPlayer()
		if isValid(ply) then return ply end
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

function SF.Entities.GetPhysObject(entity)
	if not ents.IsValid(entity) then return nil end
	if entity:GetMoveType() ~= MOVETYPE_VPHYSICS then return nil end
	return entity:GetPhysicsObject()
end

local isValid = SF.Entities.IsValid
local getPhysObject = SF.Entities.GetPhysObject
local getOwner = SF.Entities.GetOwner


-- TODO: Write clientside functions
