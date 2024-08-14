-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local IsValid = FindMetaTable("Entity").IsValid

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
SF.RegisterType("Npc", false, true, FindMetaTable("NPC"), "Entity")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local npc_methods, npc_meta, wrap, unwrap = instance.Types.Npc.Methods, instance.Types.Npc, instance.Types.Npc.Wrap, instance.Types.Npc.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local getent
instance:AddHook("initialize", function()
	getent = ent_meta.GetEntity
	npc_meta.__tostring = ent_meta.__tostring
end)

local function getnpc(self)
	local ent = npc_meta.sf2sensitive[self]
	if IsValid(ent) then
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
	-- @param Entity ent The target entity
	-- @param string disp String of the relationship. ("hate", "fear", "like", "neutral")
	-- @param number priority How strong the relationship is. Higher number is stronger
	function npc_methods:addEntityRelationship(ent, disp, priority)
		local npc = getnpc(self)
		local target = getent(ent)
		local relation = dispositions[disp]
		if not relation then SF.Throw("Invalid relationship specified", 2) end
		checkpermission(instance, npc, "npcs.modify")
		npc:AddEntityRelationship(target, relation, priority)
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
		if IsValid(weapon) then
			if (weapon:GetClass() == "weapon_" .. wep) then return end
			weapon:Remove()
		end

		npc:Give("ai_weapon_" .. wep)
	end

	--- Tell the npc to fight this
	-- @server
	-- @param Entity ent Target entity
	function npc_methods:setEnemy(ent)
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		npc:SetTarget(getent(ent))
	end

	--- Gets what the npc is fighting
	-- @server
	-- @return Entity Entity the npc is fighting
	function npc_methods:getEnemy()
		return owrap(getnpc(self):GetEnemy())
	end

	--- Stops the npc
	-- @server
	function npc_methods:stop()
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		npc:SetSchedule(SCHED_NONE)
	end

	--- Makes the npc do a melee attack
	-- @server
	function npc_methods:attackMelee()
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		npc:SetSchedule(SCHED_MELEE_ATTACK1)
	end

	--- Makes the npc do a ranged attack
	-- @server
	function npc_methods:attackRange()
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		npc:SetSchedule(SCHED_RANGE_ATTACK1)
	end

	--- Makes the npc walk to a destination
	-- @server
	-- @param Vector vec The position of the destination
	function npc_methods:goWalk(vec)
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		npc:SetLastPosition(vunwrap(vec))
		npc:SetSchedule(SCHED_FORCED_GO)
	end

	--- Makes the npc run to a destination
	-- @server
	-- @param Vector vec The position of the destination
	function npc_methods:goRun(vec)
		local npc = getnpc(self)
		checkpermission(instance, npc, "npcs.modify")
		npc:SetLastPosition(vunwrap(vec))
		npc:SetSchedule(SCHED_FORCED_GO_RUN)
	end
end

end
