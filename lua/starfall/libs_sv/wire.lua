-------------------------------------------------------------------------------
-- Wire library.
-------------------------------------------------------------------------------

if not WireLib then return end

--- Wire library. Handles wire inputs/outputs, wirelinks, etc.
local wire_library = SF.Libraries.Register( "wire" )

SF.Libraries.AddHook( "initialize", function(instance)
	local ent = instance.data.entity
	if ent.Inputs == nil then
		WireLib.CreateInputs( ent, {} )
	end
	if ent.Outputs == nil then
		WireLib.CreateOutputs( ent, {} )
	end

	function ent:TriggerInput ( key, value )
		self:runScriptHook( "input", key, SF.Wire.InputConverters[ self.Inputs[ key ].Type ]( value ) )
	end

	function ent:ReadCell ( address )
		local tbl = self:runScriptHookForResult( "readcell", address )
		if tbl[1] then
			return tonumber( tbl[2] ) or 0
		end
		return 0
	end

	function ent:WriteCell ( address, data )
		local tbl = self:runScriptHookForResult( "writecell", address, data )
		if tbl[1] then
			return tbl[2]==nil or tbl[2]==true
		end
		return false
	end
end )

SF.Wire = {}
SF.Wire.Library = wire_library

--- Wirelink type
-- @server
local wirelink_methods, wirelink_metatable = SF.Typedef("Wirelink")
local wlwrap, wlunwrap = SF.CreateWrapper(wirelink_metatable,true,true)
local vwrap, vunwrap = SF.WrapObject, SF.UnwrapObject

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege( "wire.setOutputs", "Set outputs", "Allows the user to specify the set of outputs" )
	P.registerPrivilege( "wire.setInputs", "Set inputs", "Allows the user to specify the set of inputs" )
	P.registerPrivilege( "wire.output", "Output", "Allows the user to set the value of an output" )
	P.registerPrivilege( "wire.input", "Input", "Allows the user to read the value of an input" )
	P.registerPrivilege( "wire.wirelink", "Wirelink", "Allows the user to create a wirelink", {"CanTool"} )
	P.registerPrivilege( "wire.wirelink.read", "Wirelink Read", "Allows the user to read from wirelink" )
	P.registerPrivilege( "wire.wirelink.write", "Wirelink Write", "Allows the user to write to wirelink" )
	P.registerPrivilege( "wire.createWire", "Create Wire", "Allows the user to create a wire between two entities", {"CanTool"} )
	P.registerPrivilege( "wire.deleteWire", "Delete Wire", "Allows the user to delete a wire between two entities", {"CanTool"} )
	P.registerPrivilege( "wire.getInputs", "Get Inputs", "Allows the user to get Inputs of an entity" )
	P.registerPrivilege( "wire.getOutputs", "Get Outputs", "Allows the user to get Outputs of an entity" )
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

-- Allowed Expression2's types in tables and their short names
local expression2types = {
	n = "NORMAL",
	s = "STRING",
	v = "VECTOR",
	a = "ANGLE",
	xwl = "WIRELINK",
	e = "ENTITY",
	t = "TABLE"
}

local function convertFromExpression2(value, shortTypeName)
	local typ = expression2types[shortTypeName]
	if not typ or not SF.Wire.InputConverters[typ] then return nil end

	return SF.Wire.InputConverters[typ](value)
end

local function convertToExpression2(value)
	local typ = type(value)

	-- Simple type?
	if typ == "number" then return value, "n"
	elseif typ == "string" then return value, "s"
	elseif typ == "Vector" then return {value.x, value.y, value.z}, "v"
	elseif typ == "Angle" then return {value.p, value.y, value.r}, "a"

	-- We've got a table there. Is it wrapped object?
	elseif typ == "table" then
		local value = SF.Unsanitize(value)
		typ = type(value)

		if typ == "table" then 
			-- It is still table, do recursive convert
			return SF.Wire.OutputConverters.TABLE(value), "t"

		-- Unwrapped entity (wirelink goes to this, but it returns it as entity; don't think somebody needs to put wirelinks in table)
		elseif typ == "Entity" then return value, "e" end
	end

	-- Nothing found / unallowed type
	return nil, nil
end

local function identity(data) return data end
local inputConverters =
{
	NORMAL = identity,
	STRING = identity,
	VECTOR = vwrap,
	ANGLE = vwrap,
	WIRELINK = wlwrap,
	ENTITY = vwrap,

	TABLE = function(tbl)
		if not tbl.s or not tbl.stypes or not tbl.n or not tbl.ntypes or not tbl.size then return {} end
		if tbl.size == 0 then return {} end -- Don't waste our time
		local conv = {}

		-- Key-numeric part of table
		for key, typ in pairs(tbl.ntypes) do
			conv[key] = convertFromExpression2(tbl.n[key], typ)
		end

		-- Key-string part of table
		for key, typ in pairs(tbl.stypes) do
			conv[key] = convertFromExpression2(tbl.s[key], typ)
		end

		return conv
	end
}

local outputConverters =
{
	NORMAL = function(data)
		SF.CheckType(data,"number",1)
		return data
	end,
	NUMBER = function(data)
		SF.CheckType(data,"number",1)
		return data
	end,
	STRING = function(data)
		SF.CheckType(data,"string",1)
		return data
	end,
	VECTOR = function ( data )
		SF.CheckType( data, SF.Types[ "Vector" ], 1 )
		return vunwrap( data )
	end,
	ANGLE = function ( data )
		SF.CheckType( data, SF.Types[ "Angle" ], 1 )
		return vunwrap( data )
	end,
	ENTITY = function ( data )
		SF.CheckType( data, SF.Types[ "Entity" ] )
		return vunwrap( data )
	end,

	TABLE = function(data)
		SF.CheckType(data,"table",1)

		local tbl = {istable=true, size=0, n={}, ntypes={}, s={}, stypes={}}

		for key, value in pairs(data) do
			local value, shortType = convertToExpression2(value)

			if shortType then
				if type(key) == "string" then
					tbl.s[key] = value
					tbl.stypes[key] = shortType
					tbl.size = tbl.size+1

				elseif type(key) == "number" then
					tbl.n[key] = value
					tbl.ntypes[key] = shortType
					tbl.size = tbl.size+1
				end
			end
		end

		return tbl
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

--- Creates/Modifies wire inputs. All wire ports must begin with an uppercase
-- letter and contain only alphabetical characters.
-- @param names An array of input names. May be modified by the function.
-- @param types An array of input types. May be modified by the function.
function wire_library.adjustInputs ( names, types )
	SF.Permissions.check( SF.instance.player, nil, "wire.setInputs" )
	SF.CheckType(names,"table")
	SF.CheckType(types,"table")
	local ent = SF.instance.data.entity
	if not ent then SF.throw( "No entity to create inputs on", 2 ) end
	
	if #names ~= #types then SF.throw( "Table lengths not equal", 2 ) end
	for i=1,#names do
		local newname = names[i]
		local newtype = types[i]
		if type(newname) ~= "string" then SF.throw( "Non-string input name: " .. newname, 2 ) end
		if type(newtype) ~= "string" then SF.throw( "Non-string input type: " .. newtype, 2 ) end
		newtype = newtype:upper()
		if not newname:match( "^[%u][%a%d]*$" ) then SF.throw( "Invalid input name: " .. newname, 2 ) end
		if not inputConverters[ newtype ] then SF.throw( "Invalid/unsupported input type: " .. newtype, 2 ) end
		names[i] = newname
		types[i] = newtype
	end
	ent._inputs = {names, types}
	WireLib.AdjustSpecialInputs(ent,names,types)
end

--- Creates/Modifies wire outputs. All wire ports must begin with an uppercase
-- letter and contain only alphabetical characters.
-- @param names An array of output names. May be modified by the function.
-- @param types An array of output types. May be modified by the function.
function wire_library.adjustOutputs ( names, types )
	SF.Permissions.check( SF.instance.player, nil, "wire.setOutputs" )
	SF.CheckType(names,"table")
	SF.CheckType(types,"table")
	local ent = SF.instance.data.entity
	if not ent then SF.throw( "No entity to create outputs on", 2 ) end
	
	if #names ~= #types then SF.throw( "Table lengths not equal", 2 ) end
	for i=1,#names do
		local newname = names[i]
		local newtype = types[i]
		if type(newname) ~= "string" then SF.throw( "Non-string output name: " .. newname, 2 ) end
		if type(newtype) ~= "string" then SF.throw( "Non-string output type: " .. newtype, 2 ) end
		newtype = newtype:upper()
		if not newname:match("^[%u][%a%d]*$") then SF.throw( "Invalid output name: " .. newname, 2 ) end
		if not outputConverters[newtype] then SF.throw( "Invalid/unsupported output type: " .. newtype, 2 ) end
		names[i] = newname
		types[i] = newtype
	end
	ent._outputs = {names, types}	
	WireLib.AdjustSpecialOutputs(ent,names,types)
end

--- Returns the wirelink representing this entity.
function wire_library.self()
	local ent = SF.instance.data.entity
	if not ent then SF.throw( "No entity", 2 ) end
	return wlwrap(ent)
end

--- Returns the server's UUID.
-- @return UUID as string
function wire_library.serverUUID()
	return WireLib.GetServerUUID()
end

--- Wires two entities together
-- @param entI Entity with input
-- @param entO Entity with output
-- @param inputname Input to be wired
-- @param outputname Output to be wired
function wire_library.create ( entI, entO, inputname, outputname )
	SF.CheckType( entI, SF.Types[ "Entity" ] )
	SF.CheckType( entO, SF.Types[ "Entity" ] )
	SF.CheckType( inputname, "string" )
	SF.CheckType( outputname, "string" )
		
	local entI = SF.Entities.Unwrap( entI )
	local entO = SF.Entities.Unwrap( entO )
	
	if not IsValid( entI ) then SF.throw( "Invalid source" ) end
	if not IsValid( entO ) then SF.throw( "Invalid target" ) end
	
	SF.Permissions.check( SF.instance.player, entI, "wire.createWire" )
	SF.Permissions.check( SF.instance.player, entO, "wire.createWire" )
	
	if not entI.Inputs then SF.throw( "Source has no valid inputs" ) end
	if not entO.Outputs then SF.throw( "Target has no valid outputs" ) end
	
	if inputname == "" then SF.throw( "Invalid input name" ) end
	if outputname == "" then SF.throw( "Invalid output name" ) end
	
	if not entI.Inputs[ inputname ] then SF.throw( "Invalid source input: " .. inputname ) end
	if not entO.Outputs[ outputname ] then SF.throw( "Invalid source output: " .. outputname ) end
	if entI.Inputs[ inputname ].Src then
		local CheckInput = entI.Inputs[ inputname ]
		if CheckInput.SrcId == outputname and CheckInput.Src == entO then SF.throw( "Source \"" .. inputname .. "\" is already wired to target \"" .. outputname .. "\"" ) end
	end
		
	WireLib.Link_Start( SF.instance.player:UniqueID(), entI, entI:WorldToLocal( entI:GetPos() ), inputname, "cable/rope", Vector( 255, 255, 255 ), 0 )
	WireLib.Link_End( SF.instance.player:UniqueID(), entO, entO:WorldToLocal( entO:GetPos() ), outputname, SF.instance.player )
end

--- Unwires an entity's input
-- @param entI Entity with input
-- @param inputname Input to be un-wired
function wire_library.delete ( entI, inputname )
	SF.CheckType( entI, SF.Types[ "Entity" ] )
	SF.CheckType( inputname, "string" )
	
	local entI = SF.Entities.Unwrap( entI )
	
	if not IsValid( entI ) then SF.throw( "Invalid source" ) end
	
	SF.Permissions.check( SF.instance.player, entI, "wire.deleteWire" )
	
	if not entI.Inputs or not entI.Inputs[ inputname ] then SF.throw( "Entity does not have input: " .. inputname ) end
	if not entI.Inputs[ inputname ].Src then SF.throw( "Input \"" .. inputname .. "\" is not wired" ) end
	
	WireLib.Link_Clear( entI, inputname )
end

local function parseEntity( ent, io )
	
	if ent then
		SF.CheckType( ent, SF.Types[ "Entity" ] )
		ent = SF.Entities.Unwrap( ent )
		SF.Permissions.check( SF.instance.player, ent, "wire.get" .. io )
	else
		ent = SF.instance.data.entity or nil
	end
	
	if not IsValid( ent ) then SF.throw( "Invalid source" ) end

	local ret = {}
	for k, v in pairs( ent[ io ] ) do
		if k ~= "" then
			table.insert( ret, k )
		end
	end	

	return ret
end

--- Returns a table of entity's inputs
-- @param entI Entity with input(s)
-- @return Table of entity's inputs
function wire_library.getInputs ( entI )
	return parseEntity( entI, "Inputs" )
end

--- Returns a table of entity's outputs
-- @param entO Entity with output(s)
-- @return Table of entity's outputs
function wire_library.getOutputs ( entO )
	return parseEntity( entO, "Outputs" )
end

--- Returns a wirelink to a wire entity
-- @param ent Wire entity
-- @return Wirelink of the entity
function wire_library.getWirelink ( ent )
	SF.CheckType( ent, SF.Types[ "Entity" ] )
	ent = SF.Entities.Unwrap( ent )
	if not ent:IsValid() then return end
	SF.Permissions.check( SF.instance.player, ent, "wire.wirelink" )
	
	if not ent.extended then
		WireLib.CreateWirelinkOutput( SF.instance.player, ent, {true} )
	end
	
	return wlwrap(ent)
end

-- ------------------------- Wirelink ------------------------- --

--- Retrieves an output. Returns nil if the output doesn't exist.
wirelink_metatable.__index = function(self,k)
	SF.Permissions.check( SF.instance.player, nil, "wire.wirelink.read" )
	SF.CheckType(self,wirelink_metatable)
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
wirelink_metatable.__newindex = function(self,k,v)
	SF.Permissions.check( SF.instance.player, nil, "wire.wirelink.write" )
	SF.CheckType(self,wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl or not wl:IsValid() or not wl.extended then return end -- TODO: What is wl.extended?
	if type(k) == "number" then
		SF.CheckType(v,"number")
		if not wl.WriteCell then return
		else wl:WriteCell(k,v) end
	else
		local input = wl.Inputs and wl.Inputs[k]
		if not input or not outputConverters[input.Type] then return end
		WireLib.TriggerInput(wl,k,outputConverters[input.Type](v))
	end
end

--- Checks if a wirelink is valid. (ie. doesn't point to an invalid entity)
function wirelink_methods:isValid()
	SF.CheckType(self,wirelink_metatable)
	return wlunwrap(self) and true or false
end

--- Returns the type of input name, or nil if it doesn't exist
function wirelink_methods:inputType(name)
	SF.CheckType(self,wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return end
	local input = wl.Inputs[name]
	return input and input.Type
end

--- Returns the type of output name, or nil if it doesn't exist
function wirelink_methods:outputType(name)
	SF.CheckType(self,wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return end
	local output = wl.Outputs[name]
	return output and output.Type
end

--- Returns the entity that the wirelink represents
function wirelink_methods:entity()
	SF.CheckType(self,wirelink_metatable)
	return SF.Entities.Wrap(wlunwrap(self))
end

--- Returns a table of all of the wirelink's inputs
function wirelink_methods:inputs()
	SF.CheckType(self,wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return nil end
	local Inputs = wl.Inputs
	if not Inputs then return {} end
	
	local inputNames = {}
	for _,port in pairs(Inputs) do
		inputNames[#inputNames+1] = port.Name
	end
	
	local function portsSorter(a,b)
		return Inputs[a].Num < Inputs[b].Num
	end
	table.sort(inputNames, portsSorter)
	
	return inputNames
end

--- Returns a table of all of the wirelink's outputs
function wirelink_methods:outputs()
	SF.CheckType(self,wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return nil end
	local Outputs = wl.Outputs
	if not Outputs then return {} end
	
	local outputNames = {}
	for _,port in pairs(Outputs) do
		outputNames[#outputNames+1] = port.Name
	end
	
	local function portsSorter(a,b)
		return Outputs[a].Num < Outputs[b].Num
	end
	table.sort(outputNames, portsSorter)
	
	return outputNames
end

--- Checks if an input is wired.
-- @param name Name of the input to check
function wirelink_methods:isWired(name)
	SF.CheckType(self,wirelink_metatable)
	SF.CheckType(name,"string")
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
	SF.CheckType(self,wirelink_metatable)
	SF.CheckType(name,"string")
	local wl = wlunwrap(self)
	if not wl then return nil end
	local input = wl.Inputs[name]
	if input and input.Src and input.Src:IsValid() then
		return SF.Entities.Wrap( input.Src )
	end
end

--- Returns the name of the output an input of the wirelink is wired to.
-- @param name Name of the input of the wirelink.
-- @return String name of the output that the input is wired to.
function wirelink_methods:getWiredToName(name)
	SF.CheckType(self,wirelink_metatable)
	SF.CheckType(name,"string")
	local wl = wlunwrap(self)
	if not wl then return nil end
	local input = wl.Inputs[name]
	if input and input.Src and input.Src:IsValid() then
		return input.SrcId
	end
end

-- ------------------------- Ports Metatable ------------------------- --
local wire_ports_methods, wire_ports_metamethods = SF.Typedef("Ports")

function wire_ports_metamethods:__index ( name )
	SF.Permissions.check( SF.instance.player, nil, "wire.input" )
	SF.CheckType(name,"string")
	local instance = SF.instance
	local ent = instance.data.entity
	if not ent then SF.throw( "No entity", 2 ) end

	local input = ent.Inputs[name]
	if not (input and input.Src and input.Src:IsValid()) then
		return nil
	end
	return inputConverters[ent.Inputs[name].Type](ent.Inputs[name].Value)
end

function wire_ports_metamethods:__newindex ( name, value )
	SF.Permissions.check( SF.instance.player, nil, "wire.output" )
	SF.CheckType(name,"string")
	local instance = SF.instance
	local ent = instance.data.entity
	if not ent then SF.throw( "No entity", 2 ) end

	local output = ent.Outputs[name]
	if not output then return end
	
	Wire_TriggerOutput(ent, name, outputConverters[output.Type](value))
end

--- Ports table. Reads from this table will read from the wire input
-- of the same name. Writes will write to the wire output of the same name.
-- @class table
-- @name wire_library.ports
wire_library.ports = setmetatable({},wire_ports_metamethods)

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
