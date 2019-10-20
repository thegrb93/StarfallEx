
--- Library for creating and manipulating physics-less models AKA "Props".
-- @shared
local props_library = SF.RegisterLibrary("prop")

local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

-- Register privileges
SF.Permissions.registerPrivilege("prop.create", "Create prop", "Allows the user to create props")
SF.Permissions.registerPrivilege("prop.createCustom", "Create custom prop", "Allows the user to create custom props")


local plyCount = SF.LimitObject("props", "props", -1, "The number of props allowed to spawn via Starfall")
local plyPropBurst = SF.BurstObject("props", "props", 4, 4, "Rate props can be spawned per second.", "Number of props that can be spawned in a short time.")

local maxCustomSize = CreateConVar("sf_props_custom_maxsize", "500", FCVAR_ARCHIVE, "The max hull size of a custom prop")
local minVertexDistance = CreateConVar("sf_props_custom_minvertexdistance", "0.5", FCVAR_ARCHIVE, "The min distance between two vertices in a custom prop")

local plyVertexCount = SF.LimitObject("props_custom_vertices", "custom prop vertices", 14400, "The max vertices allowed to spawn custom props per player")
local maxVerticesPerConvex = CreateConVar("sf_props_custom_maxverticesperconvex", "300", FCVAR_ARCHIVE, "The max verteces allowed per convex")
local maxConvexesPerProp = CreateConVar("sf_props_custom_maxconvexesperprop", "48", FCVAR_ARCHIVE, "The max convexes per prop")

SF.AddHook("initialize", function(instance)
	instance.data.props = {props = {}}
end)

SF.AddHook("deinitialize", function(instance)
	if instance.data.props.clean ~= false then --Return true on nil too
		for prop, _ in pairs(instance.data.props.props) do
			prop:Remove()
		end
	end
end)

local vec_meta, vwrap, vunwrap, ang_meta, awrap, aunwrap
SF.AddHook("postload", function()
	vec_meta = SF.Vectors.Metatable
	ang_meta = SF.Angles.Metatable

	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap
	awrap = SF.Angles.Wrap
	aunwrap = SF.Angles.Unwrap
end)

local function propOnDestroy(ent, instance)
	local ply = instance.player
	plyCount:free(ply, 1)
	instance.data.props.props[ent] = nil
end

local function register(ent, instance)
	ent:CallOnRemove("starfall_prop_delete", propOnDestroy, instance)
	plyCount:free(instance.player, -1)
	instance.data.props.props[ent] = true
end

--- Creates a prop.
-- @server
-- @return The prop object
function props_library.create(pos, ang, model, frozen)

	checkpermission(SF.instance, nil, "prop.create")

	checktype(pos, vec_meta)
	checktype(ang, ang_meta)
	checkluatype(model, TYPE_STRING)
	frozen = frozen and true or false

	local pos = vunwrap(pos)
	local ang = aunwrap(ang)

	local instance = SF.instance
	local ply = instance.player


	plyPropBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)
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
			undo.SetPlayer(ply)
			undo.AddEntity(propent)
		undo.Finish("Prop (" .. tostring(model) .. ")")
	end
	ply:AddCleanup("props", propent)

	gamemode.Call("PlayerSpawnedProp", ply, model, propent)
	FixInvalidPhysicsObject(propent)

	register(propent, instance)

	return SF.Entities.Wrap(propent)
end


local customPropStream = {players = {}}

local function customPropFinished()
	for k, v in pairs(customPropStream.players) do
		if not customPropStream.stream.finished[v] then
			if CurTime()<customPropStream.timeout then
				return false
			else
				customPropStream.stream:Remove()
				break
			end
		end
	end
	return true
end

--- Returns if it is possible to create a custom prop yet
-- @return boolean if a custom prop can be created
function props_library.canCreateCustom()
	local ply = SF.instance.player
	return customPropFinished() and plyCount:check(ply) > 0 and plyPropBurst:check(ply) >= 1
end

--- Creates a custom prop.
-- @server
-- @param pos The position to spawn the prop
-- @param ang The angles to spawn the prop
-- @param frozen Whether the prop starts frozen
-- @return The prop object
function props_library.createCustom(pos, ang, vertices, frozen)
	checktype(pos, vec_meta)
	checktype(ang, ang_meta)
	checkluatype(vertices, TYPE_TABLE)
	frozen = frozen and true or false

	checkpermission(SF.instance, nil, "prop.createCustom")

	local instance = SF.instance
	local ply = instance.player

	if not customPropFinished() then SF.Throw("Waiting for previous custom prop to finish downloading", 2) end

	plyPropBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)
	if not gamemode.Call("PlayerSpawnProp", ply, "starfall_prop") then SF.Throw("Another hook prevented the prop from spawning", 2) end

	local uwVertices = {}
	local max = maxCustomSize:GetFloat()
	local mindist = minVertexDistance:GetFloat()^2
	local maxVerticesPerConvex = maxVerticesPerConvex:GetInt()
	local maxConvexesPerProp = maxConvexesPerProp:GetInt()
	
	local totalVertices = 0
	local stream = SF.StringStream()
	stream:writeInt32(#vertices)
	for k, v in ipairs(vertices) do
		if k>maxConvexesPerProp then SF.Throw("Exceeded the max convexes per prop (" .. maxConvexesPerProp .. ")", 2) end
		stream:writeInt32(#v)
		totalVertices = totalVertices + #v
		plyVertexCount:checkuse(ply, totalVertices)
		local t = {}
		for o, p in ipairs(v) do
			if o>maxVerticesPerConvex then SF.Throw("Exceeded the max vertices per convex (" .. maxVerticesPerConvex .. ")", 2) end
			checktype(p, vec_meta)
			local vec = vunwrap(p)
			if math.abs(vec.x)>max or math.abs(vec.y)>max or math.abs(vec.z)>max then SF.Throw("The custom prop cannot exceed a hull size of " .. max, 2) end
			if vec.x~=vec.x or vec.y~=vec.y or vec.z~=vec.z then SF.Throw("Your mesh contains nan values!", 2) end
			for i=1, o-1 do
				if t[i]:DistToSqr(vec) < mindist then
					SF.Throw("No two vertices can have a distance less than " .. minVertexDistance:GetFloat(), 2)
				end
			end
			stream:writeFloat(vec.x)
			stream:writeFloat(vec.y)
			stream:writeFloat(vec.z)
			t[o] = vec
		end
		uwVertices[k] = t
	end

	plyVertexCount:free(-totalVertices)

	local pos = vunwrap(pos)
	local ang = aunwrap(ang)

	local propdata = instance.data.props
	
	local propent = ents.Create("starfall_prop")
	propent:SetPos(SF.clampPos(pos))
	propent:SetAngles(ang)
	propent.Mesh = uwVertices
	propent:Spawn()
	
	local physobj = propent:GetPhysicsObject()
	if not physobj:IsValid() then
		SF.Throw("Custom prop generated with invalid physics object!", 2)
	end

	physobj:EnableCollisions(true)
	physobj:EnableMotion(not frozen)
	physobj:EnableDrag(true)
	physobj:Wake()

	net.Start("starfall_custom_prop")
	net.WriteUInt(propent:EntIndex(), 16)
	customPropStream = {players = player.GetAll(), stream = net.WriteStream(stream:getString()), timeout = CurTime()+5}
	net.Broadcast()

	if propdata.undo then
		undo.Create("Prop")
			undo.SetPlayer(ply)
			undo.AddEntity(propent)
		undo.Finish("Starfall Prop")
	end
	ply:AddCleanup("props", propent)

	gamemode.Call("PlayerSpawnedProp", ply, "starfall_prop", propent)

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
	checktype(pos, vec_meta)
	checktype(ang, ang_meta)
	checkluatype(class, TYPE_STRING)

	if not allowed_components[class] then return SF.Throw("Invalid class!", 1) end

	local pos = vunwrap(pos)
	local ang = aunwrap(ang)

	local instance = SF.instance
	local ply = instance.player
	local propdata = instance.data.props

	if not ply:CheckLimit("starfall_components") then SF.Throw("Limit of components reached!", 2) end
	plyPropBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)
	if not gamemode.Call("PlayerSpawnProp", ply, model) then return end

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
			undo.SetPlayer(ply)
			undo.AddEntity(comp)
		undo.Finish("Prop (" .. tostring(model) .. ")")
	end

	ply:AddCount("starfall_components", comp)
	ply:AddCleanup("starfall_components", comp)

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

	checktype(pos, vec_meta)
	checktype(ang, ang_meta)
	checkluatype(class, TYPE_STRING)
	frozen = frozen and true or false

	local pos = SF.clampPos(vunwrap(pos))
	local ang = aunwrap(ang)

	local instance = SF.instance
	local ply = instance.player
	plyPropBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)

	local swep = list.Get("Weapon")[class]
	local sent = list.Get("SpawnableEntities")[class]
	local npc = list.Get("NPC")[class]
	local vehicle = list.Get("Vehicles")[class]

	local propdata = instance.data.props
	local entity
	local hookcall

	if swep then

		if ((not swep.Spawnable and not ply:IsAdmin()) or
				(swep.AdminOnly and not ply:IsAdmin())) then SF.Throw("This swep is admin only!", 2) end
		if (not gamemode.Call("PlayerSpawnSWEP", ply, class, swep)) then SF.Throw("Another hook prevented the swep from spawning", 2) end


		entity = ents.Create(swep.ClassName)

		hookcall = "PlayerSpawnedSWEP"

	elseif sent then

		if (sent.AdminOnly and not ply:IsAdmin()) then SF.Throw("This sent is admin only!", 2) end
		if (not gamemode.Call("PlayerSpawnSENT", ply, class)) then SF.Throw("Another hook prevented the sent from spawning", 2) end

		local sent = scripted_ents.GetStored( class )
		if sent and sent.t.SpawnFunction then
			entity = sent.t.SpawnFunction( sent.t, ply, SF.dumbTrace(NULL, pos), class )
		else
			entity = ents.Create( class )
			if entity and entity:IsValid() then
				entity:SetPos(pos)
				entity:SetAngles(ang)
				entity:Spawn()
				entity:Activate()
			end
		end

		hookcall = "PlayerSpawnedSENT"

	elseif npc then

		if (npc.AdminOnly and not ply:IsAdmin()) then SF.Throw("This npc is admin only!", 2) end
		if (not gamemode.Call("PlayerSpawnNPC", ply, class, "")) then SF.Throw("Another hook prevented the npc from spawning", 2) end

		entity = ents.Create(npc.Class)

		if entity and entity:IsValid() then
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
			entity:SetPos(pos)
			entity:SetAngles(ang)
			entity:Spawn()
			entity:Activate()
		end

		hookcall = "PlayerSpawnedNPC"

	elseif vehicle then

		if (not gamemode.Call("PlayerSpawnVehicle", ply, vehicle.Model, vehicle.Class, vehicle)) then SF.Throw("Another hook prevented the vehicle from spawning", 2) end

		entity = ents.Create(vehicle.Class)

		if entity and entity:IsValid() then
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
			entity:SetPos(pos)
			entity:SetAngles(ang)
			entity:Spawn()
			entity:Activate()
		end

		hookcall = "PlayerSpawnedVehicle"

	end

	if entity and entity:IsValid() then

		entity:SetCreator( ply )

		local phys = entity:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(not frozen)
		end

		if propdata.undo then
			undo.Create("SF")
				undo.SetPlayer(ply)
				undo.AddEntity(entity)
			undo.Finish("SF (" .. class .. ")")
		end

		ply:AddCleanup("props", entity)
		gamemode.Call(hookcall, ply, entity)

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
	return plyCount:check(instance.player) > 0 and plyPropBurst:check(instance.player) >= 1
end

--- Checks how many props can be spawned
-- @server
-- @return number of props able to be spawned
function props_library.propsLeft()
	local instance = SF.instance
	if not SF.Permissions.hasAccess(instance,  nil, "prop.create") then return 0 end
	return math.min(plyCount:check(instance.player), plyPropBurst:check(instance.player))
end

--- Returns how many props per second the user can spawn
-- @server
-- @return Number of props per second the user can spawn
function props_library.spawnRate()

	return plyPropBurst.rate

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
