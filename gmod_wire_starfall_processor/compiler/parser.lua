/******************************************************************************\
  Starfall Parser for Garry's Mod
  By Colonel Thirty Two
  initrd.gz@gmail.com
  
  Based on the Expression 2 Parser by
  Andreas "Syranide" Svensson, me@syranide.com
\******************************************************************************/

AddCSLuaFile("parser.lua")

--[[

- seQuence
SeqSPace 		- "sIF qSP"
SeqCOmma 		- "sIF, qSP"

- Statements

StmtDeClare 	- "type var", "type var = sEX"
StmtASsign 		- "var = sEX"
StmtIF			- "if(ePR) { sSP }"
StmtEXpr 		- "eVR"

- Expressions
ExprPRimitive	- strings, numbers, other primitive data types
ExprCAllIndex	- "var([sEX,...]), var[I], var:var([sEX,...])"
ExprVaR			- "var"


]]
/******************************************************************************/

SF_Parser = {}
SF_Parser.__index = SF_Parser

function SF_Parser:Process(...)
	-- instantiate Parser
	local instance = setmetatable({}, SF_Parser)
	
	-- and pcall the new instance's Execute method.
	return pcall(SF_Parser.Execute, instance, ...)
end

function SF_Parser:Error(message, token)
	if token then
		error(message .. " at line " .. token[4] .. ", char " .. token[5], 0)
	else
		error(message .. " at line " .. self.token[4] .. ", char " .. self.token[5], 0)
	end
end

function SF_Parser:Execute(tokens, params)
	self.tokens = tokens
	
	self.index = 0
	self.count = #tokens
	
	PrintTable(tokens)
	self:NextToken()
	local tree = self:Root()
	
	return tree
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
	return {name, trace, ...}
end


function SF_Parser:HasTokens()
	return self.readtoken != nil
end

function SF_Parser:NextToken()
	if self.index <= self.count then
		--Msg("Advancing tokens. Index="..self.index.."... ")
		if self.index > 0 then
			--Msg("Reading from readtoken\n")
			self.token = self.readtoken
		else
			--Msg("Creating fake token\n")
			self.token = {"", "", false, 1, 1}
		end
		
		self.index = self.index + 1
		--Msg("New Readtoken: ".. (self.tokens[self.index] or {"nil"})[1] .. ", index = "..self.index.."\n")
		self.readtoken = self.tokens[self.index]
	else
		--Msg("No more tokens ("..self.index.."/"..self.count..")\n")
		self.readtoken = nil
	end
end

function SF_Parser:TrackBack()
	self.index = self.index - 2
	self:NextToken()
end


function SF_Parser:AcceptRoamingToken(name)
	--Msg("Trying to accept token "..name.."...")
	local token = self.readtoken
	if not token or token[1] ~= name then
		--Msg(" Failed, token name is "..(token or {"nil"})[1].."\n")
		return false
	end
	
	--Msg(" Accepted.\n")
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

function SF_Parser:Condition(msg)
	msg = msg or "condition"
	if not self:AcceptRoamingToken("lpa") then
		self:Error("Left parenthesis (() missing to begin "..msg)
	end
	
	local expr = self:StmtExpr()
	
	if not self:AcceptRoamingToken("rpa") then
		self:Error("Right parenthesis ()) missing to end "..msg)
	end
	
	return expr
end

function SF_Parser:Block(msg)
	msg = msg or "block"
	local trace = self:GetTokenTrace()
	local stmts = self:Instruction(trace,"seq")
	
	if not self:AcceptRoamingToken("lcb") then
		self:Error("Left curly bracket ({) missing to start "..msg)
	end
	
	local token = self:GetToken()
	
	if self:AcceptRoamingToken("rcb") then return stmts end
	
	while self:HasTokens() do
		if self:AcceptRoamingToken("com") then
			self:Error("Statement seperator (,) must not appear multiple times")
		elseif self:AcceptRoamingToken("rcb") then
			self:Error("Statement seperator (,) must be suceeded by a statement")
		end
		
		stmts[#stmts+1] = self:StmtDeclare()
		
		if self:AcceptRoamingToken("rcb") then return stmts end
		
		if not self:AcceptRoamingToken("com") then
			
		end
	end
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
		
		stmts[#stmts + 1] = self:StmtDecl()
		
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
	--Msg("--Beginning Declaration statement--\n")
	if self:AcceptRoamingToken("var") then
		local trace = self:GetTokenTrace()
		local typ = self:GetTokenData()
		
		if self:AcceptRoamingToken("var") then
			local var = self:GetTokenData()
			
			if not SFLib.types[typ] then
				self:TrackBack()
				self:Error("Unknown type: "..typ)
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
	
	return self:StmtAssign()
end

function SF_Parser:StmtAssign()
	--Msg("--Beginning Assignment statement--\n")
	if self:AcceptRoamingToken("var") then
		local trace = self:GetTokenTrace()
		local var = self:GetTokenData()
		
		if self:AcceptRoamingToken("ass") then
			return self:Instruction(trace, "assign", var, self:StmtExpr())
		else
			self:TrackBack()
		end
	end
	
	return self:StmtIf()
end

function SF_Parser:StmtIf()
	if self:AcceptRoamingToken("if") then
		if not self:AcceptRoamingToken("lpa") then
			self:Error("Left Parenthesis (() missing to close 
		end
	end
	return StmtExpr()
end

function SF_Parser:StmtExpr()
	return self:ExprPrimitive()
end

-- ----------------------------------- --

function SF_Parser:ExprPrimitive()
	--Msg("--Beginning Primitive expression--\n")
	if self:AcceptRoamingToken("str") then
		return self:Instruction(self:GetTokenTrace(), "str", self:GetTokenData())
	elseif self:AcceptRoamingToken("num") then
		return self:Instruction(self:GetTokenTrace(), "num", self:GetTokenData())
	end
	
	return self:ExprVar()
end

function SF_Parser:ExprGroup()
	if self:AcceptRoamingToken("lpa") then
		local token = self:GetToken()
		local expr = self:Expr1()
		
		if not self:AcceptRoamingToken("rpa") then
			self:Error("Right parenthesis ()) missing to close grouped equasion",token)
		end
		return expr
	end
end

function SF_Parser:ExprCallIndex()
	local begin = self:ExprVar()
	while true do
		if self:AcceptTailingToken("lpa") then
			-- Function
			local trace,token = self:GetTokenTrace(),self:GetToken()
			local exprs = {}
			while self:AcceptRoamingToken("com") do
				exprs[#exprs+1] = self:ExprPrimitive()
			end
			
			if not self:AcceptRoamingToken("rpa") then
				self:Error("Right parenthesis ()) missing to close function argument list",token)
			end
			
			return self:Instruction(trace,"call",begin,exprs)
		elseif self:AcceptRoamingToken("lpa") then
			
		end
	end
end

function SF_Parser:ExprVar()
	--Msg("--Beginning Variable expression--\n")
	if self:AcceptRoamingToken("var") then
		return self:Instruction(self:GetTokenTrace(), "var", self:GetTokenData())
	end
	
	return self:ExprError()
end

function SF_Parser:ExprError()
	local err
	
	if not self:HasTokens() then
		err = "Further input of code required; incomplete expression"
	else
		-- TODO: Put error detection code here
	end
	
	if err == nil then
		err = "Unexpected token found: "..self:GetToken()[1]
	end
	
	self:Error(err)
end