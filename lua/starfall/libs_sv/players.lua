-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkvalidnumber = SF.CheckValidNumber
local checkvector = SF.CheckVector
local registerprivilege = SF.Permissions.registerPrivilege
local ENT_META = FindMetaTable("Entity")
local PLY_META = FindMetaTable("Player")

local playerMaxScale = CreateConVar("sf_player_model_scale_max", "10", { FCVAR_ARCHIVE }, "Maximum player model scale the user is allowed to set using Player.setModelScale", 1, 100)

-- Register privileges
registerprivilege("player.dropweapon", "DropWeapon", "Drops a weapon from the player", { entities = {} })
registerprivilege("player.setammo", "SetAmmo", "Whether a player can set their ammo", { usergroups = { default = 1 }, entities = {} })
registerprivilege("player.enterVehicle", "EnterVehicle", "Whether a player can be forced into a vehicle", { usergroups = { default = 1 }, entities = {} })
registerprivilege("player.setArmor", "SetArmor", "Allows changing a player's armor", { usergroups = { default = 1 }, entities = {} })
registerprivilege("player.setMaxArmor", "SetMaxArmor", "Allows changing a player's max armor", { usergroups = { default = 1 }, entities = {} })
registerprivilege("player.modifyMovementProperties", "ModifyMovementProperties", "Allows various changes to a player's movement", { usergroups = { default = 1 }, entities = {} })

local PVSLimitCvar = CreateConVar("sf_pvs_pointlimit", 16, FCVAR_ARCHIVE, "The number of PVS points that can be set on each player, limit is shared across all chips")

local PVSManager = {

	__index = { 
		updateActiveTable = function(self)
			table.Empty(self.PVSactiveTable)

			local active = self.PVSactiveTable
			for cPly, chips in pairs( self.PVScountTable ) do
				for chip, targets in pairs( chips ) do
					for tPly, points in pairs( targets ) do
						table.Add( active[tPly] , points )
					end
				end
			end

			if not table.IsEmpty(self.PVSactiveTable) then--activate/deactivate hook depending on whether or not active table is empty.
				hook.Add("SetupPlayerVisibility", "SF_SetupPlayerVisibility", function( ply, viewEntity )
					local plyPVSes = self.PVSactiveTable[ ply ]
					if plyPVSes then
						for _,point in ipairs( plyPVSes ) do
							AddOriginToPVS( point )
						end
					end
				end)
			else
				hook.Remove( "SetupPlayerVisiblity", "SF_SetupPlayerVisibility")
			end
		end,

		prepareUpdateActiveTable = function(self)
			if not self.preparingPVSUpdate then
				self.preparingPVSUpdate = true
				timer.Simple(0,function()
					self:updateActiveTable()
					self.preparingPVSUpdate = false
				end)
			end	
		end,

		clearInstCountTable = function(self, inst)
			self.PVScountTable[inst.player][inst] = nil
			if table.IsEmpty(self.PVScountTable[inst.player]) then
				self.PVScountTable[inst.player] = nil
			end
			self:prepareUpdateActiveTable()
		end,

		clearInstPlyTable = function(self, inst, tply )
			self.PVScountTable[inst.player][inst][tply] = nil

			if table.IsEmpty(self.PVScountTable[inst.player][inst]) then
				self:clearInstCountTable(inst)
			end
			self:prepareUpdateActiveTable()
		end,

		checkCountTable = function( self, inst, tply, id, pos)
			local count = 0
			if rawget(self.PVScountTable[inst.player][inst][tply],id) ~= nil or pos == nil then return end
			for c,chip in pairs(self.PVScountTable[inst.player]) do
				count = count + table.Count(chip[tply])
			end
			if count >= PVSLimitCvar:GetInt() then SF.Throw("The max number of PVS points for "..tply:Nick() .." has been reached. ("..PVSLimitCvar:GetInt()..")") end
		end,

		setPointToCountTable = function(self, inst, tply, id, pos)
		
		
			self:checkCountTable(inst, tply, id, pos)
			self.PVScountTable[inst.player][inst][tply][id] = pos

			if table.IsEmpty(self.PVScountTable[inst.player][inst][tply]) then
				self:clearInstPlyTable(inst, tply)
			end
			self:prepareUpdateActiveTable()
		end
	},
	__call = function(t)
		return setmetatable({
			PVScountTable = SF.AutoGrowingTable(),
			PVSactiveTable = SF.AutoGrowingTable(),
			PreparingPVSUpdate = false
		}, t)
	end
}

setmetatable(PVSManager,PVSManager)

local PlayerPVSManager = PVSManager()

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_SetFriction,Ent_SetModelScale = ENT_META.SetFriction,ENT_META.SetModelScale
local Ply_Alive,Ply_DropNamedWeapon,Ply_DropWeapon,Ply_EnterVehicle,Ply_GetTimeoutSeconds,Ply_HasGodMode,Ply_IsConnected,Ply_IsTimingOut,Ply_Kill,Ply_LastHitGroup,Ply_PacketLoss,Ply_Say,Ply_SetAmmo,Ply_SetArmor,Ply_SetCrouchedWalkSpeed,Ply_SetDuckSpeed,Ply_SetEyeAngles,Ply_SetJumpPower,Ply_SetLadderClimbSpeed,Ply_SetMaxArmor,Ply_SetMaxSpeed,Ply_SetRunSpeed,Ply_SetSlowWalkSpeed,Ply_SetStepSize,Ply_SetUnDuckSpeed,Ply_SetViewEntity,Ply_SetWeaponColor,Ply_SetWalkSpeed,Ply_StripAmmo,Ply_StripWeapon,Ply_StripWeapons,Ply_TimeConnected = PLY_META.Alive,PLY_META.DropNamedWeapon,PLY_META.DropWeapon,PLY_META.EnterVehicle,PLY_META.GetTimeoutSeconds,PLY_META.HasGodMode,PLY_META.IsConnected,PLY_META.IsTimingOut,PLY_META.Kill,PLY_META.LastHitGroup,PLY_META.PacketLoss,PLY_META.Say,PLY_META.SetAmmo,PLY_META.SetArmor,PLY_META.SetCrouchedWalkSpeed,PLY_META.SetDuckSpeed,PLY_META.SetEyeAngles,PLY_META.SetJumpPower,PLY_META.SetLadderClimbSpeed,PLY_META.SetMaxArmor,PLY_META.SetMaxSpeed,PLY_META.SetRunSpeed,PLY_META.SetSlowWalkSpeed,PLY_META.SetStepSize,PLY_META.SetUnDuckSpeed,PLY_META.SetViewEntity,PLY_META.SetWeaponColor,PLY_META.SetWalkSpeed,PLY_META.StripAmmo,PLY_META.StripWeapon,PLY_META.StripWeapons,PLY_META.TimeConnected

local player_methods, player_meta, wrap, unwrap = instance.Types.Player.Methods, instance.Types.Player, instance.Types.Player.Wrap, instance.Types.Player.Unwrap
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local wep_meta, wwrap, wunwrap = instance.Types.Weapon, instance.Types.Weapon.Wrap, instance.Types.Weapon.Unwrap
local veh_meta, vhwrap, vhunwrap = instance.Types.Vehicle, instance.Types.Vehicle.Wrap, instance.Types.Vehicle.Unwrap

local getent, getply
local vunwrap1, vunwrap2
local aunwrap1
instance:AddHook("initialize", function()
	getent = ent_meta.GetEntity
	getply = player_meta.GetPlayer
	player_meta.__tostring = ent_meta.__tostring
	vunwrap1, vunwrap2 = vec_meta.QuickUnwrap1, vec_meta.QuickUnwrap2
	aunwrap1 = ang_meta.QuickUnwrap1
end)

instance:AddHook("deinitialize", function()
	for k, ply in pairs(player.GetAll()) do
		if instance.data.viewEntityChanged then
			Ply_SetViewEntity(ply)
		end
	end
	PlayerPVSManager:clearInstCountTable( instance )
end)

instance:AddHook( "starfall_hud_disconnected", function( activator, ply )
	if ply ~= instance.player then
		PlayerPVSManager:clearInstPlyTable( instance, ply )
	end
end)

--- Lets you change the size of yourself if the server has sf_permissions_entity_owneraccess 1
-- @param number scale The scale to apply, will be truncated to the first two decimal places (min 0.01, max 100)
function player_methods:setModelScale(scale)
	checkvalidnumber(scale)
	local ply = getply(self)
	checkpermission(instance, ply, "entities.setRenderProperty")
	Ent_SetModelScale(ply, math.Clamp(math.Truncate(scale, 2), 0.01, playerMaxScale:GetFloat()))
end

--- Checks if the player is connected to a HUD component that's linked to this chip
-- @return boolean If a HUD component is connected and active for the player
function player_methods:isHUDActive()
	return SF.IsHUDActive(instance.entity, getply(self))
end

--- Sets the view entity of the player. Only works if they are linked to a hud.
-- @param Entity? ent Entity to set the player's view entity to, or nothing to reset it
function player_methods:setViewEntity(ent)
	local ply = getply(self)
	if ent~=nil then ent = getent(ent) end
	if not SF.IsHUDActive(instance.entity, ply) then SF.Throw("Player isn't connected to HUD!", 2) end
	instance.data.viewEntityChanged = ent ~= nil and ent ~= ply
	Ply_SetViewEntity(ply, ent)
end

--- Returns whether or not the player has godmode
-- @return boolean True if the player has godmode
function player_methods:hasGodMode()
	return Ply_HasGodMode(getply(self))
end

--- Drops the player's weapon
-- @param Weapon|string weapon The weapon instance or class name of the weapon to drop
-- @param Vector? target If set, launches the weapon at the given position
-- @param Vector? velocity If set and target is unset, launches the weapon with the given velocity
function player_methods:dropWeapon(weapon, target, velocity)
	local ply = getply(self)
	checkpermission(instance, ply, "player.dropweapon")

	if target~=nil then target = vunwrap1(target) end
	if velocity~=nil then velocity = vunwrap2(velocity) end

	if isstring(weapon) then
		Ply_DropNamedWeapon(ply, weapon, target, velocity)
	else
		weapon = wunwrap(weapon)
		Ply_DropWeapon(ply, weapon, target, velocity)
	end
end

--- Strips the player's weapon
-- @param string weapon The weapon class name of the weapon to strip
function player_methods:stripWeapon(weapon)
	local ply = getply(self)
	checkpermission(instance, ply, "player.dropweapon")
	checkluatype(weapon, TYPE_STRING)
	Ply_StripWeapon(ply, weapon)
end

--- Strips all the player's weapons
function player_methods:stripWeapons()
	local ply = getply(self)
	checkpermission(instance, ply, "player.dropweapon")
	Ply_StripWeapons(ply)
end

--- Sets the player's ammo
-- @param number amount The ammo value
-- @param number|string ammoType Ammo type id or name
function player_methods:setAmmo(amount, ammoType)
	local ply = getply(self)
	checkpermission(instance, ply, "player.setammo")

	checkvalidnumber(amount)
	if not (isstring(ammoType) or isnumber(ammoType)) then
		SF.ThrowTypeError("number or string", SF.GetType(ammoType), 2)
	end

	Ply_SetAmmo(ply, amount, ammoType)
end

--- Removes all a player's ammo
function player_methods:stripAmmo()
	local ply = getply(self)
	checkpermission(instance, ply, "player.setammo")
	Ply_StripAmmo(ply)
end

--- Returns the hitgroup where the player was last hit.
-- @return number Hitgroup, see https://wiki.facepunch.com/gmod/Enums/HITGROUP
function player_methods:lastHitGroup()
	return Ply_LastHitGroup(getply(self))
end

--- Sets a player's eye angles
-- @param Angle ang New angles
function player_methods:setEyeAngles(ang)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setEyeAngles")
	Ply_SetEyeAngles(ent, aunwrap1(ang))
end

--- Returns the packet loss of the client
-- @return number Packets lost
function player_methods:getPacketLoss()
	return Ply_PacketLoss(getply(self))
end

--- Returns the time in seconds since the player connected
-- @return number Time connected
function player_methods:getTimeConnected()
	return Ply_TimeConnected(getply(self))
end

--- Returns the number of seconds that the player has been timing out for
-- @return number Timeout seconds
function player_methods:getTimeoutSeconds()
	return Ply_GetTimeoutSeconds(getply(self))
end

--- Returns true if the player is timing out
-- @return boolean isTimingOut
function player_methods:isTimingOut()
	return Ply_IsTimingOut(getply(self))
end

--- Returns whether the player is connected
-- @return boolean True if player is connected
function player_methods:isConnected()
	return Ply_IsConnected(getply(self))
end

--- Forces the player to say the first argument
-- Only works on the chip's owner.
-- @param string text The text to force the player to say
-- @param boolean? teamOnly Team chat only?, Defaults to false.
function player_methods:say(text, teamOnly)
	checkluatype(text, TYPE_STRING)
	if teamOnly~=nil then checkluatype(teamOnly, TYPE_BOOL) end
	local ply = getply(self)
	if instance.player ~= ply then SF.Throw("Player say can only be used on yourself!", 2) end
	if CurTime() < (ply.sf_say_cd or 0) then SF.Throw("Player say must wait 0.5s between calls!", 2) end
	ply.sf_say_cd = CurTime() + 0.5
	Ply_Say(ply, text, teamOnly)
end

--- Sets the armor of the player.
-- @param number newarmor New armor value.
function player_methods:setArmor(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.setArmor")
	checkvalidnumber(val)
	Ply_SetArmor(ent, val)
end

--- Sets the maximum armor for player. You can still set a player's armor above this amount with Player:setArmor.
-- @param number newmaxarmor New max armor value.
function player_methods:setMaxArmor(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.setMaxArmor")
	checkvalidnumber(val)
	Ply_SetMaxArmor(ent, val)
end

--- Sets Crouched Walk Speed
-- @param number newcwalkspeed New Crouch Walk speed, This is a multiplier from 0 to 1.
function player_methods:setCrouchedWalkSpeed(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.modifyMovementProperties")
	checkvalidnumber(val)
	Ply_SetCrouchedWalkSpeed(ent, math.Clamp(val,0,1))
end

--- Sets Duck Speed
-- @param number newduckspeed New Duck speed, This is a multiplier from 0 to 1.
function player_methods:setDuckSpeed(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.modifyMovementProperties")
	checkvalidnumber(val)
	Ply_SetDuckSpeed(ent, math.Clamp(val,0.005,0.995))
end

--- Sets UnDuck Speed
-- @param number newunduckspeed New UnDuck speed, This is a multiplier from 0 to 1.
function player_methods:setUnDuckSpeed(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.modifyMovementProperties")
	checkvalidnumber(val)
	Ply_SetUnDuckSpeed(ent, math.Clamp(val,0.005,0.995))
end

--- Sets Ladder Climb Speed, probably unstable
-- @param number newladderclimbspeed New Ladder Climb speed.
function player_methods:setLadderClimbSpeed(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.modifyMovementProperties")
	checkvalidnumber(val)
	Ply_SetLadderClimbSpeed(ent, math.max(val,0))
end

--- Sets Max Speed
-- @param number newmaxspeed New Max speed.
function player_methods:setMaxSpeed(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.modifyMovementProperties")
	checkvalidnumber(val)
	Ply_SetMaxSpeed(ent, math.max(val,0))
end

--- Sets Run Speed ( +speed )
-- @param number newrunspeed New Run speed.
function player_methods:setRunSpeed(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.modifyMovementProperties")
	checkvalidnumber(val)
	Ply_SetRunSpeed(ent, math.max(val,0))
end

--- Sets Slow Walk Speed ( +walk )
-- @param number newslowwalkspeed New Slow Walk speed.
function player_methods:setSlowWalkSpeed(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.modifyMovementProperties")
	checkvalidnumber(val)
	Ply_SetSlowWalkSpeed(ent, math.max(val,0))
end

--- Sets Walk Speed
-- @param number newwalkspeed New Walk speed.
function player_methods:setWalkSpeed(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.modifyMovementProperties")
	checkvalidnumber(val)
	Ply_SetWalkSpeed(ent, math.max(val,0))
end

--- Sets Jump Power
-- @param number newjumppower New Jump Power.
function player_methods:setJumpPower(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.modifyMovementProperties")
	checkvalidnumber(val)
	Ply_SetJumpPower(ent, math.max(val,0))
end

--- Sets Step Size
-- @param number newstepsize New Step Size.
function player_methods:setStepSize(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.modifyMovementProperties")
	checkvalidnumber(val)
	Ply_SetStepSize(ent, math.max(val,0))
end

--- Sets Friction
-- @param number newfriction New Friction.
function player_methods:setFriction(val)
	local ent = getply(self)
	checkpermission(instance, ent, "player.modifyMovementProperties")
	checkvalidnumber(val)
	Ent_SetFriction(ent, math.Clamp(val/cvars.Number("sv_friction"),0,10))
end

--- Sets the player's weapon color
-- @param vector col The new color with values 0-1 in each vector component
function player_methods:setWeaponColor(col)
	local ent = getply(self)
	checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	checkvector(col)
	Ply_SetWeaponColor(ent, vunwrap1(col))
end

--- Kills the target.
--- Requires 'entities.setHealth' permission.
function player_methods:kill()
	local ent = getply(self)
	checkpermission(instance, ent, "entities.setHealth")
	if Ply_Alive(ent) then
		Ply_Kill(ent)
	end
end

--- Attempts to force the target into a vehicle.
--- Requires 'player.enterVehicle' permission on the player.
-- @param Vehicle vehicle
function player_methods:enterVehicle(vehicle)
	local ent = getply(self)
	checkpermission(instance, ent, "player.enterVehicle")
	Ply_EnterVehicle(ent, vhunwrap(vehicle))
end

--- sets ID of a given point to add PVS points
-- can only be used on either the chip's owner, or HUD connected players.
-- @param number ID ID to set position of, clamped between 1 and the PVS Points limit.
-- @param Vector? position position to set the override point to, nil to delete this point if it exists.
function player_methods:setPVSPoint( ID, position )
	checkluatype(ID, TYPE_NUMBER)
	ID = math.floor(math.Clamp(ID,1,PVSLimitCvar:GetInt()))
	if not (SF.IsHUDActive(instance.entity, getply(self) ) or getply(self) == instance.player) then 
		SF.Throw("setPVS can only be used on owner or HUD connected players!") 
	end
	if position ~= nil then position = vunwrap( position ) checkvector(position) end
	PlayerPVSManager:setPointToCountTable(instance, getply(self), ID, position)
end

--- Clears a given player's PVS override points set by this chip
function player_methods:clearPVSPoints()
	PlayerPVSManager:clearInstPlyTable( instance, getply(self) )
end

end
