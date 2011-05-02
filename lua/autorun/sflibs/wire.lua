
local wire_module = {}

local function arrcpy(arr)
	local arr2 = {}
	for _,d in ipairs(arr) do
		arr2[d] = true
	end
	return arr2
end

--------------------------- Serializers ---------------------------

local function identitySerializer(data) return data end
local inputSerializers =
{
	NORMAL = identitySerializer,
	STRING = identitySerializer,
	VECTOR = identitySerializer,
	WIRELINK = function(wl) return nil end,
}

local outputSerializers =
{
	NORMAL = function(data)
		if data == nil or type(data) ~= "number" then error("Tried to output non-number to number output.",3) end
		return data
	end,
	STRING = function(data)
		if data == nil or type(data) ~= "string" then error("Tried to output non-string to string output.",3) end
		return data
	end,
	VECTOR = function(data)
		if type(data) ~= "Vector" then error("Tried to output non-vector to vector output.",3) end
		return data
	end
}

--------------------------- Basic Wire Functions ---------------------------

function wire_module.setPorts(inputs, outputs)
	if inputs == nil then inputs = {} end
	if outputs == nil then outputs = {} end
	
	local inNames = {}
	local inTypes = {}
	local outNames = {}
	local outTypes = {}
	
	local inrecord = {}
	local outrecord = {}
	
	for _,name in ipairs(inputs) do
		if type(name) ~= "string" then error("Nonstring argument in inputs array.",2) end
		local inp = string.Explode(":",name)
		
		local name = inp[1]:Trim()
		if name == "" then error("Invalid wire name in inputs array.",2) end
		if inrecord[name] then error("Duplicate input: "..name,3) end
		
		local typ
		if inp[2] == nil then typ = "NORMAL"
		else typ = inp[2]:upper():Trim() end
		
		if not inputSerializers[typ] then error("Invalid input type: "..typ..".",2) end
		
		local index = #inNames + 1
		inNames[index] = name
		inTypes[index] = typ
		inrecord[name] = typ
	end
	
	for _,name in ipairs(outputs) do
		if type(name) ~= "string" then error("Nonstring argument in inputs array.",2) end
		local inp = string.Explode(":",name)
		
		local name = inp[1]:Trim()
		if name == "" then error("Invalid wire name in inputs array.",2) end
		if inrecord[name] then error("Duplicate output: "..name,3) end
		
		local typ
		if inp[2] == nil then typ = "NORMAL"
		else typ = inp[2]:upper():Trim() end
		
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
	if name == nil or type(name) ~= "string" then error("Non-string name passed to getInput()",2) end
	if not SF_Compiler.currentChip.ent.Inputs[name] or not SF_Compiler.currentChip.ent.Inputs[name]:IsValid() then
		return nil
	end
	local context = SF_Compiler.currentChip
	return inputSerializers[context.data.inputs[name]](context.ent.Inputs[name].Value)
end

function wire_module.setOutput(name, value)
	if name == nil or type(name) ~= "string" then
		error("Nonstring name passed to setOutput.",2)
	end
	
	local context = SF_Compiler.currentChip
	if not context.data.outputs[name] then return false end
	
	local realvalue = outputSerializers[context.data.outputs[name]](value)
	
	Wire_TriggerOutput(context.ent, name, realvalue)
	return true
end

function wire_module.isInputWired(name)
	if name == nil or type(name) ~= "string" then error("Non-string passed to isInputWired",2) end
	local context = SF_Compiler.currentChip
	if not context.data.inputs[name] then error("Input "..name.." does not exist",2) end
	return context.ent.Inputs[name].Src and context.ent.Inputs[name].Src:IsValid()
end

function wire_module.isOutputWired(name)
	if name == nil or type(name) ~= "string" then error("Non-string passed to isOutputWired",2) end
	local context = SF_Compiler.currentChip
	if not context.data.outputs[name] then error("Output "..name.." does not exist",2) end
	return context.ent.Outputs[name].Src and context.ent.Outputs[name].Src:IsValid()
end

--------------------------- Wirelink ---------------------------

local function getWirelink(name)
	if type(name) ~= "string" then error("Passed non-string argument for input name",3) end
	local context = SF_Compiler.currentChip
	if context.data.inputs[name] ~= "WIRELINK" then error("Input "..name.." is not a wirelink", 3) end
	local wl = context.ent.Inputs[name].Value
	if wl == nil or not wl:IsValid() or not wl.extended then
		error("Wirelink "..name.." is not wired or invalid",3)
	end
	return wl
end

function wire_module.wirelinkGetOutput(wlname,outputname)
	if outputname == nil or type(outputname) ~= "string" then error("Non-string passed to wirelinkGetOutput",2) end
	
	local context = SF_Compiler.currentChip
	
	local wl = getWirelink(wlname)
	if not wl.Outputs[outputname] then error("Wirelink "..wlname.." does not have output "..outputname,2) end
	local value, typ = wl.Outputs[outputname].Value, wl.Outputs[outputname].Type
	
	if not inputSerializers[typ] then error("Output "..outputname.." has an incompatible type: "..typ,2) end
	return inputSerializers[typ](value)
end

function wire_module.wirelinkSetInput(wlname,inputname,value)
	if outputname == nil or type(outputname) ~= "string" then error("Non-string passed to wirelinkSetInput",2) end
	
	local context = SF_Compiler.currentChip
	
	local wl = getWirelink(wlname)
	if not wl.Inputs[inputname] then error("Wirelink "..wlname.." does not have input "..inputname,2) end
	
	if not outputSerializers[typ] then error("Output "..outputname.." has an incompatible type: "..typ,2) end
	WireLib.TriggerInput(wl, inputname, outputSerializers[typ](value))
end

function wire_module.wirelinkIsHiSpeed(wlname)
	local wl = getWirelink(wlname)
	if wl.ReadCell or wl.WriteCell then return true else return false end
end

function wire_module.wirelinkReadCell(wlname, cell)
	if type(cell) ~= "number" then error("Passed non-number cell argument to wirelinkReadCell",2) end
	local wl = getWirelink(wlname)
	
	if not wl.ReadCell then error("Wirelink "..wlname.." has no readable hispeed memory",2) end
	local byte = wl:ReadCell(cell)
	return byte
end

function wire_module.wirelinkWriteCell(wlname, cell, value)
	if type(cell) ~= "number" then error("Passed non-number cell argument to wirelinkWriteCell",2) end
	if type(value) ~= "number" then error("Passed non-number value argument to wirelinkWriteCell",2) end
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