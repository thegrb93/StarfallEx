
SF_WireLibrary = {}
local wire_module = {}

--------------------------- Serializers ---------------------------

local function identitySerializer(data) return data end
local inputSerializers =
{
	NORMAL = identitySerializer,
	STRING = identitySerializer,
	VECTOR = identitySerializer,
	ANGLE = identitySerializer,
	WIRELINK = function(wl) return nil end,
}

local outputSerializers =
{
	NORMAL = function(data)
		SF_Compiler.CheckType(data,"number",1)
		return data
	end,
	STRING = function(data)
		SF_Compiler.CheckType(data,"string",1)
		return data
	end,
	VECTOR = function(data)
		SF_Compiler.CheckType(data,"Vector",1)
		return data
	end,
	ANGLE = function(data)
		SF_Compiler.CheckType(data,"Angle",1)
		return data
	end
}

--------------------------- Basic Wire Functions ---------------------------

function wire_module.setPorts(inputs, outputs)
	inputs = SF_Compiler.CheckType(inputs or {}, "table")
	outputs = SF_Compiler.CheckType(outputs or {}, "table")
	
	local inNames = {}
	local inTypes = {}
	local outNames = {}
	local outTypes = {}
	
	local inrecord = {}
	local outrecord = {}
	
	for _,name in ipairs(inputs) do
		if type(name) ~= "string" then error("Nonstring argument in inputs array ("..(tostring(name) or "?")..").",2) end
		local inp = string.Explode(":",name)
		
		local name = string.Trim(inp[1])
		if name == "" then error("Invalid wire name in inputs array.",2) end
		if inrecord[name] then error("Duplicate input: "..name,3) end
		
		local typ
		if not inp[2] then typ = "NORMAL"
		else typ = string.Trim(inp[2]:upper()) end
		
		if not inputSerializers[typ] then error("Invalid input type: "..typ..".",2) end
		
		local index = #inNames + 1
		inNames[index] = name
		inTypes[index] = typ
		inrecord[name] = typ
	end
	
	for _,name in ipairs(outputs) do
		if type(name) ~= "string" then error("Nonstring argument in outputs array ("..(tostring(name) or "?")..").",2) end
		local inp = string.Explode(":",name)
		
		local name = string.Trim(inp[1])
		if name == "" then error("Invalid wire name in inputs array.",2) end
		if outrecord[name] then error("Duplicate output: "..name,3) end
		
		local typ
		if inp[2] == nil then typ = "NORMAL"
		else typ = string.Trim(inp[2]:upper()) end
		
		if not outputSerializers[typ] then error("Invalid output type: "..typ..".",2) end
		
		local index = #outNames + 1
		outNames[index] = name
		outTypes[index] = typ
		outrecord[name] = typ
	end
	
	SF_Compiler.currentChip.data.inputs = inrecord
	SF_Compiler.currentChip.data.outputs = outrecord
	SF_Compiler.currentChip.data.inputVals = {}
	
	WireLib.AdjustSpecialInputs(SF_Compiler.currentChip.ent, inNames, inTypes)
	WireLib.AdjustSpecialOutputs(SF_Compiler.currentChip.ent, outNames, outTypes)
end

function wire_module.getInput(name)
	SF_Compiler.CheckType(name,"string")
	if not (SF_Compiler.currentChip.ent.Inputs[name] and
	        SF_Compiler.currentChip.ent.Inputs[name].Src and
	        SF_Compiler.currentChip.ent.Inputs[name].Src:IsValid()) then
		return nil
	end
	local context = SF_Compiler.currentChip
	return inputSerializers[context.data.inputs[name]](context.ent.Inputs[name].Value)
end

function wire_module.setOutput(name, value)
	SF_Compiler.CheckType(name,"string")
	
	local context = SF_Compiler.currentChip
	if not context.data.outputs[name] then error("Output "..name.." does not exist",2) end
	
	local realvalue = outputSerializers[context.data.outputs[name]](value)
	
	Wire_TriggerOutput(context.ent, name, realvalue)
end

function wire_module.isInputWired(name)
	SF_Compiler.CheckType(name,"string")
	local context = SF_Compiler.currentChip
	if not context.data.inputs[name] then error("Input "..name.." does not exist",2) end
	return context.ent.Inputs[name].Src and context.ent.Inputs[name].Src:IsValid()
end

function wire_module.isOutputWired(name)
	SF_Compiler.CheckType(name,"string")
	local context = SF_Compiler.currentChip
	if not context.data.outputs[name] then error("Output "..name.." does not exist",2) end
	return context.ent.Outputs[name].Src and context.ent.Outputs[name].Src:IsValid()
end

--------------------------- Wirelink ---------------------------

local function getWirelink(name)
	SF_Compiler.CheckType(name,"string",1)
	local context = SF_Compiler.currentChip
	if context.data.inputs[name] ~= "WIRELINK" then error("Input "..name.." is not a wirelink", 3) end
	local wl = context.ent.Inputs[name].Value
	if wl == nil or not wl:IsValid() or not wl.extended then
		error("Wirelink "..name.." is not wired or invalid",3)
	end
	return wl
end

function wire_module.wirelinkGetOutput(wlname,outputname)
	SF_Compiler.CheckType(outputname,"string")

	local context = SF_Compiler.currentChip
	
	local wl = getWirelink(wlname)
	if not wl.Outputs[outputname] then error("Wirelink "..wlname.." does not have output "..outputname,2) end
	local value, typ = wl.Outputs[outputname].Value, wl.Outputs[outputname].Type
	
	if not inputSerializers[typ] then error("Output "..outputname.." has an incompatible type: "..typ,2) end
	return inputSerializers[typ](value)
end

function wire_module.wirelinkSetInput(wlname,inputname,value)
	SF_Compiler.CheckType(inputname,"string")
	
	local context = SF_Compiler.currentChip
	
	local wl = getWirelink(wlname)
	if not wl.Inputs[inputname] then error("Wirelink "..wlname.." does not have input "..inputname,2) end
	local typ = wl.Inputs[inputname].Type
	
	if not outputSerializers[typ] then error("Input "..inputname.." has an incompatible type: "..typ,2) end
	WireLib.TriggerInput(wl, inputname, outputSerializers[typ](value))
end

function wire_module.wirelinkIsHiSpeed(wlname)
	local wl = getWirelink(wlname)
	if wl.ReadCell or wl.WriteCell then return true else return false end
end

function wire_module.wirelinkReadCell(wlname, cell)
	SF_Compiler.CheckType(cell,"number")
	local wl = getWirelink(wlname)
	
	if not wl.ReadCell then error("Wirelink "..wlname.." has no readable hispeed memory",2) end
	local byte = wl:ReadCell(cell)
	return byte
end

function wire_module.wirelinkWriteCell(wlname, cell, value)
	SF_Compiler.CheckType(cell,"number")
	SF_Compiler.CheckType(value,"number")
	local wl = getWirelink(wlname)
	
	if not wl.WriteCell then error("Wirelink "..wlname.." has no writeable hispeed memory",2) end
	return wl:WriteCell(cell, value)
end

SF_Compiler.AddModule("wire",wire_module)

local function inputhook(ent, name, value)
	if inputSerializers[ent.Inputs[name].Type] then
		ent:RunHook("Input",name, inputSerializers[ent.Inputs[name].Type](value))
	end
end
SF_Compiler.AddInternalHook("WireInputChanged",inputhook)

--------------------------- Easy-Access Metatable ---------------------------
local wire_ports_metatable = {}

function wire_ports_metatable:__index(name)
	SF_Compiler.CheckType(name,"string")
	if not (SF_Compiler.currentChip.ent.Inputs[name] and
	        SF_Compiler.currentChip.ent.Inputs[name].Src and
	        SF_Compiler.currentChip.ent.Inputs[name].Src:IsValid()) then
		return nil
	end
	local context = SF_Compiler.currentChip
	return inputSerializers[context.data.inputs[name]](context.ent.Inputs[name].Value)
end

function wire_ports_metatable:__newindex(name,value)
	SF_Compiler.CheckType(name,"string")
	
	local context = SF_Compiler.currentChip
	if not context.data.outputs[name] then error("Output "..name.." does not exist",2) end
	
	local realvalue = outputSerializers[context.data.outputs[name]](value)
	
	Wire_TriggerOutput(context.ent, name, realvalue)
end

wire_ports_metatable.__metatable = "Ports Table"

wire_module.ports = setmetatable({},wire_ports_metatable)


--------------------------- Library Functions ---------------------------

function SF_WireLibrary.AddInputType(typename, serializer)
	inputSerializers[typename] = serializer
end

function SF_WireLibrary.AddOutputType(typename, serializer)
	outputSerializers[typename] = serializer
end