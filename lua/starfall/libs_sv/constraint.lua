-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local registerprivilege = SF.Permissions.registerPrivilege

-- Register privileges
registerprivilege("constraints.weld", "Weld", "Allows the user to weld two entities", { entities = {} })
registerprivilege("constraints.axis", "Axis", "Allows the user to axis two entities", { entities = {} })
registerprivilege("constraints.ballsocket", "Ballsocket", "Allows the user to ballsocket two entities", { entities = {} })
registerprivilege("constraints.ballsocketadv", "BallsocketAdv", "Allows the user to advanced ballsocket two entities", { entities = {} })
registerprivilege("constraints.slider", "Slider", "Allows the user to slider two entities", { entities = {} })
registerprivilege("constraints.rope", "Rope", "Allows the user to rope two entities", { entities = {} })
registerprivilege("constraints.elastic", "Elastic", "Allows the user to elastic two entities", { entities = {} })
registerprivilege("constraints.nocollide", "Nocollide", "Allows the user to nocollide two entities", { entities = {} })
registerprivilege("constraints.any", "Any", "General constraint functions", { entities = {} })

local plyCount = SF.LimitObject("constraints", "constraints", 600, "The number of constraints allowed to spawn via Starfall")

local function constraintOnDestroy(ent, constraints, ply)
	plyCount:free(ply, 1)
	constraints[ent] = nil
end


--- Library for creating and manipulating constraints.
-- @name constraint
-- @class library
-- @libtbl constraint_library
SF.RegisterLibrary("constraint")


return function(instance)


local getent
instance:AddHook("initialize", function()
	instance.data.constraints = {constraints = {}}
	getent = instance.Types.Entity.GetEntity
end)

instance:AddHook("deinitialize", function()
	if instance.data.constraints.clean ~= false then --Return true on nil too
		local constraints = instance.data.constraints.constraints
		for ent, _ in pairs(constraints) do
			if (ent and ent:IsValid()) then
				ent:RemoveCallOnRemove("starfall_constraint_delete")
				constraintOnDestroy(ent, constraints, instance.player)
				ent:Remove()
			end
		end
	end
end)

local constraint_library = instance.Libraries.constraint

local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local function checkConstraint(e, t)
	if e then
		if e:IsValid() then
			if e:GetMoveType() == MOVETYPE_VPHYSICS then
				checkpermission(instance, e, t)
			else
				SF.Throw("Can only constrain entities with physics", 3)
			end
		elseif not e:IsWorld() then
			SF.Throw("Invalid Entity", 3)
		end
	else
		SF.Throw("Invalid Entity", 3)
	end
end

local function register(ent, instance)
	local constraints = instance.data.constraints.constraints
	local ply = instance.player
	ent:CallOnRemove("starfall_constraint_delete", constraintOnDestroy, constraints, ply)
	plyCount:free(ply, -1)
	constraints[ent] = true
end

--- Welds two entities
-- @param e1 The first entity
-- @param e2 The second entity
-- @param bone1 Number bone of the first entity
-- @param bone2 Number bone of the second entity
-- @param force_lim Max force the weld can take before breaking
-- @param nocollide Bool whether or not to nocollide the two entities
-- @server
function constraint_library.weld(e1, e2, bone1, bone2, force_lim, nocollide)
	plyCount:checkuse(instance.player, 1)

	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)

	checkConstraint(ent1, "constraints.weld")
	checkConstraint(ent2, "constraints.weld")

	bone1 = bone1 or 0
	bone2 = bone2 or 0
	force_lim = force_lim or 0
	nocollide = nocollide and true or false

	checkluatype(bone1, TYPE_NUMBER)
	checkluatype(bone2, TYPE_NUMBER)
	checkluatype(force_lim, TYPE_NUMBER)

	local ent = constraint.Weld(ent1, ent2, bone1, bone2, force_lim, nocollide)
	if ent then
		register(ent, instance)
	end
end

--- Axis two entities
-- @server
function constraint_library.axis(e1, e2, bone1, bone2, v1, v2, force_lim, torque_lim, friction, nocollide, laxis)
	plyCount:checkuse(instance.player, 1)

	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)
	local vec1 = vunwrap(v1)
	local vec2 = vunwrap(v2)
	local axis = laxis and vunwrap(laxis) or nil

	checkConstraint(ent1, "constraints.axis")
	checkConstraint(ent2, "constraints.axis")

	bone1 = bone1 or 0
	bone2 = bone2 or 0
	force_lim = force_lim or 0
	torque_lim = torque_lim or 0
	friction = friction or 0
	nocollide = nocollide and 1 or 0

	checkluatype(bone1, TYPE_NUMBER)
	checkluatype(bone2, TYPE_NUMBER)
	checkluatype(force_lim, TYPE_NUMBER)
	checkluatype(torque_lim, TYPE_NUMBER)
	checkluatype(friction, TYPE_NUMBER)

	local ent = constraint.Axis(ent1, ent2, bone1, bone2, vec1, vec2, force_lim, torque_lim, friction, nocollide, axis)
	if ent then
		register(ent, instance)
	end
end

--- Ballsocket two entities
-- @server
function constraint_library.ballsocket(e1, e2, bone1, bone2, v1, force_lim, torque_lim, nocollide)
	plyCount:checkuse(instance.player, 1)

	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)
	local vec1 = vunwrap(v1)

	checkConstraint(ent1, "constraints.ballsocket")
	checkConstraint(ent2, "constraints.ballsocket")

	bone1 = bone1 or 0
	bone2 = bone2 or 0
	force_lim = force_lim or 0
	torque_lim = torque_lim or 0
	nocollide = nocollide and 1 or 0

	checkluatype(bone1, TYPE_NUMBER)
	checkluatype(bone2, TYPE_NUMBER)
	checkluatype(force_lim, TYPE_NUMBER)
	checkluatype(torque_lim, TYPE_NUMBER)

	local ent = constraint.Ballsocket(ent1, ent2, bone1, bone2, vec1, force_lim, torque_lim, nocollide)
	if ent then
		register(ent, instance)
	end
end

--- Advanced Ballsocket two entities
-- @server
function constraint_library.ballsocketadv(e1, e2, bone1, bone2, v1, v2, force_lim, torque_lim, minv, maxv, frictionv, rotateonly, nocollide)
	plyCount:checkuse(instance.player, 1)

	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)
	local vec1 = vunwrap(v1)
	local vec2 = vunwrap(v2)
	local mins = vunwrap(minv) or Vector (0, 0, 0)
	local maxs = vunwrap(maxv) or Vector (0, 0, 0)
	local frictions = vunwrap(frictionv) or Vector (0, 0, 0)

	checkConstraint(ent1, "constraints.ballsocketadv")
	checkConstraint(ent2, "constraints.ballsocketadv")

	bone1 = bone1 or 0
	bone2 = bone2 or 0
	force_lim = force_lim or 0
	torque_lim = torque_lim or 0
	rotateonly = rotateonly and 1 or 0
	nocollide = nocollide and 1 or 0

	checkluatype(bone1, TYPE_NUMBER)
	checkluatype(bone2, TYPE_NUMBER)
	checkluatype(force_lim, TYPE_NUMBER)
	checkluatype(torque_lim, TYPE_NUMBER)

	local ent = constraint.AdvBallsocket(ent1, ent2, bone1, bone2, vec1, vec2, force_lim, torque_lim, mins.x, mins.y, mins.z, maxs.x, maxs.y, maxs.z, frictions.x, frictions.y, frictions.z, rotateonly, nocollide)
	if ent then
		register(ent, instance)
	end
end

--- Elastic two entities
-- @server
function constraint_library.elastic(index, e1, e2, bone1, bone2, v1, v2, const, damp, rdamp, width, strech)
	plyCount:checkuse(instance.player, 1)

	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)
	local vec1 = vunwrap(v1)
	local vec2 = vunwrap(v2)

	checkConstraint(ent1, "constraints.elastic")
	checkConstraint(ent2, "constraints.elastic")

	bone1 = bone1 or 0
	bone2 = bone2 or 0
	const = const or 1000
	damp = damp or 100
	rdamp = rdamp or 0
	width = width or 0
	strech = strech and true or false

	checkluatype(bone1, TYPE_NUMBER)
	checkluatype(bone2, TYPE_NUMBER)
	checkluatype(const, TYPE_NUMBER)
	checkluatype(damp, TYPE_NUMBER)
	checkluatype(rdamp, TYPE_NUMBER)
	checkluatype(width, TYPE_NUMBER)

	e1.Elastics = e1.Elastics or {}
	e2.Elastics = e2.Elastics or {}

	local ent = constraint.Elastic(ent1, ent2, bone1, bone2, vec1, vec2, const, damp, rdamp, "cable/cable2", math.Clamp(width, 0, 50), strech)
	if ent then
		register(ent, instance)

		e1.Elastics[index] = ent
		e2.Elastics[index] = ent
	end
end

--- Ropes two entities
-- @server
function constraint_library.rope(index, e1, e2, bone1, bone2, v1, v2, length, addlength, force_lim, width, material, rigid)
	plyCount:checkuse(instance.player, 1)

	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)
	local vec1 = vunwrap(v1)
	local vec2 = vunwrap(v2)

	checkConstraint(ent1, "constraints.rope")
	checkConstraint(ent2, "constraints.rope")


	bone1 = bone1 or 0
	bone2 = bone2 or 0
	length = length or 0
	addlength = addlength or 0
	force_lim = force_lim or 0
	width = width or 0
	rigid = rigid and true or false

	checkluatype(bone1, TYPE_NUMBER)
	checkluatype(bone2, TYPE_NUMBER)
	checkluatype(length, TYPE_NUMBER)
	checkluatype(addlength, TYPE_NUMBER)
	checkluatype(force_lim, TYPE_NUMBER)
	checkluatype(width, TYPE_NUMBER)

	e1.Ropes = e1.Ropes or {}
	e2.Ropes = e2.Ropes or {}

	local ent = constraint.Rope(ent1, ent2, bone1, bone2, vec1, vec2, length, addlength, force_lim, math.Clamp(width, 0, 50), material, rigid)
	if ent then
		register(ent, instance)

		e1.Ropes[index] = ent
		e2.Ropes[index] = ent
	end
end

--- Sliders two entities
-- @server
function constraint_library.slider(e1, e2, bone1, bone2, v1, v2, width)

	plyCount:checkuse(instance.player, 1)

	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)
	local vec1 = vunwrap(v1)
	local vec2 = vunwrap(v2)

	checkConstraint(ent1, "constraints.slider")
	checkConstraint(ent2, "constraints.slider")

	bone1 = bone1 or 0
	bone2 = bone2 or 0
	width = width or 0

	checkluatype(bone1, TYPE_NUMBER)
	checkluatype(bone2, TYPE_NUMBER)
	checkluatype(width, TYPE_NUMBER)

	local ent = constraint.Slider(ent1, ent2, bone1, bone2, vec1, vec2, math.Clamp(width, 0, 50), "cable/cable2")
	if ent then
		register(ent, instance)
	end
end

--- Nocollides two entities
-- @server
function constraint_library.nocollide(e1, e2, bone1, bone2)

	plyCount:checkuse(instance.player, 1)

	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)

	checkConstraint(ent1, "constraints.nocollide")
	checkConstraint(ent2, "constraints.nocollide")

	bone1 = bone1 or 0
	bone2 = bone2 or 0

	checkluatype(bone1, TYPE_NUMBER)
	checkluatype(bone2, TYPE_NUMBER)

	local ent = constraint.NoCollide(ent1, ent2, bone1, bone2)
	if ent then
		register(ent, instance)
	end
end

--- Sets the length of a rope attached to the entity
-- @server
function constraint_library.setRopeLength(index, e, length)
	local ent1 = getent(e)

	checkpermission(instance, ent1, "constraints.rope")

	checkluatype(length, TYPE_NUMBER)
	length = math.max(length, 0)


	if e.Ropes then
		local con = e.Ropes[index]
		if (con and con:IsValid()) then
			con:SetKeyValue("addlength", length)
		end
	end
end

--- Sets the length of an elastic attached to the entity
-- @server
function constraint_library.setElasticLength(index, e, length)
	local ent1 = getent(e)

	checkpermission(instance, ent1, "constraints.elastic")

	checkluatype(length, TYPE_NUMBER)
	length = math.max(length, 0)

	if e.Elastics then
		local con = e.Elastics[index]
		if (con and con:IsValid()) then
			con:Fire("SetSpringLength", length, 0)
		end
	end
end

--- Breaks all constraints on an entity
-- @server
function constraint_library.breakAll(e)
	local ent1 = getent(e)
	checkpermission(instance, ent1, "constraints.any")

	constraint.RemoveAll(ent1)
end

--- Breaks all constraints of a certain type on an entity
-- @server
function constraint_library.breakType(e, typename)
	checkluatype(typename, TYPE_STRING)

	local ent1 = getent(e)

	checkpermission(instance, ent1, "constraints.any")

	constraint.RemoveConstraints(ent1, typename)
end


--- Returns the table of constraints on an entity
-- @param ent The entity
-- @return Table of entity constraints
function constraint_library.getTable(ent)
	return instance.Sanitize(constraint.GetTable(getent(ent)))
end

--- Sets whether the chip should remove created constraints when the chip is removed
-- @param on Boolean whether the constraints should be cleaned or not
function constraint_library.setConstraintClean(on)
	instance.data.constraints.clean = on
end

--- Checks how many constraints can be spawned
-- @server
-- @return number of constraints able to be spawned
function constraint_library.constraintsLeft()
	return plyCount:check(instance.player)
end

end
