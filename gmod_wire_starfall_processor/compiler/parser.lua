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
SeqSPace 	- "sIF qSP"
SeqCOmma 	- "sIF, qSP"

- Statements
StmtIF		- "if(eVR) { qSP } fEI"
StmtEXpr 	- "eVR"

- Expressions
ExprVaR		- "var"

- iF blocks
IfElseIf	- "elseif { q1 } i1"

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

local loopdepth

function SF_Parser:Root()
	loopdepth = 0
	return self:Stmts()
end

