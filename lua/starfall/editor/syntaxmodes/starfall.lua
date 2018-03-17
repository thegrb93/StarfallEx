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
local storageTypes = {
	["function"] = { [true] = true, [false] = true },
	["local"] = { [true] = true },
}
local keywords = {
	-- keywords that can be followed by a "(":
	["if"] = { [true] = true, [false] = true },
	["elseif"] = { [true] = true, [false] = true },
	["while"] = { [true] = true, [false] = true },
	["for"] = { [true] = true, [false] = true },

	["repeat"] = { [true] = true, [false] = true },
	["until"] = { [true] = true, [false] = true },
	["and"] = { [true] = true, [false] = true },
	["or"] = { [true] = true, [false] = true },
	["not"] = { [true] = true, [false] = true },

	-- keywords that cannot be followed by a "(":
	["true"] = { [true] = true },
	["false"] = { [true] = true },
	["do"] = { [true] = true, [false] = true },
	["else"] = { [true] = true },
	["break"] = { [true] = true },
	["continue"] = { [true] = true },
	["then"] = { [true] = true },
	["end"] = { [true] = true },
	["in"] = { [true] = true },
	["return"] = { [true] = true },
	["nil"] = { [true] = true },
}

-- fallback for nonexistant entries:
setmetatable(keywords, { __index = function(tbl, index) return {} end })
setmetatable(storageTypes, { __index = function(tbl, index) return {} end })

local directives = {
	["@name"] = 0,
	["@author"] = 0,
	["@include"] = 0,
	["@includedir"] = 0,
	["@shared"] = 0,
	["@client"] = 0,
	["@server"] = 0,
	["@model"] = 0,
}
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
	end
	cols[#cols + 1] = { tokendata, { textcolor, bgcolor, 0 }, "color" }
	lastcol = cols[#cols]
end

function EDITOR:BlockCommentSelection(removecomment)
	local sel_start, sel_caret = self:MakeSelection(self:Selection())
	local mode = self:GetParent().BlockCommentStyleConVar:GetInt()

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

	found = self:NextPattern("local%s*function")  -- local function
	if found then
		local l, spaces, f = self.tokendata:match("(local)(%s*)(function)")

		addToken("keyword", l)
		if spaces and #spaces>0 then addToken("whitespace", spaces) end
		addToken("storageType", f) -- Add "function"

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
			elseif self:NextPattern(rgbapattern) then -- Color(r,g,b)
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
		elseif self:NextPattern("^[0-9][0-9.e]*") then
			tokenname = "number"
		elseif self:NextPattern("^%:[a-zA-Z][a-zA-Z0-9_]*") then -- Methods
			addToken("operator", self.tokendata:sub(1, 1)) -- Adding : as operator
			self.tokendata = self.tokendata:sub(2)  -- Operator was handled, so remove it from tokendata
			if libmap["Methods"][self.tokendata] then
				tokenname = "method"
			else
				tokenname = "notfound"
			end
		elseif self:NextPattern("^[a-zA-Z][a-zA-Z0-9_]*") then
			local sstr = self.tokendata

			-- is this a keyword or a function?
			local char = self.character or ""
			local keyword = char ~= "("

			if storageTypes[sstr][keyword] then
				tokenname = "storageType"
			elseif keywords[sstr][keyword] then
				tokenname = "keyword"
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
							tokenname = "notfound"
						end
					end
				end
			else
				tokenname = "notfound"
			end
			if self.tokendata ~= "" then
				addToken(tokenname, self.tokendata)
				self.tokendata = ""
			end

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
			if tokenname == "" then -- If no ending " was found...
				tokenname = "string"
			else
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
				self.tokendata = "" -- we dont need that anymore as we already added it

				self:NextPattern("[%S]*") -- Find first word
				if directives[self.tokendata] then --Directive
					tokenname = "directive"
				end
				self:NextPattern(".*") -- Rest of comment/directive
			end
		elseif self:NextPattern("[%+%-%/%*%^%%%#]") then
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

return EDITOR
