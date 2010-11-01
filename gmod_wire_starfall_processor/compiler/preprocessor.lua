--[[---------------------------------------]
   [ Starfall Preprocessor                 ]
   [ By Colonel Thirty Two                 ]
   [---------------------------------------]]


SF_PProcessor = SF_PProcessor or {}
SF_PProcessor.__index = SF_PProcessor

SF_PProcessor.directives = {}

-- ----------------------------------- --
-- Helper Functions                    --
-- ----------------------------------- --

local function remove_block(text, start, theend)
	-- Removes a block of text starting at start and ending at theend, inclusive.
	-- Adds newlines and padding to compensate for removed lines/spaces
	local newlines = 0
	
	local oldindex = start
	local lastindex = start - 1
	local index = text:find("\n",start+1)
	while index and index < theend do
		newlines = newlines + 1
		lastindex = index
		index = text:find("\n",index+1)
		
		if index == nil then
			index = text:len()
			break
		end
	end
	
	local padding = theend - lastindex
	return text:sub(1,start-1) .. string.rep("\n", newlines) .. string.rep(" ", padding) .. text:sub(theend+1)
end

local function get_line(text, char)
	-- Returns the line and column number of char
	local lines = 1
	local lastindex = 1
	local index = text:find("\n")
	
	while index and index <= char do
		lines = lines + 1
		lastindex = index
		index = text:find("\n",index+1)
	end
	
	return lines, char - lastindex
end

local function find_string_end(text, start)
	-- Finds the end of a string, ignoring escaped quotation marks
	local index = text:find('"',start+1)
	while text:sub(text, index-1, index) == "\\\"" do
		index = text:find('"',index+1)
		if index == nil then
			-- Unterminated string
			local line, col = get_line(text, start)
			self:Error("Unterminated string starting ", line, col)
		end
	end
	return index
end

-- ----------------------------------- --
-- Methods                             --
-- ----------------------------------- --

function SF_PProcessor:Process(code, ...)
	-- Processes code, you should call this.
	local instance = setmetatable({}, SF_PProcessor)
	return pcall(SF_PProcessor.Parse, instance, code, ...)
end

function SF_PProcessor:AddDirective(name, handler)
	self.directives[name] = handler
end

function SF_PProcessor:Error(msg, index)
	local line, col = get_line(self.code, index)
	error(msg .. "at line " .. line .. ", column " .. col, 0)
end

function SF_PProcessor:Parse(code, ...)
	self.code = code
	self.data = {}
	self.incode = false
	
	local index = code:find("[\"#@]")
	local offset = 1
	
	while index do
		
		if not self.incode and not code:sub(1,index-1):match("[%s\n]*") then
			self.incode = true
		end
		
		if code:sub(index, index) == '"' then
			-- String, skip it
			offset = find_string_end(code,index) + 1
		elseif code:sub(index, index+1) == "#[" then
			-- Block comment
			local theend = code:find("]#",index+2,true)
			if theend == nil then
				-- Unterminated block comment
				self:Error("Unterminated block comment starting ", index)
			end
			
			code = remove_block(code, index, theend+1)
			offset = index
		elseif code:sub(index, index) == "#" then
			-- Normal comment
			local theend = code:find("\n",index+1)
			if theend == nil then
				-- Comment is on the last line
				theend = code:len()
			end
			
			code = remove_block(code, index, theend-1)
		elseif code:sub(index, index) == "@" then
			-- Directive
			local theend = code:find("\n",index+1)
			if theend == nil then
				-- Directive is on the last line
				theend = code:len()
			end
			
			local section = code:sub(index+1, theend-1)
			local directive, args = section:match("([a-z0-9]+) ?(.*)")
			if directive == nil then
				self:Error("Preprocessor directive (@) must be followed by a directive", index)
			end
			
			local handler = self.directives[directive]
			if handler == nil then
				self:Error("Unknown preprocessor statement: " .. directive, index)
			end
			
			local ok, acode = pcall(handler, args, self.data, code, index)
			if not ok then
				self:Error(acode, index)
			end
			
			code = remove_block(acode, index, theend-1)
			offset = index
		end
		
		index = code:find("[\"#@]",offset)
	end
	
	return code, self.data
end

-- ----------------------------------- --
-- Default Directives                  --
-- ----------------------------------- --

--[[
local function directive_example(args, data, code, index)
	args = A string containing the directive arguments (everything after the directive)
	data = A table containing data for all directives
	code = The code, processed up to index
	index = The index of the start of the directive
	
	-- You may change code after the directive and return the string
	-- You should not change code before or in the directive's line
	-- If you don't do anything with code, you must still return it
	return code
	
	-- Raise errors like this:
	error("Something is wrong", 0)
	-- The preprocessor will add in the directive's line+column number for you.
end
-- The directive name must be in lowercase and contain only alphanumeric characters
SF_PProcessor:AddDirective("example", handler)

]]

local function directive_name(args, data, code, index)
	-- @name .*
	if data.name ~= nil then
		error("Duplicate name directive", 0)
	end
	
	data.name = args:Trim()
	return code
end
