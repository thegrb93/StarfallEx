-------------------------------------------------------------------------------
-- Wire library.
-------------------------------------------------------------------------------

if not WireLib then return end

--- Wire library. Handles wire inputs/outputs, wirelinks, etc.
local wire_library = SF.RegisterLibrary("wire")

SF.AddHook("initialize", function(instance)
	local ent = instance.data.entity
	if ent.Inputs == nil then
		WireLib.CreateInputs(ent, {})
	end
	if ent.Outputs == nil then
		WireLib.CreateOutputs(ent, {})
	end

	function ent:TriggerInput (key, value)
		if self.instance then
			self.instance:runScriptHook("input", key, SF.Wire.InputConverters[self.Inputs[key].Type](value))
		end
	end

	function ent:ReadCell (address)
		if self.instance then
			local tbl = self.instance:runScriptHookForResult("readcell", address)
			if tbl[1] then
				return tonumber(tbl[2]) or 0
			end
		end
		return 0
	end

	function ent:WriteCell (address, data)
		if self.instance then
			local tbl = self.instance:runScriptHookForResult("writecell", address, data)
			if tbl[1] then
				return tbl[2]==nil or tbl[2]==true
			end
		end
		return false
	end
end)

SF.AddHook("postload", function()
	--- Returns an entities wirelink
	-- @return Wirelink of the entity
	SF.Entities.Methods.getWirelink = wire_library.getWirelink
end)

SF.Wire = {}
SF.Wire.Library = wire_library

--- Wirelink type
-- @server
local wirelink_methods, wirelink_metatable = SF.RegisterType("Wirelink")
local wlwrap, wlunwrap = SF.CreateWrapper(wirelink_metatable, true, true)
local vwrap, awrap = SF.Vectors.Wrap, SF.Angles.Wrap
local vunwrap, aunwrap = SF.Vectors.Unwrap, SF.Angles.Unwrap
local ewrap, eunwrap = SF.WrapObject, SF.Entities.Unwrap
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local COLOR_WHITE = Color(255, 255, 255)
-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("wire.setOutputs", "Set outputs", "Allows the user to specify the set of outputs")
	P.registerPrivilege("wire.setInputs", "Set inputs", "Allows the user to specify the set of inputs")
	P.registerPrivilege("wire.output", "Output", "Allows the user to set the value of an output")
	P.registerPrivilege("wire.input", "Input", "Allows the user to read the value of an input")
	P.registerPrivilege("wire.wirelink", "Wirelink", "Allows the user to create a wirelink", { entities = {} })
	P.registerPrivilege("wire.wirelink.read", "Wirelink Read", "Allows the user to read from wirelink")
	P.registerPrivilege("wire.wirelink.write", "Wirelink Write", "Allows the user to write to wirelink")
	P.registerPrivilege("wire.createWire", "Create Wire", "Allows the user to create a wire between two entities", { entities = {} })
	P.registerPrivilege("wire.deleteWire", "Delete Wire", "Allows the user to delete a wire between two entities", { entities = {} })
	P.registerPrivilege("wire.getInputs", "Get Inputs", "Allows the user to get Inputs of an entity")
	P.registerPrivilege("wire.getOutputs", "Get Outputs", "Allows the user to get Outputs of an entity")
end

---
-- @class table
-- @name SF.Wire.WlMetatable
SF.Wire.WlMetatable = wirelink_metatable
SF.Wire.WlMethods = wirelink_methods

---
-- @class function
-- @name SF.Wire.WlWrap
-- @param wirelink
SF.Wire.WlWrap = wlwrap

---
-- @class function
-- @name SF.Wire.WlUnwrap
-- @param wrapped
SF.Wire.WlUnwrap = wlunwrap

-- ------------------------- Internal Library ------------------------- --

local function identity(data) return data end
local typeToE2Type = {
	[TYPE_NUMBER] = {identity, "n"},
	[TYPE_STRING] = {identity, "s"},
	[TYPE_VECTOR] = {function(x) return {x.x, x.y, x.z} end, "v"},
	[TYPE_ANGLE] = {function(x) return {x.p, x.y, x.r} end, "a"},
	[TYPE_ENTITY] = {identity, "e"}
}

local inputConverters =
{
	NORMAL = identity,
	STRING = identity,
	VECTOR = vwrap,
	ANGLE = awrap,
	WIRELINK = wlwrap,
	ENTITY = ewrap,

	TABLE = function(data)
		local completed_tables = {}
		local function recursiveConvert(tbl)
			if not tbl.s or not tbl.stypes or not tbl.n or not tbl.ntypes or not tbl.size then return {} end
			if tbl.size == 0 then return {} end
			local conv = {}
			completed_tables[tbl] = conv

			-- Key-numeric part of table
			for key, typ in pairs(tbl.ntypes) do
				local val = tbl.n[key]
				if typ=="t" then
					conv[key] = completed_tables[val] or recursiveConvert(val)
				else
					conv[key] = SF.Wire.InputConverters[typ] and SF.Wire.InputConverters[typ](val)
				end
			end

			-- Key-string part of table
			for key, typ in pairs(tbl.stypes) do
				local val = tbl.s[key]
				if typ=="t" then
					conv[key] = completed_tables[val] or recursiveConvert(val)
				else
					conv[key] = SF.Wire.InputConverters[typ] and SF.Wire.InputConverters[typ](val)
				end
			end

			return conv
		end
		return recursiveConvert(data)
	end,
	ARRAY = function(tbl)
		local ret = {}
		for i, v in ipairs(tbl) do
			ret[i] = SF.WrapObject(v)
		end
		return ret
	end
}
inputConverters.n = inputConverters.NORMAL
inputConverters.s = inputConverters.STRING
inputConverters.v = inputConverters.VECTOR
inputConverters.a = inputConverters.ANGLE
inputConverters.xwl = inputConverters.WIRELINK
inputConverters.e = inputConverters.ENTITY
inputConverters.t = inputConverters.TABLE
inputConverters.r = inputConverters.ARRAY

local outputConverters =
{
	NORMAL = function(data)
		checkluatype(data, TYPE_NUMBER, 1)
		return data
	end,
	STRING = function(data)
		checkluatype(data, TYPE_STRING, 1)
		return data
	end,
	VECTOR = function(data)
		checktype(data, SF.Types["Vector"], 1)
		return vunwrap(data)
	end,
	ANGLE = function(data)
		checktype(data, SF.Types["Angle"], 1)
		return aunwrap(data)
	end,
	ENTITY = function(data)
		checktype(data, SF.Types["Entity"], 1)
		return eunwrap(data)
	end,
	TABLE = function(data)
		checkluatype(data, TYPE_TABLE, 1)
		local completed_tables = {}

		local function recursiveConvert(tbl)
			local ret = { istable = true, size = 0, n = {}, ntypes = {}, s = {}, stypes = {} }
			completed_tables[tbl] = ret
			for key, value in pairs(tbl) do

				local ktyp = TypeID(key)
				local valueList, typeList
				if ktyp == TYPE_NUMBER then
					valueList, typeList = ret.n, ret.ntypes
				elseif ktyp == TYPE_STRING then
					valueList, typeList = ret.s, ret.stypes
				else
					continue
				end

				value = SF.UnwrapObject(value) or value
				local vtyp = TypeID(value)
				local convert = typeToE2Type[vtyp]

				if convert then
					valueList[key] = convert[1](value)
					typeList[key] = convert[2]
					ret.size = ret.size + 1
				elseif vtyp == TYPE_TABLE then
					valueList[key] = completed_tables[value] or recursiveConvert(value)
					typeList[key] = "t"
					ret.size = ret.size + 1
				end
			end

			return ret
		end
		return recursiveConvert(data)
	end,
	ARRAY = function(data)
		local ret = {}
		for i, v in ipairs(data) do
			local obj = SF.UnwrapObject(v)
			if obj then
				local typ = typeToE2Type[TypeID(obj)]
				ret[i] = typ and typ[1](obj)
			end
		end
		return ret
	end
}

SF.Wire.InputConverters = inputConverters
SF.Wire.OutputConverters = outputConverters

--- Adds an input type
-- @param name Input type name. Case insensitive.
-- @param converter The function used to convert the wire data to SF data (eg, wrapping)
function SF.Wire.AddInputType(name, converter)
	inputConverters[name:upper()] = converter
end

--- Adds an output type
-- @param name Output type name. Case insensitive.
-- @param deconverter The function used to check for the appropriate type and convert the SF data to wire data (eg, unwrapping)
function SF.Wire.AddOutputType(name, deconverter)
	outputConverters[name:upper()] = deconverter
end

-- ------------------------- Basic Wire Functions ------------------------- --

local sfTypeToWireTypeTable = {
	N = "NORMAL",
	S = "STRING",
	V = "VECTOR",
	A = "ANGLE",
	XWL = "WIRELINK",
	E = "ENTITY",
	T = "TABLE",
	NUMBER = "NORMAL"
}

--- Creates/Modifies wire inputs. All wire ports must begin with an uppercase
-- letter and contain only alphabetical characters.
-- @param names An array of input names. May be modified by the function.
-- @param types An array of input types. Can be shortcuts. May be modified by the function.
function wire_library.adjustInputs (names, types)
	checkpermission(SF.instance, nil, "wire.setInputs")
	checkluatype(names, TYPE_TABLE)
	checkluatype(types, TYPE_TABLE)
	local ent = SF.instance.data.entity
	if not ent then SF.Throw("No entity to create inputs on", 2) end

	if #names ~= #types then SF.Throw("Table lengths not equal", 2) end
	for i = 1, #names do
		local newname = names[i]
		local newtype = types[i]
		if type(newname) ~= "string" then SF.Throw("Non-string input name: " .. newname, 2) end
		if type(newtype) ~= "string" then SF.Throw("Non-string input type: " .. newtype, 2) end
		newtype = newtype:upper()
		newtype = sfTypeToWireTypeTable[newtype] or newtype
		if not newname:match("^[%u][%a%d_]*$") then SF.Throw("Invalid input name: " .. newname, 2) end
		if not inputConverters[newtype] then SF.Throw("Invalid/unsupported input type: " .. newtype, 2) end
		names[i] = newname
		types[i] = newtype
	end
	ent._inputs = { names, types }
	WireLib.AdjustSpecialInputs(ent, names, types)
end

--- Creates/Modifies wire outputs. All wire ports must begin with an uppercase
-- letter and contain only alphabetical characters.
-- @param names An array of output names. May be modified by the function.
-- @param types An array of output types. Can be shortcuts. May be modified by the function.
function wire_library.adjustOutputs (names, types)
	checkpermission(SF.instance, nil, "wire.setOutputs")
	checkluatype(names, TYPE_TABLE)
	checkluatype(types, TYPE_TABLE)
	local ent = SF.instance.data.entity
	if not ent then SF.Throw("No entity to create outputs on", 2) end

	if #names ~= #types then SF.Throw("Table lengths not equal", 2) end
	for i = 1, #names do
		local newname = names[i]
		local newtype = types[i]
		if type(newname) ~= "string" then SF.Throw("Non-string output name: " .. newname, 2) end
		if type(newtype) ~= "string" then SF.Throw("Non-string output type: " .. newtype, 2) end
		newtype = newtype:upper()
		newtype = sfTypeToWireTypeTable[newtype] or newtype
		if not newname:match("^[%u][%a%d_]*$") then SF.Throw("Invalid output name: " .. newname, 2) end
		if not outputConverters[newtype] then SF.Throw("Invalid/unsupported output type: " .. newtype, 2) end
		names[i] = newname
		types[i] = newtype
	end
	ent._outputs = { names, types }
	WireLib.AdjustSpecialOutputs(ent, names, types)
end

--- Returns the wirelink representing this entity.
function wire_library.self()
	local ent = SF.instance.data.entity
	if not ent then SF.Throw("No entity", 2) end
	return wlwrap(ent)
end

--- Returns the server's UUID.
-- @return UUID as string
function wire_library.serverUUID()
	return WireLib.GetServerUUID()
end

local ValidWireMat = { 	["cable/rope"] = true, ["cable/cable2"] = true, ["cable/xbeam"] = true, ["cable/redlaser"] = true, ["cable/blue_elec"] = true, ["cable/physbeam"] = true, ["cable/hydra"] = true, ["arrowire/arrowire"] = true, ["arrowire/arrowire2"] = true }
--- Wires two entities together
-- @param entI Entity with input
-- @param entO Entity with output
-- @param inputname Input to be wired
-- @param outputname Output to be wired
-- @param width Width of the wire(optional)
-- @param color Color of the wire(optional)
-- @param material Material of the wire(optional), Valid materials are cable/rope, cable/cable2, cable/xbeam, cable/redlaser, cable/blue_elec, cable/physbeam, cable/hydra, arrowire/arrowire, arrowire/arrowire2
function wire_library.create (entI, entO, inputname, outputname, width, color, material)
	checktype(entI, SF.Types["Entity"])
	checktype(entO, SF.Types["Entity"])
	checkluatype(inputname, TYPE_STRING)
	checkluatype(outputname, TYPE_STRING)

	if width == nil then
		width = 0
	else
		checkluatype (width, TYPE_NUMBER)
		width = math.Clamp(width, 0, 5)
	end
	if color ~= nil then
		checktype(color, SF.Types['Color'])
	else
		color = COLOR_WHITE
	end
	material = ValidWireMat[material] and material or "cable/rope"

	local entI = eunwrap(entI)
	local entO = eunwrap(entO)

	if not IsValid(entI) then SF.Throw("Invalid source") end
	if not IsValid(entO) then SF.Throw("Invalid target") end

	checkpermission(SF.instance, entI, "wire.createWire")
	checkpermission(SF.instance, entO, "wire.createWire")

	if not entI.Inputs then SF.Throw("Source has no valid inputs") end
	if not entO.Outputs then SF.Throw("Target has no valid outputs") end

	if inputname == "" then SF.Throw("Invalid input name") end
	if outputname == "" then SF.Throw("Invalid output name") end

	if not entI.Inputs[inputname] then SF.Throw("Invalid source input: " .. inputname) end
	if not entO.Outputs[outputname] then SF.Throw("Invalid source output: " .. outputname) end
	if entI.Inputs[inputname].Src then
		local CheckInput = entI.Inputs[inputname]
		if CheckInput.SrcId == outputname and CheckInput.Src == entO then SF.Throw("Source \"" .. inputname .. "\" is already wired to target \"" .. outputname .. "\"") end
	end

	WireLib.Link_Start(SF.instance.player:UniqueID(), entI, entI:WorldToLocal(entI:GetPos()), inputname, material, color, width)
	WireLib.Link_End(SF.instance.player:UniqueID(), entO, entO:WorldToLocal(entO:GetPos()), outputname, SF.instance.player)
end

--- Unwires an entity's input
-- @param entI Entity with input
-- @param inputname Input to be un-wired
function wire_library.delete (entI, inputname)
	checktype(entI, SF.Types["Entity"])
	checkluatype(inputname, TYPE_STRING)

	local entI = eunwrap(entI)

	if not IsValid(entI) then SF.Throw("Invalid source") end

	checkpermission(SF.instance, entI, "wire.deleteWire")

	if not entI.Inputs or not entI.Inputs[inputname] then SF.Throw("Entity does not have input: " .. inputname) end
	if not entI.Inputs[inputname].Src then SF.Throw("Input \"" .. inputname .. "\" is not wired") end

	WireLib.Link_Clear(entI, inputname)
end

local function parseEntity(ent, io)

	if ent then
		checktype(ent, SF.Types["Entity"])
		ent = eunwrap(ent)
		checkpermission(SF.instance, ent, "wire.get" .. io)
	else
		ent = SF.instance.data.entity or nil
	end

	if not IsValid(ent) then SF.Throw("Invalid source") end

	local ret = {}
	for k, v in pairs(ent[io]) do
		if k ~= "" then
			table.insert(ret, k)
		end
	end

	return ret
end

--- Returns a table of entity's inputs
-- @param entI Entity with input(s)
-- @return Table of entity's inputs
function wire_library.getInputs (entI)
	return parseEntity(entI, "Inputs")
end

--- Returns a table of entity's outputs
-- @param entO Entity with output(s)
-- @return Table of entity's outputs
function wire_library.getOutputs (entO)
	return parseEntity(entO, "Outputs")
end

--- Returns a wirelink to a wire entity
-- @param ent Wire entity
-- @return Wirelink of the entity
function wire_library.getWirelink (ent)
	checktype(ent, SF.Types["Entity"])
	ent = eunwrap(ent)
	if not ent:IsValid() then return end
	checkpermission(SF.instance, ent, "wire.wirelink")

	if not ent.extended then
		WireLib.CreateWirelinkOutput(SF.instance.player, ent, { true })
	end

	return wlwrap(ent)
end

-- ------------------------- Wirelink ------------------------- --

--- Retrieves an output. Returns nil if the output doesn't exist.
wirelink_metatable.__index = function(self, k)
	checkpermission(SF.instance, nil, "wire.wirelink.read")
	checktype(self, wirelink_metatable)
	if wirelink_methods[k] then
		return wirelink_methods[k]
	else
		local wl = wlunwrap(self)
		if not wl or not wl:IsValid() or not wl.extended then return end -- TODO: What is wl.extended?

		if type(k) == "number" then
			return wl.ReadCell and wl:ReadCell(k) or nil
		else
			local output = wl.Outputs and wl.Outputs[k]
			if not output or not inputConverters[output.Type] then return end
			return inputConverters[output.Type](output.Value)
		end
	end
end

--- Writes to an input.
wirelink_metatable.__newindex = function(self, k, v)
	checkpermission(SF.instance, nil, "wire.wirelink.write")
	checktype(self, wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl or not wl:IsValid() or not wl.extended then return end -- TODO: What is wl.extended?
	if type(k) == "number" then
		checkluatype(v, TYPE_NUMBER)
		if not wl.WriteCell then return
		else wl:WriteCell(k, v) end
	else
		local input = wl.Inputs and wl.Inputs[k]
		if not input or not outputConverters[input.Type] then return end
		WireLib.TriggerInput(wl, k, outputConverters[input.Type](v))
	end
end

--- Checks if a wirelink is valid. (ie. doesn't point to an invalid entity)
function wirelink_methods:isValid()
	checktype(self, wirelink_metatable)
	return wlunwrap(self) and true or false
end

--- Returns the type of input name, or nil if it doesn't exist
function wirelink_methods:inputType(name)
	checktype(self, wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return end
	local input = wl.Inputs[name]
	return input and input.Type
end

--- Returns the type of output name, or nil if it doesn't exist
function wirelink_methods:outputType(name)
	checktype(self, wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return end
	local output = wl.Outputs[name]
	return output and output.Type
end

--- Returns the entity that the wirelink represents
function wirelink_methods:entity()
	checktype(self, wirelink_metatable)
	return ewrap(wlunwrap(self))
end

--- Returns a table of all of the wirelink's inputs
function wirelink_methods:inputs()
	checktype(self, wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return nil end
	local Inputs = wl.Inputs
	if not Inputs then return {} end

	local inputNames = {}
	for _, port in pairs(Inputs) do
		inputNames[#inputNames + 1] = port.Name
	end

	local function portsSorter(a, b)
		return Inputs[a].Num < Inputs[b].Num
	end
	table.sort(inputNames, portsSorter)

	return inputNames
end

--- Returns a table of all of the wirelink's outputs
function wirelink_methods:outputs()
	checktype(self, wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return nil end
	local Outputs = wl.Outputs
	if not Outputs then return {} end

	local outputNames = {}
	for _, port in pairs(Outputs) do
		outputNames[#outputNames + 1] = port.Name
	end

	local function portsSorter(a, b)
		return Outputs[a].Num < Outputs[b].Num
	end
	table.sort(outputNames, portsSorter)

	return outputNames
end

--- Checks if an input is wired.
-- @param name Name of the input to check
function wirelink_methods:isWired(name)
	checktype(self, wirelink_metatable)
	checkluatype(name, TYPE_STRING)
	local wl = wlunwrap(self)
	if not wl then return nil end
	local input = wl.Inputs[name]
	if input and input.Src and input.Src:IsValid() then return true
	else return false end
end

--- Returns what an input of the wirelink is wired to.
-- @param name Name of the input
-- @return The entity the wirelink is wired to
function wirelink_methods:getWiredTo(name)
	checktype(self, wirelink_metatable)
	checkluatype(name, TYPE_STRING)
	local wl = wlunwrap(self)
	if not wl then return nil end
	local input = wl.Inputs[name]
	if input and input.Src and input.Src:IsValid() then
		return ewrap(input.Src)
	end
end

--- Returns the name of the output an input of the wirelink is wired to.
-- @param name Name of the input of the wirelink.
-- @return String name of the output that the input is wired to.
function wirelink_methods:getWiredToName(name)
	checktype(self, wirelink_metatable)
	checkluatype(name, TYPE_STRING)
	local wl = wlunwrap(self)
	if not wl then return nil end
	local input = wl.Inputs[name]
	if input and input.Src and input.Src:IsValid() then
		return input.SrcId
	end
end

-- ------------------------- Ports Metatable ------------------------- --
local wire_ports_methods, wire_ports_metamethods = SF.RegisterType("Ports")

function wire_ports_metamethods:__index (name)
	checkpermission(SF.instance, nil, "wire.input")
	checkluatype(name, TYPE_STRING)

	local input = SF.instance.data.entity.Inputs[name]
	if input and input.Src and input.Src:IsValid() then
		return inputConverters[input.Type](input.Value)
	end
end

function wire_ports_metamethods:__newindex (name, value)
	checkpermission(SF.instance, nil, "wire.output")
	checkluatype(name, TYPE_STRING)

	local ent = SF.instance.data.entity
	local output = ent.Outputs[name]
	if output then
		Wire_TriggerOutput(ent, name, outputConverters[output.Type](value))
	end
end

--- Ports table. Reads from this table will read from the wire input
-- of the same name. Writes will write to the wire output of the same name.
-- @class table
-- @name wire_library.ports
wire_library.ports = setmetatable({}, wire_ports_metamethods)

-- ------------------------- Hook Documentation ------------------------- --

--- Called when an input on a wired SF chip is written to
-- @name input
-- @class hook
-- @param input The input name
-- @param value The value of the input

--- Called when a high speed device reads from a wired SF chip
-- @name readcell
-- @class hook
-- @server
-- @param address The address requested
-- @return The value read

--- Called when a high speed device writes to a wired SF chip
-- @name writecell
-- @class hook
-- @param address The address written to
-- @param data The data being written
