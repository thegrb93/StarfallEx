local table_concat = table.concat
local string_sub = string.sub
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local libmap = SF.Editor.TabHandlers.wire.LibMap
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local surface_PlaySound = surface.PlaySound
local surface_SetTextPos = surface.SetTextPos
local surface_SetTextColor = surface.SetTextColor
local surface_DrawText = surface.DrawText
local EDITOR = {}

local kwCanParenthesis = { [true] = true, [false] = true }
local kwNoParenthesis = { [true] = true }

-- keywords[name][nextchar!="("]
local storageTypes = {
	["function"] = kwCanParenthesis,
	["local"] = kwNoParenthesis,
}

local keywords = {
	-- keywords that can be followed by a "(":
	["if"] = kwCanParenthesis,
	["elseif"] = kwCanParenthesis,
	["while"] = kwCanParenthesis,
	["for"] = kwCanParenthesis,

	["repeat"] = kwCanParenthesis,
	["until"] = kwCanParenthesis,
	["and"] = kwCanParenthesis,
	["or"] = kwCanParenthesis,
	["not"] = kwCanParenthesis,

	-- keywords that cannot be followed by a "(":
	["do"] = kwNoParenthesis,
	["goto"] = kwNoParenthesis,
	["else"] = kwNoParenthesis,
	["break"] = kwNoParenthesis,
	["continue"] = kwNoParenthesis,
	["then"] = kwNoParenthesis,
	["end"] = kwNoParenthesis,
	["in"] = kwNoParenthesis,
	["return"] = kwNoParenthesis,
}

-- Keywords that are constant values.
local keyword_const = {
	["nil"] = kwNoParenthesis,
	["true"] = kwNoParenthesis,
	["false"] = kwNoParenthesis,
	["_G"] = kwCanParenthesis,
	["self"] = kwCanParenthesis,
	["..."] = kwNoParenthesis
}

-- fallback for nonexistant entries:
local fallback_meta = { __index = function(tbl, index) return {} end }
setmetatable(keywords, fallback_meta)
setmetatable(keyword_const, fallback_meta)
setmetatable(storageTypes, fallback_meta)

-- Get directives from the preprocessor so we don't have to hard-code them here.
-- Allows for addons to make their own directives that properly highlight.
local directives = SF.PreprocessData.directives

--Color scheme:
--{foreground color, background color, fontStyle}
--Style can be: 0 - normal  1 - italic 2 - bold

local colors = { }

function EDITOR:LoadSyntaxColors()
	colors = { }

	for k, v in pairs(SF.Editor.Themes.CurrentTheme) do
		colors[k] = v
	end
end

-- cols[n] = { tokendata, color }
local cols = {}
local lastcol
local lasttoken
local unconnectable = {--Each token of this type shouldnt be connected because editor goes through them
	["bracket"] = true,
	["keyword"] = true,
}
local function addToken(tokenname, tokendata)
	if not tokendata or #tokendata < 0 then error("EMPTY TOKEN") end
	if not tokenname then tokenname = "notfound" end

	local color = colors[tokenname] or colors["notfound"]

	if lasttoken and tokenname == lasttoken and not unconnectable[tokenname] then
		local newdata = cols[#cols][1] .. tokendata
		cols[#cols][1] = newdata
	else
		cols[#cols + 1] = { tokendata, color, tokenname }
		lasttoken = tokenname
	end
end

local function addColorToken(tokenname, bgcolor, tokendata)
	local usePigments = SF.Editor.TabHandlers.wire.PigmentsConVar:GetInt()
	local textcolor
	if usePigments == 2 then
		local h, s, v = ColorToHSV(bgcolor) --We're finding high-contrast color
		h = (h + 180)%360
		s = 1 - s
		v = 1 - v
		textcolor = HSVToColor(h, s, v)
	elseif usePigments == 1 then
		textcolor = colors[tokenname][1]
	else
		addToken(tokenname, tokendata)
	end
	cols[#cols + 1] = { tokendata, { textcolor, bgcolor, 0 }, "color."..tokenname }
	lastcol = cols[#cols]
end

function EDITOR:BlockCommentSelection(removecomment)
	local sel_start, sel_caret = self:MakeSelection(self:Selection())
	local mode = SF.Editor.TabHandlers.wire.BlockCommentStyleConVar:GetInt()

	if mode == 0 then -- New (alt 1)
		local str = self:GetSelection()
		if removecomment then
			if str:find("^%-%-%[%[\n") and str:find("\n%]%]$") then
				self:SetSelection(str:gsub("^%-%-%[%[\n(.+)\n%]%]$", "%1"))
				sel_caret[1] = sel_caret[1] - 2
			end
		else
			self:SetSelection("--[[\n" .. str .. "\n]]")
			sel_caret[1] = sel_caret[1] + 1
			sel_caret[2] = 3
		end
	elseif mode == 1 then -- New (alt 2)
		local str = self:GetSelection()
		if removecomment then
			if str:find("^%-%-%[%[") and str:find("%]%]$") then
				self:SetSelection(str:gsub("^%-%-%[%[(.+)%]%]$", "%1"))

				sel_caret[2] = sel_caret[2] - 4
			end
		else
			self:SetSelection("--[[" .. self:GetSelection() .. "]]")
		end
	elseif mode == 2 then -- Old
		local comment_char = "%-%- "
		if removecomment then
			-- shift-TAB with a selection --
			local tmp = string_gsub("\n"..self:GetSelection(), "\n"..comment_char, "\n")
			-- makes sure that the first line is outdented
			self:SetSelection(tmp:sub(2))
		else
			-- plain TAB with a selection --
			self:SetSelection("-- "..self:GetSelection():gsub("\n", "\n"..comment_char))
		end
	else
		ErrorNoHalt("Invalid block comment style")
	end

	return { sel_start, sel_caret }
end

function EDITOR:CommentSelection(removecomment)

	local sel_start, sel_caret = self:MakeSelection(self:Selection())
	local str = self:GetSelection()
	if removecomment then
		if str:find("^%-%-%[%[\n") and str:find("\n%]%]$") then
			self:SetSelection(str:gsub("^%-%-%[%[\n(.+)\n%]%]$", "%1"))

			if sel_caret[1] == sel_start[1] then
				sel_caret[2] = sel_caret[2] - 4
			else
				sel_caret[2] = sel_caret[2] - 2
			end
		end
	else
		self:SetSelection("--[[\n" .. str .."\n]]")

		if sel_caret[1] == sel_start[1] then
			sel_caret[2] = sel_caret[2] + 4
		else
			sel_caret[2] = sel_caret[2] + 2
		end
	end
	return { sel_start, sel_caret }
end

function EDITOR:ResetTokenizer(row)
	local p = self.Rows[row-1]
	if p then p = p[2] end
	self.multilinestring = p and p["multilinestring"] or false
	self.blockcomment = p and p["blockcomment"] or false
	lasttoken = nil
end

--That code sucks, if you can do any better then DO IT
local numbpattern = "0?[xb]?%x+"
local numbpatternG = "("..numbpattern..")"
local spacedcomma = "%s*,%s*"
local spacedcommaG = "("..spacedcomma..")"
local rgbpattern = "^Color%s*%(%s*"..numbpattern..spacedcomma..numbpattern..spacedcomma..numbpattern.."%s*%)"
local rgbpatternG = "^(Color%s*)(%(%s*)"..numbpatternG..spacedcommaG..numbpatternG..spacedcommaG..numbpatternG.."(%s*%))"
local rgbapattern = "^Color%s*%(%s*"..numbpattern..spacedcomma..numbpattern..spacedcomma..numbpattern..spacedcomma..numbpattern.."%s*%)"
local rgbapatternG = "^(Color%s*)(%(%s*)"..numbpatternG..spacedcommaG..numbpatternG..spacedcommaG..numbpatternG..spacedcommaG..numbpatternG.."(%s*%))"
local setrgbapattern = "^setRGBA%s*%(%s*"..numbpattern..spacedcomma..numbpattern..spacedcomma..numbpattern..spacedcomma..numbpattern.."%s*%)"
local setrgbapatternG = "^(setRGBA%s*)(%(%s*)"..numbpatternG..spacedcommaG..numbpatternG..spacedcommaG..numbpatternG..spacedcommaG..numbpatternG.."(%s*%))"


--End of monsterous code

function EDITOR:SyntaxColorLine(row)
	local usePigments = SF.Editor.TabHandlers.wire.PigmentsConVar:GetInt() > 0
	cols, lastcol = {}, nil

	self:ResetTokenizer(row)
	self:NextCharacter()

	-- 0=name 1=port 2=trigger 3=foreach
	local highlightmode = nil

	if self.blockcomment then -- Closing block comments
		-- [0; +inf) for Lua comments, -1 for C comments
		local blockEnd = (self.blockcomment >= 0) and (".-%]"..string.rep('=',self.blockcomment).."%]") or (".-%*/")

		if self:NextPattern(blockEnd) then
			self.blockcomment = nil
		else
			self:NextPattern(".*")
		end

		addToken("comment", self.tokendata)
	elseif self.multilinestring then
		local ending = "%]"..string.rep('=',self.multilinestring).."%]"
		while self.character do -- Find the ending ]]
			if self:NextPattern(ending) then
				self.multilinestring = nil
				break
			end
			if self.character == "\\" then self:NextCharacter() end
			self:NextCharacter()
		end

		addToken("string", self.tokendata)
	end
	local spaces = self:SkipPattern(" *")
	if spaces then addToken("whitespace", spaces) end

	local found = self:SkipPattern("(function)")
	if found then
		addToken("storageType", found) -- Add "function"
		self.tokendata = "" -- Reset tokendata

		local spaces = self:SkipPattern(" *")
		if spaces then addToken("whitespace", spaces) end

		if self:NextPattern("%s*[a-zA-Z][a-zA-Z0-9_]*") then -- function THIS()

			local spaces, funcname = self.tokendata:match("(%s*)(%a[a-zA-Z0-9_]*)")
			addToken("userfunction", funcname)

		end
		self.tokendata = ""

		if self:NextPattern("%(") then -- We found a bracket
			-- Color the bracket
			addToken("bracket", self.tokendata)
		end

		self.tokendata = ""
		if self:NextPattern("%) *") then -- check for ending bracket
			addToken("notfound", self.tokendata)
		end
		cols.foldable = true
	end
	local spaces = self:SkipPattern(" *")
	if spaces then addToken("whitespace", spaces) end

	found = self:NextPattern("local%s*function%s+")  -- local function
	if found then
		local l, spaces, f, spaces2 = self.tokendata:match("(local)(%s*)(function)(%s+)")

		addToken("keyword", l)
		if #spaces>0 then addToken("whitespace", spaces) end
		addToken("storageType", f) -- Add "function"
		addToken("whitespace", spaces2)

		self.tokendata = "" -- Reset tokendata

		local spaces = self:SkipPattern(" *")
		if spaces then addToken("whitespace", spaces) end

		if self:NextPattern("%s*[a-zA-Z][a-zA-Z0-9_]*") then -- local function THIS()

			local spaces, funcname = self.tokendata:match("(%s*)(%a[a-zA-Z0-9_]*)")
			addToken("userfunction", funcname)

		end
		self.tokendata = ""

		if self:NextPattern("%(") then -- We found a bracket
			-- Color the bracket
			addToken("bracket", self.tokendata)
		end

		self.tokendata = ""
		if self:NextPattern("%)") then
			addToken("bracket", self.tokendata)
		end
		cols.foldable = true
	end
	while self.character do
		local tokenname = ""
		self.tokendata = ""

		-- eat all spaces
		local spaces = self:SkipPattern(" *")
		if spaces then addToken("whitespace", spaces) end
		if not self.character then break end

		-- eat next token
		if usePigments then
			if self:NextPattern(rgbpattern) then -- Color(r,g,b)
				local fname, bracket1, r, comma1, g, comma2, b, bracket2 = self.tokendata:match(rgbpatternG)
				local cr, cg, cb = tonumber(r), tonumber(g), tonumber(b)
				local col
				if cr and cg and cb then
					col = Color(cr, cg, cb)
				else
					col = Color(0, 0, 0, 0) -- Transparent because its invalid
				end
				addColorToken("function", col, fname)
				addColorToken("bracket", col, bracket1)
				if cr then
					addColorToken("number", col, r)
				else
					addColorToken("notfound", col, r)
				end
				addColorToken("notfound", col, comma1)
				if cg then
					addColorToken("number", col, g)
				else
					addColorToken("notfound", col, g)
				end
				addColorToken("notfound", col, comma2)
				if cb then
					addColorToken("number", col, b)
				else
					addColorToken("notfound", col, b)
				end
				addColorToken("bracket", col, bracket2)
				tokenname = "" -- It's custom token
				self.tokendata = ""
			elseif self:NextPattern(rgbapattern) then -- Color(r,g,b,a)
				local fname, bracket1, r, comma1, g, comma2, b, comma3, a, bracket2 = self.tokendata:match(rgbapatternG)
				local cr, cg, cb, ca = tonumber(r), tonumber(g), tonumber(b), tonumber(a)
				local col
				if cr and cg and cb and ca then
					col = Color(cr, cg, cb, ca)
				else
					col = Color(0, 0, 0, 0) -- Transparent because its invalid
				end
				addColorToken("function", col, fname)
				addColorToken("bracket", col, bracket1)
				if cr then
					addColorToken("number", col, r)
				else
					addColorToken("notfound", col, r)
				end
				addColorToken("notfound", col, comma1)
				if cg then
					addColorToken("number", col, g)
				else
					addColorToken("notfound", col, g)
				end
				addColorToken("notfound", col, comma2)
				if cb then
					addColorToken("number", col, b)
				else
					addColorToken("notfound", col, b)
				end
				addColorToken("notfound", col, comma3)
				if ca then
					addColorToken("number", col, a)
				end
				addColorToken("bracket", col, bracket2)
				tokenname = "" -- It's custom token
				self.tokendata = ""
			end
		end

		if self:NextPattern("^0[xb][a-fA-F0-9]+") then
			tokenname = "number"
		elseif self:NextPattern("^::[^:]*::") then
			tokenname = "string"
		elseif self:NextPattern("^[0-9][0-9.e]*") then
			tokenname = "number"
		elseif self:NextPattern("^%:[a-zA-Z][a-zA-Z0-9_]*") then -- Methods
			addToken("operator", self.tokendata:sub(1, 1)) -- Adding : as operator
			self.tokendata = self.tokendata:sub(2)  -- Operator was handled, so remove it from tokendata
			if libmap["Methods"][self.tokendata] then
				tokenname = "method"
			else
				tokenname = "identifier"
			end
		elseif self:NextPattern("^[a-zA-Z_][a-zA-Z0-9_]*") then
			local sstr = self.tokendata

			-- is this a keyword or a function?
			local char = self.character or ""
			local keyword = char ~= "("

			if storageTypes[sstr][keyword] then
				tokenname = "storageType"
			elseif keywords[sstr][keyword] then
				tokenname = "keyword"
			elseif keyword_const[sstr][keyword] then
				tokenname = "constant"
			elseif libmap["Environment"][sstr] then -- We Environment /constant
				local val = libmap["Environment"][sstr]
				if istable(val) then
					addToken("constant", self.tokendata)
					self.tokendata = ""
					if self:NextPattern("%.") then -- There is dot after enum, color it
						addToken("operator", self.tokendata)
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
						if self:NextPattern("%s*[({'\"]") then -- we are checking if there is ( after name, or if single parameter function with string literal or table literal
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
				if self:NextPattern("^%.") then -- We found a dot, looking for library method/constant
					addToken("operator", self.tokendata)
					self.tokendata = ""
					if sstr=="render" and usePigments and self:NextPattern(setrgbapattern) then -- setRGBA(r,g,b)
						local fname, bracket1, r, comma1, g, comma2, b, comma3, a, bracket2 = self.tokendata:match(setrgbapatternG)
						local cr, cg, cb, ca = tonumber(r), tonumber(g), tonumber(b), tonumber(a)
						local col
						if cr and cg and cb and ca then
							col = Color(cr, cg, cb, ca)
						else
							col = Color(0, 0, 0, 0) -- Transparent because its invalid
						end
						addColorToken("function", col, fname)
						addColorToken("bracket", col, bracket1)
						if cr then
							addColorToken("number", col, r)
						else
							addColorToken("notfound", col, r)
						end
						addColorToken("notfound", col, comma1)
						if cg then
							addColorToken("number", col, g)
						else
							addColorToken("notfound", col, g)
						end
						addColorToken("notfound", col, comma2)
						if cb then
							addColorToken("number", col, b)
						else
							addColorToken("notfound", col, b)
						end
						addColorToken("notfound", col, comma3)
						if ca then
							addColorToken("number", col, a)
						end
						addColorToken("bracket", col, bracket2)
						tokenname = "" -- It's custom token
						self.tokendata = ""

					elseif self:NextPattern("^[a-zA-Z][a-zA-Z0-9_]*") then
						local t = libmap[sstr][self.tokendata]
						if t then -- Valid function, woohoo
							tokenname = t == "function" and "function" or "constant"
						else
							tokenname = "identifier"
						end
					end
				end
			else
				tokenname = "identifier"
			end
			if self.tokendata ~= "" then
				addToken(tokenname, self.tokendata)
				self.tokendata = ""
			end
		elseif self:NextPattern("%[=*%[") then -- Multiline strings
			local reps = #self.tokendata:match("%[(=*)%[")
			local ending = "%]"..string.rep("=",reps).."%]"
			while self.character do -- Find the ending ]] if it isnt really multline(who does that?! Shame on you!)
				if self:NextPattern(ending) then
					tokenname = "string"
					break
				end
				if self.character == "\\" then self:NextCharacter() end
				self:NextCharacter()
			end

			if tokenname == "" then -- If no ending ]] was found...
				self.multilinestring = reps
				tokenname = "string"
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
			if tokenname == "" then -- If no ending " was found...
				tokenname = "string"
			else
				self:NextCharacter()
			end
		elseif self:NextPattern("%-%-") then -- Comments
			
			if self:NextPattern("%[=*%[") then -- Block comment
				local reps = #self.tokendata:match("%[(=*)%[")
				while self.character do
					if self:NextPattern("%]"..string.rep("=",reps).."%]") then
						tokenname = "comment"
						break
					end
					if self.character == "\\" then self:NextCharacter() end
					self:NextCharacter()
				end

				if tokenname == "" then -- If no ending ]] was found...
					self.blockcomment = reps
					tokenname = "comment"
				end
				--"string"
			end
			if tokenname == "" then
				tokenname = "comment"
				self:NextPattern("[^@]*") -- Skip everything BEFORE @
				addToken(tokenname, self.tokendata)
				self.tokendata = "" -- we dont need that anymore as we already added it

				self:NextPattern("[%S]*") -- Find first word
				if directives[self.tokendata:sub(2)] then -- Search directives created with SF.Preprocessor.SetGlobalDirective
					tokenname = "directive"
				end
				self:NextPattern(".*") -- Rest of comment/directive
			end
		elseif self:NextPattern("//") then -- Comments
			tokenname = "comment"
			self:NextPattern(".*") -- Rest of comment/directive
		elseif self:NextPattern("/%*") then -- C Block Comments
			while self.character do
				if self:NextPattern("%*/") then
					tokenname = "comment"
					break
				end
				if self.character == "\\" then self:NextCharacter() end
				self:NextCharacter()
			end

			if tokenname == "" then -- If no ending */ was found...
				self.blockcomment = -1
				tokenname = "comment"
			end
		elseif self:NextPattern("[%>%<%!%~]%=") then
			tokenname = "operator"
		elseif self:NextPattern("%.%.%.") then
			-- Manual [...] constant
			tokenname = "constant"
		elseif self:NextPattern("[%+%-%/%*%^%%%#%=%.%>%<]") then
			tokenname = "operator"
		elseif self:NextPattern("%.%.") then -- .. string concat
			tokenname = "operator"
		elseif self:NextPattern("[%{%}%]%[%)%(]") then -- {}()[]
			tokenname = "bracket"
		else
			self:NextCharacter()

			tokenname = "notfound"
		end
		if tokenname ~= "" then
			addToken(tokenname, self.tokendata)
		end
	end

	--So other rows can know that one contians unfinished blockcomment, multiline string etc
	cols.multilinestring = self.multilinestring
	cols.blockcomment = self.blockcomment

	cols.unfinished = self.multilinestring or self.blockcomment
	return cols
end

local incBlock = {["function"]=true,["then"]=true,["do"]=true,["else"]=true}
local decBlock = {["end"]=true,["elseif"]=true,["else"]=true}
local BracketPairs = {
	["{"] = {Removes = {["}"]=true}, Adds = {["{"]=true}},
	["["] = {Removes = {["]"]=true}, Adds = {["["]=true}},
	["("] = {Removes = {[")"]=true}, Adds = {["("]=true}},
	["then"] = {Adds = incBlock, Removes = decBlock},
	["function"] = {Adds = incBlock, Removes = decBlock},
	["do"] = {Adds = incBlock, Removes = decBlock},
	["else"] = {Adds = incBlock, Removes = decBlock},
}
local BracketPairs2 = {
	["}"] = {Adds = {["}"]=true}, Removes = {["{"]=true}},
	["]"] = {Adds = {["]"]=true}, Removes = {["["]=true}},
	[")"] = {Adds = {[")"]=true}, Removes = {["("]=true}},
	["end"] = {Removes = incBlock, Adds = decBlock},
	["elseif"] = {Removes = incBlock, Adds = decBlock},
}

function EDITOR:PopulateContextMenu(menu)
	local caret = self:CursorToCaret()
	if not caret then return end
	local token = self:GetTokenAtPosition(caret)
	if not token then return end
	token = token[3]:Split(".") -- It can have subtoken after dot

	local subtoken = token[2]
	token = token[1]
	self:ResetTokenizer(caret[1])
	self.position = caret[2] - 1
	self:NextCharacter()

	if token == "color" then
		local startpos,endpos
		if subtoken == "number" or subtoken == "notfound" or subtoken == "bracket" then
			while self.character do
				if self.character == "(" then
					startpos = self.position + 1
					break
				end
				self:PrevCharacter()
			end
			while self.character do
				if self.character == ")" then
					endpos = self.position - 1
					break
				end
				self:NextCharacter()
			end
		end
		if subtoken == "function" then
			while self.character do
				if self.character == "(" then
					startpos = self.position + 1
					break
				end
				self:NextCharacter()
			end
			while self.character do
				if self.character == ")" then
					endpos = self.position - 1
					break
				end
				self:NextCharacter()
			end
		end
		if startpos and endpos then
			local colorstr = self.line:sub(startpos,endpos)
			local r,g,b,a = unpack(colorstr:Split(","))
			r, g, b = tonumber(r), tonumber(g), tonumber(b)
			if a then
				a = tonumber(a)
			end

			menu:AddOption("Colorpicker",function()
				local ColorPicker = vgui.Create("StarfallColorPicker")
				ColorPicker:SetColor(Color(r, g, b, a or 255))
				ColorPicker.OnColorPicked = function(_, color)
					self.Start = {caret[1], startpos}
					self.Caret = {caret[1], endpos + 1}
					if a or color.a ~= 255 then
						self:SetSelection(string.format("%d, %d, %d, %d", color.r, color.g, color.b, color.a))
					else
						self:SetSelection(string.format("%d, %d, %d", color.r, color.g, color.b))
					end
				end
				ColorPicker:Open()
			end)
		end
	end

end
function EDITOR:PaintTextOverlay()
	local bracket,bracketindex = self:GetTokenAtPosition(self.Caret)
	local width, height = self.FontWidth, self.FontHeight
	local lines = #self.RowTexts
	if bracket then
		bracket = bracket[1]
	end
	if bracket and BracketPairs[bracket] or BracketPairs2[bracket] then
		local sum = 0
		local startPos = bracketindex
		local line = self.Caret[1]
		local x, y
		local cBracketPos = 0
		local bracketLength = #bracket
		local tokens = self:GetRowCache(line)
		local length = 0
		if BracketPairs[bracket] then
			local lookup = BracketPairs[bracket]
			while line < lines and not y do
				tokens = self:GetRowCache(line)
				if not tokens then break end
				x = 0
				for I = 1, #tokens do
					local text = tokens[I][1]
					if I < startPos then
						x = x + #text
						cBracketPos = x
						continue
					end
					if lookup.Removes[text] and sum>0 then
						sum = sum - 1
						if lookup.Adds[text] and sum>0 then
							sum = sum + 1
						end
					elseif lookup.Adds[text] then
						sum = sum + 1
					end
					if sum < 0 then return end
					if sum == 0 then
						y = line
						x = x + 1
						length = #text
						break
					end
					x = x + #text
				end
				startPos = 1
				line = line + 1
			end
		else--Reverse search
			local lookup = BracketPairs2[bracket]
			startPos = bracketindex
			line = self.Caret[1]
			tokens = self:GetRowCache(line)
			while line > 0 and not y do
				x = 0
				for I = #tokens, 1, -1 do
					local text = tokens[I][1]
					if I > startPos then
						x = x + #text
						cBracketPos = x
						continue
					end
					if lookup.Removes[text] and sum>0 then
						sum = sum - 1
						if lookup.Adds[text] and sum>0 then
							sum = sum + 1
						end
					elseif lookup.Adds[text] then
						sum = sum + 1
					end
					if sum == 0 then
						y = line
						length = #text
						x = #self:GetRowText(line) - x - length + 1
						cBracketPos = #self:GetRowText(self.Caret[1]) - cBracketPos - bracketLength
						break
					end
					x = x + #text
				end
				line = line - 1
				if line < 1 then break end
				tokens = self:GetRowCache(line)
				if not tokens then break end
				startPos = #tokens
			end
		end
		if x and y then
			if not self.Rows[y][3] then
				surface_SetDrawColor(colors.word_highlight.r,colors.word_highlight.g,colors.word_highlight.b,100)
				surface_DrawRect((x-self.Scroll[2]) * width + self.LineNumberWidth + self.FontWidth - 1, (y - self:GetRowOffset(y) -self.Scroll[1]) * height + 1, length*width-2, height-2)
			end
			surface_SetDrawColor(colors.word_highlight.r,colors.word_highlight.g,colors.word_highlight.b,100)
			surface_DrawRect((cBracketPos-self.Scroll[2] +1) * width + self.LineNumberWidth + self.FontWidth - 1, (self.Caret[1] - self:GetRowOffset(self.Caret[1]) -self.Scroll[1]) * height + 1, bracketLength*width-2, height-2)

		end
	end

end
return EDITOR
