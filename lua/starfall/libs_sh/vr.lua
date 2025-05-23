
local checkluatype = SF.CheckLuaType
local haspermission = SF.Permissions.hasAccess

--- VRMod Library
-- Addon and module: https://steamcommunity.com/sharedfiles/filedetails/?id=1678408548
-- Follow install instructions on the addon's page.
-- @name vr
-- @class library
-- @libtbl vr_library
SF.RegisterLibrary("vr")

--- Called when a player enters VR
-- @name VRStart
-- @class hook
-- @param Player ply Player entering VR
SF.hookAdd("VRMod_Start", "vrstart")

--- Called when a player exits VR
-- @name VRExit
-- @class hook
-- @param Player ply Player exiting VR
SF.hookAdd("VRMod_Exit", "vrexit")

if CLIENT then
	--- This gets called every time a boolean controller input action changes state
	-- @name VRInput
	-- @class hook
	-- @param string actionname Name of the input
	-- @param boolean state State of the input
	-- @client
	SF.hookAdd("VRMod_Input", "vrinput")

	local function hudPrepareSafeArgs(instance, ...)
		if haspermission(instance, nil, "render.hud") or instance.player == SF.Superuser then
			instance:prepareRender()
			return true, {...}
		end
		return false
	end
	local function cleanupRender(instance)
		instance:cleanupRender()
	end

	--- Called before rendering the game. Any code that you want to run once per frame should be put here. HUD is required.
	-- @name VRPreRender
	-- @class hook
	-- @client
	SF.hookAdd("VRMod_PreRender", "vrprerenderleft", hudPrepareSafeArgs, cleanupRender)

	--- Called before rendering the right eye. This along with the previous hook can be used to render different things in different eyes. HUD is required.
	-- @name VRPreRenderRight
	-- @class hook
	-- @client
	SF.hookAdd("VRMod_PreRenderRight", "vrprerenderright", hudPrepareSafeArgs, cleanupRender)
end

return function(instance)

if not vrmod then return end --only add these functions if vrmod is installed

local vr_library = instance.Libraries.vr

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local plywrap = instance.Types.Player.Wrap

local getply
instance:AddHook("initialize", function()
	getply = instance.Types.Player.GetPlayer
end)

--- Checks whether the player is in VR
-- @param Player target Player to check
-- @return boolean True if player is in VR
function vr_library.isPlayerInVR(ply)
	return vrmod.IsPlayerInVR(getply(ply))
end

--- Checks whether the player is using empty hands
-- @param Player target Player to check
-- @return boolean True if player is using empty hands
function vr_library.usingEmptyHands(ply)
	return vrmod.UsingEmptyHands(getply(ply))
end

--HMD

--- Returns the Head Mounted Device position
-- @param Player target Player to get the HMD position from
-- @return Vector HMD Position
function vr_library.getHMDPos(ply)
	return vwrap(vrmod.GetHMDPos(getply(ply)))
end

--- Returns the Head Mounted Device angles
-- @param Player target Player to get the HMD angles from
-- @return Angle HMD Angles
function vr_library.getHMDAng(ply)
	return awrap(vrmod.GetHMDAng(getply(ply)))
end

--- Returns the HMD pose
-- @param Player target Player to get the HMD pose from
-- @return Vector HMD Position
-- @return Angle HMD Angles
function vr_library.getHMDPose(ply)
	local pos, ang = vrmod.GetHMDPose(getply(ply))
	return vwrap(pos), awrap(ang)
end

--Left Hand

--- Returns the left hand position
-- @param Player target Player to get the left hand position from
-- @return Vector Position
function vr_library.getLeftHandPos(ply)
	return vwrap(vrmod.GetLeftHandPos(getply(ply)))
end

--- Returns the left hand angles
-- @param Player target Player to get the left hand angles from
-- @return Angle Angles
function vr_library.getLeftHandAng(ply)
	return awrap(vrmod.GetLeftHandAng(getply(ply)))
end

--- Returns the left hand pose
-- @param Player target Player to get the left hand pose from
-- @return Vector Position
-- @return Angle Angles
function vr_library.getLeftHandPose(ply)
	local pos, ang = vrmod.GetLeftHandPose(getply(ply))
	return vwrap(pos), awrap(ang)
end

--Right Hand

--- Returns the right hand position
-- @param Player target Player to get the right hand position from
-- @return Vector Position
function vr_library.getRightHandPos(ply)
	return vwrap(vrmod.GetRightHandPos(getply(ply)))
end

--- Returns the left hand angles
-- @param Player target Player to get the right hand angles from
-- @return Angle Angles
function vr_library.getRightHandAng(ply)
	return awrap(vrmod.GetRightHandAng(getply(ply)))
end

--- Returns the left hand pose
-- @param Player target Player to get the right hand pose from
-- @return Vector Position
-- @return Angle Angles
function vr_library.getRightHandPose(ply)
	local pos, ang = vrmod.GetRightHandPose(getply(ply))
	return vwrap(pos), awrap(ang)
end

if CLIENT then

	--- Returns the a controller's input state, may return boolean, number or vector.
	-- @param string actionname ActionName to check control of, see the VR enums
	-- @return boolean|Vector|number Boolean, Vector or Number of input
	-- @client
	function vr_library.getInput(actionname)
		checkluatype(actionname, TYPE_STRING)
		local var = vrmod.GetInput(actionname)
		local typeid = TypeID(var)
		if typeid == TYPE_BOOL or typeid == TYPE_NUMBER then
			return var
		elseif typeid == TYPE_TABLE then
			return vwrap(Vector(var.x, var.y or 0, 0))
		end
		return var
	end


	-- HMD

	--- Returns the HMD velocity
	-- @return Vector HMD Velocity
	-- @client
	function vr_library.getHMDVelocity()
		return vwrap(vrmod.GetHMDVelocity())
	end

	--- Returns the HMD angular velocity
	-- @return Vector Angular velocity
	-- @client
	function vr_library.getHMDAngularVelocity()
		return vwrap(vrmod.GetHMDVelocity())
	end

	--- Returns the HMD velocities, position and angular
	-- @return Vector Velocity
	-- @return Vector Angular velocity
	-- @client
	function vr_library.getHMDVelocities()
		local v1, v2 = vrmod.GetHMDVelocities()
		return vwrap(v1), vwrap(v2)
	end

	--Left hand

	--- Returns the left hand velocity
	-- @return Vector Velocity
	-- @client
	function vr_library.getLeftHandVelocity()
		return vwrap(vrmod.GetLeftHandVelocity())
	end

	--- Returns the left hand angular velocity
	-- @return Vector Angular velocity
	-- @client
	function vr_library.getLeftHandAngularVelocity()
		return vwrap(vrmod.GetLeftHandAngularVelocity())
	end

	--- Returns the left hand velocities, position and angular
	-- @return Vector Velocity
	-- @return Vector Angular velocity
	-- @client
	function vr_library.getLeftHandVelocities()
		local v1, v2 = vrmod.GetLeftHandVelocities()
		return vwrap(v1), vwrap(v2)
	end

	--Right hand

	--- Returns the right hand velocity
	-- @return Vector Velocity
	-- @client
	function vr_library.getRightHandVelocity()
		return vwrap(vrmod.GetRightHandVelocity())
	end

	--- Returns the right hand angular velocity
	-- @return Vector Angular velocity
	-- @client
	function vr_library.getRightHandAngularVelocity()
		return vwrap(vrmod.GetRightHandAngularVelocity())
	end

	--- Returns the right hand velocities, position and angular
	-- @return Vector Velocity
	-- @return Vector Angular velocity
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

	--- Returns the playspace position
	-- @return Vector Position
	-- @client
	function vr_library.getOriginPos()
		return vwrap(vrmod.GetOriginPos())
	end

	--- Returns the playspace angles
	-- @return Angle Angles
	-- @client
	function vr_library.getOriginAng()
		return awrap(vrmod.GetOriginAng())
	end

	--- Returns the playspace position and angles
	-- @return Vector Position
	-- @return Angle Angles
	-- @client
	function vr_library.getOrigin()
		local pos, ang = vrmod.GetOrigin()
		return vwrap(pos), awrap(ang)
	end

	--eyes GetEyePos

	--- Returns position of the eye that is currently being used for rendering.
	-- @return Vector Position
	-- @client
	function vr_library.getEyePos()
		return vwrap(vrmod.GetEyePos())
	end

	--- Returns position of the left eye
	-- @return Vector Position
	-- @client
	function vr_library.getLeftEyePos()
		return vwrap(vrmod.GetLeftEyePos())
	end

	--- Returns position of the right eye
	-- @return Vector Position
	-- @client
	function vr_library.getRightEyePos()
		return vwrap(vrmod.GetRightEyePos())
	end
end

end
