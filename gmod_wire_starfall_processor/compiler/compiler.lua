
local SF_Compiler = SF_Compiler or {}
SF_Compiler.__index = SF_Compiler

function SF_Compiler:Error(message, instr)
	error(message .. " at line " .. instr[2][1] .. ", char " .. instr[2][2], 0)
end

function SF_Compiler:Process(root, inputs, outputs, params)
	self.contexts = {}
	self:PushContext("do")

	self.inputs = inputs
	self.outputs = outputs
	
	self.code = ""
	Compiler["Instr" .. string.upper(root[1])](self, root)
	self:PopContext()

	-- Debug code
	if #self.contexts > 0 then
		error("SF Internal Error: Did not pop all contexts.")
	end
	
	return self.code
end

function SF_Compiler:EvaluateStatement(args, index)
	local name = string.upper(args[index + 2][1])
	local ex, tp = SF_Compiler["Instr" .. name](self, args[index + 2])
	return ex, tp
end

function SF_Compiler:Evaluate(args, index)
	local ex, tp = self:EvaluateStatement(args, index)

	if tp == "" then
		self:Error("Function has no return value (void), cannot be part of expression or assigned", args)
	end

	return ex, tp
end

-- ---------------------------------------- --
-- Context Management                       --
-- ---------------------------------------- --
function SF_Compiler:PushContext(beginning)
	local tbl = {
		vars = {},
		code = "",
		cost = 0
	}
	self.contexts[#self.contexts + 1] = tbl
	self:AddCode(beginning or "")
end

function SF_Compiler:PopContext(ending)
	ending = ending or "end"

	local tbl = self.contexts[#self.contexts]
	self.contexts[#self.contexts] = nil

	if tbl.vars[1] then
		local varsdef = "local "
		for _,var in ipairs(tbl.vars) do
			varsdef = varsdef .. var .. ", "
		end
		self:AddCode(varsdef:sub(1,varsdef:len()-2)
	end

	self:AddCode("SF_Self:IncrementCost("..tbl.cost..")\n")
	self:AddCode(tbl.code.."\n"..ending.."\n")
end

function SF_Compiler:AddCode(code)
	-- Adds code to the current context.
	-- ONLY statement instructions should call this!
	local tbl = self.contexts[#self.contexts]
	if tbl then
		tbl.code = tbl.code .. code
	else
		self.code = self.code .. code
	end
end

function SF_Compiler:IncrementCost(cost)
	local tbl = self.contexts[#self.contexts]
	tbl.cost = tbl.cost + cost
end

-- ---------------------------------------- --
-- Variable Management                      --
-- ---------------------------------------- --

function SF_Compiler:DefineVar(name, typ, instr)
	--local name, typ = args[2], args[3]
	local curcontext = self.contexts[#self.contexts]
	if curcontext[name] ~= typ then
		self:Error("Types for variable "..var.." do not match (expected "..self:GetVarType(var,instr)..", got "..tp..")",args)
	end

	curcontext[name] = typ
end

--[[TODO: Don't think we need this
function SF_Compiler:DefineGlobalVar(name, typ)
	if self.contexts[1][name] ~= typ then
		self:Error("Type mismatch for variable " .. name .. " (expected " .. self.contexts[1][name] .. ", got " .. typ)
	end

	self.contexts[1][name] = typ
end]]

function SF_Compiler:GetVarType(name, instr)
	for i = #self.contexts, 1, -1 do
		if self.contexts[i][name] then
			return self.contexts[i][name]
		end
	end

	if self.outputs[name] then return self.outputs[name] end
	if self.inputs[name] then return self.inputs[name] end

	if SFLib.functions[name] then
		return "function"
	end

	self:Error("Undefined variable (" .. name .. ")", instr)
end

-- ---------------------------------------- --
-- Instructions - Statements                --
-- ---------------------------------------- --

function SF_Compiler:InstrDECL(args)
	local typ, name, val = args[3],args[4],args[5]
	self:DefineVar(name, typ, args)

	if val then
		local ex, tp = self:Evaluate(args,3)
		if tp ~= typ then
			self:Error("Types for variable "..var.." do not match (expected "..self:GetVarType(var,args)..", got "..tp..")",args)
		end
		self:AddCode(name .. " = " .. ex)
	else
		self:AddCode(name .. " = SFLib.types[\""..typ.."\"]._zero"
	end
end

function SF_Compiler:InstrASSIGN(args)
	local var = args[3]

	local ex, tp = self:Evaluate(args,2)
	if tp ~= self:GetVarType(var, args) then
		self:Error("Types for variable "..var.." do not match (expected "..self:GetVarType(var,args)..", got "..tp..")",args)
	end
end

-- ---------------------------------------- --
-- Instructions - Expression                --
-- ---------------------------------------- --

function SF_Compiler:InstrVAR(args)
	local name = args[3]

	local typ = self:GetVarType(name)
	return self:GenerateLua_VariableReference(name), typ
end

function SF_Compiler:InstrNUM(args)
	local num = args[3]

	return num, "number"
end

function SF_Compiler:InstrSTR(args)
	local str = args[3]

	str = str:replace('"',"\\\""):replace("\n","\\n")
	str = "\""..str.."\""

	return str, "string"
end

function SF_Compiler:InstrCALL(args)
	local ex, tp = self:Evaluate(args,1)
	local instrs = args[4]

	local exprs = {}
	local tps = {}

	if tp ~= "function" then
		self:Error("Tried to call non-function value",args)
	end

	for i=1,#args[4] do
		local ex, tp = self:Evaluate(args[4], i - 2)
		tps[#tps + 1] = tp
		exprs[#exprs + 1] = ex
	end


end

-- ---------------------------------------- --
-- Lua Generation Functions                 --
-- ---------------------------------------- --

function SF_Compiler:GenerateLua_VariableReference(name)
	for i = #self.contexts, 1, -1 do
		if self.contexts[i][name] then
			return self.contexts[i][name]
		end
	end

	if self.outputs[name] then return "SF_Ent.outputs[\"" .. name .. "\"]" end
	if self.inputs[name] then return "SF_Ent.inputs[\"" .. name .. "\"]" end

	if SFLib.functions[name] then
		return "SFLib.functions[\""..name.."\"]"
	end

	error("Internal Error: Tried to generate Lua code for undefined variable \""..name.."\"! Post your code & this error at wiremod.com.")
end