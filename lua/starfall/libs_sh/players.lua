-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkvalidnumber = SF.CheckValidNumber
local registerprivilege = SF.Permissions.registerPrivilege
local ENT_META = FindMetaTable("Entity")
local PLY_META = FindMetaTable("Player")

local Ent_SetCycle = ENT_META.SetCycle

local playerMaxScale
if SERVER then
	-- Register privileges
	registerprivilege("player.dropweapon", "DropWeapon", "Drops a weapon from the player", { entities = {} })
	registerprivilege("player.setammo", "SetAmmo", "Whether a player can set their ammo", { usergroups = { default = 1 }, entities = {} })
	registerprivilege("player.enterVehicle", "EnterVehicle", "Whether a player can be forced into a vehicle", { usergroups = { default = 1 }, entities = {} })

	playerMaxScale = CreateConVar("sf_player_model_scale_max", "10", { FCVAR_ARCHIVE }, "Maximum player model scale the user is allowed to set using Player.setModelScale", 1, 100)
else
	registerprivilege("player.getFriendStatus", "FriendStatus", "Whether friend status can be retrieved", { client = { default = 1 } })
end
registerprivilege("player.setArmor", "SetArmor", "Allows changing a player's armor", { usergroups = { default = 1 }, entities = {} })
registerprivilege("player.setMaxArmor", "SetMaxArmor", "Allows changing a player's max armor", { usergroups = { default = 1 }, entities = {} })
registerprivilege("player.modifyMovementProperties", "ModifyMovementProperties", "Allows various changes to a player's movement", { usergroups = { default = 1 }, entities = {} })

-- Player animation
local playerAnimAdd
local playerAnimRemove
local playerAnimGet
if CLIENT then
	local playerAnimation

	playerAnimAdd = function(ply, anim)
		if next(playerAnimation) == nil then
			hook.Add("CalcMainActivity", "sf_player_animation", function(ply, vel)
				local anim = playerAnimation[ply]
				if not anim then return end

				if anim.auto then
					anim.progress = anim.progress + FrameTime() / anim.duration * anim.rate / anim.range

					local more = anim.progress > 1
					if more or anim.progress < 0 then
						if anim.loop then
							if anim.bounce then
								anim.rate = -anim.rate
								anim.progress = -anim.progress + (more and 2 or 0)
							else
								anim.progress = anim.progress % 1
							end
						else
							playerAnimRemove(ply)

							return
						end
					end
				end

				Ent_SetCycle(ply, anim.min + anim.progress * anim.range)

				local seq = anim.sequence
				return anim.activity or seq, seq
			end)
		end

		playerAnimation[ply] = anim

		return anim
	end

	playerAnimRemove = function(ply)
		playerAnimation[ply] = nil

		if next(playerAnimation) == nil then
			hook.Remove("CalcMainActivity", "sf_player_animation")
		end
	end

	playerAnimGet = function(ply)
		return playerAnimation[ply]
	end

	playerAnimation = SF.EntityTable("playerAnimation", playerAnimRemove)
end

--- Player type
-- @name Player
-- @class type
-- @libtbl player_methods
SF.RegisterType("Player", false, true, PLY_META, "Entity")


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_GetFriction,Ent_GetGroundEntity,Ent_GetMoveType,Ent_GetSequenceActivity,Ent_IsValid,Ent_LookupSequence,Ent_SequenceDuration,Ent_SetCycle,Ent_SetFriction,Ent_SetModelScale = ENT_META.GetFriction,ENT_META.GetGroundEntity,ENT_META.GetMoveType,ENT_META.GetSequenceActivity,ENT_META.IsValid,ENT_META.LookupSequence,ENT_META.SequenceDuration,ENT_META.SetCycle,ENT_META.SetFriction,ENT_META.SetModelScale
local Ply_Alive,Ply_AnimResetGestureSlot,Ply_AnimRestartGesture,Ply_AnimSetGestureWeight,Ply_Armor,Ply_Crouching,Ply_Deaths,Ply_DropNamedWeapon,Ply_DropWeapon,Ply_EnterVehicle,Ply_FlashlightIsOn,Ply_Frags,Ply_GetActiveWeapon,Ply_GetAimVector,Ply_GetAmmoCount,Ply_GetCrouchedWalkSpeed,Ply_GetDuckSpeed,Ply_GetEntityInUse,Ply_GetEyeTrace,Ply_GetFOV,Ply_GetFriendStatus,Ply_GetJumpPower,Ply_GetLadderClimbSpeed,Ply_GetMaxArmor,Ply_GetMaxSpeed,Ply_GetName,Ply_GetPlayerColor,Ply_GetRagdollEntity,Ply_GetRunSpeed,Ply_GetShootPos,Ply_GetSlowWalkSpeed,Ply_GetStepSize,Ply_GetTimeoutSeconds,Ply_GetUnDuckSpeed,Ply_GetUserGroup,Ply_GetVehicle,Ply_GetViewEntity,Ply_GetViewModel,Ply_GetViewPunchAngles,Ply_GetWalkSpeed,Ply_GetWeapon,Ply_GetWeaponColor,Ply_GetWeapons,Ply_HasGodMode,Ply_InVehicle,Ply_IsAdmin,Ply_IsBot,Ply_IsConnected,Ply_IsFrozen,Ply_IsMuted,Ply_IsSpeaking,Ply_IsSprinting,Ply_IsSuperAdmin,Ply_IsTimingOut,Ply_IsTyping,Ply_IsUserGroup,Ply_IsWalking,Ply_KeyDown,Ply_Kill,Ply_LastHitGroup,Ply_OwnerSteamID64,Ply_PacketLoss,Ply_Ping,Ply_Say,Ply_SetAmmo,Ply_SetArmor,Ply_SetCrouchedWalkSpeed,Ply_SetDuckSpeed,Ply_SetEyeAngles,Ply_SetJumpPower,Ply_SetLadderClimbSpeed,Ply_SetMaxArmor,Ply_SetMaxSpeed,Ply_SetRunSpeed,Ply_SetSlowWalkSpeed,Ply_SetStepSize,Ply_SetUnDuckSpeed,Ply_SetViewEntity,Ply_SetWalkSpeed,Ply_ShouldDrawLocalPlayer,Ply_SteamID,Ply_SteamID64,Ply_StripAmmo,Ply_StripWeapon,Ply_StripWeapons,Ply_Team,Ply_TimeConnected,Ply_UserID,Ply_VoiceVolume = PLY_META.Alive,PLY_META.AnimResetGestureSlot,PLY_META.AnimRestartGesture,PLY_META.AnimSetGestureWeight,PLY_META.Armor,PLY_META.Crouching,PLY_META.Deaths,PLY_META.DropNamedWeapon,PLY_META.DropWeapon,PLY_META.EnterVehicle,PLY_META.FlashlightIsOn,PLY_META.Frags,PLY_META.GetActiveWeapon,PLY_META.GetAimVector,PLY_META.GetAmmoCount,PLY_META.GetCrouchedWalkSpeed,PLY_META.GetDuckSpeed,PLY_META.GetEntityInUse,PLY_META.GetEyeTrace,PLY_META.GetFOV,PLY_META.GetFriendStatus,PLY_META.GetJumpPower,PLY_META.GetLadderClimbSpeed,PLY_META.GetMaxArmor,PLY_META.GetMaxSpeed,PLY_META.GetName,PLY_META.GetPlayerColor,PLY_META.GetRagdollEntity,PLY_META.GetRunSpeed,PLY_META.GetShootPos,PLY_META.GetSlowWalkSpeed,PLY_META.GetStepSize,PLY_META.GetTimeoutSeconds,PLY_META.GetUnDuckSpeed,PLY_META.GetUserGroup,PLY_META.GetVehicle,PLY_META.GetViewEntity,PLY_META.GetViewModel,PLY_META.GetViewPunchAngles,PLY_META.GetWalkSpeed,PLY_META.GetWeapon,PLY_META.GetWeaponColor,PLY_META.GetWeapons,PLY_META.HasGodMode,PLY_META.InVehicle,PLY_META.IsAdmin,PLY_META.IsBot,PLY_META.IsConnected,PLY_META.IsFrozen,PLY_META.IsMuted,PLY_META.IsSpeaking,PLY_META.IsSprinting,PLY_META.IsSuperAdmin,PLY_META.IsTimingOut,PLY_META.IsTyping,PLY_META.IsUserGroup,PLY_META.IsWalking,PLY_META.KeyDown,PLY_META.Kill,PLY_META.LastHitGroup,PLY_META.OwnerSteamID64,PLY_META.PacketLoss,PLY_META.Ping,PLY_META.Say,PLY_META.SetAmmo,PLY_META.SetArmor,PLY_META.SetCrouchedWalkSpeed,PLY_META.SetDuckSpeed,PLY_META.SetEyeAngles,PLY_META.SetJumpPower,PLY_META.SetLadderClimbSpeed,PLY_META.SetMaxArmor,PLY_META.SetMaxSpeed,PLY_META.SetRunSpeed,PLY_META.SetSlowWalkSpeed,PLY_META.SetStepSize,PLY_META.SetUnDuckSpeed,PLY_META.SetViewEntity,PLY_META.SetWalkSpeed,PLY_META.ShouldDrawLocalPlayer,PLY_META.SteamID,PLY_META.SteamID64,PLY_META.StripAmmo,PLY_META.StripWeapon,PLY_META.StripWeapons,PLY_META.Team,PLY_META.TimeConnected,PLY_META.UserID,PLY_META.VoiceVolume

local player_methods, player_meta, wrap, unwrap = instance.Types.Player.Methods, instance.Types.Player, instance.Types.Player.Wrap, instance.Types.Player.Unwrap
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local wep_meta, wwrap, wunwrap = instance.Types.Weapon, instance.Types.Weapon.Wrap, instance.Types.Weapon.Unwrap
local veh_meta, vhwrap, vhunwrap = instance.Types.Vehicle, instance.Types.Vehicle.Wrap, instance.Types.Vehicle.Unwrap

local getent
local vunwrap1, vunwrap2
local aunwrap1
instance:AddHook("initialize", function()
	getent = ent_meta.GetEntity
	player_meta.__tostring = ent_meta.__tostring
	vunwrap1, vunwrap2 = vec_meta.QuickUnwrap1, vec_meta.QuickUnwrap2
	aunwrap1 = ang_meta.QuickUnwrap1
end)

if SERVER then
	instance:AddHook("deinitialize", function()
		for k, ply in pairs(player.GetAll()) do
			if instance.data.viewEntityChanged then
				Ply_SetViewEntity(ply)
			end
		end
	end)
end

local function getply(self)
	local ent = player_meta.sf2sensitive[self]
	if Ent_IsValid(ent) then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end
player_meta.GetPlayer = getply

-- ------------------------------------------------------------------------- --
--- Returns whether the player is alive
-- @shared
-- @return boolean True if player alive
function player_methods:isAlive()
	return Ply_Alive(getply(self))
end

--- Returns the players armor
-- @shared
-- @return number Armor
function player_methods:getArmor()
	return Ply_Armor(getply(self))
end

--- Returns the players maximum armor capacity
-- @shared
-- @return number Armor limit
function player_methods:getMaxArmor()
	return Ply_GetMaxArmor(getply(self))
end

--- Returns the players Crouched Walk Speed
-- @shared
-- @return number Crouch Walk Speed value
function player_methods:getCrouchedWalkSpeed()
	return Ply_GetCrouchedWalkSpeed(getply(self))
end

--- Returns the players Duck Speed, a rate from 0-1 for how quickly they can crouch
-- @shared
-- @return number Duck Speed value
function player_methods:getDuckSpeed()
	return Ply_GetDuckSpeed(getply(self))
end

--- Returns the players UnDuck Speed, a rate from 0-1 for how quickly they can uncrouch
-- @shared
-- @return number UnDuck Speed value
function player_methods:getUnDuckSpeed()
	return Ply_GetUnDuckSpeed(getply(self))
end

--- Returns the players Ladder Climb Speed, probably unstable
-- @shared
-- @return number Ladder Climb Speed value
function player_methods:getLadderClimbSpeed()
	return Ply_GetLadderClimbSpeed(getply(self))
end

--- Returns the players Max Speed, probably unstable
-- @shared
-- @return number Max Speed value
function player_methods:getMaxSpeed()
	return Ply_GetMaxSpeed(getply(self))
end

--- Returns the players Run Speed, which is +speed
-- @shared
-- @return number Run Speed value
function player_methods:getRunSpeed()
	return Ply_GetRunSpeed(getply(self))
end

--- Returns the players Slow Walk Speed, which is +walk
-- @shared
-- @return number Slow Walk Speed value
function player_methods:getSlowWalkSpeed()
	return Ply_GetSlowWalkSpeed(getply(self))
end

--- Returns the players Walk Speed
-- @shared
-- @return number Walk Speed value
function player_methods:getWalkSpeed()
	return Ply_GetWalkSpeed(getply(self))
end

--- Returns the players Jump Power
-- @shared
-- @return number Jump Power value
function player_methods:getJumpPower()
	return Ply_GetJumpPower(getply(self))
end

--- Returns the players Friction
-- @shared
-- @return number Friction value
function player_methods:getFriction()
	return Ent_GetFriction(getply(self)) * cvars.Number("sv_friction")
end

--- Returns the players Step Size
-- @shared
-- @return number Step Size Value
function player_methods:getStepSize()
	return Ply_GetStepSize(getply(self))
end

--- Returns whether the player is crouching
-- @shared
-- @return boolean True if player crouching
function player_methods:isCrouching()
	return Ply_Crouching(getply(self))
end

--- Returns the amount of deaths of the player
-- @shared
-- @return number Amount of deaths
function player_methods:getDeaths()
	return Ply_Deaths(getply(self))
end

--- Returns whether the player's flashlight is on
-- @shared
-- @return boolean True if player has flashlight on
function player_methods:isFlashlightOn()
	return Ply_FlashlightIsOn(getply(self))
end

--- Returns true if the player is noclipped
-- @shared
-- @return boolean True if the player is noclipped
function player_methods:isNoclipped()
	return Ent_GetMoveType(getply(self)) == MOVETYPE_NOCLIP
end

--- Returns the amount of kills of the player
-- @shared
-- @return number Amount of kills
function player_methods:getFrags()
	return Ply_Frags(getply(self))
end

--- Returns the name of the player's active weapon
-- @shared
-- @return Weapon The weapon
function player_methods:getActiveWeapon()
	return wwrap(Ply_GetActiveWeapon(getply(self)))
end

--- Returns the player's aim vector
-- @shared
-- @return Vector Aim vector
function player_methods:getAimVector()
	return vwrap(Ply_GetAimVector(getply(self)))
end

--- Returns the player's field of view
-- @shared
-- @return number Field of view as a float
function player_methods:getFOV()
	return Ply_GetFOV(getply(self))
end

--- Returns the player's name
-- @shared
-- @return string Name
function player_methods:getName()
	return Ply_GetName(getply(self))
end

--- Returns the entity the player is currently using, like func_tank mounted turrets or +use prop pickups.
-- @shared
-- @return Entity Entity
function player_methods:getEntityInUse()
	return owrap(Ply_GetEntityInUse(getply(self)))
end

--- Returns the player's shoot position
-- @shared
-- @return Vector Shoot position
function player_methods:getShootPos()
	return vwrap(Ply_GetShootPos(getply(self)))
end

--- Returns whether the player is in a vehicle
-- @shared
-- @return boolean True if player in vehicle
function player_methods:inVehicle()
	return Ply_InVehicle(getply(self))
end

--- Returns the vehicle the player is driving
-- @shared
-- @return Vehicle Vehicle if player in vehicle or nil
function player_methods:getVehicle()
	return vhwrap(Ply_GetVehicle(getply(self)))
end

--- Returns whether the player is an admin
-- @shared
-- @return boolean True if player is admin
function player_methods:isAdmin()
	return Ply_IsAdmin(getply(self))
end

--- Returns whether the player is a bot
-- @shared
-- @return boolean True if player is a bot
function player_methods:isBot()
	return Ply_IsBot(getply(self))
end

--- Returns whether the player is frozen
-- @shared
-- @return boolean True if player is frozen
function player_methods:isFrozen()
	return Ply_IsFrozen(getply(self))
end

--- Returns whether the player is a super admin
-- @shared
-- @return boolean True if player is super admin
function player_methods:isSuperAdmin()
	return Ply_IsSuperAdmin(getply(self))
end

--- Returns whether the player belongs to a usergroup
-- @shared
-- @param string groupName Group to check against
-- @return boolean True if player belongs to group
function player_methods:isUserGroup(group)
	return Ply_IsUserGroup(getply(self), group)
end

--- Returns the usergroup of the player
-- @shared
-- @return string Usergroup, "user" if player has no group
function player_methods:getUserGroup()
	return Ply_GetUserGroup(getply(self))
end

--- Returns the player's current ping
-- @shared
-- @return number The player's ping
function player_methods:getPing()
	return Ply_Ping(getply(self))
end

--- Returns the player's SteamID
-- @shared
-- @return string SteamID
function player_methods:getSteamID()
	return Ply_SteamID(getply(self))
end

--- Returns the player's SteamID64 / Community ID
-- In singleplayer, this will return no value serverside.
-- For bots, this will return 90071996842377216 (equivalent to STEAM_0:0:0) for the first bot to join, and adds 1 to the id for the bot id.
-- Returns no value for bots clientside.
-- @shared
-- @param boolean? owner Return the actual game owner account id
-- @return string SteamID64 aka Community ID
function player_methods:getSteamID64(owner)
	if owner then
		return Ply_OwnerSteamID64(getply(self))
	else
		return Ply_SteamID64(getply(self))
	end
end

--- Returns the player's current team
-- @shared
-- @return number Team Index, from TEAM enums or custom teams
function player_methods:getTeam()
	return Ply_Team(getply(self))
end

--- Returns the name of the player's current team
-- @shared
-- @return string Team Name
function player_methods:getTeamName()
	return team.GetName(Ply_Team(getply(self)))
end

--- Returns the player's UserID
-- @shared
-- @return number UserID
function player_methods:getUserID()
	return Ply_UserID(getply(self))
end

--- Returns a table with information of what the player is looking at
-- @shared
-- @return table Trace data https://wiki.facepunch.com/gmod/Structures/TraceResult
function player_methods:getEyeTrace()
	return SF.StructWrapper(instance, Ply_GetEyeTrace(getply(self)), "TraceResult")
end

--- Returns the player's current view entity
-- @shared
-- @return Entity Player's current view entity
function player_methods:getViewEntity()
	return owrap(Ply_GetViewEntity(getply(self)))
end

--- Returns the player's view model
-- In the Client realm, other players' viewmodels are not available unless they are being spectated
-- @shared
-- @return Entity Player's view model
function player_methods:getViewModel()
	return owrap(Ply_GetViewModel(getply(self), 0))
end

--- Returns the camera punch offset angle
-- @return Angle The angle of the view offset
function player_methods:getViewPunchAngles()
	return awrap(Ply_GetViewPunchAngles(getply(self)))
end

--- Returns a table of weapons the player is carrying
-- @shared
-- @return table Table of weapons
function player_methods:getWeapons()
	return instance.Sanitize(Ply_GetWeapons(getply(self)))
end

--- Returns the specified weapon or nil if the player doesn't have it
-- @shared
-- @param string wep Weapon class name
-- @return Weapon Weapon
function player_methods:getWeapon(wep)
	checkluatype(wep, TYPE_STRING)
	return wwrap(Ply_GetWeapon(getply(self), wep))
end

--- Returns a player's weapon color
-- The part of the model that is colored is determined by the model itself, and is different for each model
-- The format is Vector(r,g,b), and each color should be between 0 and 1
-- @shared
-- @return Vector The color
function player_methods:getWeaponColor()
	return vwrap(Ply_GetWeaponColor(getply(self)))
end

--- Returns a player's color
-- The part of the model that is colored is determined by the model itself, and is different for each model
-- The format is Vector(r,g,b), and each color should be between 0 and 1
-- @shared
-- @return Vector The color
function player_methods:getPlayerColor()
	return vwrap(Ply_GetPlayerColor(getply(self)))
end

--- Returns the entity that the player is standing on
-- @shared
-- @return Entity Ground entity
function player_methods:getGroundEntity()
	return owrap(Ent_GetGroundEntity(getply(self)))
end

--- Gets the amount of ammo the player has.
-- @shared
-- @param string|number idOrName The string ammo name or number id of the ammo
-- @return number The amount of ammo player has in reserve.
function player_methods:getAmmoCount(id)
	if not isnumber(id) and not isstring(id) then SF.ThrowTypeError("number or string", SF.GetType(id), 2) end

	return Ply_GetAmmoCount(getply(self), id)
end

--- Returns whether the player is typing in their chat
-- @shared
-- @return boolean Whether they are typing in the chat
function player_methods:isTyping()
	return Ply_IsTyping(getply(self))
end

--- Returns whether the player is sprinting
-- @shared
-- @return boolean Whether they are sprinting
function player_methods:isSprinting()
	return Ply_IsSprinting(getply(self))
end

--- Returns whether the player is walking
-- In singleplayer, this will return false clientside
-- @shared
-- @return boolean Whether they are walking
function player_methods:isWalking()
	return Ply_IsWalking(getply(self))
end

--- Gets the player's death ragdoll
-- @return Entity? The entity or nil if it doesn't exist
function player_methods:getDeathRagdoll()
	return owrap(Ply_GetRagdollEntity(getply(self)))
end

if SERVER then
	--- Lets you change the size of yourself if the server has sf_permissions_entity_owneraccess 1
	-- @param number scale The scale to apply, will be truncated to the first two decimal places (min 0.01, max 100)
	-- @server
	function player_methods:setModelScale(scale)
		checkvalidnumber(scale)
		local ply = getply(self)
		checkpermission(instance, ply, "entities.setRenderProperty")
		Ent_SetModelScale(ply, math.Clamp(math.Truncate(scale, 2), 0.01, playerMaxScale:GetFloat()))
	end

	--- Checks if the player is connected to a HUD component that's linked to this chip
	-- @server
	-- @return boolean True if a HUD component is connected and active for the player, nil otherwise
	function player_methods:isHUDActive()
		return SF.IsHUDActive(instance.entity, getply(self))
	end

	--- Sets the view entity of the player. Only works if they are linked to a hud.
	-- @server
	-- @param Entity ent Entity to set the player's view entity to, or nothing to reset it
	function player_methods:setViewEntity(ent)
		local ply = getply(self)
		if ent~=nil then ent = getent(ent) end
		if not SF.IsHUDActive(instance.entity, ply) then SF.Throw("Player isn't connected to HUD!", 2) end
		instance.data.viewEntityChanged = ent ~= nil and ent ~= ply
		Ply_SetViewEntity(ply, ent)
	end

	--- Returns whether or not the player has godmode
	-- @server
	-- @return boolean True if the player has godmode
	function player_methods:hasGodMode()
		return Ply_HasGodMode(getply(self))
	end

	--- Drops the player's weapon
	-- @server
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
	-- @server
	-- @param string weapon The weapon class name of the weapon to strip
	function player_methods:stripWeapon(weapon)
		local ply = getply(self)
		checkpermission(instance, ply, "player.dropweapon")
		checkluatype(weapon, TYPE_STRING)
		Ply_StripWeapon(ply, weapon)
	end

	--- Strips all the player's weapons
	-- @server
	function player_methods:stripWeapons()
		local ply = getply(self)
		checkpermission(instance, ply, "player.dropweapon")
		Ply_StripWeapons(ply)
	end

	--- Sets the player's ammo
	-- @server
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
	-- @server
	function player_methods:stripAmmo()
		local ply = getply(self)
		checkpermission(instance, ply, "player.setammo")
		Ply_StripAmmo(ply)
	end

	--- Returns the hitgroup where the player was last hit.
	-- @server
	-- @return number Hitgroup, see https://wiki.facepunch.com/gmod/Enums/HITGROUP
	function player_methods:lastHitGroup()
		return Ply_LastHitGroup(getply(self))
	end

	--- Sets a player's eye angles
	-- @server
	-- @param Angle ang New angles
	function player_methods:setEyeAngles(ang)
		local ent = getent(self)
		checkpermission(instance, ent, "entities.setEyeAngles")
		Ply_SetEyeAngles(ent, aunwrap1(ang))
	end

	--- Returns the packet loss of the client
	-- @server
	-- @return number Packets lost
	function player_methods:getPacketLoss()
		return Ply_PacketLoss(getply(self))
	end

	--- Returns the time in seconds since the player connected
	-- @server
	-- @return number Time connected
	function player_methods:getTimeConnected()
		return Ply_TimeConnected(getply(self))
	end

	--- Returns the number of seconds that the player has been timing out for
	-- @server
	-- @return number Timeout seconds
	function player_methods:getTimeoutSeconds()
		return Ply_GetTimeoutSeconds(getply(self))
	end

	--- Returns true if the player is timing out
	-- @server
	-- @return boolean isTimingOut
	function player_methods:isTimingOut()
		return Ply_IsTimingOut(getply(self))
	end

	--- Returns whether the player is connected
	-- @server
	-- @return boolean True if player is connected
	function player_methods:isConnected()
		return Ply_IsConnected(getply(self))
	end

	--- Forces the player to say the first argument
	-- Only works on the chip's owner.
	-- @server
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
	-- @server
	-- @param number newarmor New armor value.
	function player_methods:setArmor(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.setArmor")
		checkvalidnumber(val)
		Ply_SetArmor(ent, val)
	end

	--- Sets the maximum armor for player. You can still set a player's armor above this amount with Player:setArmor.
	-- @server
	-- @param number newmaxarmor New max armor value.
	function player_methods:setMaxArmor(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.setMaxArmor")
		checkvalidnumber(val)
		Ply_SetMaxArmor(ent, val)
	end

	--- Sets Crouched Walk Speed
	-- @server
	-- @param number newcwalkspeed New Crouch Walk speed, This is a multiplier from 0 to 1.
	function player_methods:setCrouchedWalkSpeed(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.modifyMovementProperties")
		checkvalidnumber(val)
		Ply_SetCrouchedWalkSpeed(ent, math.Clamp(val,0,1))
	end

	--- Sets Duck Speed
	-- @server
	-- @param number newduckspeed New Duck speed, This is a multiplier from 0 to 1.
	function player_methods:setDuckSpeed(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.modifyMovementProperties")
		checkvalidnumber(val)
		Ply_SetDuckSpeed(ent, math.Clamp(val,0.005,0.995))
	end

	--- Sets UnDuck Speed
	-- @server
	-- @param number newunduckspeed New UnDuck speed, This is a multiplier from 0 to 1.
	function player_methods:setUnDuckSpeed(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.modifyMovementProperties")
		checkvalidnumber(val)
		Ply_SetUnDuckSpeed(ent, math.Clamp(val,0.005,0.995))
	end

	--- Sets Ladder Climb Speed, probably unstable
	-- @server
	-- @param number newladderclimbspeed New Ladder Climb speed.
	function player_methods:setLadderClimbSpeed(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.modifyMovementProperties")
		checkvalidnumber(val)
		Ply_SetLadderClimbSpeed(ent, math.max(val,0))
	end

	--- Sets Max Speed
	-- @server
	-- @param number newmaxspeed New Max speed.
	function player_methods:setMaxSpeed(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.modifyMovementProperties")
		checkvalidnumber(val)
		Ply_SetMaxSpeed(ent, math.max(val,0))
	end

	--- Sets Run Speed ( +speed )
	-- @server
	-- @param number newrunspeed New Run speed.
	function player_methods:setRunSpeed(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.modifyMovementProperties")
		checkvalidnumber(val)
		Ply_SetRunSpeed(ent, math.max(val,0))
	end

	--- Sets Slow Walk Speed ( +walk )
	-- @server
	-- @param number newslowwalkspeed New Slow Walk speed.
	function player_methods:setSlowWalkSpeed(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.modifyMovementProperties")
		checkvalidnumber(val)
		Ply_SetSlowWalkSpeed(ent, math.max(val,0))
	end

	--- Sets Walk Speed
	-- @server
	-- @param number newwalkspeed New Walk speed.
	function player_methods:setWalkSpeed(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.modifyMovementProperties")
		checkvalidnumber(val)
		Ply_SetWalkSpeed(ent, math.max(val,0))
	end

	--- Sets Jump Power
	-- @server
	-- @param number newjumppower New Jump Power.
	function player_methods:setJumpPower(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.modifyMovementProperties")
		checkvalidnumber(val)
		Ply_SetJumpPower(ent, math.max(val,0))
	end

	--- Sets Step Size
	-- @server
	-- @param number newstepsize New Step Size.
	function player_methods:setStepSize(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.modifyMovementProperties")
		checkvalidnumber(val)
		Ply_SetStepSize(ent, math.max(val,0))
	end

	--- Sets Friction
	-- @server
	-- @param number newfriction New Friction.
	function player_methods:setFriction(val)
		local ent = getply(self)
		checkpermission(instance, ent, "player.modifyMovementProperties")
		checkvalidnumber(val)
		Ent_SetFriction(ent, math.Clamp(val/cvars.Number("sv_friction"),0,10))
	end
	
	--- Kills the target.
	--- Requires 'entities.setHealth' permission.
	-- @server
	function player_methods:kill()
		local ent = getply(self)
		checkpermission(instance, ent, "entities.setHealth")
		if Ply_Alive(ent) then
			Ply_Kill(ent)
		end
	end
	
	--- Attempts to force the target into a vehicle.
	--- Requires 'player.enterVehicle' permission on the player.
	-- @server
	-- @param Vehicle vehicle
	function player_methods:enterVehicle(vehicle)
		local ent = getply(self)
		checkpermission(instance, ent, "player.enterVehicle")
		Ply_EnterVehicle(ent, vhunwrap(vehicle))
	end
end

--- Returns whether or not the player is pushing the key.
-- @shared
-- @param number key Key to check. IN_KEY table values
-- @return boolean Whether they key is down
function player_methods:keyDown(key)
	checkvalidnumber(key)
	return Ply_KeyDown(getply(self), key)
end

if CLIENT then
	--- Returns the relationship of the player to the local client
	-- @client
	-- @return string One of: "friend", "blocked", "none", "requested"
	function player_methods:getFriendStatus()
		checkpermission(instance, nil, "player.getFriendStatus")
		return Ply_GetFriendStatus(getply(self))
	end

	--- Returns whether the local player has muted the player
	-- @client
	-- @return boolean True if the player was muted
	function player_methods:isMuted()
		return Ply_IsMuted(getply(self))
	end

	--- Returns whether the player is heard by the local player.
	-- @client
	-- @return boolean Whether they are speaking and able to be heard by LocalPlayer
	function player_methods:isSpeaking()
		return Ply_IsSpeaking(getply(self))
	end

	--- Returns the voice volume of the player
	-- @client
	-- @return number Returns the players voice volume, how loud the player's voice communication currently is, as a normal number. Doesn't work on local player unless the voice_loopback convar is set to 1.
	function player_methods:voiceVolume()
		return Ply_VoiceVolume(getply(self))
	end

	--- Plays gesture animations on a player
	-- @client
	-- @param string|number animation Sequence string or act number. https://wiki.facepunch.com/gmod/Enums/ACT
	-- @param boolean? loop Optional boolean (Default true), should the gesture loop
	-- @param number? slot Optional int (Default GESTURE_SLOT.CUSTOM), the gesture slot to use. GESTURE_SLOT table values
	-- @param number? weight Optional float (Default 1), the weight of the gesture. Ranging from 0-1
	function player_methods:playGesture(animation, loop, slot, weight)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		if slot == nil then
			slot = GESTURE_SLOT_CUSTOM
		else
			checkvalidnumber(slot)
			if slot < 0 or slot > 6 then return end
		end

		if weight == nil then weight = 1 else checkvalidnumber(weight) end

		if isstring(animation) then
			animation = Ent_GetSequenceActivity(ply, Ent_LookupSequence(ply, animation))
		elseif not isnumber(animation) then
			SF.ThrowTypeError("number or string", SF.GetType(animation), 2)
		end

		Ply_AnimResetGestureSlot(ply, slot)
		Ply_AnimRestartGesture(ply, slot, animation, not loop)
		Ply_AnimSetGestureWeight(ply, slot, weight)
	end

	--- Resets gesture animations on a player
	-- @client
	-- @param number? slot Optional int (Default GESTURE_SLOT.CUSTOM), the gesture slot to use. GESTURE_SLOT table values
	function player_methods:resetGesture(slot)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		if slot == nil then slot = GESTURE_SLOT_CUSTOM else checkvalidnumber(slot) end

		Ply_AnimResetGestureSlot(ply, slot)
	end

	--- Sets the weight of the gesture animation in the given gesture slot
	-- @client
	-- @param number? slot Optional int (Default GESTURE_SLOT.CUSTOM), the gesture slot to use. GESTURE_SLOT table values
	-- @param number? weight Optional float (Default 1), the weight of the gesture. Ranging from 0-1
	function player_methods:setGestureWeight(slot, weight)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		if slot == nil then slot = GESTURE_SLOT_CUSTOM else checkvalidnumber(slot) end
		if weight == nil then weight = 1 else checkvalidnumber(weight) end

		Ply_AnimSetGestureWeight(ply, slot, weight)
	end

	--- Plays an animation on the player
	-- @client
	-- @param number|string sequence Sequence number or string name
	-- @param number? progress Optional float (Default 0), the progress of the animation. Ranging from 0-1
	-- @param number? rate Optional float (Default 1), the playback rate of the animation
	-- @param boolean? loop Optional boolean (Default false), should the animation loop
	-- @param boolean? auto_advance Optional boolean (Default true), should the animation handle advancing itself
	-- @param number|string|nil act Optional number or string name (Default sequence value), the activity the player should use
	function player_methods:setAnimation(seq, progress, rate, loop, auto_advance, act)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		if isstring(seq) then
			seq = Ent_LookupSequence(ply, seq)
		elseif not isnumber(seq) then
			SF.ThrowTypeError("number or string", SF.GetType(seq), 2)
		end

		if progress == nil then progress = 0 else checkvalidnumber(progress) end
		if rate == nil then rate = 1 else checkvalidnumber(rate) end
		if loop == nil then loop = false else checkluatype(loop, TYPE_BOOL) end
		if auto_advance == nil then auto_advance = true else checkluatype(auto_advance, TYPE_BOOL) end

		if act ~= nil then
			if isstring(act) then
				act = Ent_LookupSequence(ply, act)
			elseif not isnumber(act) then
				SF.ThrowTypeError("number, string or nil", SF.GetType(act), 2)
			end
		end

		Ent_SetCycle(ply, progress)

		local anim = playerAnimAdd(ply, {})
		anim.sequence = seq
		anim.activity = act
		anim.rate = rate
		anim.loop = loop
		anim.auto = auto_advance
		anim.bounce = false
		anim.min = 0
		anim.max = 1

		anim.range = 1
		anim.progress = progress
		anim.duration = Ent_SequenceDuration(ply, seq)
	end

	--- Resets the animation
	-- @client
	function player_methods:resetAnimation()
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		playerAnimRemove(ply)
	end

	--- Sets the animation activity
	-- @client
	-- @param number|string|nil activity Activity, nil to use the current animation sequence
	function player_methods:setAnimationActivity(act)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		local anim = playerAnimGet(ply)
		if not anim then SF.Throw("No animation is playing.", 2) end

		if isstring(act) then
			act = Ent_LookupSequence(ply, act)
		elseif act ~= nil and not isnumber(act) then
			SF.ThrowTypeError("number, string or nil", SF.GetType(act), 2)
		end

		anim.activity = act
	end

	--- Sets the animation progress
	-- @client
	-- @param number progress The progress of the animation. Ranging from 0-1
	function player_methods:setAnimationProgress(progress)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		local anim = playerAnimGet(ply)
		if not anim then SF.Throw("No animation is playing.", 2) end

		checkvalidnumber(progress)

		anim.progress = progress
	end

	--- Sets the animation time
	-- @client
	-- @param number time The time of the animation in seconds. Float
	function player_methods:setAnimationTime(time)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		local anim = playerAnimGet(ply)
		if not anim then SF.Throw("No animation is playing.", 2) end

		checkvalidnumber(time)

		anim.progress = (time / anim.duration - anim.min) * (1 / anim.range)
	end

	--- Sets the animation playback rate
	-- @client
	-- @param number rate The playback rate of the animation. Float
	function player_methods:setAnimationRate(rate)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		local anim = playerAnimGet(ply)
		if not anim then SF.Throw("No animation is playing.", 2) end

		checkvalidnumber(rate)

		anim.rate = rate
	end

	--- Sets the animation auto advance
	-- @client
	-- @param boolean auto_advance Should the animation handle advancing itself?
	function player_methods:setAnimationAutoAdvance(auto_advance)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		local anim = playerAnimGet(ply)
		if not anim then SF.Throw("No animation is playing.", 2) end

		checkluatype(auto_advance, TYPE_BOOL)

		anim.auto = auto_advance
	end

	--- Sets the animation bounce
	-- @client
	-- @param boolean bounce Should the animation bounce instead of loop?
	function player_methods:setAnimationBounce(bounce)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		local anim = playerAnimGet(ply)
		if not anim then SF.Throw("No animation is playing.", 2) end

		checkluatype(bounce, TYPE_BOOL)

		anim.bounce = bounce
	end

	--- Sets the animation loop
	-- @client
	-- @param boolean loop Should the animation loop?
	function player_methods:setAnimationLoop(loop)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		local anim = playerAnimGet(ply)
		if not anim then SF.Throw("No animation is playing.", 2) end

		checkluatype(loop, TYPE_BOOL)

		anim.loop = loop
	end

	--- Sets the animation range
	-- @client
	-- @param number min Min. Ranging from 0-1
	-- @param number max Max. Ranging from 0-1
	function player_methods:setAnimationRange(min, max)
		local ply = getply(self)
		if instance.owner ~= ply then checkpermission(instance, ply, "entities.setRenderProperty") end

		local anim = playerAnimGet(ply)
		if not anim then SF.Throw("No animation is playing.", 2) end

		checkvalidnumber(min)
		checkvalidnumber(max)

		anim.min = math.max(min, 0)
		anim.max = math.min(max, 1)
		anim.range = anim.max - anim.min
	end

	--- Gets whether a animation is playing
	-- @client
	-- @return boolean If an animation is playing
	function player_methods:isPlayingAnimation()
		local ply = getply(self)
		return playerAnimGet(ply) ~= nil
	end

	--- Gets the progress of the animation ranging 0-1
	-- @client
	-- @return number Progress ranging 0-1
	function player_methods:getAnimationProgress()
		local ply = getply(self)
		local anim = playerAnimGet(ply)

		if not anim then return 0 end
		return anim.progress
	end

	--- Gets the animation time
	-- @client
	-- @return number Time in seconds
	function player_methods:getAnimationTime()
		local ply = getply(self)
		local anim = playerAnimGet(ply)

		if not anim then return 0 end
		return (anim.progress * anim.range + anim.min) * anim.duration
	end

	--- Returns whether the player's player model will be drawn at the time the function is called.
	-- @client
	-- @return boolean True if the player's playermodel is visible
	function player_methods:shouldDrawLocalPlayer()
		return Ply_ShouldDrawLocalPlayer(getply(self))
	end
end

end
