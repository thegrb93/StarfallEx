-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

-- Register privileges
registerprivilege("prop.create", "Create prop", "Allows the user to create props")
registerprivilege("prop.createRagdoll", "Create a ragdoll", "Allows the user to create ragdolls")
registerprivilege("prop.createCustom", "Create custom prop", "Allows the user to create custom props")


local plyCount = SF.LimitObject("props", "props", -1, "The number of props allowed to spawn via Starfall")
local plyPropBurst = SF.BurstObject("props", "props", 4, 4, "Rate props can be spawned per second.", "Number of props that can be spawned in a short time.")

local maxCustomSize = CreateConVar("sf_props_custom_maxsize", "2048", FCVAR_ARCHIVE, "The max hull size of a custom prop")
local minVertexDistance = CreateConVar("sf_props_custom_minvertexdistance", "0.2", FCVAR_ARCHIVE, "The min distance between two vertices in a custom prop")

local plyVertexCount = SF.LimitObject("props_custom_vertices", "custom prop vertices", 14400, "The max vertices allowed to spawn custom props per player")
local maxVerticesPerConvex = CreateConVar("sf_props_custom_maxverticesperconvex", "300", FCVAR_ARCHIVE, "The max verteces allowed per convex")
local maxConvexesPerProp = CreateConVar("sf_props_custom_maxconvexesperprop", "10", FCVAR_ARCHIVE, "The max convexes per prop")

--- Library for creating and manipulating physics-less models AKA "Props".
-- @name prop
-- @class library
-- @libtbl props_library
SF.RegisterLibrary("prop")


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

instance:AddHook("initialize", function()
	instance.data.props = {props = {}}
end)

instance:AddHook("deinitialize", function()
	if instance.data.props.clean ~= false then --Return true on nil too
		for prop, _ in pairs(instance.data.props.props) do
			prop:Remove()
		end
	end
end)


local props_library = instance.Libraries.prop
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local function propOnDestroy(ent)
	local ply = instance.player
	plyCount:free(ply, 1)
	instance.data.props.props[ent] = nil
end

local function register(ent)
	ent:CallOnRemove("starfall_prop_delete", propOnDestroy)
	plyCount:free(instance.player, -1)
	instance.data.props.props[ent] = true
end

--- Creates a prop
-- @server
-- @param pos Initial entity position
-- @param ang Initial entity angles
-- @param model Model path
-- @param frozen True to spawn the entity in a frozen state. Default = False
-- @return The prop object
function props_library.create(pos, ang, model, frozen)

	checkpermission(instance, nil, "prop.create")
	checkluatype(model, TYPE_STRING)
	frozen = frozen and true or false

	local pos = SF.clampPos(vunwrap(pos))
	local ang = aunwrap(ang)

	local ply = instance.player
	model = SF.CheckModel(model, ply)
	if not model then SF.Throw("Invalid model", 2) end

	plyPropBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)
	if ply ~= SF.Superuser and gamemode.Call("PlayerSpawnProp", ply, model)==false then SF.Throw("Another hook prevented the prop from spawning", 2) end

	local propdata = instance.data.props
	local propent = ents.Create("prop_physics")
	register(propent, instance)
	propent:SetPos(pos)
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
	FixInvalidPhysicsObject(propent)

	if ply ~= SF.Superuser then
		gamemode.Call("PlayerSpawnedProp", ply, model, propent)

		if propdata.undo then
			undo.Create("Prop")
				undo.SetPlayer(ply)
				undo.AddEntity(propent)
			undo.Finish("Prop (" .. tostring(model) .. ")")
		end
		ply:AddCleanup("props", propent)
	end

	return ewrap(propent)
end

--- Creates a ragdoll
-- @server
-- @param model Model path
-- @param frozen True to spawn the entity in a frozen state. Default = False
-- @return The ragdoll entity
function props_library.createRagdoll(model, frozen)
    checkpermission(instance, nil, "prop.createRagdoll")
    checkluatype(model, TYPE_STRING)
    frozen = frozen and true or false

    local ply = instance.player
    model = SF.CheckRagdoll(model, ply)
    if not model then SF.Throw("Invalid model", 2) end

    plyPropBurst:use(ply, 1)
    plyCount:checkuse(ply, 1)
    if ply ~= SF.Superuser and gamemode.Call("PlayerSpawnRagdoll", ply, model)==false then SF.Throw("Another hook prevented the ragdoll from spawning", 2) end

    local propdata = instance.data.props
    local ent = ents.Create("prop_ragdoll")
    register(ent, instance)
    ent:SetModel(model)
    ent:Spawn()

    if not ent:GetModel() then ent:Remove() SF.Throw("Invalid model", 2) end

    if frozen then
        for I = 0, ent:GetPhysicsObjectCount() - 1 do
            local obj = ent:GetPhysicsObjectNum(I)
            if obj:IsValid() then
                obj:EnableMotion(false)
            end
        end
    end

    if ply ~= SF.Superuser then
        gamemode.Call("PlayerSpawnedRagdoll", ply, model, ent)

        if propdata.undo then
            undo.Create("Ragdoll")
                undo.SetPlayer(ply)
                undo.AddEntity(ent)
            undo.Finish("Ragdoll (" .. tostring(model) .. ")")
        end
        ply:AddCleanup("ragdolls", ent)
    end

    return ewrap(ent)
end

--- Creates a custom prop.
-- @server
-- @param pos The position to spawn the prop
-- @param ang The angles to spawn the prop
-- @param vertices The table of tables of vectices that make up the physics mesh {{v1,v2,...},{v1,v2,...},...}
-- @param frozen Whether the prop starts frozen
-- @return The prop object
function props_library.createCustom(pos, ang, vertices, frozen)
	local pos = SF.clampPos(vunwrap(pos))
	local ang = aunwrap(ang)
	checkluatype(vertices, TYPE_TABLE)
	frozen = frozen and true or false

	checkpermission(instance, nil, "prop.createCustom")

	local ply = instance.player

	plyPropBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)
	if instance.player ~= SF.Superuser and gamemode.Call("PlayerSpawnProp", ply, "starfall_prop")==false then SF.Throw("Another hook prevented the prop from spawning", 2) end

	local uwVertices = {}
	local max = maxCustomSize:GetFloat()
	local mindist = minVertexDistance:GetFloat()^2
	local maxVerticesPerConvex = maxVerticesPerConvex:GetInt()
	local maxConvexesPerProp = maxConvexesPerProp:GetInt()

	local totalVertices = 0
	local streamdata = SF.StringStream()
	streamdata:writeInt32(#vertices)
	for k, v in ipairs(vertices) do
		if k>maxConvexesPerProp then SF.Throw("Exceeded the max convexes per prop (" .. maxConvexesPerProp .. ")", 2) end
		streamdata:writeInt32(#v)
		totalVertices = totalVertices + #v
		plyVertexCount:checkuse(ply, totalVertices)
		local t = {}
		for o, p in ipairs(v) do
			if o>maxVerticesPerConvex then SF.Throw("Exceeded the max vertices per convex (" .. maxVerticesPerConvex .. ")", 2) end
			local vec = vunwrap(p)
			if math.abs(vec.x)>max or math.abs(vec.y)>max or math.abs(vec.z)>max then SF.Throw("The custom prop cannot exceed a hull size of " .. max, 2) end
			if vec.x~=vec.x or vec.y~=vec.y or vec.z~=vec.z then SF.Throw("Your mesh contains nan values!", 2) end
			for i=1, o-1 do
				if t[i]:DistToSqr(vec) < mindist then
					SF.Throw("No two vertices can have a distance less than " .. minVertexDistance:GetFloat(), 2)
				end
			end
			streamdata:writeFloat(vec.x)
			streamdata:writeFloat(vec.y)
			streamdata:writeFloat(vec.z)
			t[o] = vec
		end
		uwVertices[k] = t
	end
	streamdata = util.Compress(streamdata:getString())
	SF.NetBurst:use(instance.player, #streamdata*8)

	plyVertexCount:free(-totalVertices)

	local propdata = instance.data.props

	local propent = ents.Create("starfall_prop")
	register(propent, instance)
	propent.streamdata = streamdata
	propent:SetPos(pos)
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

	propent:TransmitData()

	if ply ~= SF.Superuser then
		gamemode.Call("PlayerSpawnedProp", ply, "starfall_prop", propent)

		if propdata.undo then
			undo.Create("Prop")
				undo.SetPlayer(ply)
				undo.AddEntity(propent)
			undo.Finish("Starfall Prop")
		end
		ply:AddCleanup("props", propent)
	end

	return ewrap(propent)
end

local allowed_components = {
	["starfall_screen"] = true,
	["starfall_hud"] = true,
}
--- Creates starfall component
-- Allowed components:
-- starfall_hud
-- starfall_screen
-- @param pos Position of created component
-- @param ang Angle of created component
-- @param class Class of created component
-- @param model Model of created component
-- @param frozen True to spawn frozen
-- @server
-- @return Component entity
function props_library.createComponent(pos, ang, class, model, frozen)
	checkpermission(instance,  nil, "prop.create")
	checkluatype(class, TYPE_STRING)
	checkluatype(model, TYPE_STRING)

	if not allowed_components[class] then return SF.Throw("Invalid class!", 1) end

	local pos = SF.clampPos(vunwrap(pos))
	local ang = aunwrap(ang)

	local ply = instance.player
	model = SF.CheckModel(model, ply)
	if not model then SF.Throw("Invalid model", 2) end

	local propdata = instance.data.props

	if not ply:CheckLimit("starfall_components") then SF.Throw("Limit of components reached!", 2) end
	plyPropBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)
	if ply ~= SF.Superuser and gamemode.Call("PlayerSpawnProp", ply, model)==false then SF.Throw("Another hook prevented the model from spawning", 2) end

	local comp = ents.Create(class)
	register(comp, instance)
	comp:SetPos(pos)
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

	if ply ~= SF.Superuser then
		if propdata.undo then
			undo.Create(class)
				undo.SetPlayer(ply)
				undo.AddEntity(comp)
			undo.Finish("Prop (" .. tostring(model) .. ")")
		end

		ply:AddCount("starfall_components", comp)
		ply:AddCleanup("starfall_components", comp)
		gamemode.Call("PlayerSpawnedSENT", ply, comp)
	end

	return ewrap(comp)
end

--- Get a list of all spawnable sents.
-- @param categorized True to get an categorized list
-- @return The table
function props_library.getSpawnableSents(categorized)
	local tbl = {}

	local add
	if categorized then
		add = function(list_name)
			tbl[list_name] = {}
			for class, _ in pairs(list.GetForEdit(list_name)) do
				table.insert(tbl[list_name], class)
			end
		end
	else
		add = function(list_name)
			for class, _ in pairs(list.GetForEdit(list_name)) do
				table.insert(tbl, class)
			end
		end
	end

	add("Weapon")
	add("SpawnableEntities")
	add("NPC")
	add("Vehicles")
	add("starfall_creatable_sent")

	return tbl
end

--- Creates a sent.
-- @param pos Position of created sent
-- @param ang Angle of created sent
-- @param class Class of created sent
-- @param frozen True to spawn frozen
-- @param data Optional table, additional entity data to be supplied to certain SENTs. See prop.SENT_Data_Structures table in Docs for list of SENTs
-- @server
-- @return The sent object
function props_library.createSent(pos, ang, class, frozen, data)
	checkpermission(instance,  nil, "prop.create")

	checkluatype(class, TYPE_STRING)
	frozen = frozen and true or false

	local pos = SF.clampPos(vunwrap(pos))
	local ang = aunwrap(ang)

	local ply = instance.player
	plyPropBurst:use(ply, 1)
	plyCount:checkuse(ply, 1)

	local swep = list.GetForEdit("Weapon")[class]
	local sent = list.GetForEdit("SpawnableEntities")[class]
	local npc = list.GetForEdit("NPC")[class]
	local vehicle = list.GetForEdit("Vehicles")[class]
	local sent2 = list.GetForEdit("starfall_creatable_sent")[class]

	local propdata = instance.data.props
	local entity
	local hookcall

	if swep then
		if ply ~= SF.Superuser then
			if ((not swep.Spawnable and not ply:IsAdmin()) or
					(swep.AdminOnly and not ply:IsAdmin())) then SF.Throw("This swep is admin only!", 2) end
			if gamemode.Call("PlayerSpawnSWEP", ply, class, swep) == false then SF.Throw("Another hook prevented the swep from spawning", 2) end
		end

		entity = ents.Create(swep.ClassName)
		if entity and entity:IsValid() then
			entity:SetPos(pos)
			entity:SetAngles(ang)
			entity:Spawn()
			entity:Activate()
		end

		hookcall = "PlayerSpawnedSWEP"
	elseif sent then
		if ply ~= SF.Superuser then
			if sent.AdminOnly and not ply:IsAdmin() then SF.Throw("This sent is admin only!", 2) end
			if gamemode.Call("PlayerSpawnSENT", ply, class) == false then SF.Throw("Another hook prevented the sent from spawning", 2) end
		end

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
		if ply ~= SF.Superuser then
			if npc.AdminOnly and not ply:IsAdmin() then SF.Throw("This npc is admin only!", 2) end
			if gamemode.Call("PlayerSpawnNPC", ply, class, "") == false then SF.Throw("Another hook prevented the npc from spawning", 2) end
		end

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
		if ply ~= SF.Superuser and gamemode.Call("PlayerSpawnVehicle", ply, vehicle.Model, vehicle.Class, vehicle) == false then SF.Throw("Another hook prevented the vehicle from spawning", 2) end

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
	elseif sent2 then
		if ply ~= SF.Superuser then
			if scripted_ents.GetStored(class).t.AdminOnly and not ply:IsAdmin() then SF.Throw("This sent is admin only!", 2) end
			if gamemode.Call("PlayerSpawnSENT", ply, class) == false then SF.Throw("Another hook prevented the sent from spawning", 2) end
		end

		local enttbl = {}
		local sentparams = sent2[1]
		if data ~= nil then checkluatype(data, TYPE_TABLE) else data = {} end
		if data.Model and isstring(data.Model) then
			data.Model = SF.CheckModel(data.Model, ply)
			if not data.Model then SF.Throw("Invalid model", 2) end
		end

		for k, v in pairs(data) do
			if not sentparams[k] then SF.Throw("Invalid parameter in data: " .. tostring(k), 2) end
		end

		-- Apply data
		for param, org in pairs(sentparams) do
			local value = data[param]

			if value~=nil then
				value = ounwrap(value) or value

				if org[1]==TYPE_COLOR then
					if not IsColor(value) then SF.ThrowTypeError("Color", SF.GetType(value), 2, "Parameter: " .. param) end
					enttbl[param] = value
				else
					checkluatype(value, org[1], nil, "Parameter: " .. param)
					enttbl[param] = value
				end

			elseif org[2]~=nil then
				enttbl[param] = org[2]
			else
				SF.Throw("Missing data parameter: " .. param, 2)
			end
		end

		-- Supply additional data
		enttbl.Data = enttbl
		enttbl.Name = ""
		enttbl.Class = class
		enttbl.Pos = pos
		enttbl.Angle = ang

		if sent2._preFactory then
			sent2._preFactory(ply, enttbl)
		end

		entity = duplicator.CreateEntityFromTable(ply, enttbl)

		if sent2._postFactory then
			sent2._postFactory(ply, entity, enttbl)
		end

		if entity.PreEntityCopy then
			entity:PreEntityCopy() -- To build dupe modifiers
		end
		if entity.PostEntityPaste then
			entity:PostEntityPaste(ply, entity, {[entity:EntIndex()] = entity})
		end

		hookcall = "PlayerSpawnedSENT"
	end

	if entity and entity:IsValid() then
		register(entity, instance)

		entity:SetCreator( ply )

		local phys = entity:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(not frozen)
		end

		if ply ~= SF.Superuser then
			if propdata.undo then
				undo.Create("SF")
					undo.SetPlayer(ply)
					undo.AddEntity(entity)
				undo.Finish("SF (" .. class .. ")")
			end

			ply:AddCleanup("props", entity)
			gamemode.Call(hookcall, ply, entity)
		end

		return owrap(entity)
	end
end

--- Checks if a user can spawn anymore props.
-- @server
-- @return True if user can spawn props, False if not.
function props_library.canSpawn()
	if not SF.Permissions.hasAccess(instance, nil, "prop.create") then return false end
	return plyCount:check(instance.player) > 0 and plyPropBurst:check(instance.player) >= 1
end

--- Checks how many props can be spawned
-- @server
-- @return number of props able to be spawned
function props_library.propsLeft()
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
	instance.data.props.clean = on
end

--- Sets whether the props should be undo-able
-- @param on Boolean whether the props should be undo-able
function props_library.setPropUndo(on)
	instance.data.props.undo = on
end

end
