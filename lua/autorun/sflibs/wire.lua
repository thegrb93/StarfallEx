
local wire_module = {}

local function arrcpy(arr)
	local arr2 = {}
	for _,d in ipairs(arr) do
		arr2[d] = true
	end
	return arr2
end

-- TODO: Add types argument

local valid_types = {
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
	end,
}

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
		
		if not valid_types[typ] then error("Invalid input type: "..typ..".",2) end
		
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
		
		if not valid_types[typ] then error("Invalid output type: "..typ..".",2) end
		
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
	return SF_Compiler.currentChip.data.inputVals[name]
end

function wire_module.setOutput(name, value)
	if name == nil or type(name) ~= "string" then
		error("Nonstring name passed to setOutput.",2)
	end
	
	local context = SF_Compiler.currentChip
	if not context.data.outputs[name] then return false end
	
	local realvalue = valid_types[context.data.outputs[name]](value)
	
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

SF_Compiler.AddModule("wire",wire_module)