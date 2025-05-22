-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local ENT_META,PLY_META,VEH_META = FindMetaTable("Entity"),FindMetaTable("Player"),FindMetaTable("Vehicle")


local UseEnableVehicles
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
local Veh_GetDriver,Veh_GetPassenger = VEH_META.GetDriver,VEH_META.GetPassenger

local vehicle_methods, vehicle_meta, wrap, unwrap = instance.Types.Vehicle.Methods, instance.Types.Vehicle, instance.Types.Vehicle.Wrap, instance.Types.Vehicle.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
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

if SERVER then
	--- Ejects the driver of the vehicle
	-- @server
	function vehicle_methods:ejectDriver()
		local driver = getveh(self):GetDriver()
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

end

end
