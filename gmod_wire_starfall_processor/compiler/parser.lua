/******************************************************************************\
  Expression 2 Parser for Garry's Mod
  Andreas "Syranide" Svensson, me@syranide.com
  
  Modified for Starfall
  By Colonel Thirty Two
  initrd.gz@gmail.com
\******************************************************************************/

AddCSLuaFile("parser.lua")

--[[ Not correct

- seQuence
SeqSPace 		- "sIF qSP"
SeqCOmma 		- "sIF, qSP"

- Statements

StmtDeClare 	- "type var", "type var = sEX"
StmtASsign 		- "var = sEX"
StmtEXpr 		- "eVR"

- Expressions
ExprPRimitive	- strings, numbers, other primitive data types
ExprVaR			- "var"


]]
/******************************************************************************/

SF_Parser = {}
SF_Parser.__index = SF_Parser

function SF_Parser.Execute(...)
	-- instantiate Parser
	local instance = setmetatable({}, SF_Parser)
	
	-- and pcall the new instance's Process method.
	return pcall(SF_Parser.Process, instance, ...)
end

function SF_Parser:Error(message, token)
	if token then
		error(message .. " at line " .. token[4] .. ", char " .. token[5], 0)
	else
		error(message .. " at line " .. self.token[4] .. ", char " .. self.token[5], 0)
	end
end

function SF_Parser:Process(tokens, params)
	self.tokens = tokens
	
	self.index = 0
	self.count = #tokens
	self.delta = {}
	
	self:NextToken()
	local tree = self:Root()
	
	return tree, self.delta
end

/******************************************************************************/

function SF_Parser:GetToken()
	return self.token
end

function SF_Parser:GetTokenData()
	return self.token[2]
end

function SF_Parser:GetTokenTrace()
	return {self.token[4], self.token[5]}
end


function SF_Parser:Instruction(trace, name, ...)
	return {name, trace, ...} //
end


function SF_Parser:HasTokens()
	return self.readtoken != nil
end

function SF_Parser:NextToken()
	if self.index <= self.count then
		if self.index > 0 then
			self.token = self.readtoken
		else
			self.token = {"", "", false, 1, 1}
		end
		
		self.index = self.index + 1
		self.readtoken = self.tokens[self.index]
	else
		self.readtoken = nil
	end
end

function SF_Parser:TrackBack()
	self.index = self.index - 2
	self:NextToken()
end


function SF_Parser:AcceptRoamingToken(name)
	local token = self.readtoken
	if not token or token[1] ~= name then
		return false
	end
	
	self:NextToken()
	return true
end

function SF_Parser:AcceptTailingToken(name)
	local token = self.readtoken
	if !token or token[3] then return false end
	
	return self:AcceptRoamingToken(name)
end

function SF_Parser:AcceptLeadingToken(name)
	local token = self.tokens[self.index + 1]
	if !token or token[3] then return false end
	
	return self:AcceptRoamingToken(name)
end


function SF_Parser:RecurseLeft(func, tbl)
	local expr = func(self)
	local hit = true
	
	while hit do
		hit = false
		for i=1,#tbl do
			if self:AcceptRoamingToken(tbl[i]) then
				local trace = self:GetTokenTrace()
				
				hit = true
				expr = self:Instruction(trace, tbl[i], expr, func(self))
				break
			end
		end
	end
	
	return expr
end

-- ----------------------------------- --

function SF_Parser:Root()
	self.loopdepth = 0
	
	local trace = self:GetTokenTrace()
	local stmts = self:Instruction(trace, "seq")

	if !self:HasTokens() then return stmts end
	
	while true do
		if self:AcceptRoamingToken("com") then
			self:Error("Statement separator (,) must not appear multiple times")
		end
		
		stmts[#stmts + 1] = self:Stmt1()
		
		if !self:HasTokens() then break end
		
		if !self:AcceptRoamingToken("com") then
			if self.readtoken[3] == false then
				self:Error("Statements must be separated by comma (,) or whitespace")
			end
		end
	end
	
	return stmts
end

function SF_Parser:StmtDecl()
	if self:AcceptRoamingToken("var") then
		local trace = self:GetTokenTrace()
		local typ = self:GetTokenData()
		
		if self:AcceptRoamingToken("var") then
			local var = self:GetTokenData()
			
			if not SFLib.types[typ] then
				self:Error("Unknown type: "..typ, trace)
			end
			
			if self:AcceptRoamingToken("ass") then
				return self:Instruction(trace, "decl", typ, var, self:StmtExpr())
			else
				return self:Instruction(trace, "decl", typ, var, nil)
			end
		else
			self:TrackBack()
		end
	end
	
	return SF_Parser:StmtAssign()
end

function SF_Parser:StmtAssign()
	if self:AcceptRoamingToken("var") then
		local trace = self:GetTokenTrace()
		local var = self:GetTokenData()
		
		if self:AcceptRoamingToken("ass") then
			return self:Instruction(trace, "assign", self:StmtExpr())
		else
			self:TrackBack()
		end
	end
end

function SF_Parser:StmtExpr()
	return SF_Parser:ExprPrimitive()
end

-- ----------------------------------- --

function SF_Parser:ExprPrimitive()
	if self:AcceptRoamingToken("str") then
		return self:Instruction(self:GetTokenTrace(), "str", self:GetTokenData())
	elseif self:AcceptRoamingToken("num") then
		return self:Instruction(self:GetTokenTrace(), "num", self:GetTokenData())
	end
	
	return self:ExprVar()
end

function SF_Parser:ExprVar()
	if self:AcceptRoamingToken("var") then
		return self:Instruction(self:GetTokenTrace(), "var", self:GetTokenData())
	end
	
	return self:ExprError()
end

function SF_Parser:ExprError()
	local err
	
	if not self:HasTokens() then
		err = "Further input of code required; incomplete expression"
	end
	
	-- TODO: Put error detection code here
	
	if not err then
		err = "Unexpected token found: "..self:GetToken()[1]
	end
	
	self:Error(err)
end