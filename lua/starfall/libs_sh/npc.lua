-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local registerprivilege = SF.Permissions.registerPrivilege

if SERVER then
	-- Register privileges
	registerprivilege("npcs.modify", "Modify", "Allows the user to modify npcs", { entities = {} })
	registerprivilege("npcs.giveweapon", "Give weapon", "Allows the user to give npcs weapons", { entities = {} })
end


--- Npc type
SF.RegisterType("Npc", false, true, debug.getregistry().NPC, "Entity")

return function(instance)

local checktype = instance.CheckType
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local npc_methods, npc_meta, wrap, unwrap = instance.Types.Npc.Methods, instance.Types.Npc, instance.Types.Npc.Wrap, instance.Types.Npc.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap

-- ------------------------------------------------------------------------- --
function npc_meta:__tostring()
	local ent = unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

if SERVER then
	--- Adds a relationship to the npc
	-- @server
	-- @param str The relationship string. http://wiki.garrysmod.com/page/NPC/AddRelationship
	function npc_methods:addRelationship(str)
		checktype(self, npc_meta)
		local npc = unwrap(self)
		if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
		checkpermission(instance, npc, "npcs.modify")
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
	-- @server
	-- @param ent The target entity
	-- @param disp String of the relationship. (hate fear like neutral)
	-- @param priority number how strong the relationship is. Higher number is stronger
	function npc_methods:addEntityRelationship(ent, disp, priority)
		checktype(self, npc_meta)
		local npc = unwrap(self)
		local target = unwrap(ent)
		local relation = dispositions[disp]
		if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
		if not target:IsValid() then SF.Throw("Target is invalid", 2) end
		if not relation then SF.Throw("Invalid relationship specified") end
		checkpermission(instance, npc, "npcs.modify")
		npc:AddEntityRelationship(target, relation, priority)
	end

	--- Gets the npc's relationship to the target
	-- @server
	-- @param ent Target entity
	-- @return string relationship of the npc with the target
	function npc_methods:getRelationship(ent)
		checktype(self, npc_meta)
		checktype(ent, ent_meta)
		local npc = unwrap(self)
		local target = unwrap(ent)
		if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
		if not target:IsValid() then SF.Throw("Target is invalid", 2) end
		return dispositions[npc:Disposition()]
	end

	--- Gives the npc a weapon
	-- @server
	-- @param wep The classname of the weapon
	function npc_methods:giveWeapon(wep)
		checktype(self, npc_meta)
		checkluatype(wep, TYPE_STRING)

		local npc = unwrap(self)
		if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
		checkpermission(instance, npc, "npcs.giveweapon")

		local weapon = npc:GetActiveWeapon()
		if (weapon:IsValid()) then
			if (weapon:GetClass() == "weapon_" .. wep) then return end
			weapon:Remove()
		end

		npc:Give("ai_weapon_" .. wep)
	end

	--- Tell the npc to fight this
	-- @server
	-- @param ent Target entity
	function npc_methods:setEnemy(ent)
		checktype(self, npc_meta)
		checktype(ent, ent_meta)
		local npc = unwrap(self)
		local target = unwrap(ent)
		if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
		if not target:IsValid() then SF.Throw("Target is invalid", 2) end
		checkpermission(instance, npc, "npcs.modify")
		npc:SetTarget(target)
	end

	--- Gets what the npc is fighting
	-- @server
	-- @return Entity the npc is fighting
	function npc_methods:getEnemy()
		checktype(self, npc_meta)
		local npc = unwrap(self)
		if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
		return owrap(npc:GetEnemy())
	end

	--- Stops the npc
	-- @server
	function npc_methods:stop()
		checktype(self, npc_meta)
		local npc = unwrap(self)
		if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
		checkpermission(instance, npc, "npcs.modify")
		npc:SetSchedule(SCHED_NONE)
	end

	--- Makes the npc do a melee attack
	-- @server
	function npc_methods:attackMelee()
		checktype(self, npc_meta)
		local npc = unwrap(self)
		if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
		checkpermission(instance, npc, "npcs.modify")
		npc:SetSchedule(SCHED_MELEE_ATTACK1)
	end

	--- Makes the npc do a ranged attack
	-- @server
	function npc_methods:attackRange()
		checktype(self, npc_meta)
		local npc = unwrap(self)
		if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
		checkpermission(instance, npc, "npcs.modify")
		npc:SetSchedule(SCHED_RANGE_ATTACK1)
	end

	--- Makes the npc walk to a destination
	-- @server
	-- @param vec The position of the destination
	function npc_methods:goWalk(vec)
		checktype(self, npc_meta)
		local npc = unwrap(self)
		if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
		checkpermission(instance, npc, "npcs.modify")
		npc:SetLastPosition(vunwrap(vec))
		npc:SetSchedule(SCHED_FORCED_GO)
	end

	--- Makes the npc run to a destination
	-- @server
	-- @param vec The position of the destination
	function npc_methods:goRun(vec)
		checktype(self, npc_meta)
		local npc = unwrap(self)
		if not npc:IsValid() then SF.Throw("NPC is invalid", 2) end
		checkpermission(instance, npc, "npcs.modify")
		npc:SetLastPosition(vunwrap(vec))
		npc:SetSchedule(SCHED_FORCED_GO_RUN)
	end
end

end
