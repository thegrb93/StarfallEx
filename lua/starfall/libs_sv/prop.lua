
--- Library for creating and manipulating physics-less models AKA "Props".
-- @shared
local props_library = SF.Libraries.Register("prop")

local vunwrap = SF.UnwrapObject

SF.Props = {}

SF.Props.personalquota = CreateConVar("sf_props_personalquota", "-1", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
	"The number of props allowed to spawn via Starfall scripts for a single instance")

SF.Props.burstmax = CreateConVar("sf_props_burstmax", "4", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
	"The number of props allowed to spawn in a short interval of time via Starfall scripts for a single instance ( burst )")

SF.Props.burstrate = CreateConVar("sf_props_burstrate", "4", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
	"The rate at which the burst regenerates per second.")

-- Register privileges
SF.Permissions.registerPrivilege("prop.create", "Create prop", "Allows the user to create props")

-- Table with player keys that automatically cleans when player leaves.
local plyCount = SF.EntityTable("playerProps")

SF.Libraries.AddHook("initialize", function(inst)
	inst.data.props = {
		props = {},
		burst = SF.BurstObject(SF.Props.burstrate:GetFloat(), SF.Props.burstmax:GetFloat())
	}

	plyCount[inst.player] = plyCount[inst.player] or 0
end)

SF.Libraries.AddHook("deinitialize", function(inst)
	if inst.data.props.clean ~= false then --Return true on nil too
		for prop, _ in pairs(inst.data.props.props) do
			local propent = SF.Entities.Unwrap(prop)
			if IsValid(propent) then
				propent:Remove()
			end
		end
	end

	inst.data.props.props = nil
end)

local function propOnDestroy(propent, propdata, ply)
	plyCount[ply] = plyCount[ply] - 1
	if not propdata.props then return end
	local prop = SF.Entities.Wrap(propent)
	if propdata.props[prop] then
		propdata.props[prop] = nil
	end
end

--- Checks if the users personal limit of props has been exhausted
-- @class function
-- @param i Instance to use, this will relate to the player in question
-- @return True/False depending on if the personal limit has been reached for SF Props
local function personal_max_reached(i)
	if SF.Props.personalquota:GetInt() < 0 then return false end
	return plyCount[i.player] >= SF.Props.personalquota:GetInt()
end

--- Creates a prop.
-- @server
-- @return The prop object
function props_library.create (pos, ang, model, frozen)

	SF.Permissions.check(SF.instance.player,  nil, "prop.create")

	SF.CheckType(pos, SF.Types["Vector"])
	SF.CheckType(ang, SF.Types["Angle"])
	SF.CheckLuaType(model, TYPE_STRING)
	frozen = frozen and true or false

	local pos = vunwrap(pos)
	local ang = SF.Angles.Unwrap(ang)

	local instance = SF.instance

	if not instance.data.props.burst:use(1) then return SF.Throw("Can't spawn props that often", 2)
	elseif personal_max_reached(instance) then return SF.Throw("Can't spawn props, maximum personal limit of " .. SF.Props.personalquota:GetInt() .. " has been reached", 2) end
	if not gamemode.Call("PlayerSpawnProp", instance.player, model) then return end

	local propdata = instance.data.props
	local propent = ents.Create("prop_physics")

	propent:CallOnRemove("starfall_prop_delete", propOnDestroy, propdata, instance.player)
	SF.setPos(propent, pos)
	SF.setAng(propent, ang)
	propent:SetModel(model)
	propent:Spawn()

	if not propent:GetModel() then propent:Remove() return end

	for I = 0,  propent:GetPhysicsObjectCount() - 1 do
		local obj = propent:GetPhysicsObjectNum(I)
		if obj:IsValid() then
			obj:EnableMotion(not frozen)
		end
	end

	if propdata.undo then
		undo.Create("Prop")
			undo.SetPlayer(instance.player)
			undo.AddEntity(propent)
		undo.Finish("Prop (" .. tostring(model) .. ")")
	end

	instance.player:AddCleanup("props", propent)

	gamemode.Call("PlayerSpawnedProp", instance.player, model, propent)
	FixInvalidPhysicsObject(propent)

	local prop = SF.Entities.Wrap(propent)

	propdata.props[prop] = prop
	plyCount[instance.player] = plyCount[instance.player] + 1

	return prop
end

local allowed_components = {
	["starfall_screen"] = true,
	["starfall_hud"] = true,
}
--- Creates starfall component.\n Allowed components:\n starfall_hud\n starfall_screen
-- @param pos Position of created component
-- @param ang Angle of created component
-- @param class Class of created component
-- @param model Model of created component
-- @param frozen True to spawn frozen
-- @server
-- @return Component entity
function props_library.createComponent (pos, ang, class, model, frozen)
	SF.Permissions.check(SF.instance.player,  nil, "prop.create")
	SF.CheckType(pos, SF.Types["Vector"])
	SF.CheckType(ang, SF.Types["Angle"])
	SF.CheckLuaType(class, TYPE_STRING)

	if not allowed_components[class] then return SF.Throw("Invalid class!", 1) end

	local pos = vunwrap(pos)
	local ang = SF.Angles.Unwrap(ang)

	local instance = SF.instance
	local propdata = instance.data.props

	if not instance.player:CheckLimit("starfall_components") then SF.Throw("Limit of components reached!", 2) end
	if not instance.data.props.burst:use(1) then return SF.Throw("Can't spawn props that often", 2) end
	if personal_max_reached(instance) then return SF.Throw("Can't spawn props, maximum personal limit of " .. SF.Props.personalquota:GetInt() .. " has been reached", 2) end
	if not gamemode.Call("PlayerSpawnProp", instance.player, model) then return end

	local comp = ents.Create(class)

	comp:CallOnRemove("starfall_prop_delete", propOnDestroy, propdata, instance.player)
	
	SF.setPos(comp, pos)
	SF.setAng(comp, ang)
	comp:SetModel(model)
	comp:Spawn()

	local mdl = comp:GetModel()
	if not mdl or mdl == "models/error.mdl" then
		comp:Remove()
		return SF.Throw("Invalid model!", 1)
	end

	for I = 0,  comp:GetPhysicsObjectCount() - 1 do
		local obj = comp:GetPhysicsObjectNum(I)
		if obj:IsValid() then
			obj:EnableMotion(not frozen)
		end
	end

	if propdata.undo then
		undo.Create(class)
			undo.SetPlayer(instance.player)
			undo.AddEntity(comp)
		undo.Finish("Prop (" .. tostring(model) .. ")")
	end

	instance.player:AddCount("starfall_components", comp)
	instance.player:AddCleanup("starfall_components", comp)

	local prop = SF.Entities.Wrap(comp)

	propdata.props[prop] = prop
	plyCount[instance.player] = plyCount[instance.player] + 1

	return prop

end

--- Creates a sent.
-- @param pos Position of created sent
-- @param ang Angle of created sent
-- @param class Class of created sent
-- @param frozen True to spawn frozen
-- @server
-- @return The sent object
function props_library.createSent (pos, ang, class, frozen)

	SF.Permissions.check(SF.instance.player,  nil, "prop.create")

	SF.CheckType(pos, SF.Types["Vector"])
	SF.CheckType(ang, SF.Types["Angle"])
	SF.CheckLuaType(class, TYPE_STRING)
	frozen = frozen and true or false

	local pos = vunwrap(pos)
	local ang = SF.Angles.Unwrap(ang)

	local instance = SF.instance
	if not instance.data.props.burst:use(1) then return SF.Throw("Can't spawn props that often", 2)
	elseif personal_max_reached(instance) then return SF.Throw("Can't spawn props, maximum personal limit of " .. SF.Props.personalquota:GetInt() .. " has been reached", 2) end

	local swep = list.Get("Weapon")[class]
	local sent = list.Get("SpawnableEntities")[class]
	local npc = list.Get("NPC")[class]
	local vehicle = list.Get("Vehicles")[class]

	local propdata = instance.data.props
	local entity
	local hookcall

	if swep then

		if ((not swep.Spawnable and not instance.player:IsAdmin()) or
				(swep.AdminOnly and not instance.player:IsAdmin())) then return end
		if (not gamemode.Call("PlayerSpawnSWEP", instance.player, class, swep)) then return end


		entity = ents.Create(swep.ClassName)

		hookcall = "PlayerSpawnedSWEP"

	elseif sent then

		if (sent.AdminOnly and not instance.player:IsAdmin()) then return false end
		if (not gamemode.Call("PlayerSpawnSENT", instance.player, class)) then return end

		entity = ents.Create(sent.ClassName)

		hookcall = "PlayerSpawnedSENT"

	elseif npc then

		if (npc.AdminOnly and not instance.player:IsAdmin()) then return false end
		if (not gamemode.Call("PlayerSpawnNPC", instance.player, class, "")) then return end

		entity = ents.Create(npc.Class)

		if IsValid(entity) then
			if (npc.Model) then
				entity:SetModel(npc.Model)
			end
			if (npc.Material) then
				entity:SetMaterial(npc.Material)
			end
			local SpawnFlags = bit.bor(SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK)
			if (npc.SpawnFlags) then SpawnFlags = bit.bor(SpawnFlags, npc.SpawnFlags) end
			if (npc.TotalSpawnFlags) then SpawnFlags = npc.TotalSpawnFlags end
			entity:SetKeyValue("spawnflags", SpawnFlags)
			entity.SpawnFlags = SpawnFlags
			if (npc.KeyValues) then
				for k, v in pairs(npc.KeyValues) do
					entity:SetKeyValue(k, v)
				end
			end
			if (npc.Skin) then
				entity:SetSkin(npc.Skin)
			end
		end

		hookcall = "PlayerSpawnedNPC"

	elseif vehicle then

		if (not gamemode.Call("PlayerSpawnVehicle", instance.player, vehicle.Model, vehicle.Class, vehicle)) then return end

		entity = ents.Create(vehicle.Class)

		if IsValid(entity) then
			entity:SetModel(vehicle.Model)
			if (vehicle.Model == "models/buggy.mdl") then
				entity:SetKeyValue("vehiclescript", "scripts/vehicles/jeep_test.txt")
			end
			if (vehicle.Model == "models/vehicle.mdl") then
				entity:SetKeyValue("vehiclescript", "scripts/vehicles/jalopy.txt")
			end
			if (vehicle.KeyValues) then
				for k, v in pairs(vehicle.KeyValues) do

					local kLower = string.lower(k)

					if (kLower == "vehiclescript" or
						 kLower == "limitview"     or
						 kLower == "vehiclelocked" or
						 kLower == "cargovisible"  or
						 kLower == "enablegun")
					then
						entity:SetKeyValue(k, v)
					end

				end
			end

			if (vehicle.Members) then
				table.Merge(entity, vehicle.Members)
				duplicator.StoreEntityModifier(entity, "VehicleMemDupe", vehicle.Members)
			end

			if (entity.SetVehicleClass) then entity:SetVehicleClass(class) end
			entity.VehicleName = class
			entity.VehicleTable = vehicle

			entity.ClassOverride = vehicle.Class
		end

		hookcall = "PlayerSpawnedVehicle"

	end

	if (IsValid(entity)) then

		entity:CallOnRemove("starfall_prop_delete", propOnDestroy, propdata, instance.player)

		SF.setPos(entity, pos)
		SF.setAng(entity, ang)

		entity:Spawn()
		entity:Activate()

		local phys = entity:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(not frozen)
		end

		if propdata.undo then
			undo.Create("SF")
				undo.SetPlayer(instance.player)
				undo.AddEntity(entity)
			undo.Finish("SF (" .. class .. ")")
		end

		instance.player:AddCleanup("props", entity)
		gamemode.Call(hookcall, instance.player, entity)

		local wrapped = SF.WrapObject(entity)

		propdata.props[wrapped] = wrapped

		plyCount[instance.player] = plyCount[instance.player] + 1

		return wrapped
	end
end

--- Checks if a user can spawn anymore props.
-- @server
-- @return True if user can spawn props, False if not.
function props_library.canSpawn ()

	if not SF.Permissions.hasAccess(SF.instance.player,  nil, "prop.create") then return false end

	local instance = SF.instance
	return not personal_max_reached(instance) and instance.data.props.burst:check()>1

end

--- Checks how many props can be spawned
-- @server
-- @return number of props able to be spawned
function props_library.propsLeft ()

	if not SF.Permissions.hasAccess(SF.instance.player,  nil, "prop.create") then return 0 end

	local instance = SF.instance

	if SF.Props.personalquota:GetInt() < 0 then return -1 end
	return math.min(SF.Props.personalquota:GetInt() - plyCount[instance.player], instance.data.props.burst)

end

--- Returns how many props per second the user can spawn
-- @server
-- @return Number of props per second the user can spawn
function props_library.spawnRate ()

	return SF.Props.burstrate:GetFloat() or 4

end

--- Sets whether the chip should remove created props when the chip is removed
-- @param on Boolean whether the props should be cleaned or not
function props_library.setPropClean(on)
	SF.instance.data.props.clean = on
end

--- Sets whether the props should be undo-able
-- @param on Boolean whether the props should be undo-able
function props_library.setPropUndo(on)
	SF.instance.data.props.undo = on
end
