
local checkluatype = SF.CheckLuaType

--- VRMod library https://steamcommunity.com/sharedfiles/filedetails/?id=2132574168
-- @name vr
-- @class library
-- @libtbl vr_library
SF.RegisterLibrary("vr")

return function(instance)

if vrmod then --only add these functions if vrmod is installed

local vr_library = instance.Libraries.vr

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local plywrap, plyunwrap = instance.Types.Player.Wrap, instance.Types.Player.Unwrap

--- Called when a player enters VR
-- @name VRStart
-- @class hook
-- @param ply Player entering VR
SF.hookAdd("VRMod_Start", "vrstart")

--- Called when a player exits VR
-- @name VRExit
-- @class hook
-- @param ply Player exiting VR
SF.hookAdd("VRMod_Exit", "vrexit")


--- Checks wether the player is in VR
-- @class function
-- @param target player to check
-- @return boolean true if player is in VR
function vr_library.isPlayerInVR(ply)
	local ply = plyunwrap(ply)
	checkluatype(ply, TYPE_ENTITY) 
	return vrmod.IsPlayerInVR(ply)
end

--- Checks wether the player is using empty hands
-- @class function
-- @param target player to check
-- @return boolean true if player is using empty hands
function vr_library.usingEmptyHands(ply)
	local ply = plyunwrap(ply)
	checkluatype(ply, TYPE_ENTITY) 
	return vrmod.UsingEmptyHands(ply)
end

--HMD

--- returns the HMD position
-- @class function
-- @param target player to get the HMD position from
-- @return vector position
function vr_library.getHMDPos(ply)
	local ply = plyunwrap(ply)
	checkluatype(ply, TYPE_ENTITY) 
	return vwrap(vrmod.GetHMDPos(ply))
end

--- returns the HMD angles
-- @class function
-- @param target player to get the HMD angles from
-- @return angle angles
function vr_library.getHMDAng(ply)
	local ply = plyunwrap(ply)
	checkluatype(ply, TYPE_ENTITY) 
	return awrap(vrmod.GetHMDAng(ply))
end

--- returns the HMD pose
-- @class function
-- @param target player to get the HMD pose from
-- @return vector position, angle angles
function vr_library.getHMDPose(ply)
	local ply = plyunwrap(ply)
	checkluatype(ply, TYPE_ENTITY) 
	local pos, ang = vrmod.GetHMDPose(ply)
	return vwrap(pos), awrap(ang)
end

--Left Hand

--- returns the left hand position
-- @class function
-- @param target player to get the left hand position from
-- @return vector position
function vr_library.getLeftHandPos(ply)
	local ply = plyunwrap(ply)
	checkluatype(ply, TYPE_ENTITY) 
	return vwrap(vrmod.GetLeftHandPos(ply))
end

--- returns the left hand angles
-- @class function
-- @param target player to get the left hand angles from
-- @return angle angles
function vr_library.getLeftHandAng(ply)
	local ply = plyunwrap(ply)
	checkluatype(ply, TYPE_ENTITY) 
	return awrap(vrmod.GetLeftHandAng(ply))
end

--- returns the left hand pose
-- @class function
-- @param target player to get the left hand pose from
-- @return vector position, angle angles
function vr_library.getLeftHandPose(ply)
	local ply = plyunwrap(ply)
	checkluatype(ply, TYPE_ENTITY) 
	local pos, ang = vrmod.GetLeftHandPose(ply)
	return vwrap(pos), awrap(ang)
end

--Right Hand

--- returns the right hand position
-- @class function
-- @param target player to get the right hand position from
-- @return vector position
function vr_library.getRightHandPos(ply)
	local ply = plyunwrap(ply)
	checkluatype(ply, TYPE_ENTITY) 
	return vwrap(vrmod.GetRightHandPos(ply))
end

--- returns the left hand angles
-- @class function
-- @param target player to get the right hand angles from
-- @return angle angles
function vr_library.getRightHandAng(ply)
	local ply = plyunwrap(ply)
	checkluatype(ply, TYPE_ENTITY) 
	return awrap(vrmod.GetRightHandAng(ply))
end

--- returns the left hand pose
-- @class function
-- @param target player to get the right hand pose from
-- @return vector position, angle angles
function vr_library.getRightHandPose(ply)
	local ply = plyunwrap(ply)
	checkluatype(ply, TYPE_ENTITY) 
	local pos, ang = vrmod.GetRightHandPose(ply)
	return vwrap(pos), awrap(ang)
end

if CLIENT then

local env = instance.env

--- VRmod library enums
-- @name vr_library.VR
-- @class table
-- @client
-- @field BOOLEAN_PRIMARYFIRE
-- @field VECTOR1_PRIMARYFIRE
-- @field BOOLEAN_SECONDARYFIRE
-- @field BOOLEAN_CHANGEWEAPON
-- @field BOOLEAN_USE
-- @field BOOLEAN_SPAWNMENU
-- @field VECTOR2_WALKDIRECTION
-- @field BOOLEAN_WALK
-- @field BOOLEAN_FLASHLIGHT
-- @field BOOLEAN_TURNLEFT
-- @field BOOLEAN_TURNRIGHT
-- @field VECTOR2_SMOOTHTURN
-- @field BOOLEAN_CHAT
-- @field BOOLEAN_RELOAD
-- @field BOOLEAN_JUMP
-- @field BOOLEAN_LEFT_PICKUP
-- @field BOOLEAN_RIGHT_PICKUP
-- @field BOOLEAN_UNDO
-- @field BOOLEAN_SPRINT
-- @field VECTOR1_FORWARD
-- @field VECTOR1_REVERSE
-- @field BOOLEAN_TURBO
-- @field VECTOR2_STEER
-- @field BOOLEAN_HANDBRAKE
-- @field BOOLEAN_EXIT
-- @field BOOLEAN_TURRET

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

--- returns the a controller's input state, may return boolean, number or vector.
-- @class function
-- @param actionname to check control of, check VR enums
-- @return boolean, vector or number of input
-- @client
function vr_library.getInput(actionname)
	checkluatype(actionname, TYPE_STRING) 
	local var = vrmod.GetInput(actionname)
	if TypeID(var) == TYPE_BOOL or TypeID(var) == TYPE_NUMBER then
		return var
	elseif TypeID(var) == TYPE_TABLE then
		return vwrap(Vector(var.x, var.y or 0, 0))
	end
	return var
end


-- HMD

--- returns the HMD velocity
-- @class function
-- @return vector velocity
-- @client
function vr_library.getHMDVelocity()
	return vwrap(vrmod.GetHMDVelocity())
end

--- returns the HMD angular velocity
-- @class function
-- @return vector angular velocity
-- @client
function vr_library.getHMDAngularVelocity()
	return vwrap(vrmod.GetHMDVelocity())
end

--- returns the HMD velocities, position and angular
-- @class function
-- @return vector velocity, vector angular velocity
-- @client
function vr_library.getHMDVelocities()
	local v1, v2 = vrmod.GetHMDVelocities()
	return vwrap(v1), vwrap(v2)
end

--Left hand

--- returns the left hand velocity
-- @class function
-- @return vector velocity
-- @client
function vr_library.getLeftHandVelocity()
	return vwrap(vrmod.GetLeftHandVelocity())
end

--- returns the left hand angular velocity
-- @class function
-- @return vector angular velocity
-- @client
function vr_library.getLeftHandAngularVelocity()
	return vwrap(vrmod.GetLeftHandAngularVelocity())
end

--- returns the left hand velocities, position and angular
-- @class function
-- @return vector velocity, vector angular velocity
-- @client
function vr_library.getLeftHandVelocities()
	local v1, v2 = vrmod.GetLeftHandVelocities()
	return vwrap(v1), vwrap(v2)
end

--Right hand

--- returns the right hand velocity
-- @class function
-- @return vector velocity
-- @client
function vr_library.getRightHandVelocity()
	return vwrap(vrmod.GetRightHandVelocity())
end

--- returns the right hand angular velocity
-- @class function
-- @return vector angular velocity
-- @client
function vr_library.getRightHandAngularVelocity()
	return vwrap(vrmod.GetRightHandAngularVelocity())
end

--- returns the right hand velocities, position and angular
-- @class function
-- @return vector velocity, vector angular velocity
-- @client
function vr_library.getRightHandVelocities()
	local v1, v2 = vrmod.GetRightHandVelocities()
	return vwrap(v1), vwrap(v2)
end

--TODO: Add
--vrmod.SetLeftHandPose(vector pos, angle ang)
--vrmod.SetRightHandPose(vector pos, angle ang)
--only usable in VR Prerender hook AND SF Hud

--Add those finger functions...

--Playspace

--- returns the playspace position
-- @class function
-- @return vector position
-- @client
function vr_library.getOriginPos()
	return vwrap(vrmod.GetOriginPos())
end

--- returns the playspace angles
-- @class function
-- @return angle angles
-- @client
function vr_library.getOriginAng()
	return awrap(vrmod.GetOriginAng())
end

--- returns the playspace position and angles
-- @class function
-- @return vector position, angle angles
-- @client
function vr_library.getOrigin()
	local pos, ang = vrmod.GetOrigin()
	return vwrap(pos), awrap(ang)
end

--eyes GetEyePos

--- returns position of the eye that is currently being used for rendering.
-- @class function
-- @return vector position
-- @client
function vr_library.getEyePos()
	return vwrap(vrmod.GetEyePos())
end

--- returns position of the left eye
-- @class function
-- @return vector position
-- @client
function vr_library.getLeftEyePos()
	return vwrap(vrmod.GetLeftEyePos())
end

--- returns position of the right eye
-- @class function
-- @return vector position
-- @client
function vr_library.getRightEyePos()
	return vwrap(vrmod.GetRightEyePos())
end

local function canRenderHudSafeArgs(instance, ...)
	return instance:isHUDActive() and (instance.player == SF.Superuser or haspermission(instance, nil, "render.hud")), {...}
end

--- This gets called every time a boolean controller input action changes state
-- @name VRInput
-- @class hook
-- @param actionname Name of the input
-- @param boolean State of the input
-- @client
SF.hookAdd("VRMod_Input", "vrinput")

--- Called before rendering the game. Any code that you want to run once per frame should be put here. HUD is required.
-- @name VRPreRender
-- @class hook
-- @client
SF.hookAdd("VRMod_PreRender", "vrprerender", canRenderHudSafeArgs)

--- Called before rendering the right eye. This along with the previous hook can be used to render different things in different eyes. HUD is required.
-- @name VRPreRenderRight
-- @class hook
-- @client
SF.hookAdd("VRMod_PreRenderRight", "vrprerenderright", canRenderHudSafeArgs)

--- Called after rendering the game. HUD is required.
-- @name VRPostRender
-- @class hook
-- @client
SF.hookAdd("VRMod_PostRender", "vrpostrender", canRenderHudSafeArgs)


end

end

end