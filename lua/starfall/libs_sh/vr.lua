
local checkluatype = SF.CheckLuaType

--- VRMod library https://steamcommunity.com/sharedfiles/filedetails/?id=2132574168
-- @name vr
-- @class library
-- @libtbl vr_library
SF.RegisterLibrary("vr")

return function(instance)

local vr_library = instance.Libraries.vr

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local plywrap, plyunwrap = instance.Types.Player.Wrap, instance.Types.Player.Unwrap

--- Checks wether the player is in VR
-- @class function
-- @param target player to check
-- @return boolean true if player is in VR
function vr_library.isPlayerInVR( ply )
	local ply = plyunwrap( ply )
	checkluatype(ply, TYPE_ENTITY) 
	return vrmod.IsPlayerInVR( ply )
end

--- Checks wether the player is using empty hands
-- @class function
-- @param target player to check
-- @return boolean true if player is using empty hands
function vr_library.usingEmptyHands( ply )
	local ply = plyunwrap( ply )
	checkluatype(ply, TYPE_ENTITY) 
	return vrmod.UsingEmptyHands( ply )
end

--HMD

--- returns the HMD position
-- @class function
-- @param target player to get the HMD position from
-- @return vector position
function vr_library.getHMDPos( ply )
	local ply = plyunwrap( ply )
	checkluatype(ply, TYPE_ENTITY) 
	return vwrap( vrmod.GetHMDPos( ply ) )
end

--- returns the HMD angles
-- @class function
-- @param target player to get the HMD angles from
-- @return angle angles
function vr_library.getHMDAng( ply )
	local ply = plyunwrap( ply )
	checkluatype(ply, TYPE_ENTITY) 
	return awrap( vrmod.GetHMDAng( ply ) )
end

--- returns the HMD pose
-- @class function
-- @param target player to get the HMD pose from
-- @return vector position, angle angles
function vr_library.getHMDPose( ply )
	local ply = plyunwrap( ply )
	checkluatype(ply, TYPE_ENTITY) 
	local pos, ang = vrmod.GetHMDPose( ply )
	return vwrap( pos ), awrap( ang )
end

--Left Hand

--- returns the left hand position
-- @class function
-- @param target player to get the left hand position from
-- @return vector position
function vr_library.getLeftHandPos( ply )
	local ply = plyunwrap( ply )
	checkluatype(ply, TYPE_ENTITY) 
	return vwrap( vrmod.GetLeftHandPos( ply ) )
end

--- returns the left hand angles
-- @class function
-- @param target player to get the left hand angles from
-- @return angle angles
function vr_library.getLeftHandAng( ply )
	local ply = plyunwrap( ply )
	checkluatype(ply, TYPE_ENTITY) 
	return awrap( vrmod.GetLeftHandAng( ply ) )
end

--- returns the left hand pose
-- @class function
-- @param target player to get the left hand pose from
-- @return vector position, angle angles
function vr_library.getLeftHandPose( ply )
	local ply = plyunwrap( ply )
	checkluatype(ply, TYPE_ENTITY) 
	local pos, ang = vrmod.GetLeftHandPose( ply )
	return vwrap( pos ), awrap( ang )
end

--Right Hand

--- returns the right hand position
-- @class function
-- @param target player to get the right hand position from
-- @return vector position
function vr_library.getRightHandPos( ply )
	local ply = plyunwrap( ply )
	checkluatype(ply, TYPE_ENTITY) 
	return vwrap( vrmod.GetRightHandPos( ply ) )
end

--- returns the left hand's angles
-- @class function
-- @param target player to get the right hand angles from
-- @return angle angles
function vr_library.getRightHandAng( ply )
	local ply = plyunwrap( ply )
	checkluatype(ply, TYPE_ENTITY) 
	return awrap( vrmod.GetRightHandAng( ply ) )
end

--- returns the left hand's pose
-- @class function
-- @param target player to get the right hand pose from
-- @return vector position, angle angles
function vr_library.getRightHandPose( ply )
	local ply = plyunwrap( ply )
	checkluatype(ply, TYPE_ENTITY) 
	local pos, ang = vrmod.GetRightHandPose( ply )
	return vwrap( pos ), awrap( ang )
end

if CLIENT then

local env = instance.env

--- VRmod library enums
-- @name vr_library.VR
-- @class table
-- @field GENERIC
-- @field ERROR
-- @field UNDO
-- @field HINT
-- @field CLEANUP
env.VR = {
	["BOOLEAN_PRIMARYFIRE"] = "boolean_primaryfire",
	["VECTOR1_PRIMARYFIRE"] = "vector1_primaryfire",
	["BOOLEAN_SECONDARYFIRE"] = "boolean_secondaryfire",
	["BOOLEAN_CHANGEWEAPON"] = "boolean_changeweapon",
	["BOOLEAN_USE"] = "boolean_use",
	["BOOLEAN_SPAWNMENU"] = "boolean_spawnmenu",
	["VECTOR2_WALKDIRECTION"] = "vector2_walkdirection",
	["BOOLEAN_WALK"] = "boolean_walk",
	["BOOLEAN_FLASHLIGHT"] = "boolean_flashlight",
	["BOOLEAN_TURNLEFT"] = "boolean_turnleft",
	["BOOLEAN_TURNRIGHT"] = "boolean_turnright",
	["VECTOR2_SMOOTHTURN"] = "vector2_smoothturn",
	["BOOLEAN_CHAT"] = "boolean_chat",
	["BOOLEAN_RELOAD"] = "boolean_reload",
	["BOOLEAN_JUMP"] = "boolean_jump",
	["BOOLEAN_LEFT_PICKUP"] = "boolean_left_pickup",
	["BOOLEAN_RIGHT_PICKUP"] = "boolean_right_pickup",
	["BOOLEAN_UNDO"] = "boolean_undo",
	["BOOLEAN_SPRINT"] = "boolean_sprint",
	["VECTOR1_FORWARD"] = "vector1_forward",
	["VECTOR1_REVERSE"] = "vector1_reverse",
	["BOOLEAN_TURBO"] = "boolean_turbo",
	["VECTOR2_STEER"] = "vector2_steer",
	["BOOLEAN_HANDBRAKE"] = "boolean_handbrake",
	["BOOLEAN_EXIT"] = "boolean_exit",
	["BOOLEAN_TURRET"] = "boolean_turret",
}

--- returns the left hand's pose
-- @class function
-- @param actionname to check control of, check VR enums
-- @return boolean, vector or table of input
function vr_library.getInput( actionname )
	checkluatype(actionname, TYPE_STRING) 
	local var = vrmod.GetInput( actionname )
	--PrintTable( var )
	if TypeID( var ) == TYPE_BOOL or TypeID( var ) == TYPE_NUMBER then
		return var
	elseif TypeID( var ) == TYPE_TABLE then
		return vwrap( Vector( var.x, var.y, 0 ) )
	end
	return var
end

end

end