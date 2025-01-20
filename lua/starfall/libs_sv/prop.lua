-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local IsValid = FindMetaTable("Entity").IsValid
local IsValidPhys = FindMetaTable("PhysObj").IsValid

-- Register privileges
registerprivilege("prop.create", "Create prop", "Allows the user to create props")
registerprivilege("prop.createRagdoll", "Create a ragdoll", "Allows the user to create ragdolls")
registerprivilege("prop.createCustom", "Create custom prop", "Allows the user to create custom props")


local entList = SF.EntManager("props", "props", -1, "The number of props allowed to spawn via Starfall")
local plyPropBurst = SF.BurstObject("props", "props", 4, 4, "Rate props can be spawned per second.", "Number of props that can be spawned in a short time.")

local maxCustomSize = CreateConVar("sf_props_custom_maxsize", "2048", FCVAR_ARCHIVE, "The max hull size of a custom prop")
local minVertexDistance = CreateConVar("sf_props_custom_minvertexdistance", "0.2", FCVAR_ARCHIVE, "The min distance between two vertices in a custom prop")

local plyVertexCount = SF.LimitObject("props_custom_vertices", "custom prop vertices", 14400, "The max vertices allowed to spawn custom props per player")
local maxVerticesPerConvex = CreateConVar("sf_props_custom_maxverticesperconvex", "300", FCVAR_ARCHIVE, "The max vertices allowed per convex")
local maxConvexesPerProp = CreateConVar("sf_props_custom_maxconvexesperprop", "10", FCVAR_ARCHIVE, "The max convexes per prop")

--- Library for creating and manipulating physics-less models AKA "Props".
-- @name prop
-- @class library
-- @libtbl props_library
SF.RegisterLibrary("prop")


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end


local props_library = instance.Libraries.prop
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local propConfig = {clean = true, undo = false, propList = entList}
instance.data.props = propConfig

local vunwrap1
local aunwrap1
instance:AddHook("initialize", function()
	vunwrap1 = vec_meta.QuickUnwrap1
	aunwrap1 = ang_meta.QuickUnwrap1
end)

instance:AddHook("deinitialize", function()
	entList:deinitialize(instance, propConfig.clean)
end)

--- Creates a prop
-- @server
-- @param Vector pos Initial entity position
-- @param Angle ang Initial entity angles
-- @param string model Model path
-- @param boolean? frozen True to spawn the entity in a frozen state. Default = False
-- @return Entity The prop object
function props_library.create(pos, ang, model, frozen)

	checkpermission(instance, nil, "prop.create")
	checkluatype(model, TYPE_STRING)
	if frozen~=nil then checkluatype(frozen, TYPE_BOOL) else frozen = false end

	pos = SF.clampPos(vunwrap1(pos))
	ang = aunwrap1(ang)

	local ply = instance.player
	model = SF.CheckModel(model, ply, true)

	plyPropBurst:use(ply, 1)
	entList:checkuse(ply, 1)
	if ply ~= SF.Superuser and gamemode.Call("PlayerSpawnProp", ply, model)==false then SF.Throw("Another hook prevented the prop from spawning", 2) end

	local propent = ents.Create("prop_physics")
	propent:SetPos(pos)
	propent:SetAngles(ang)
	propent:SetModel(model)
	propent:Spawn()
	entList:register(instance, propent)

	if not propent:GetModel() then propent:Remove() SF.Throw("Invalid model", 2) end

	for I = 0, propent:GetPhysicsObjectCount() - 1 do
		local obj = propent:GetPhysicsObjectNum(I)
		if IsValidPhys(obj) then
			obj:EnableMotion(not frozen)
		end
	end
	FixInvalidPhysicsObject(propent)

	if ply ~= SF.Superuser then
		gamemode.Call("PlayerSpawnedProp", ply, model, propent)

		if propConfig.undo then
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
-- @param string model Model path
-- @param boolean? frozen True to spawn the entity in a frozen state. Default = False
-- @return Entity The ragdoll entity
function props_library.createRagdoll(model, frozen)
	checkpermission(instance, nil, "prop.createRagdoll")
	checkluatype(model, TYPE_STRING)
	if frozen~=nil then checkluatype(frozen, TYPE_BOOL) else frozen = false end

	local ply = instance.player
	model = SF.CheckRagdoll(model, ply)
	if not model then SF.Throw("Invalid model", 2) end

	plyPropBurst:use(ply, 1)
	entList:checkuse(ply, 1)
	if ply ~= SF.Superuser and gamemode.Call("PlayerSpawnRagdoll", ply, model)==false then SF.Throw("Another hook prevented the ragdoll from spawning", 2) end

	local ent = ents.Create("prop_ragdoll")
	ent:SetModel(model)
	ent:Spawn()
	entList:register(instance, ent)

	if not ent:GetModel() then ent:Remove() SF.Throw("Invalid model", 2) end

	if frozen then
		for I = 0, ent:GetPhysicsObjectCount() - 1 do
			local obj = ent:GetPhysicsObjectNum(I)
			if IsValidPhys(obj) then
				obj:EnableMotion(false)
			end
		end
	end

	if ply ~= SF.Superuser then
		gamemode.Call("PlayerSpawnedRagdoll", ply, model, ent)

		if propConfig.undo then
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
-- @param Vector pos The position to spawn the prop
-- @param Angle ang The angles to spawn the prop
-- @param table vertices The table of tables of vertices that make up the physics mesh {{v1,v2,...},{v1,v2,...},...}
-- @param boolean? frozen True to spawn the entity in a frozen state. Default = False
-- @return Entity The prop object
function props_library.createCustom(pos, ang, vertices, frozen)
	pos = SF.clampPos(vunwrap1(pos))
	ang = aunwrap1(ang)
	checkluatype(vertices, TYPE_TABLE)
	if frozen~=nil then checkluatype(frozen, TYPE_BOOL) else frozen = false end

	checkpermission(instance, nil, "prop.createCustom")

	local ply = instance.player

	plyPropBurst:use(ply, 1)
	entList:checkuse(ply, 1)
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

	plyVertexCount:free(ply, -totalVertices)

	local propent = ents.Create("starfall_prop")
	propent.streamdata = streamdata
	propent:SetPos(pos)
	propent:SetAngles(ang)
	propent.Mesh = uwVertices
	propent:Spawn()
	entList:register(instance, propent, function()
		plyVertexCount:free(ply, totalVertices)
	end)

	local physobj = propent:GetPhysicsObject()
	if not IsValidPhys(physobj) then
		SF.Throw("Custom prop generated with invalid physics object!", 2)
	end

	physobj:EnableCollisions(true)
	physobj:EnableMotion(not frozen)
	physobj:EnableDrag(true)
	physobj:Wake()

	propent:TransmitData()

	if ply ~= SF.Superuser then
		gamemode.Call("PlayerSpawnedProp", ply, "starfall_prop", propent)

		if propConfig.undo then
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
-- @param Vector pos Position of created component
-- @param Angle ang Angle of created component
-- @param string class Class of created component
-- @param string model Model of created component
-- @param boolean? frozen True to spawn the entity in a frozen state. Default = False
-- @server
-- @return Entity Component entity
function props_library.createComponent(pos, ang, class, model, frozen)
	checkpermission(instance,  nil, "prop.create")
	checkluatype(class, TYPE_STRING)
	checkluatype(model, TYPE_STRING)
	if frozen~=nil then checkluatype(frozen, TYPE_BOOL) else frozen = false end

	if not allowed_components[class] then return SF.Throw("Invalid class!", 1) end

	local pos = SF.clampPos(vunwrap1(pos))
	local ang = aunwrap1(ang)

	local ply = instance.player
	model = SF.CheckModel(model, ply, true)

	if ply ~= SF.Superuser then
		if not ply:CheckLimit("starfall_components") then SF.Throw("Limit of components reached!", 2) end
		plyPropBurst:use(ply, 1)
		entList:checkuse(ply, 1)
		if gamemode.Call("PlayerSpawnSENT", ply, class)==false then SF.Throw("Another hook prevented the component from spawning", 2) end
	end

	local comp = ents.Create(class)
	comp:SetPos(pos)
	comp:SetAngles(ang)
	comp:SetModel(model)
	comp:Spawn()
	entList:register(instance, comp)

	local mdl = comp:GetModel()
	if not mdl or mdl == "models/error.mdl" then
		comp:Remove()
		return SF.Throw("Invalid model!", 1)
	end

	for I = 0,  comp:GetPhysicsObjectCount() - 1 do
		local obj = comp:GetPhysicsObjectNum(I)
		if IsValidPhys(obj) then
			obj:EnableMotion(not frozen)
		end
	end

	if ply ~= SF.Superuser then
		if propConfig.undo then
			undo.Create(class)
				undo.SetPlayer(ply)
				undo.AddEntity(comp)
			undo.Finish("Prop (" .. tostring(model) .. ")")
		end

		ply:AddCount("starfall_components", comp)
		ply:AddCleanup("starfall_components", comp)
	end

	return ewrap(comp)
end

--- Get a list of all spawnable sents.
-- @param boolean? categorized True to get an categorized list
-- @return table The table
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

--- Creates a seat.
-- @param Vector pos Position of created seat
-- @param Angle ang Angle of created seat
-- @param string model Model of created seat
-- @param boolean? frozen True to spawn the entity in a frozen state. Default = False
-- @server
-- @return Entity The seat object
function props_library.createSeat(pos, ang, model, frozen)
	checkpermission(instance, nil, "prop.create")
	checkluatype(model, TYPE_STRING)
	if frozen~=nil then checkluatype(frozen, TYPE_BOOL) else frozen = false end

	local pos = SF.clampPos(vunwrap1(pos))
	local ang = aunwrap1(ang)

	local ply = instance.player
	model = SF.CheckModel(model, ply, true)

	plyPropBurst:use(ply, 1)
	entList:checkuse(ply, 1)

	local class = "prop_vehicle_prisoner_pod"

	local prop

	prop = ents.Create(class)
	prop:SetModel(model)

	prop:SetPos(pos)
	prop:SetAngles(ang)
	prop:Spawn()
	prop:SetKeyValue( "limitview", 0 )
	prop:Activate()

	entList:register(instance, prop)

	local phys = prop:GetPhysicsObject()
	if IsValidPhys(phys) then
		phys:EnableMotion(not frozen)
	end

	if ply ~= SF.Superuser then
		prop:SetCreator( ply )

		if propConfig.undo then
			undo.Create("SF")
				undo.SetPlayer(ply)
				undo.AddEntity(prop)
			undo.Finish("SF (" .. class .. ")")
		end

		ply:AddCleanup("props", prop)
		gamemode.Call("PlayerSpawnedVehicle", ply, prop)
	end

	return owrap(prop)
end

--- Creates a sent.
-- @param Vector pos Position of created sent
-- @param Angle ang Angle of created sent
-- @param string class Class of created sent
-- @param boolean? frozen True to spawn the entity in a frozen state. Default = False
-- @param table? data Optional table, additional entity data to be supplied to certain SENTs. See prop.SENT_Data_Structures table in Docs for list of SENTs
-- @server
-- @return Entity The sent object
function props_library.createSent(pos, ang, class, frozen, data)
	checkpermission(instance,  nil, "prop.create")

	checkluatype(class, TYPE_STRING)
	if frozen~=nil then checkluatype(frozen, TYPE_BOOL) else frozen = false end

	pos = SF.clampPos(vunwrap1(pos))
	ang = aunwrap1(ang)

	local ply = instance.player
	plyPropBurst:use(ply, 1)
	entList:checkuse(ply, 1)

	local swep = list.GetForEdit("Weapon")[class]
	local sent = list.GetForEdit("SpawnableEntities")[class]
	local npc = list.GetForEdit("NPC")[class]
	local vehicle = list.GetForEdit("Vehicles")[class]
	local sent2 = list.GetForEdit("starfall_creatable_sent")[class]

	local entity
	local hookcall

	if swep then
		if ply ~= SF.Superuser then
			if ((not swep.Spawnable and not ply:IsAdmin()) or
					(swep.AdminOnly and not ply:IsAdmin())) then SF.Throw("This swep is admin only!", 2) end
			if gamemode.Call("PlayerSpawnSWEP", ply, class, swep) == false then SF.Throw("Another hook prevented the swep from spawning", 2) end
		end

		entity = ents.Create(swep.ClassName)
		if IsValid(entity) then
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
			if IsValid(entity) then
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
			entity:SetPos(pos)
			entity:SetAngles(ang)
			entity:Spawn()
			entity:Activate()
		end

		hookcall = "PlayerSpawnedNPC"
	elseif vehicle then
		if ply ~= SF.Superuser and gamemode.Call("PlayerSpawnVehicle", ply, vehicle.Model, vehicle.Class, vehicle) == false then SF.Throw("Another hook prevented the vehicle from spawning", 2) end

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
			data.Model = SF.CheckModel(data.Model, ply, true)
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
				elseif org[1]==TYPE_NUMBER then
					SF.CheckValidNumber(value, nil, "Parameter: " .. param)
				else
					checkluatype(value, org[1], nil, "Parameter: " .. param)
				end
				enttbl[param] = value

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

		local isOk, errorMsg = instance:runExternal(function()
			if sent2._preFactory then
				sent2._preFactory(ply, enttbl)
			end

			entity = duplicator.CreateEntityFromTable(ply, enttbl)
			if not isentity(entity) then
				entity = nil
				error("Factory func returned invalid value", 2)
			end

			if sent2._postFactory then
				sent2._postFactory(ply, entity, enttbl)
			end

			if entity.PreEntityCopy then
				entity:PreEntityCopy() -- To build dupe modifiers
			end
			if entity.PostEntityCopy then
				entity:PostEntityCopy()
			end
			if entity.PostEntityPaste then
				entity:PostEntityPaste(ply, entity, {[entity:EntIndex()] = entity})
			end
		end)

		if not isOk then
			if IsValid(entity) then
				entity:Remove()
			end

			if debug.getmetatable(errorMsg) == SF.Errormeta then
				error(errorMsg, 3)
			else
				SF.Throw("Failed to create entity (" .. tostring(errorMsg) .. ")", 2)
			end
		end
	end

	if IsValid(entity) then
		entList:register(instance, entity)

		if CPPI then entity:CPPISetOwner(ply == SF.Superuser and NULL or ply) end

		local phys = entity:GetPhysicsObject()
		if IsValidPhys(phys) then
			phys:EnableMotion(not frozen)
		end

		if ply ~= SF.Superuser then
			entity:SetCreator( ply )

			if propConfig.undo then
				undo.Create("SF")
					undo.SetPlayer(ply)
					undo.AddEntity(entity)
				undo.Finish("SF (" .. class .. ")")
			end

			ply:AddCleanup("props", entity)
			if hookcall then
				gamemode.Call(hookcall, ply, entity)
			end
		end

		return owrap(entity)
	end
end

--- Checks if a user can spawn anymore props.
-- @server
-- @return boolean True if user can spawn props, False if not.
function props_library.canSpawn()
	if not SF.Permissions.hasAccess(instance, nil, "prop.create") then return false end
	return entList:check(instance.player) > 0 and plyPropBurst:check(instance.player) >= 1
end

--- Checks how many props can be spawned
-- @server
-- @return number Number of props able to be spawned
function props_library.propsLeft()
	if not SF.Permissions.hasAccess(instance,  nil, "prop.create") then return 0 end
	return math.min(entList:check(instance.player), plyPropBurst:check(instance.player))
end

--- Returns how many props per second the user can spawn
-- @server
-- @return number Number of props per second the user can spawn
function props_library.spawnRate()
	return plyPropBurst.rate
end

--- Sets whether the chip should remove created props when the chip is removed
-- @param boolean on Whether the props should be cleaned or not
function props_library.setPropClean(on)
	propConfig.clean = on
end

--- Sets whether the props should be undo-able
-- @param boolean on Whether the props should be undo-able
function props_library.setPropUndo(on)
	propConfig.undo = on
end

end
