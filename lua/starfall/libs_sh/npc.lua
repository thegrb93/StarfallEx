-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local ENT_META = FindMetaTable("Entity")
local NPC_META = FindMetaTable("NPC")


if SERVER then
	-- Register privileges
	registerprivilege("npcs.modify", "Modify", "Allows the user to modify npcs", { entities = {} })
	registerprivilege("npcs.giveweapon", "Give weapon", "Allows the user to give npcs weapons", { entities = {} })
end


--- Npc type
-- @name Npc
-- @class type
-- @libtbl npc_methods
-- @libtbl npc_meta
SF.RegisterType("Npc", false, true, NPC_META, "Entity")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_GetClass,Ent_IsValid,Ent_Remove = ENT_META.GetClass,ENT_META.IsValid,ENT_META.Remove
local Npc_AddEntityRelationship,Npc_AddRelationship,Npc_GetEnemy,Npc_Give,Npc_SetLastPosition,Npc_SetSchedule,Npc_SetTarget = NPC_META.AddEntityRelationship,NPC_META.AddRelationship,NPC_META.GetEnemy,NPC_META.Give,NPC_META.SetLastPosition,NPC_META.SetSchedule,NPC_META.SetTarget

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local npc_methods, npc_meta, wrap, unwrap = instance.Types.Npc.Methods, instance.Types.Npc, instance.Types.Npc.Wrap, instance.Types.Npc.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local getent
local vunwrap1
instance:AddHook("initialize", function()
	getent = ent_meta.GetEntity
	npc_meta.__tostring = ent_meta.__tostring
	vunwrap1 = vec_meta.QuickUnwrap1
end)

local function getnpc(self)
	local ent = npc_meta.sf2sensitive[self]
	if Ent_IsValid(ent) then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end

if SERVER then
	--- Adds a relationship to the npc
	-- @server
	-- @param string str The relationship string. http://wiki.facepunch.com/gmod/NPC:AddRelationship
	function npc_methods:addRelationship(str)
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_AddRelationship(npc, str)
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
	-- @server
	-- @param Entity ent The target entity
	-- @param string disp String of the relationship. ("hate", "fear", "like", "neutral")
	-- @param number priority How strong the relationship is. Higher number is stronger
	function npc_methods:addEntityRelationship(ent, disp, priority)
		local npc = getnpc(self)
		local target = getent(ent)
		local relation = dispositions[disp]
		if not relation then SF.Throw("Invalid relationship specified", 2) end
		checkpermission(instance, npc, "npcs.modify")
		Npc_AddEntityRelationship(npc, target, relation, priority)
	end

	--- Gets the npc's relationship to the target
	-- @server
	-- @param Entity ent Target entity
	-- @return string Relationship of the npc with the target
	function npc_methods:getRelationship(ent)
		return dispositions[getnpc(self):Disposition(getent(ent))]
	end

	--- Gives the npc a weapon
	-- @server
	-- @param string wep The classname of the weapon
	function npc_methods:giveWeapon(wep)
		checkluatype(wep, TYPE_STRING)

		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.giveweapon")

		local weapon = npc:GetActiveWeapon()
		if Ent_IsValid(weapon) then
			if (Ent_GetClass(weapon) == "weapon_" .. wep) then return end
			Ent_Remove(weapon)
		end

		Npc_Give(npc, "ai_weapon_" .. wep)
	end

	--- Tell the npc to fight this
	-- @server
	-- @param Entity ent Target entity
	function npc_methods:setEnemy(ent)
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetTarget(npc, getent(ent))
	end

	--- Gets what the npc is fighting
	-- @server
	-- @return Entity Entity the npc is fighting
	function npc_methods:getEnemy()
		return owrap(Npc_GetEnemy(getnpc(self)))
	end

	--- Stops the npc
	-- @server
	function npc_methods:stop()
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetSchedule(npc, SCHED_NONE)
	end

	--- Makes the npc do a melee attack
	-- @server
	function npc_methods:attackMelee()
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetSchedule(npc, SCHED_MELEE_ATTACK1)
	end

	--- Makes the npc do a ranged attack
	-- @server
	function npc_methods:attackRange()
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetSchedule(npc, SCHED_RANGE_ATTACK1)
	end

	--- Makes the npc walk to a destination
	-- @server
	-- @param Vector vec The position of the destination
	function npc_methods:goWalk(vec)
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetLastPosition(npc, vunwrap1(vec))
		Npc_SetSchedule(npc, SCHED_FORCED_GO)
	end

	--- Makes the npc run to a destination
	-- @server
	-- @param Vector vec The position of the destination
	function npc_methods:goRun(vec)
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetLastPosition(npc, vunwrap1(vec))
		Npc_SetSchedule(npc, SCHED_FORCED_GO_RUN)
	end
end

end
