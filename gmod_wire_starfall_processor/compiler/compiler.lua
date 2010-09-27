
local SF_Compiler = SF_Compiler or {}
SF_Compiler.__index = SF_Compiler

function SF_Compiler:Error(message, instr)
	error(message .. " at line " .. instr[2][1] .. ", char " .. instr[2][2], 0)
end

function SF_Compiler:Process(root, inputs, outputs, params)
	self.contexts = {}
	self:PushContext()
	
	self.inputs = inputs
	self.outputs = outputs
	
	self.code = ""
end

function SF_Compiler:AddCode(code)
	self.code = self.code .. code .. "\n"
end

function SF_Compiler:PushContext()
	local tbl = {
		vars = {},
		code = "",
		cost = 0
	}
	self.contexts[#self.contexts + 1] = tbl
end

function SF_Compiler:DefineVar(name, typ)
	local curcontext = self.contexts[#self.contexts]
	if curcontext[name] ~= typ then
		self:Error("Type mismach for variable " .. name .. " (expected " .. curcontext[name] .. ", got " .. typ)
	end
	
	curcontext[name] = typ
end

function SF_Compiler:DefineGlobalVar(name, typ)
	if self.contexts[1][name] ~= typ then
		self:Error("Type mismatch for variable " .. name .. " (expected " .. self.contexts[1][name] .. ", got " .. typ)
	end
	
	self.contexts[1][name] = typ
end

function SF_Compiler:GetVarType(name)
	for i = #self.contexts, 1, -1 do
		if self.contexts[i][name] then
			return self.contexts[i][name]
		end
	end
	
	self:Error("Undefined variable (" .. name .. ")")
end

function SF_Compiler:GenerateLua_VariableReference(name)
	for i = #self.contexts, 1, -1 do
		if self.contexts[i][name] then
			return self.contexts[i][name]
		end
	end
end