-- Global to all Starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local ENT_META = FindMetaTable("Entity")
local NPC_META = FindMetaTable("NPC")


local lagCompensated
if SERVER then
	-- Register privileges
	registerprivilege("npcs.modify", "Modify", "Allows the user to modify NPCs", { entities = {} })
	registerprivilege("npcs.giveweapon", "Give weapon", "Allows the user to give NPCs weapons", { entities = {} })

	lagCompensated = SF.EntManager("npcs_lag_compensated", "lag compensated npcs", 40, "The number of NPCs allowed to be lag compensated")
end


--- NPC type.
-- Inherits all functions from `Entity` type.
-- Created with `prop.createSent` function, e.g. with class "npc_zombine".
-- @name Npc
-- @class type
-- @libtbl npc_methods
-- @libtbl npc_meta
SF.RegisterType("Npc", "entity", nil, NPC_META, "Entity")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_GetClass,Ent_IsLagCompensated,Ent_IsValid,Ent_Remove,Ent_SetLagCompensated = ENT_META.GetClass,ENT_META.IsLagCompensated,ENT_META.IsValid,ENT_META.Remove,ENT_META.SetLagCompensated
local Npc_AddEntityRelationship,Npc_AddRelationship,Npc_GetEnemy,Npc_Give,Npc_SetLastPosition,Npc_SetSchedule,Npc_SetTarget = NPC_META.AddEntityRelationship,NPC_META.AddRelationship,NPC_META.GetEnemy,NPC_META.Give,NPC_META.SetLastPosition,NPC_META.SetSchedule,NPC_META.SetTarget

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local npc_methods, npc_meta, wrap, unwrap = instance.Types.Npc.Methods, instance.Types.Npc, instance.Types.Npc.Wrap, instance.Types.Npc.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local vunwrap1
instance:AddHook("initialize", function()
	npc_meta.__tostring = ent_meta.__tostring
	vunwrap1 = vec_meta.QuickUnwrap1
end)

instance:AddHook("deinitialize", function()
	if SERVER then lagCompensated:deinitialize(instance) end
end)

if SERVER then

	--- Sets an NPC's hitboxes to compensate for lag, but limited number of NPCs can be set due to high processing needed
	-- @server
	-- @param boolean compensate Whether to make an NPC's hitboxes compensate lag
	function npc_methods:setLagCompensated(compensate)
		local npc = unwrap(self)
		checkpermission(instance, npc, "npcs.modify")
		if compensate and not Ent_IsLagCompensated(npc) then
			lagCompensated:checkuse(instance.player, 1)
			lagCompensated:register(instance, npc)
			Ent_SetLagCompensated(npc, true)
		elseif not compensate and Ent_IsLagCompensated(npc) then
			lagCompensated:unregister(npc)
			Ent_SetLagCompensated(npc, false)
		end
	end

	--- Gets whether an NPC is lag compensated
	-- @server
	-- @return boolean Whether the NPC is lag compensated
	function npc_methods:isLagCompensated()
		return Ent_IsLagCompensated(unwrap(self))
	end

	--- Adds a relationship to the NPC
	-- @server
	-- @param string str The relationship string. https://wiki.facepunch.com/gmod/NPC:AddRelationship
	function npc_methods:addRelationship(str)
		local npc = unwrap(self)
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
	--- Adds a relationship to the NPC with an entity
	-- @server
	-- @param Entity ent The target entity
	-- @param string disp String of the relationship. ("hate", "fear", "like", "neutral")
	-- @param number priority How strong the relationship is. Higher number is stronger
	function npc_methods:addEntityRelationship(ent, disp, priority)
		local npc = unwrap(self)
		local target = eunwrap(ent)
		local relation = dispositions[disp]
		if not relation then SF.Throw("Invalid relationship specified", 2) end
		checkpermission(instance, npc, "npcs.modify")
		Npc_AddEntityRelationship(npc, target, relation, priority)
	end

	--- Gets the NPC's relationship to the target
	-- @server
	-- @param Entity ent Target entity
	-- @return string Relationship of the NPC with the target
	function npc_methods:getRelationship(ent)
		return dispositions[unwrap(self):Disposition(eunwrap(ent))]
	end

	--- Gives the NPC a weapon
	-- @server
	-- @param string wep The classname of the weapon
	function npc_methods:giveWeapon(wep)
		checkluatype(wep, TYPE_STRING)

		local npc = unwrap(self)
		checkpermission(instance, npc, "npcs.giveweapon")

		local npcSpawnable = false
		for _, v in ipairs(list.GetForEdit("NPCUsableWeapons")) do
			if v.class == wep then npcSpawnable = true break end
		end
		if not npcSpawnable then SF.Throw("Weapon "..wep.." is not in npc useable weapons list!", 2) end

		local weapon = npc:GetActiveWeapon()
		if Ent_IsValid(weapon) then
			if (Ent_GetClass(weapon) == wep) then return end
			Ent_Remove(weapon)
		end

		Npc_Give(npc, wep)
	end

	--- Tell the NPC to fight this
	-- @server
	-- @param Entity ent Target entity
	function npc_methods:setEnemy(ent)
		local npc = unwrap(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetTarget(npc, eunwrap(ent))
	end

	--- Gets what the NPC is fighting
	-- @server
	-- @return Entity Entity the NPC is fighting
	function npc_methods:getEnemy()
		return owrap(Npc_GetEnemy(unwrap(self)))
	end

	--- Stops the NPC
	-- @server
	function npc_methods:stop()
		local npc = unwrap(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetSchedule(npc, SCHED_NONE)
	end

	--- Makes the NPC do a melee attack
	-- @server
	function npc_methods:attackMelee()
		local npc = unwrap(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetSchedule(npc, SCHED_MELEE_ATTACK1)
	end

	--- Makes the NPC do a ranged attack
	-- @server
	function npc_methods:attackRange()
		local npc = unwrap(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetSchedule(npc, SCHED_RANGE_ATTACK1)
	end

	--- Makes the NPC walk to a destination
	-- @server
	-- @param Vector vec The position of the destination
	function npc_methods:goWalk(vec)
		local npc = unwrap(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetLastPosition(npc, vunwrap1(vec))
		Npc_SetSchedule(npc, SCHED_FORCED_GO)
	end

	--- Makes the NPC run to a destination
	-- @server
	-- @param Vector vec The position of the destination
	function npc_methods:goRun(vec)
		local npc = unwrap(self)
		checkpermission(instance, npc, "npcs.modify")
		Npc_SetLastPosition(npc, vunwrap1(vec))
		Npc_SetSchedule(npc, SCHED_FORCED_GO_RUN)
	end
end

end
