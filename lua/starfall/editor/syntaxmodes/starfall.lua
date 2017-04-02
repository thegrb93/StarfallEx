local table_concat = table.concat
local string_sub = string.sub
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local libmap = SF.Editor.TabHandlers.wire.LibMap
local EDITOR = {}
local function istype(tp)
	return false
end

-- keywords[name][nextchar!="("]
local keywords = {
	-- keywords that can be followed by a "(":
	["if"] = { [true] = true, [false] = true },
	["elseif"] = { [true] = true, [false] = true },
	["while"] = { [true] = true, [false] = true },
	["for"] = { [true] = true, [false] = true },
	["function"] = { [true] = true, [false] = true },

	["or"] = { [true] = true, [false] = true },
	["not"] = { [true] = true, [false] = true },
	["true"] = { [true] = true, [false] = true },
	["false"] = { [true] = true, [false] = true },

	-- keywords that cannot be followed by a "(":
	["do"] = { [true] = true, [false] = true },
	["else"] = { [true] = true },
	["break"] = { [true] = true },
	["continue"] = { [true] = true },
	["then"] = { [true] = true },
	["end"] = { [true] = true },
	["in"] = { [true] = true },
	["return"] = { [true] = true },
	["local"] = { [true] = true },
}

-- fallback for nonexistant entries:
setmetatable(keywords, { __index=function(tbl,index) return {} end })

local directives = {
	["@name"] = 0, -- all yellow
	["@author"] = 0,
	["@include"] = 0,
	["@shared"] = 1, -- directive yellow, types orange, rest normal
	["@model"] = 0,
}

local colors = {
	["keyword"] = { Color(142,192,124), false},
	["directive"] = { Color(142, 192, 124), false},
	["comment"] = { Color(146, 131, 116), false},
	["string"] = { Color(184, 187, 38), false},
	["number"] = { Color(211, 134, 155), false},
	["function"] = { Color(184, 187, 38), false},
	["library"] = { Color(184, 187, 38), false},
	["operator"] = { Color(211, 134, 155), false},
	["notfound"] = { Color(251, 241, 199), false},
	["userfunction"] = { Color(251, 241, 199), false},
	["constant"] = { Color(211, 134, 155), false},
}

function EDITOR:GetSyntaxColor(name)
	return colors[name][1]
end

function EDITOR:SetSyntaxColor( colorname, colr )
	if not colors[colorname] then return end
	colors[colorname][1] = colr
end

-- cols[n] = { tokendata, color }
local cols = {}
local lastcol
local function addToken(tokenname, tokendata)
	if not tokenname then tokenname = "notfound" end
	local color = colors[tokenname]
	if lastcol and color == lastcol[2] then
		lastcol[1] = lastcol[1] .. tokendata
	else
		cols[#cols + 1] = { tokendata, color, tokenname }
		lastcol = cols[#cols]
	end
end

function EDITOR:BlockCommentSelection(removecomment)
	local sel_start, sel_caret = self:MakeSelection( self:Selection() )
	local mode = self:GetParent().BlockCommentStyleConVar:GetInt()

	if mode == 0 then -- New (alt 1)
		local str = self:GetSelection()
		if removecomment then
			if str:find( "^%-%-%[%[\n" ) and str:find( "\n%]%]$" ) then
				self:SetSelection( str:gsub( "^%-%-%[%[\n(.+)\n%]%]$", "%1" ) )
				sel_caret[1] = sel_caret[1] - 2
			end
		else
			self:SetSelection( "--[[\n" .. str .. "\n]]" )
			sel_caret[1] = sel_caret[1] + 1
			sel_caret[2] = 3
		end
	elseif mode == 1 then -- New (alt 2)
		local str = self:GetSelection()
		if removecomment then
			if str:find( "^%-%-%[%[" ) and str:find( "%]%]$" ) then
				self:SetSelection( str:gsub( "^%-%-%[%[(.+)%]%]$", "%1" ) )

				sel_caret[2] = sel_caret[2] - 4
			end
		else
			self:SetSelection( "--[[" .. self:GetSelection() .. "]]" )
		end
	elseif mode == 2 then -- Old
		local comment_char = "--"
		if removecomment then
			-- shift-TAB with a selection --
			local tmp = string_gsub("\n"..self:GetSelection(), "\n"..comment_char, "\n")

			-- makes sure that the first line is outdented
			self:SetSelection(tmp:sub(2))
		else
			-- plain TAB with a selection --
			self:SetSelection(comment_char .. self:GetSelection():gsub("\n", "\n"..comment_char))
		end
	else
		ErrorNoHalt( "Invalid block comment style" )
	end

	return { sel_start, sel_caret }
end

function EDITOR:CommentSelection(removecomment)

	local sel_start, sel_caret = self:MakeSelection( self:Selection() )
	local str = self:GetSelection()
	if removecomment then
		if str:find( "^%-%-%[%[\n" ) and str:find( "\n%]%]$" ) then
			self:SetSelection( str:gsub( "^%-%-%[%[\n(.+)\n%]%]$", "%1" ) )

			if sel_caret[1] == sel_start[1] then
				sel_caret[2] = sel_caret[2] - 4
			else
				sel_caret[2] = sel_caret[2] - 2
			end
		end
	else
		self:SetSelection( "--[[\n" .. str .."\n]]" )

		if sel_caret[1] == sel_start[1] then
			sel_caret[2] = sel_caret[2] + 4
		else
			sel_caret[2] = sel_caret[2] + 2
		end
	end
	return { sel_start, sel_caret }
end

function EDITOR:ResetTokenizer(row)
	if row == self.Scroll[1] then

		-- This code checks if the visible code is inside a string or a block comment
		self.blockcomment = nil
		self.multilinestring = nil
		local singlelinecomment = false

		local str = string_gsub( table_concat( self.Rows, "\n", 1, self.Scroll[1]-1 ), "\r", "" )

		for before, char, after in string_gmatch( str, '()([%-%[%]"\n])()' ) do
			local before = string_sub( str, before-1, before-1 )
			local after = string_sub( str, after, after )
			if not self.blockcomment and not self.multilinestring and not singlelinecomment then
				if before != "\\" and char == "[" and after =="[" then
					self.multilinestring = true
				elseif before != "\\" and char == "[" and after == "[" then
					self.blockcomment = true
				elseif after=="-" and char == "-" then
					singlelinecomment = true
				end
			elseif self.multilinestring and before != "\\" and char == ']' and after == "]" then
				self.multilinestring = nil
			elseif self.blockcomment and before != '\\' and char == "]" and after == "]" then
				self.blockcomment = nil
			elseif singlelinecomment and char == "\n" then
				singlelinecomment = false
			end
		end
	end

end

function EDITOR:SyntaxColorLine(row)
	cols,lastcol = {}, nil

	self:ResetTokenizer(row)
	self:NextCharacter()

	-- 0=name 1=port 2=trigger 3=foreach
	local highlightmode = nil

	if self.blockcomment then -- Closing block comments
		if self:NextPattern(".-%]%]") then
			self.blockcomment = nil
		else
			self:NextPattern(".*")
		end

		addToken("comment", self.tokendata)
	elseif self.multilinestring then
		while self.character do -- Find the ending ]]
			if self:NextPattern(".-%]%]") then
				self.multilinestring = nil
				self:NextCharacter()
				break
			end
			if self.character == "\\" then self:NextCharacter() end
			self:NextCharacter()
		end

		addToken("string", self.tokendata)
	end

	local found = self:SkipPattern( "( *function)" )
	if found then
		addToken( "keyword", found ) -- Add "function"
		self.tokendata = "" -- Reset tokendata

		local spaces = self:SkipPattern( " *" )
		if spaces then addToken( "comment", spaces ) end

		if self:NextPattern( "%s*[a-zA-Z][a-zA-Z0-9_]*" ) then -- function THIS()

			local spaces, funcname = self.tokendata:match( "(%s*)(%a[a-zA-Z0-9_]*)" )
			addToken( "userfunction", funcname )

		end
		self.tokendata = ""

		if self:NextPattern( "%(" ) then -- We found a bracket
			-- Color the bracket
			addToken( "notfound", self.tokendata )
		end

		self.tokendata = ""
		if self:NextPattern( "%) *{?" ) then -- check for ending bracket (and perhaps an ending {?)
			addToken( "notfound", self.tokendata )
		end
	end

	while self.character do
		local tokenname = ""
		self.tokendata = ""

		-- eat all spaces
		local spaces = self:SkipPattern(" *")
		if spaces then addToken("comment", spaces) end
		if not self.character then break end

		-- eat next token

		if self:NextPattern("^0[xb][0-9A-F]+") then
			tokenname = "number"
		elseif self:NextPattern("^[0-9][0-9.e]*") then
			tokenname = "number"

		elseif self:NextPattern("^[a-zA-Z][a-zA-Z0-9_]*") then
			local sstr = self.tokendata

			-- is this a keyword or a function?
			local char = self.character or ""
			local keyword = char ~= "("

			local spaces = self:SkipPattern(" *") or ""

			if keywords[sstr][keyword] then
				tokenname = "keyword"
			elseif libmap["Environment"][sstr] then -- We Environment /constant
				local val = libmap["Environment"][sstr]
				if istable(val) then
					addToken("constant", self.tokendata)
					self.tokendata = ""
					if self:NextPattern( "%." ) then -- There is dot after enum, color it
						addToken( "operator", self.tokendata )
						self.tokendata = ""
					end
					if self:NextPattern("^[a-zA-Z][a-zA-Z0-9_]*") then -- Looking for enum key
						tokenname = val[self.tokendata] and "constant" or "notfound"
					else
						tokenname = "notfound"
					end
				else
					if val == "function" then
						tokenname = "notfound" -- we wont color if there is no (
						local pos = self.position -- We are saving that, so we can move tokenizer back
						local c = self.character
						local td = self.tokendata
						if self:NextPattern("%s*%(") then -- we are checking if there is ( after name
							tokenname = "function"
							self.position = pos -- We dont want to move tokenizer as we were just checking without parsing
							self.character = c
							self.tokendata = td
						end
					else
						tokenname = "constant"
					end
				end
			elseif libmap[sstr] then --We found library
				addToken("library", self.tokendata)
				self.tokendata = ""
				if self:NextPattern( "%." ) then -- We found a dot, looking for library method/constant
					addToken( "operator", self.tokendata )
					self.tokendata = ""
					if self:NextPattern( "^[a-zA-Z][a-zA-Z0-9_]*" ) then
						local t = libmap[sstr][self.tokendata]
						if t then -- Valid function, woohoo
							tokenname = t == "function" and "function" or "constant"
						else
							tokenname = "notfound"
						end
					end
				end
			else
				tokenname = "notfound"
			end
			if self.tokendata != "" then
				addToken(tokenname, self.tokendata)
			end
			tokenname = "comment"
			self.tokendata = spaces

		elseif self:NextPattern("%[%[") then -- Multiline strings
			self:NextCharacter()
			while self.character do -- Find the ending ]] if it isnt really multline(who does that?! Shame on you!)
				if self:NextPattern("%]%]") then
					tokenname = "string"
					break
				end
				if self.character == "\\" then self:NextCharacter() end
				self:NextCharacter()
			end

			if tokenname == "" then -- If no ending ]] was found...
				self.multilinestring = true
				tokenname = "string"
			else
				self:NextCharacter()
			end
			--"string"
		elseif self.character == '"' then -- Singleline "string"
			self:NextCharacter()
			while self.character do -- Find the ending "
				if self.character == '"' then
					tokenname = "string"
					break
				end
				if self.character == "\\" then self:NextCharacter() end
				self:NextCharacter()
			end

			if tokenname == "" then -- If no ending " was found...
				--self.multilinestring = true
				tokenname = "string"
			else
				self:NextCharacter()
			end
		elseif self.character == "'" then -- Singleline 'string'
			self:NextCharacter()
			while self.character do -- Find the ending "
				if self.character == "'" then
					tokenname = "string"
					break
				end
				if self.character == "\\" then self:NextCharacter() end
				self:NextCharacter()
			end
		elseif self:NextPattern("%-%-") then -- Comments

			if self.character == "[" and self:NextPattern("%[%[") then -- Check if there is a [[ directly after the --
				while self.character do -- Find the ending ]
					if self.character == "]" then
						self:NextCharacter()
						if self.character == "]" then -- Check if ] is double
							tokenname = "comment"
							break
						end
					end
					if self.character == "\\" then self:NextCharacter() end
					self:NextCharacter()
				end
				if tokenname == "" then -- If no ending ]] was found...
					self.blockcomment = true
					tokenname = "comment"
				else
					self:NextCharacter()
				end
			end

			if tokenname == "" then
				tokenname = "comment"
				self:NextPattern("[^@]*") -- Skip everything BEFORE @
				addToken(tokenname, self.tokendata)
				self.tokendata ="" -- we dont need that anymore as we already added it

				self:NextPattern("[%S]*") -- Find first word
				if directives[self.tokendata] then --Directive
					tokenname = "directive"
				end
				self:NextPattern(".*") -- Rest of comment/directive
			end
		else
			self:NextCharacter()

			tokenname = "notfound"
		end

		addToken(tokenname, self.tokendata)
	end

	return cols
end

return EDITOR
