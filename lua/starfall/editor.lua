
SF.Editor = {}

-- TODO: Server-side controls

--- Includes table
-- @name Includes table
-- @class table
-- @field mainfile Main file
-- @field files filename : file contents pairs

if CLIENT then

	local keywords = {
		["if"] = true,
		["elseif"] = true,
		["else"] = true,
		["then"] = true,
		["end"] = true,
		
		["while"] = true,
		["for"] = true,
		["in"] = true,
		
		["do"] = true,
		["repeat"] = true,
		["until"] = true,
		
		["function"] = true,
		["local"] = true,
		["return"] = true,
		
		["and"] = true,
		["or"] = true,
		["not"] = true,
		
		["true"] = true,
		["false"] = true,
		["nil"] = true,
	}
	
	local operators = {
		["+"] = true,
		["-"] = true,
		["/"] = true,
		["*"] = true,
		["^"] = true,
		["%"] = true,
		["#"] = true,
		["="] = true,
		["=="] = true,
		["~="] = true,
		[","] = true,
		["."] = true,
		["<"] = true,
		[">"] = true,
		
		["{"] = true,
		["}"] = true,
		["("] = true,
		[")"] = true,
		["["] = true,
		["]"] = true,
		
		["_"] = true,
	}
	
	local operatorstr = "%+%-/%*%^%%#=~,%.%(%)%[%]{}_" -- A string of all operators, used in the patterns below
	
	--[[
	-- E2 colors
	local colors = {
		["keyword"]		= { Color(160,240,240), false }, -- teal
		["operator"]	= { Color(224,224,224), false }, -- white
		
		["function"]	= { Color(160,160,240), false }, -- blue
		["number"]		= { Color(240,160,160), false }, -- light red
		["variable"]	= { Color(160,240,160), false }, -- green
		
		["string"]		= { Color(160,160,160), false }, -- gray
		["comment"]		= { Color(160,160,160), false }, -- gray
		
		["ppcommand"]	= { Color(240,240,160), false }, -- pink
		["notfound"]	= { Color(240, 96, 96), false }, -- dark red
	}
	
	-- Colors originally by Cenius; slightly modified by Divran
	local colors = {
		["keyword"]		= { Color(160, 240, 240), false},
		["operator"]	= { Color(224, 224, 224), false},
		["function"]	= { Color(160, 160, 240), false}, -- Was originally called "expression"
		
		["number"]		= { Color(240, 160, 160), false}, 
		["string"]		= { Color(160, 160, 160), false}, -- Changed to lighter grey so it isn't the same as comments
		["variable"]	= { Color(180, 180, 260), false}, -- Was originally called "globals".
		
		--["comment"] 	= { Color(0, 255, 0), false}, -- Cenius' original comment color was green... imo not very nice
		["comment"]		= { Color(128,128,128), false }, -- Changed to grey
		
		["ppcommand"]	= { Color(240, 240, 160), false},
		
		["notfound"]	= { Color(240,  96,  96), false}, 
	}
	]]
	
	--Sublime text editor inspired colors
	local colors = {
		["keyword"]	= { Color(249,  38, 114), false}, -- pink
		["operator"]	= { Color(248, 248, 248), false}, -- pink
		["number"]		= { Color(174, 129, 255), false}, -- purpleish
		["variable"]	= { Color(248, 248, 242), false}, -- white
		["string"]		= { Color(230, 219, 116), false}, -- yellowish
		["function"]	= { Color(102, 217, 239), false}, -- teal
		
		["comment"]		= { Color(133, 133, 133), false}, -- grey
		["ppcommand"]   = { Color(240, 240, 160), false}, -- It was the same as "string". Hurt eyes. (Copy-paste mistake?) Now the same as from E2's editor
		
		["notfound"]	= { Color(240,  96,  96), false}, -- dark red
	}
	
	-- cols[n] = { tokendata, color }
	local cols = {}
	local lastcol
	local function addToken(tokenname, tokendata)
		local color = colors[tokenname]
		if lastcol and color == lastcol[2] then
			lastcol[1] = lastcol[1] .. tokendata
		else
			cols[#cols + 1] = { tokendata, color, tokenname }
			lastcol = cols[#cols]
		end
	end
	
	local string_gsub = string.gsub
	local string_find = string.find
	local string_sub = string.sub
	local string_format = string.format
	
	local function findStringEnding(self,row,char)
		char = char or '"'
		
		while self.character do
			if self:NextPattern( ".-"..char ) then -- Found another string char (' or ")
				if self.tokendata[#self.tokendata-1] ~= "\\" then -- Ending found
					return true
				end
			else -- Didn't find another :(
				return false
			end
			
			self:NextCharacter()		
		end
		
		return false
	end

	local function findMultilineEnding(self,row,what) -- also used to close multiline comments
		if self:NextPattern( ".-%]%]" ) then -- Found ending
			return true
		end
		
		self.multiline = what
		return false
	end
	
	local table_concat = table.concat
	local string_gmatch = string.gmatch
	
	local function findInitialMultilineEnding(self,row,what)
		if row == self.Scroll[1] then
			-- This code checks if the visible code is inside a string or a block comment
			self.multiline = nil
			local singleline = false

			local str = string_gsub( table_concat( self.Rows, "\n", 1, self.Scroll[1]-1 ), "\r", "" )
			
			for before, char, after in string_gmatch( str, "()([%-\"'\n%[%]])()" ) do
				before = string_sub( str, before-1, before-1 )
				after = string_sub( str, after, after+2 )
				
				if not self.multiline and not singleline then
					if char == '"' or char == "'" or (char == "-" and after[1] == "-" and after ~= "-[[") then
						singleline = true
					elseif char == "-" and after == "-[[" then
						self.multiline = "comment"
					elseif char == "[" and after[1] == "[" then
						self.multiline = "string"
					end
				elseif singleline and ((char == "'" or char == '"') and before ~= "\\" or char == "\n") then
					singleline = false
				elseif self.multiline and char == "]" and after[1] == "]" then
					self.multiline = nil
				end
			end
		end
	end

	-- TODO: remove all the commented debug prints
	local function SyntaxColorLine(self,row)
		cols,lastcol = {}, nil
		self:ResetTokenizer(row)
		findInitialMultilineEnding(self,row,self.multiline)
		self:NextCharacter()
		
		if self.multiline then
			if findMultilineEnding(self,row,self.multiline) then
				addToken( self.multiline, self.tokendata )
				self.multiline = nil
			else
				self:NextPattern( ".*" )
				addToken( self.multiline, self.tokendata )
				return cols
			end
			self.tokendata = ""
		end

		while self.character do
			self.tokendata = ""
			
			-- Eat all spaces
			local spaces = self:SkipPattern( "^ *" )
			if spaces then addToken( "comment", spaces ) end
	
			if self:NextPattern( "^%a[%w_]*" ) then -- Variables and keywords
				if keywords[self.tokendata] then
					addToken( "keyword", self.tokendata )
				else
					local found = false
					
					local builtins = SF.DefaultEnvironment
					for funcname,_ in pairs( builtins ) do
						if self.tokendata == funcname then
							addToken( "function", self.tokendata )
							found = true
							break
						end
					end
					
					if not found then
						local libraries = SF.Libraries.libraries
						for libname,lib in pairs( libraries ) do -- Check library name
							if self.tokendata == libname then -- match!
								addToken( "function", self.tokendata )
								found = true
								break
							else -- No match. Check function name instead
								for funcname,func in pairs( lib.__index ) do
									if self.tokendata == funcname then -- match!
										addToken( "function", self.tokendata )
										found = true
										break
									end
								end
							end
						end
					end
					
					if not found then
						--print("Found variable '" .. self.tokendata .. "'" )
						addToken( "variable", self.tokendata )
					end
				end
				
				self.tokendata = ""
			elseif self:NextPattern( "^%d+" ) then -- Numbers
				addToken( "number", self.tokendata )
				self.tokendata = ""
			
			elseif self:NextPattern( "^%-%-" ) then -- Comment
				if self:NextPattern( "^@" ) then -- ppcommand
					self:NextPattern( ".*" ) -- Eat all the rest
					addToken( "ppcommand", self.tokendata )
				elseif self:NextPattern( "^%[%[" ) then -- Multi line comment
					if findMultilineEnding( self, row, "comment" ) then -- Ending found
						addToken( "comment", self.tokendata )
					else -- Ending not found
						self:NextPattern( ".*" )
						addToken( "comment", self.tokendata )
					end
				else
					self:NextPattern( ".*" ) -- Skip the rest
					addToken( "comment", self.tokendata )
				end
				
				self.tokendata = ""
			elseif self:NextPattern( "^[\"']" ) then -- Single line string
				if findStringEnding( self,row, self.tokendata ) then -- String ending found
					addToken( "string", self.tokendata )
					self.tokendata = ""
				else -- No ending found
					self:NextPattern( ".*" ) -- Eat everything
					addToken( "string", self.tokendata )
					self.tokendata = ""
				end
			elseif self:NextPattern( "^%[%[" ) then -- Multi line strings
				if findMultilineEnding( self, row, "string" ) then -- Ending found
					addToken( "string", self.tokendata )
				else -- Ending not found
					self:NextPattern( ".*" )
					addToken( "string", self.tokendata )
				end
				
				self.tokendata = ""
			elseif self:NextPattern( "^[" .. operatorstr .. "]" ) then -- Operators
				addToken( "operator", self.tokendata )
				self.tokendata = ""
			else
				self:NextCharacter()
				addToken( "notfound", self.tokendata )
			end
			
		end
		
		if self.tokendata ~= "" then
			addToken( "notfound", self.tokendata )
		end
		
		return cols
	end
	
	local code1 = "--@name \n--@author \n\n"
	local code2 = "--[[\n" .. [[    Starfall Scripting Environment

    More info: http://colonelthirtytwo.net/index.php/starfall/
    Reference Page: http://colonelthirtytwo.net/sfdoc/
    Development Thread: http://www.wiremod.com/forum/developers-showcase/22739-starfall-processor.html
    Blog: http://blog.colonelthirtytwo.net/
]] .. "]]"

	--- (Client) Intializes the editor, if not initialized already
	function SF.Editor.init()
		if SF.Editor.editor then return end
		
		SF.Editor.editor = vgui.Create("Expression2EditorFrame")
		SF.Editor.editor:Setup("SF Editor", "Starfall", "nothing") -- Setting the editor type to not nil keeps the validator line
		
		SF.Editor.editor:SetSyntaxColorLine( SyntaxColorLine )
		--SF.Editor.editor:SetSyntaxColorLine( function(self, row) return {{self.Rows[row], Color(255,255,255)}} end)
		
		function SF.Editor.editor:OnTabCreated( tab )
			local editor = tab.Panel
			editor:SetText( code1 .. code2 )
			editor.Start = editor:MovePosition({1,1}, #code1)
			editor.Caret = editor:MovePosition(editor.Start, #code2)
		end
		
		local editor = SF.Editor.editor:GetCurrentEditor()
		editor.Start = editor:MovePosition({1,1}, #code1)
		editor.Caret = editor:MovePosition(editor.Start, #code2)
		
		function SF.Editor.editor:Validate(gotoerror)
			local err = CompileString(self:GetCode(), "SF:"..(self:GetChosenFile() or "main"), false)
			
			if type(err) == "string" then
				self.C['Val'].panel:SetBGColor(128, 0, 0, 180)
				self.C['Val'].panel:SetFGColor(255, 255, 255, 128)
				self.C['Val'].panel:SetText( "   " .. err )
			else
				self.C['Val'].panel:SetBGColor(0, 128, 0, 180)
				self.C['Val'].panel:SetFGColor(255, 255, 255, 128)
				self.C['Val'].panel:SetText( "   No Syntax Errors" )
			end
		end
	end
	
	--- (Client) Returns true if initialized
	function SF.Editor.isInitialized()
		return SF.Editor.editor and true or false
	end
	
	--- (Client) Opens the editor. Initializes it first if needed.
	function SF.Editor.open()
		SF.Editor.init()
		SF.Editor.editor:Open()
	end
	
	--- (Client) Gets the filename of the currently selected file.
	-- @return The open file or nil if no files opened or not initialized
	function SF.Editor.getOpenFile()
		if not SF.Editor.editor then return nil end
		return SF.Editor.editor:GetChosenFile()
	end
	
	--- (Client) Gets the current code inside of the editor
	-- @return Code string or nil if not initialized
	function SF.Editor.getCode()
		if not SF.Editor.editor then return nil end
		return SF.Editor.editor:GetCode()
	end
	
	--- (Client) Builds a table for the compiler to use
	-- @param maincode The source code for the main chunk
	-- @param codename The name of the main chunk
	-- @return True if ok, false if a file was missing
	-- @return A table with mainfile = codename and files = a table of filenames and their contents, or the missing file path.
	function SF.Editor.BuildIncludesTable(maincode, codename)
		local tbl = {}
		maincode = maincode or SF.Editor.getCode()
		codename = codename or SF.Editor.getOpenFile() or "main"
		tbl.mainfile = codename
		tbl.files = {}
		tbl.includes = {}

		local loaded = {}
		local ppdata = {}

		local function recursiveLoad(path)
			if loaded[path] then return end
			loaded[path] = true
			
			local code
			if path == codename and maincode then
				code = maincode
			else
				code = file.Read("Starfall/"..path) or error("Bad include: "..path,0)
			end
			
			tbl.files[path] = code
			SF.Preprocessor.ParseDirectives(path,code,{},ppdata)
			
			if ppdata.includes and ppdata.includes[path] then
				local inc = ppdata.includes[path]
				tbl.includes[path] = inc
				for i=1,#inc do
					recursiveLoad(inc[i])
				end
			end
		end
		local ok, msg = pcall(recursiveLoad, codename)
		if ok then
			return true, tbl
		elseif msg:sub(1,13) == "Bad include: " then
			return false, msg
		else
			error(msg,0)
		end
	end
else
end
