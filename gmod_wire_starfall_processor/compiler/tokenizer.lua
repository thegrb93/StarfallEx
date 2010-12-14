/******************************************************************************\
  Expression 2 Tokenizer for Garry's Mod
  Andreas "Syranide" Svensson, me@syranide.com
  
  Modified for Starfall
  By Colonel Thirty Two
  initrd.gz@gmail.com
\******************************************************************************/

AddCSLuaFile("tokenizer.lua")

//SFLib = SFLib or {}

SF_Tokenizer = SF_Tokenizer or {}
SF_Tokenizer.__index = SF_Tokenizer

function SF_Tokenizer:Process(...)
	-- instantiate SF_Tokenizer
	local instance = setmetatable({}, SF_Tokenizer)
	
	-- and pcall the new instance's Execute method.
	return pcall(SF_Tokenizer.Execute, instance, ...)
end

function SF_Tokenizer:Error(message, offset)
	error(message .. " at line " .. self.tokenline .. ", char " .. (self.tokenchar+(offset or 0)), 0)
end

function SF_Tokenizer:Execute(buffer, params)
	self.buffer = buffer
	self.length = buffer:len()
	self.position = 0
	
	self:SkipCharacter()
	
	local tokens = {}
	local tokenname, tokendata, tokenspace
	self.tokendata = ""
	
	while self.character do
		tokenspace = self:NextPattern("%s+") and true or false
		
		if !self.character then break end
		
		self.tokenline = self.readline
		self.tokenchar = self.readchar
		self.tokendata = ""
		
		tokenname, tokendata = self:NextSymbol()
		
		if tokenname == nil then
			tokenname, tokendata = self:NextOperator()
			
			if tokenname == nil then
				self:Error("Unknown character found (" .. self.character .. ")")
			end
		end
		
		tokens[#tokens + 1] = { tokenname, tokendata, tokenspace, self.tokenline, self.tokenchar }
	end
	
	return tokens
end

/******************************************************************************/

function SF_Tokenizer:SkipCharacter()
	if self.position < self.length then
		if self.position > 0 then
			if self.character == "\n" then
				self.readline = self.readline + 1
				self.readchar = 1
			else
				self.readchar = self.readchar + 1
			end
		else
			self.readline = 1
			self.readchar = 1
		end
		
		self.position = self.position + 1
		self.character = self.buffer:sub(self.position, self.position)
	else
		self.character = nil
	end
end

function SF_Tokenizer:NextCharacter()
	self.tokendata = self.tokendata .. self.character
	self:SkipCharacter()
end

-- Returns true on success, nothing if it fails.
function SF_Tokenizer:NextPattern(pattern)
	if not self.character then return false end
	local startpos,endpos,text = self.buffer:find(pattern, self.position)
	
	if startpos ~= self.position then return false end
	local buf = self.buffer:sub(startpos, endpos)
	if not text then text = buf end
	
	self.tokendata = self.tokendata .. text
	
	
	self.position = endpos + 1
	if self.position <= self.length then
		self.character = self.buffer:sub(self.position, self.position)
	else
		self.character = nil
	end
	
	buf = string.Explode("\n", buf)
	if #buf > 1 then
		self.readline = self.readline+#buf-1
		self.readchar = #buf[#buf]+1
	else
		self.readchar = self.readchar + #buf[#buf]
	end
	return true
end

function SF_Tokenizer:NextSymbol()
	local tokenname
	
	if self:NextPattern("^[0-9]+%.?[0-9]*") or self:NextPattern("^.[0-9]+") then
		-- real/imaginary/quaternion number literals
		local errorpos = self.tokendata:match("^0()[0-9]") or self.tokendata:find("%.$")
		if self:NextPattern("^[eE][+-]?[0-9][0-9]*") then
			errorpos = errorpos or self.tokendata:match("[eE][+-]?()0[0-9]")
		end
		
		self:NextPattern("^[ijk]")
		if self:NextPattern("^[a-zA-Z_]") then
			errorpos = errorpos or self.tokendata:len()
		end
		
		if errorpos then
			self:Error("Invalid number format (" .. SFLib.limitString(self.tokendata, 10) .. ")", errorpos-1)
		end
		
		tokenname = "num"
		
	elseif self:NextPattern("^[A-Za-z_][a-zA-Z0-9_]*") then
		-- keywords/variable
		if self.tokendata == "if" then
			tokenname = "if"
		elseif self.tokendata == "elseif" then
			tokenname = "eif"
		elseif self.tokendata == "else" then
			tokenname = "els"
		elseif self.tokendata == "while" then
			tokenname = "whl"
		elseif self.tokendata == "for" then
			tokenname = "for"
		elseif self.tokendata == "in" then
			tokenname = "in"
		elseif self.tokendata == "break" then
			tokenname = "brk"
		elseif self.tokendata == "continue" then
			tokenname = "cnt"
		elseif self.tokendata == "function" then
			tokenname = "udf"
		elseif self.tokendata:match("^[ijk]$") and self.character ~= "(" then
			tokenname, self.tokendata = "num", "1"..self.tokendata
		else
			tokenname = "var"
		end
		
--[[	elseif self:NextPattern("^[A-Z][a-zA-Z0-9_]*") then
		-- variables
		tokenname = "var"]]
		
	--[[elseif self.character == "_" then
		-- constants
		self:NextCharacter()
		self:NextPattern("^[A-Z0-9_]*")
		
		local value = wire_expression2_constants[self.tokendata]
		local tp = type(value)
		
		if tp == "number" then
			tokenname = "num"
			self.tokendata = value
		elseif tp == "string" then
			tokenname = "str"
			self.tokendata = value
		elseif tp == "nil" then
			self:Error("Unknown constant found ("..self.tokendata..")")
		else
			self:Error("Constant ("..self.tokendata..") has invalid data type ("..tp..")")
		end]]
		
	elseif self.character == "\"" then
		-- strings
		
		-- skip opening quotation mark
		self:SkipCharacter()
		
		-- loop until the closing quotation mark
		while self.character != "\"" do
			-- check for line/file endings
			if !self.character then
				self:Error("Unterminated string (\"" .. SFLib.limitString(self.tokendata, 10) .. ")")
			end
			
			if self.character == "\\" then
				self:SkipCharacter()
				if self.character == "\n" then
					self:SkipCharacter()
				elseif self.character == "n" then
					self.tokendata = self.tokendata .. "\n"
					self:SkipCharacter()
				elseif self.character == "t" then
					self.tokendata = self.tokendata .. "\t"
					self:SkipCharacter()
				elseif self.character == "d" then
					local str = ""
					local acontinue = true
					self:SkipCharacter()
					
					for i = 1, 3 do
						if self.character == '"' or self.character:match("[0-9]") == nil then
							acontinue = false
							break
						end
						str = str..self.character
						self:SkipCharacter()
					end
					
					if acontinue then
						local num = tonumber(str)
						if num >= 32 and num <= 255 then
							self.tokendata = self.tokendata .. string.char(num)
						end
					end
				elseif self.character == "h" then
					local str = ""
					local acontinue = true
					self:SkipCharacter()
					
					for i = 1, 2 do
						if self.character == '"' or self.character:match("[0-9a-fA-F]") == nil then
							acontinue = false
							break
						end
						str = str..self.character:lower()
						self:SkipCharacter()
					end
					
					if acontinue then
						local num = tonumber(str,16)
						if num >= 32 and num <= 255 then
							self.tokendata = self.tokendata .. string.char(num)
						end
					end
				else
					self:NextCharacter()
				end
			else
				self:NextCharacter()
			end
		end
		-- skip closing quotation mark
		self:SkipCharacter()
		
		tokenname = "str"
		
	else
		-- nothing
		return
	end
	
	return tokenname, self.tokendata
end

function SF_Tokenizer:NextOperator()
	local op = SFLib.optree[self.character]
	
	if not op then return end
	
	while true do
		self:NextCharacter()
		
		-- Check for the end of the string.
		if not self.character then return op[1] end
		
		-- Check whether we are at a leaf and can't descend any further.
		if not op[2] then return op[1] end
		
		-- Check whether we are at a node with no matching branches.
		if not op[2][self.character] then return op[1] end
		
		-- branch
		op = op[2][self.character]
	end
end
