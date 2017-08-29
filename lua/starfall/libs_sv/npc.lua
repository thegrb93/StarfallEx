-------------------------------------------------------------------------------
-- Npc functions.
-------------------------------------------------------------------------------

SF.Npcs = {}
--- Npc type
local npc_methods, npc_metatable = SF.Typedef("Npc", SF.Entities.Metatable)

SF.Npcs.Methods = npc_methods
SF.Npcs.Metatable = npc_metatable

local dsetmeta = debug.setmetatable
local vwrap, vunwrap = SF.WrapObject, SF.UnwrapObject
local wrap, unwrap, ents_metatable

SF.Libraries.AddHook("postload", function()
	wrap = SF.Entities.Wrap
	unwrap = SF.Entities.Unwrap
	ents_metatable = SF.Entities.Metatable
	
	SF.AddObjectWrapper(debug.getregistry().NPC, npc_metatable, function(object)
		object = wrap(object)
		dsetmeta(object, npc_metatable)
		return object
	end)
	SF.AddObjectUnwrapper(npc_metatable, unwrap)
end)

do
	local P = SF.Permissions
	P.registerPrivilege("npcs.modify", "Modify", "Allows the user to modify npcs", { ["CanTool"] = {} })
	P.registerPrivilege("npcs.giveweapon", "Give weapon", "Allows the user to give npcs weapons", { ["CanTool"] = {} })
end

-- ------------------------------------------------------------------------- --
function npc_metatable:__tostring()
	local ent = unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

--- Adds a relationship to the npc
-- @param str The relationship string. http://wiki.garrysmod.com/page/NPC/AddRelationship
function npc_methods:addRelationship(str)
	SF.CheckType(self, npc_metatable)
	local npc = unwrap(self)
	if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
	SF.Permissions.check(SF.instance.player, npc, "npcs.modify")
	npc:AddRelationship(str)
end

local dispositions = {
	error = D_ER,
	hate = D_HT,
	fear = D_FR,
	like = D_LI,
	neutral = D_NU,
	[D_ER] = "error",
	[D_HT] = "hate",
	[D_FR] = "fear",
	[D_LI] = "like",
	[D_NU] = "neutral",
}
--- Adds a relationship to the npc with an entity
-- @param ent The target entity
-- @param disp String of the relationship. (hate fear like neutral)
-- @param priority number how strong the relationship is. Higher number is stronger
function npc_methods:addEntityRelationship(ent, disp, priority)
	SF.CheckType(self, npc_metatable)
	local npc = unwrap(self)
	local target = unwrap(ent)
	local relation = dispositions[disp]
	if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
	if not target:IsValid() then SF.Throw("Target is invalid", 2) end
	if not relation then SF.Throw("Invalid relationship specified") end
	SF.Permissions.check(SF.instance.player, npc, "npcs.modify")
	npc:AddEntityRelationship(target, relation, priority)
end

--- Gets the npc's relationship to the target
-- @param ent Target entity
-- @return string relationship of the npc with the target
function npc_methods:getRelationship(ent)
	SF.CheckType(self, npc_metatable)
	SF.CheckType(ent, ents_metatable)
	local npc = unwrap(self)
	local target = unwrap(ent)
	if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
	if not target:IsValid() then SF.Throw("Target is invalid", 2) end
	return dispositions[npc:Disposition()]
end

--- Gives the npc a weapon
-- @param wep The classname of the weapon
function npc_methods:giveWeapon(wep)
	SF.CheckType(self, npc_metatable)
	SF.CheckLuaType(wep, TYPE_STRING)
	
	local npc = unwrap(self)
	if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
	SF.Permissions.check(SF.instance.player, npc, "npcs.giveweapon")

	local weapon = npc:GetActiveWeapon()
	if (weapon:IsValid()) then
		if (weapon:GetClass() == "weapon_" .. wep) then return end
		weapon:Remove()
	end

	npc:Give("ai_weapon_" .. wep)
end

--- Tell the npc to fight this
-- @param ent Target entity
function npc_methods:setEnemy(ent)
	SF.CheckType(self, npc_metatable)
	SF.CheckType(ent, ents_metatable)
	local npc = unwrap(self)
	local target = unwrap(ent)
	if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
	if not target:IsValid() then SF.Throw("Target is invalid", 2) end
	SF.Permissions.check(SF.instance.player, npc, "npcs.modify")
	npc:SetTarget(target)
end

--- Gets what the npc is fighting
-- @return Entity the npc is fighting
function npc_methods:getEnemy()
	SF.CheckType(self, npc_metatable)
	local npc = unwrap(self)
	if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
	return vwrap(npc:GetEnemy())
end

--- Stops the npc
function npc_methods:stop()
	SF.CheckType(self, npc_metatable)
	local npc = unwrap(self)
	if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
	SF.Permissions.check(SF.instance.player, npc, "npcs.modify")
	npc:SetSchedule(SCHED_NONE)
end

--- Makes the npc do a melee attack
function npc_methods:attackMelee()
	SF.CheckType(self, npc_metatable)
	local npc = unwrap(self)
	if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
	SF.Permissions.check(SF.instance.player, npc, "npcs.modify")
	npc:SetSchedule(SCHED_MELEE_ATTACK1)
end

--- Makes the npc do a ranged attack
function npc_methods:attackRange()
	SF.CheckType(self, npc_metatable)
	local npc = unwrap(self)
	if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
	SF.Permissions.check(SF.instance.player, npc, "npcs.modify")
	npc:SetSchedule(SCHED_RANGE_ATTACK1)
end

--- Makes the npc walk to a destination
-- @param vec The position of the destination
function npc_methods:goWalk(vec)
	SF.CheckType(self, npc_metatable)
	local npc = unwrap(self)
	if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
	SF.Permissions.check(SF.instance.player, npc, "npcs.modify")
	npc:SetLastPosition(vunwrap(vec))
	npc:SetSchedule(SCHED_FORCED_GO)
end

--- Makes the npc run to a destination
-- @param vec The position of the destination
function npc_methods:goRun(vec)
	SF.CheckType(self, npc_metatable)
	local npc = unwrap(self)
	if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
	SF.Permissions.check(SF.instance.player, npc, "npcs.modify")
	npc:SetLastPosition(vunwrap(vec))
	npc:SetSchedule(SCHED_FORCED_GO_RUN)
end

