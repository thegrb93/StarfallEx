
--- Library for creating and manipulating constraints.
-- @server
local constraint_library = SF.Libraries.Register("constraint")

local vwrap = SF.WrapObject
local vunwrap = SF.UnwrapObject
local ewrap, eunwrap, ents_metatable

SF.Libraries.AddHook("postload", function()
	ewrap = SF.Entities.Wrap
	eunwrap = SF.Entities.Unwrap
	ents_metatable = SF.Entities.Metatable
end)

local function checkConstraint(e, t)
	if e then
		if e:IsValid() then
			SF.Permissions.check(SF.instance.player, e, t)
		elseif not e:IsWorld() then
			SF.Throw("Invalid Entity", 3)
		end
	else
		SF.Throw("Invalid Entity", 3)
	end
end

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("constraints.weld", "Weld", "Allows the user to weld two entities", { ["CanTool"] = {} })
	P.registerPrivilege("constraints.axis", "Axis", "Allows the user to axis two entities", { ["CanTool"] = {} })
	P.registerPrivilege("constraints.ballsocket", "Ballsocket", "Allows the user to ballsocket two entities", { ["CanTool"] = {} })
	P.registerPrivilege("constraints.ballsocketadv", "BallsocketAdv", "Allows the user to advanced ballsocket two entities", { ["CanTool"] = {} })
	P.registerPrivilege("constraints.slider", "Slider", "Allows the user to slider two entities", { ["CanTool"] = {} })
	P.registerPrivilege("constraints.rope", "Rope", "Allows the user to rope two entities", { ["CanTool"] = {} })
	P.registerPrivilege("constraints.elastic", "Elastic", "Allows the user to elastic two entities", { ["CanTool"] = {} })
	P.registerPrivilege("constraints.nocollide", "Nocollide", "Allows the user to nocollide two entities", { ["CanTool"] = {} })
	P.registerPrivilege("constraints.any", "Any", "General constraint functions", { ["CanTool"] = {} })
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
	SF.CheckType(e1, ents_metatable)
	SF.CheckType(e2, ents_metatable)
	
	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)
	
	checkConstraint(ent1, "constraints.weld")
	checkConstraint(ent2, "constraints.weld")

	bone1 = bone1 or 0
	bone2 = bone2 or 0
	force_lim = force_lim or 0
	nocollide = nocollide and true or false
	
	SF.CheckLuaType(bone1, TYPE_NUMBER)
	SF.CheckLuaType(bone2, TYPE_NUMBER)
	SF.CheckLuaType(force_lim, TYPE_NUMBER)
	
	constraint.Weld(ent1, ent2, bone1, bone2, force_lim, nocollide)
end

--- Axis two entities
-- @server
function constraint_library.axis(e1, e2, bone1, bone2, v1, v2, force_lim, torque_lim, friction, nocollide, laxis)
	SF.CheckType(e1, ents_metatable)
	SF.CheckType(e2, ents_metatable)
	SF.CheckType(v1, SF.Types["Vector"])
	SF.CheckType(v2, SF.Types["Vector"])
	
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
	
	SF.CheckLuaType(bone1, TYPE_NUMBER)
	SF.CheckLuaType(bone2, TYPE_NUMBER)
	SF.CheckLuaType(force_lim, TYPE_NUMBER)
	SF.CheckLuaType(torque_lim, TYPE_NUMBER)
	SF.CheckLuaType(friction, TYPE_NUMBER)
	
	constraint.Axis(ent1, ent2, bone1, bone2, vec1, vec2, force_lim, torque_lim, friction, nocollide, axis)
end

--- Ballsocket two entities
-- @server
function constraint_library.ballsocket(e1, e2, bone1, bone2, v1, force_lim, torque_lim, nocollide)
	SF.CheckType(e1, ents_metatable)
	SF.CheckType(e2, ents_metatable)
	SF.CheckType(v1, SF.Types["Vector"])
	
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
	
	SF.CheckLuaType(bone1, TYPE_NUMBER)
	SF.CheckLuaType(bone2, TYPE_NUMBER)
	SF.CheckLuaType(force_lim, TYPE_NUMBER)
	SF.CheckLuaType(torque_lim, TYPE_NUMBER)
	
	constraint.Ballsocket(ent1, ent2, bone1, bone2, vec1, force_lim, torque_lim, nocollide)
end

--- Advanced Ballsocket two entities
-- @server
function constraint_library.ballsocketadv(e1, e2, bone1, bone2, v1, v2, force_lim, torque_lim, minv, maxv, frictionv, rotateonly, nocollide)
	SF.CheckType(e1, ents_metatable)
	SF.CheckType(e2, ents_metatable)
	SF.CheckType(v1, SF.Types["Vector"])
	SF.CheckType(v2, SF.Types["Vector"])
	SF.CheckType(minv, SF.Types["Vector"])
	SF.CheckType(maxv, SF.Types["Vector"])
	SF.CheckType(frictionv, SF.Types["Vector"])
	
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
	
	SF.CheckLuaType(bone1, TYPE_NUMBER)
	SF.CheckLuaType(bone2, TYPE_NUMBER)
	SF.CheckLuaType(force_lim, TYPE_NUMBER)
	SF.CheckLuaType(torque_lim, TYPE_NUMBER)
	
	constraint.AdvBallsocket(ent1, ent2, bone1, bone2, vec1, vec2, force_lim, torque_lim, mins.x, mins.y, mins.z, maxs.x, maxs.y, maxs.z, frictions.x, frictions.y, frictions.z, rotateonly, nocollide)
end

--- Elastic two entities
-- @server 
function constraint_library.elastic(index, e1, e2, bone1, bone2, v1, v2, const, damp, rdamp, width, strech)
	SF.CheckType(e1, ents_metatable)
	SF.CheckType(e2, ents_metatable)
	SF.CheckType(v1, SF.Types["Vector"])
	SF.CheckType(v2, SF.Types["Vector"])
	
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
	
	SF.CheckLuaType(bone1, TYPE_NUMBER)
	SF.CheckLuaType(bone2, TYPE_NUMBER)
	SF.CheckLuaType(const, TYPE_NUMBER)
	SF.CheckLuaType(damp, TYPE_NUMBER)
	SF.CheckLuaType(rdamp, TYPE_NUMBER)
	SF.CheckLuaType(width, TYPE_NUMBER)
	
	e1.Elastics = e1.Elastics or {}
	e2.Elastics = e2.Elastics or {}
	
	local e = constraint.Elastic(ent1, ent2, bone1, bone2, vec1, vec2, const, damp, rdamp, "cable/cable2", math.Clamp(width, 0, 50), strech)
	
	e1.Elastics[index] = e
	e2.Elastics[index] = e
end

--- Ropes two entities
-- @server 
function constraint_library.rope(index, e1, e2, bone1, bone2, v1, v2, length, addlength, force_lim, width, material, rigid)
	SF.CheckType(e1, ents_metatable)
	SF.CheckType(e2, ents_metatable)
	SF.CheckType(v1, SF.Types["Vector"])
	SF.CheckType(v2, SF.Types["Vector"])
	
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
	
	SF.CheckLuaType(bone1, TYPE_NUMBER)
	SF.CheckLuaType(bone2, TYPE_NUMBER)
	SF.CheckLuaType(length, TYPE_NUMBER)
	SF.CheckLuaType(addlength, TYPE_NUMBER)
	SF.CheckLuaType(force_lim, TYPE_NUMBER)
	SF.CheckLuaType(width, TYPE_NUMBER)
	
	e1.Ropes = e1.Ropes or {}
	e2.Ropes = e2.Ropes or {}
	
	local e = constraint.Rope(ent1, ent2, bone1, bone2, vec1, vec2, length, addlength, force_lim, math.Clamp(width, 0, 50), material, rigid)
	
	e1.Ropes[index] = e
	e2.Ropes[index] = e
end

--- Sliders two entities
-- @server 
function constraint_library.slider(e1, e2, bone1, bone2, v1, v2, width)
	SF.CheckType(e1, ents_metatable)
	SF.CheckType(e2, ents_metatable)
	SF.CheckType(v1, SF.Types["Vector"])
	SF.CheckType(v2, SF.Types["Vector"])
	
	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)
	local vec1 = vunwrap(v1)
	local vec2 = vunwrap(v2)
	
	checkConstraint(ent1, "constraints.slider")
	checkConstraint(ent2, "constraints.slider")
	
	bone1 = bone1 or 0
	bone2 = bone2 or 0
	width = width or 0
	
	SF.CheckLuaType(bone1, TYPE_NUMBER)
	SF.CheckLuaType(bone2, TYPE_NUMBER)
	SF.CheckLuaType(width, TYPE_NUMBER)

	constraint.Slider(ent1, ent2, bone1, bone2, vec1, vec2, math.Clamp(width, 0, 50), "cable/cable2")
end

--- Nocollides two entities
-- @server 
function constraint_library.nocollide(e1, e2, bone1, bone2)
	SF.CheckType(e1, ents_metatable)
	SF.CheckType(e2, ents_metatable)
	
	local ent1 = eunwrap(e1)
	local ent2 = eunwrap(e2)
	
	checkConstraint(ent1, "constraints.nocollide")
	checkConstraint(ent2, "constraints.nocollide")
	
	bone1 = bone1 or 0
	bone2 = bone2 or 0
	
	SF.CheckLuaType(bone1, TYPE_NUMBER)
	SF.CheckLuaType(bone2, TYPE_NUMBER)
	
	constraint.NoCollide(ent1, ent2, bone1, bone2)
end

--- Sets the length of a rope attached to the entity
-- @server 
function constraint_library.setRopeLength(index, e, length)
	SF.CheckType(e, ents_metatable)
	local ent1 = eunwrap(e)
	
	if not IsValid(ent1) then SF.Throw("Invalid entity", 2) end
	SF.Permissions.check(SF.instance.player, ent1, "constraints.rope")

	
	SF.CheckLuaType(length, TYPE_NUMBER)
	length = math.max(length, 0)

	
	if e.Ropes then
		local con = e.Ropes[index]
		if IsValid(con) then
			con:SetKeyValue("addlength", length)
		end
	end
end

--- Sets the length of an elastic attached to the entity
-- @server 
function constraint_library.setElasticLength(index, e, length)
	SF.CheckType(e, ents_metatable)
	local ent1 = eunwrap(e)
	
	if not IsValid(ent1) then SF.Throw("Invalid entity", 2) end
	SF.Permissions.check(SF.instance.player, ent1, "constraints.elastic")

	SF.CheckLuaType(length, TYPE_NUMBER)
	length = math.max(length, 0)

	if e.Elastics then
		local con = e.Elastics[index]
		if IsValid(con) then
			con:Fire("SetSpringLength", length, 0)
		end
	end
end

--- Breaks all constraints on an entity
-- @server 
function constraint_library.breakAll(e)
	SF.CheckType(e, ents_metatable)
	local ent1 = eunwrap(e)
	
	if not IsValid(ent1) then SF.Throw("Invalid entity", 2) end
	SF.Permissions.check(SF.instance.player, ent1, "constraints.any")
	
	constraint.RemoveAll(ent1)
end

--- Breaks all constraints of a certain type on an entity
-- @server 
function constraint_library.breakType(e, typename)
	SF.CheckType(e, ents_metatable)
	SF.CheckLuaType(typename, TYPE_STRING)
	
	local ent1 = eunwrap(e)
	
	if not IsValid(ent1) then SF.Throw("Invalid entity", 2) end
	SF.Permissions.check(SF.instance.player, ent1, "constraints.any")
	
	constraint.RemoveConstraints(ent1, typename)
end


--- Returns the table of constraints on an entity
-- @param ent The entity
-- @return Table of entity constraints
function constraint_library.getTable(ent)
	SF.CheckType(ent, ents_metatable)

	ent = eunwrap(ent)
	
	if not IsValid(ent) then SF.Throw("Invalid entity", 2) end
	SF.Permissions.check(SF.instance.player, ent, "constraints.any")

	return SF.Sanitize(constraint.GetTable(ent))
end
