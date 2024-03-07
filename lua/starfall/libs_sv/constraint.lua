-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

-- Register privileges
registerprivilege("constraints.weld", "Weld", "Allows the user to weld two entities", { entities = {} })
registerprivilege("constraints.axis", "Axis", "Allows the user to axis two entities", { entities = {} })
registerprivilege("constraints.keepupright", "Keepupright", "Allows the user to keep an entity upright", { entities = {} })
registerprivilege("constraints.ballsocket", "Ballsocket", "Allows the user to ballsocket two entities", { entities = {} })
registerprivilege("constraints.ballsocketadv", "BallsocketAdv", "Allows the user to advanced ballsocket two entities", { entities = {} })
registerprivilege("constraints.slider", "Slider", "Allows the user to slider two entities", { entities = {} })
registerprivilege("constraints.rope", "Rope", "Allows the user to rope two entities", { entities = {} })
registerprivilege("constraints.elastic", "Elastic", "Allows the user to elastic two entities", { entities = {} })
registerprivilege("constraints.nocollide", "Nocollide", "Allows the user to nocollide two entities", { entities = {} })
registerprivilege("constraints.any", "Any", "General constraint functions", { entities = {} })

local entList = SF.EntManager("constraints", "constraints", 600, "The number of constraints allowed to spawn via Starfall")

--- Library for creating and manipulating constraints.
-- @name constraint
-- @class library
-- @libtbl constraint_library
SF.RegisterLibrary("constraint")

--- A constraint entity returned by constraint functions
-- @name Constraint
-- @class type
-- @libtbl constr_methods
-- @libtbl constr_meta
SF.RegisterType("Constraint", true, false)

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local getent
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)

local constraintsClean = true

instance:AddHook("deinitialize", function()
	entList:deinitialize(instance, constraintsClean)
end)

local constraint_library = instance.Libraries.constraint

local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local constr_methods, constr_meta, cwrap, cunwrap = instance.Types.Constraint.Methods, instance.Types.Constraint, instance.Types.Constraint.Wrap, instance.Types.Constraint.Unwrap
local vwrap, vunwrap = instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local awrap, aunwrap = instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap


--- Gets the string representation of the constraint
-- @return string String representation of the constraint
function constr_meta:__tostring()
	local ent = cunwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

local function check_constr_perms(ent)
	if ent.Ent1 and not ent.Ent1:IsWorld() then checkpermission(instance, ent.Ent1, "entities.remove", 3) end
	if ent.Ent2 and not ent.Ent2:IsWorld() then checkpermission(instance, ent.Ent2, "entities.remove", 3) end
	if ent.Ent3 and not ent.Ent3:IsWorld() then checkpermission(instance, ent.Ent3, "entities.remove", 3) end
	if ent.Ent4 and not ent.Ent4:IsWorld() then checkpermission(instance, ent.Ent4, "entities.remove", 3) end
end

--- Removes the constraint
-- @server
function constr_methods:remove()
	local ent = cunwrap(self)
	check_constr_perms(ent)
	entList:remove(instance, ent)
end

--- Removes all constraints created by the calling chip
-- @server
function constraint_library.removeAll()
	entList:clear(instance)
end

--- Returns whether the constraint is valid or not
-- @server
-- @return boolean True if valid, false if not
function constr_methods:isValid()
	return IsValid(cunwrap(self))
end

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

--- Welds two entities
-- @param Entity e1 The first entity
-- @param Entity e2 The second entity
-- @param number? bone1 Number bone of the first entity. Default 0
-- @param number? bone2 Number bone of the second entity. Default 0
-- @param number? force_lim Max force the weld can take before breaking. Default 0
-- @param boolean? nocollide Bool whether or not to nocollide the two entities. Default false
-- @return Constraint The constraint entity
-- @server
function constraint_library.weld(e1, e2, bone1, bone2, force_lim, nocollide)
	entList:checkuse(instance.player, 1)

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
		entList:register(instance, ent)
		return cwrap(ent)
	end
end

--- Axis two entities. v1 in e1's coordinates and v2 in e2's coordinates (or laxis in e1's coordinates again) define the axis
-- @param Entity e1 The first entity
-- @param Entity e2 The second entity
-- @param number? bone1 Number bone of the first entity. Default 0
-- @param number? bone2 Number bone of the second entity. Default 0
-- @param Vector v1 Position to center the axis, local to e1's space coordinates
-- @param Vector v2 The second position defining the axis, local to e2's space coordinates. The laxis may be specified instead which is local to e1's space coordinates
-- @param number? force_lim Amount of force until it breaks, 0 = Unbreakable. Default 0
-- @param number? torque_lim Amount of torque until it breaks, 0 = Unbreakable. Default 0
-- @param number? friction Friction of the constraint. Default 0
-- @param boolean? nocollide Bool whether or not to nocollide the two entities. Default false
-- @param Vector? laxis Optional second position of the constraint, same as v2 but local to e1
-- @return Constraint The constraint entity
-- @server
function constraint_library.axis(e1, e2, bone1, bone2, v1, v2, force_lim, torque_lim, friction, nocollide, laxis)
	entList:checkuse(instance.player, 1)

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
		entList:register(instance, ent)
		return cwrap(ent)
	end
end

--- Ballsocket two entities together. For more options, see constraint.ballsocketadv
-- @param Entity e1 The first entity
-- @param Entity e2 The second entity
-- @param number? bone1 Number bone of the first entity. Default 0
-- @param number? bone2 Number bone of the second entity. Default 0
-- @param Vector pos Position of the joint, relative to the second entity
-- @param number? force_lim Amount of force until it breaks, 0 = Unbreakable. Default 0
-- @param number? torque_lim Amount of torque until it breaks, 0 = Unbreakable. Default 0
-- @param boolean? nocollide Bool whether or not to nocollide the two entities. Default false
-- @return Constraint The constraint entity
-- @server
function constraint_library.ballsocket(e1, e2, bone1, bone2, pos, force_lim, torque_lim, nocollide)
	entList:checkuse(instance.player, 1)

	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)
	local vec1 = vunwrap(pos)

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
		entList:register(instance, ent)
		return cwrap(ent)
	end
end

--- Ballsocket two entities together with more options
-- @param Entity e1 The first entity
-- @param Entity e2 The second entity
-- @param number? bone1 Number bone of the first entity. Default 0
-- @param number? bone2 Number bone of the second entity. Default 0
-- @param Vector v1 Position on the first entity, in its local space coordinates
-- @param Vector v2 Position on the second entity, in its local space coordinates
-- @param number? force_lim Amount of force until it breaks, 0 = Unbreakable. Default 0
-- @param number? torque_lim Amount of torque until it breaks, 0 = Unbreakable. Default 0
-- @param Vector? minv Vector defining minimum rotation angle based on world axes. Default Vec(0)
-- @param Vector? maxv Vector defining maximum rotation angle based on world axes. Default Vec(0)
-- @param Vector? frictionv Vector defining rotational friction, local to the constraint. Default Vec(0)
-- @param boolean? rotateonly If True, ballsocket will only affect the rotation allowing for free movement, otherwise it will limit both - rotation and movement. Default false
-- @param boolean? nocollide Bool whether or not to nocollide the two entities. Default false
-- @return Constraint The constraint entity
-- @server
function constraint_library.ballsocketadv(e1, e2, bone1, bone2, v1, v2, force_lim, torque_lim, minv, maxv, frictionv, rotateonly, nocollide)
	entList:checkuse(instance.player, 1)

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
		entList:register(instance, ent)
		return cwrap(ent)
	end
end

--- Elastic constraint between two entities
-- @param number index Index of the elastic constraint
-- @param Entity e1 The first entity
-- @param Entity e2 The second entity
-- @param number? bone1 Number bone of the first entity. Default 0
-- @param number? bone2 Number bone of the second entity. Default 0
-- @param Vector v1 Position on the first entity, in its local space coordinates
-- @param Vector v2 Position on the second entity, in its local space coordinates
-- @param number? const Constant of the constraint. Default 1000
-- @param number? damp Damping of the constraint. Default 100
-- @param number? rdamp Rotational damping of the constraint. Default 0
-- @param number? width Width of the created constraint. Default 0
-- @param boolean? stretch True to mark as stretch-only. Default false
-- @return Constraint The constraint entity
-- @server
function constraint_library.elastic(index, e1, e2, bone1, bone2, v1, v2, const, damp, rdamp, width, stretch)
	entList:checkuse(instance.player, 1)

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

	local ent = constraint.Elastic(ent1, ent2, bone1, bone2, vec1, vec2, const, damp, rdamp, "cable/cable2", math.Clamp(width, 0, 50), stretch)
	if ent then
		entList:register(instance, ent)

		e1.Elastics[index] = ent
		e2.Elastics[index] = ent
		return cwrap(ent)
	end
end

--- Creates a rope between two entities
-- @param number index Index of the rope constraint
-- @param Entity e1 The first entity
-- @param Entity e2 The second entity
-- @param number? bone1 Number bone of the first entity. Default 0
-- @param number? bone2 Number bone of the second entity. Default 0
-- @param Vector v1 Position on the first entity, in its local space coordinates
-- @param Vector v2 Position on the second entity, in its local space coordinates
-- @param number? length Length of the created rope. Default 0
-- @param number? addlength Amount to add to the base length of the rope. Default 0
-- @param number? force_lim Amount of force until it breaks, 0 = Unbreakable. Default 0
-- @param number? width Width of the rope. Default 0
-- @param string? materialName Material of the rope
-- @param boolean? rigid Whether the rope is rigid. Default false
-- @param Color? color The color of the rope. Default white
-- @return Constraint The constraint entity
-- @server
function constraint_library.rope(index, e1, e2, bone1, bone2, v1, v2, length, addlength, force_lim, width, material, rigid, color)
	entList:checkuse(instance.player, 1)

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
	if color~=nil then color = instance.Types.Color.Unwrap(color) end

	checkluatype(bone1, TYPE_NUMBER)
	checkluatype(bone2, TYPE_NUMBER)
	checkluatype(length, TYPE_NUMBER)
	checkluatype(addlength, TYPE_NUMBER)
	checkluatype(force_lim, TYPE_NUMBER)
	checkluatype(width, TYPE_NUMBER)

	e1.Ropes = e1.Ropes or {}
	e2.Ropes = e2.Ropes or {}

	local ent = constraint.Rope(ent1, ent2, bone1, bone2, vec1, vec2, length, addlength, force_lim, math.Clamp(width, 0, 50), material, rigid, color)
	if ent then
		entList:register(instance, ent)

		e1.Ropes[index] = ent
		e2.Ropes[index] = ent
		return cwrap(ent)
	end
end

--- Sliders two entities
-- @param Entity e1 The first entity
-- @param Entity e2 The second entity
-- @param number? bone1 Number bone of the first entity. Default 0
-- @param number? bone2 Number bone of the second entity. Default 0
-- @param Vector v1 Position on the first entity, in its local space coordinates
-- @param Vector v2 Position on the second entity, in its local space coordinates
-- @param number? width Width of the slider. Default 0
-- @return Constraint The constraint entity
-- @server
function constraint_library.slider(e1, e2, bone1, bone2, v1, v2, width)

	entList:checkuse(instance.player, 1)

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
		entList:register(instance, ent)
		return cwrap(ent)
	end
end

--- Nocollides two entities
-- @param Entity e1 The first entity
-- @param Entity e2 The second entity
-- @param number? bone1 Number bone of the first entity. Default 0
-- @param number? bone2 Number bone of the second entity. Default 0
-- @return Constraint The constraint entity
-- @server
function constraint_library.nocollide(e1, e2, bone1, bone2)

	entList:checkuse(instance.player, 1)

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
		entList:register(instance, ent)
		return cwrap(ent)
	end
end

--- Applies a keepupright constraint on an entity
-- @param Entity e The entity
-- @param Angle ang The upright angle
-- @param number bone Number bone of the entity. Default 0
-- @param number lim The strength of the constraint. Default 5000
-- @return Constraint The constraint entity
-- @server
function constraint_library.keepupright(e, ang, bone, lim)
	entList:checkuse(instance.player, 1)

	e = eunwrap(e)
	ang = aunwrap(ang)

	checkConstraint(e, "constraints.keepupright")

	bone = bone or 0
	lim = lim or 5000

	checkluatype(bone, TYPE_NUMBER)
	checkluatype(lim, TYPE_NUMBER)

	local ent = constraint.Keepupright(e, ang, bone, lim)
	if ent then
		entList:register(instance, ent)
		return cwrap(ent)
	end
end

--- Sets the length of an elastic attached to the entity
-- @param number index Index of the elastic constraint
-- @param Entity e Entity that has the constraint
-- @param number length New length of the constraint
-- @return Constraint The constraint entity
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

--- Sets the damping of an elastic attached to the entity
-- @param number index Index of the elastic constraint
-- @param Entity e Entity that has the elastic
-- @param number damping New Damping value of the elastic
-- @return Constraint The constraint entity
-- @server
function constraint_library.setElasticDamping(index, e, damping)
	local ent1 = getent(e)

	checkpermission(instance, ent1, "constraints.elastic")

	checkluatype(damping, TYPE_NUMBER)
	damping = math.max(damping, 0)

	if e.Elastics then
		local con = e.Elastics[index]
		if (con and con:IsValid()) then
			con:Fire("SetSpringDamping", damping, 0)
		end
	end
end

--- Sets the constant of an elastic attached to the entity
-- @param number index Index of the elastic constraint
-- @param Entity e Entity that has the elastic
-- @param number constant New constant value of the elastic
-- @return Constraint The constraint entity
-- @server
function constraint_library.setElasticConstant(index, e, constant)
	local ent1 = getent(e)

	checkpermission(instance, ent1, "constraints.elastic")

	checkluatype(constant, TYPE_NUMBER)
	constant = math.max(constant, 0)

	if e.Elastics then
		local con = e.Elastics[index]
		if (con and con:IsValid()) then
			con:Fire("SetSpringConstant", constant, 0)
		end
	end
end

--- Breaks all constraints on an entity
-- @param Entity e Entity to remove the constraints from
-- @server
function constraint_library.breakAll(e)
	local ent1 = getent(e)
	checkpermission(instance, ent1, "constraints.any")

	constraint.RemoveAll(ent1)
end

--- Breaks all constraints of a certain type on an entity
-- @param Entity e Entity to be affected
-- @param string typename Name of the constraint type, ie. Weld, Elastic, NoCollide, etc.
-- @server
function constraint_library.breakType(e, typename)
	checkluatype(typename, TYPE_STRING)

	local ent1 = getent(e)

	checkpermission(instance, ent1, "constraints.any")

	constraint.RemoveConstraints(ent1, typename)
end


--- Returns the table of constraints on an entity
-- @param Entity ent The entity
-- @return table Table of tables containing constraint information
function constraint_library.getTable(ent)
	return instance.Sanitize(constraint.GetTable(getent(ent)))
end

--- Sets whether the chip should remove created constraints when the chip is removed
-- @param boolean on Whether the constraints should be cleaned or not
function constraint_library.setConstraintClean(on)
	constraintsClean = on
end

--- Checks how many constraints can be spawned
-- @server
-- @return number Number of constraints able to be spawned
function constraint_library.constraintsLeft()
	return entList:check(instance.player)
end

end
