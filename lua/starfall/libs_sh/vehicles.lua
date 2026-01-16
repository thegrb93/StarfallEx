-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local ENT_META,PLY_META,VEH_META = FindMetaTable("Entity"),FindMetaTable("Player"),FindMetaTable("Vehicle")


local UseEnableVehicles

registerprivilege("vehicle.thirdPerson", "Vehicle thirdPerson", "Forces the vehicle camera", { entities = {} })

if SERVER then
	-- Register privileges
	registerprivilege("vehicle.eject", "Vehicle eject", "Removes a driver from vehicle", { entities = {} })
	registerprivilege("vehicle.kill", "Vehicle kill", "Kills a driver in vehicle", { entities = {} })
	registerprivilege("vehicle.strip", "Vehicle strip", "Strips weapons from a driver in vehicle", { entities = {} })
	registerprivilege("vehicle.lock", "Vehicle lock", "Allow vehicle locking/unlocking", { entities = {} })
	registerprivilege("vehicle.use", "Vehicle use", "Allow passengers in a vehicle to use while sitting", { entities = {} })

	local sf_max_driveruse_dist = CreateConVar("sf_vehicle_use_distance", 100, FCVAR_ARCHIVE, "The max reach distance allowed for player use with Vehicle:useEnable function.")

	local Ent_IsValid = ENT_META.IsValid
	local Ply_GetVehicle,Ply_GetEyeTrace = PLY_META.GetVehicle,PLY_META.GetEyeTrace

	UseEnableVehicles = {
		setEnabled = function(self, vehicle, enabled, key)
			if enabled then
				self:addhooks()
				self.vehicles[vehicle] = key
			else
				self.vehicles[vehicle] = nil
				self:removehooks()
			end
		end,
		use = function(self, ply, veh)
			local tr = Ply_GetEyeTrace(ply)
			local ent = tr.Entity
			if Ent_IsValid(ent) and tr.HitPos:DistToSqr(tr.StartPos) <= sf_max_driveruse_dist:GetFloat()^2 and not ent:IsVehicle() and ent.Use and hook.Run("PlayerUse", ply, ent) ~= false then
				ent:Use(ply, veh, USE_ON, 0)
			end
		end,
		addhooks = function(self)
			if table.IsEmpty(self.vehicles) then
				hook.Add("KeyPress","SF_VehicleButtons",function(ply, key)
					local veh = Ply_GetVehicle(ply)
					if key==self.vehicles[veh] then
						self:use(ply, veh)
					end
				end)
			end
		end,
		removehooks = function(self)
			if table.IsEmpty(self.vehicles) then
				hook.Remove("KeyPress","SF_VehicleButtons")
			end
		end,
		vehicles = SF.EntityTable("UseEnableVehicles", function() UseEnableVehicles:removehooks() end)
	}
end

--- Vehicle type
-- @name Vehicle
-- @class type
-- @libtbl vehicle_methods
-- @libtbl vehicle_meta
SF.RegisterType("Vehicle", false, true, VEH_META, "Entity")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_Fire,Ent_IsValid = ENT_META.Fire,ENT_META.IsValid
local Ply_ExitVehicle,Ply_Kill,Ply_StripWeapon,Ply_StripWeapons = PLY_META.ExitVehicle,PLY_META.Kill,PLY_META.StripWeapon,PLY_META.StripWeapons
local Veh_CheckExitPoint,Veh_GetCameraDistance,Veh_GetDriver,Veh_GetHLSpeed,Veh_GetPassenger,Veh_GetSpeed,Veh_GetThirdPersonMode,Veh_GetVehicleViewPosition,Veh_SetCameraDistance,Veh_SetThirdPersonMode,Veh_SetVehicleEntryAnim = VEH_META.CheckExitPoint,VEH_META.GetCameraDistance,VEH_META.GetDriver,VEH_META.GetHLSpeed,VEH_META.GetPassenger,VEH_META.GetSpeed,VEH_META.GetThirdPersonMode,VEH_META.GetVehicleViewPosition,VEH_META.SetCameraDistance,VEH_META.SetThirdPersonMode,VEH_META.SetVehicleEntryAnim

local vehicle_methods, vehicle_meta, wrap, unwrap = instance.Types.Vehicle.Methods, instance.Types.Vehicle, instance.Types.Vehicle.Wrap, instance.Types.Vehicle.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap = instance.Types.Vector, instance.Types.Vector.Wrap
local ang_meta, awrap = instance.Types.Angle, instance.Types.Angle.Wrap
local pwrap = instance.Types.Player.Wrap


instance:AddHook("initialize", function()
	vehicle_meta.__tostring = ent_meta.__tostring
end)

local function getveh(self)
	local ent = vehicle_meta.sf2sensitive[self]
	if Ent_IsValid(ent) then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end

--- Returns the driver of the vehicle
-- @return Player Driver of vehicle
function vehicle_methods:getDriver()
	return pwrap(Veh_GetDriver(getveh(self)))
end

--- Returns a passenger of a vehicle
-- @param number n The index of the passenger to get
-- @return Player The passenger or NULL if empty
function vehicle_methods:getPassenger(n)
	checkluatype(n, TYPE_NUMBER)
	return pwrap(Veh_GetPassenger(getveh(self), n))
end


--- Forces the vehicles camera into third person or first person
-- @param boolean thirdPerson
function vehicle_methods:setThirdPersonMode(enabled)
	local veh = getveh(self)

	checkluatype(enabled, TYPE_BOOL)
	checkpermission(instance, veh, "vehicle.thirdPerson")

	Veh_SetThirdPersonMode(veh, enabled)
end

--- Gets if third person mode is enabled or disabled
-- @return boolean true if third person mode is enabled, false if not
function vehicle_methods:getThirdPersonMode()
	return Veh_GetThirdPersonMode(getveh(self))
end

--- Sets the third person camera distance
-- @param number distance
function vehicle_methods:setCameraDistance(dist)
	local veh = getveh(self)

	checkluatype(dist, TYPE_NUMBER)
	checkpermission(instance, veh, "vehicle.thirdPerson")

	Veh_SetCameraDistance(veh, dist)
end

--- Returns the camera distance
-- @return number distance
function vehicle_methods:getCameraDistance()
	return Veh_GetCameraDistance(getveh(self))
end

--- Returns the view position and angle of the passenger
-- @param number? role 0 is the driver.
-- @return Vector The view position
-- @return Angle The view angles
-- @return number The passengers FOV
function vehicle_methods:getVehicleViewPosition(role)
	if role then
		checkluatype(role, TYPE_NUMBER)
	end

	local pos, ang, fov = Veh_GetVehicleViewPosition(getveh(self), role)

	return vwrap(pos), awrap(ang), fov
end


if SERVER then
	--- Ejects the driver of the vehicle
	-- @server
	function vehicle_methods:ejectDriver()
		local veh = getveh(self)
		local driver = veh:GetDriver()
		checkpermission(instance, veh, "vehicle.eject")

		if Ent_IsValid(driver) then
			Ply_ExitVehicle(driver)
		end
	end

	--- Kills the driver of the vehicle
	-- @server
	function vehicle_methods:killDriver()
		local ent = getveh(self)
		checkpermission(instance, ent, "vehicle.kill")
		local driver = Veh_GetDriver(ent)
		if Ent_IsValid(driver) then
			Ply_Kill(driver)
		end
	end

	--- Strips weapons of the driver
	-- @param string? class Optional weapon class to strip. Otherwise all are stripped.
	-- @server
	function vehicle_methods:stripDriver(class)
		if class ~= nil then checkluatype(class, TYPE_STRING) end
		local ent = getveh(self)
		checkpermission(instance, ent, "vehicle.strip")
		local driver = Veh_GetDriver(ent)
		if Ent_IsValid(driver) then
			if class then
				Ply_StripWeapon(driver, class)
			else
				Ply_StripWeapons(driver)
			end
		end
	end

	--- Will lock the vehicle preventing players from entering or exiting the vehicle.
	-- @server
	function vehicle_methods:lock()
		local ent = getveh(self)
		checkpermission(instance, ent, "vehicle.lock")
		local n = "SF_CanExitVehicle"..ent:EntIndex()
		hook.Add("CanExitVehicle", n, function(v) if v==ent then return false end end)
		SF.CallOnRemove(ent, n, function() hook.Remove("CanExitVehicle", n) end)
		Ent_Fire(ent, "Lock")
	end

	--- Will unlock the vehicle.
	-- @server
	function vehicle_methods:unlock()
		local ent = getveh(self)
		checkpermission(instance, ent, "vehicle.lock")
		hook.Remove("CanExitVehicle", "SF_CanExitVehicle"..ent:EntIndex())
		Ent_Fire(ent, "Unlock")
	end

	--- Allows passengers of a vehicle to aim and use things by clicking on them
	-- @param boolean enabled Whether to enable the ability to use by clicking
	-- @param number? key Optional IN_KEY alternate control for using (default IN_KEY.ATTACK)
	function vehicle_methods:useEnable(enabled, key)
		local veh = getveh(self)
		checkluatype(enabled, TYPE_BOOL)
		checkpermission(instance, veh, "vehicle.use")
		if key~=nil then checkluatype(key, TYPE_NUMBER) else key = IN_ATTACK end
		UseEnableVehicles:setEnabled(veh, enabled, key)
	end


	--- Tries to find an exit point for leaving the vehicle
	-- @param number yaw
	-- @param number distance
	-- @return Vector The exit position, or nil if unable to exit in that direction
	-- @server
	function vehicle_methods:checkExitPoint(yaw, dist)
		checkluatype(yaw, TYPE_NUMBER)
		checkluatype(dist, TYPE_NUMBER)

		local exitPos = Veh_CheckExitPoint(getveh(self), yaw, dist)
		if exitPos then return vwrap(exitPos) end
	end

	--- Gets the vehicles speed in MPH
	-- @server
	-- @return number Speed
	function vehicle_methods:getSpeed()
		return Veh_GetSpeed(getveh(self))
	end

	--- Gets the vehicles speed in Half-Life Hammer units.
	-- @server
	-- @return number Speed
	function vehicle_methods:getHLSpeed()
		return Veh_GetHLSpeed(getveh(self))
	end
end

end
