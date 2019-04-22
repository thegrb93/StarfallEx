
--- Library for creating and manipulating physics-less models AKA "Props".
-- @shared
local props_library = SF.RegisterLibrary("prop")

local vunwrap = SF.UnwrapObject
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

-- Register privileges
SF.Permissions.registerPrivilege("prop.create", "Create prop", "Allows the user to create props")

local plyMaxProps = CreateConVar("sf_props_personalquota", "-1", FCVAR_ARCHIVE, "The number of props allowed to spawn via Starfall")
local plyCount = SF.EntityTable("playerProps")
local plyPropBurst = SF.EntityTable("playerPropBurst")
local plyPropBurstGen = SF.BurstGenObject("props", 4, 4, "Rate props can be spawned per second.", "Number of props that can be spawned in a short time.")

SF.AddHook("initialize", function(instance)
	instance.data.props = {props = {}}
	plyPropBurst[instance.player] = plyPropBurst[instance.player] or plyPropBurstGen:create()
	plyCount[instance.player] = plyCount[instance.player] or 0
end)

SF.AddHook("deinitialize", function(instance)
	if instance.data.props.clean ~= false then --Return true on nil too
		for prop, _ in pairs(instance.data.props.props) do
			prop:Remove()
		end
	end
end)

local function propOnDestroy(ent, instance)
	local ply = instance.player
	if plyCount[ply] then
		plyCount[ply] = plyCount[ply] - 1
	end
	instance.data.props.props[ent] = nil
end

local function register(ent, instance)
	ent:CallOnRemove("starfall_prop_delete", propOnDestroy, instance)
	plyCount[instance.player] = plyCount[instance.player] + 1
	instance.data.props.props[ent] = true
end

local function maxReached(ply)
	if plyMaxProps:GetInt() < 0 then return false end
	return plyCount[ply] >= plyMaxProps:GetInt()
end

--- Creates a prop.
-- @server
-- @return The prop object
function props_library.create (pos, ang, model, frozen)

	checkpermission(SF.instance, nil, "prop.create")

	checktype(pos, SF.Types["Vector"])
	checktype(ang, SF.Types["Angle"])
	checkluatype(model, TYPE_STRING)
	frozen = frozen and true or false

	local pos = vunwrap(pos)
	local ang = SF.Angles.Unwrap(ang)

	local instance = SF.instance

	if not plyPropBurst[instance.player]:use(1) then SF.Throw("Can't spawn props that often", 2) end
	if maxReached(instance.player) then SF.Throw("Can't spawn props, maximum personal limit of " .. plyMaxProps:GetInt() .. " has been reached", 2) end
	if not gamemode.Call("PlayerSpawnProp", instance.player, model) then SF.Throw("Another hook prevented the prop from spawning", 2) end

	local propdata = instance.data.props
	local propent = ents.Create("prop_physics")

	propent:SetPos(SF.clampPos(pos))
	propent:SetAngles(ang)
	propent:SetModel(model)
	propent:Spawn()

	if not propent:GetModel() then propent:Remove() SF.Throw("Invalid model", 2) end

	for I = 0, propent:GetPhysicsObjectCount() - 1 do
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

	register(propent, instance)

	return SF.Entities.Wrap(propent)
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
	checkpermission(SF.instance,  nil, "prop.create")
	checktype(pos, SF.Types["Vector"])
	checktype(ang, SF.Types["Angle"])
	checkluatype(class, TYPE_STRING)

	if not allowed_components[class] then return SF.Throw("Invalid class!", 1) end

	local pos = vunwrap(pos)
	local ang = SF.Angles.Unwrap(ang)

	local instance = SF.instance
	local propdata = instance.data.props

	if not instance.player:CheckLimit("starfall_components") then SF.Throw("Limit of components reached!", 2) end
	if not plyPropBurst[instance.player]:use(1) then return SF.Throw("Can't spawn props that often", 2) end
	if maxReached(instance.player) then return SF.Throw("Can't spawn props, maximum personal limit of " .. plyMaxProps:GetInt() .. " has been reached", 2) end
	if not gamemode.Call("PlayerSpawnProp", instance.player, model) then return end

	local comp = ents.Create(class)

	comp:SetPos(SF.clampPos(pos))
	comp:SetAngles(ang)
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

	register(comp, instance)

	return SF.Entities.Wrap(comp)
end

--- Creates a sent.
-- @param pos Position of created sent
-- @param ang Angle of created sent
-- @param class Class of created sent
-- @param frozen True to spawn frozen
-- @server
-- @return The sent object
function props_library.createSent (pos, ang, class, frozen)

	checkpermission(SF.instance,  nil, "prop.create")

	checktype(pos, SF.Types["Vector"])
	checktype(ang, SF.Types["Angle"])
	checkluatype(class, TYPE_STRING)
	frozen = frozen and true or false

	local pos = vunwrap(pos)
	local ang = SF.Angles.Unwrap(ang)

	local instance = SF.instance
	if not plyPropBurst[instance.player]:use(1) then return SF.Throw("Can't spawn props that often", 2)
	elseif maxReached(instance.player) then return SF.Throw("Can't spawn props, maximum personal limit of " .. plyMaxProps:GetInt() .. " has been reached", 2) end

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

		entity:SetPos(SF.clampPos(pos))
		entity:SetAngles(ang)

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

		register(entity, instance)

		return SF.WrapObject(entity)
	end
end

--- Checks if a user can spawn anymore props.
-- @server
-- @return True if user can spawn props, False if not.
function props_library.canSpawn()
	local instance = SF.instance
	if not SF.Permissions.hasAccess(instance, nil, "prop.create") then return false end
	return not maxReached(instance.player) and plyPropBurst[instance.player]:check()>1
end

--- Checks how many props can be spawned
-- @server
-- @return number of props able to be spawned
function props_library.propsLeft()
	local instance = SF.instance
	if not SF.Permissions.hasAccess(instance,  nil, "prop.create") then return 0 end
	if plyMaxProps:GetInt() < 0 then return -1 end
	return math.min(plyMaxProps:GetInt() - plyCount[instance.player], plyPropBurst[instance.player]:check())
end

--- Returns how many props per second the user can spawn
-- @server
-- @return Number of props per second the user can spawn
function props_library.spawnRate()

	return plyPropBurstGen.ratecvar:GetFloat()

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
