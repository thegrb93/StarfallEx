SF.Editor = {}

-- TODO: Server-side controls

--- Includes table
-- @name Includes table
-- @class table
-- @field mainfile Main file
-- @field files filename : file contents pairs

if CLIENT then
	--- (Client) Intializes the editor, if not initialized already
	function SF.Editor.init()
		if SF.Editor.editor then return end
		SF.Editor.editor = vgui.Create("Expression2EditorFrame")
		SF.Editor.editor:Setup("SF Editor", "Starfall", "nothing") -- Setting the editor type to not nil keeps the validator line
		
		-- Highlighting
		SF.Editor.editor:SetSyntaxColorLine(SF.Editor.highlighter)
		--SF.Editor.editor:SetSyntaxColorLine( function(self, row) return {{self.Rows[row], Color(255,255,255)}} end)
		
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
		
		local oldNewTab = SF.Editor.editor.NewTab
		function SF.Editor.editor:NewTab(p) 
			oldNewTab(self, p)
			self:SetCode([=[--@name 
--@author

-- Starfall Scripting Environment
-- ==============================
-- 
-- Starfall author: Colonel Thirty Two
-- More info: http://colonelthirtytwo.net/index.php/starfall/
-- Reference Page: http://colonelthirtytwo.net/sfdoc/
-- Development Thread: http://www.wiremod.com/forum/developers-showcase/22739-starfall-processor.html
-- Blog: http://blog.colonelthirtytwo.net/
--
]=])
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
	
	--- A highlighter block
	do
		local keywords = {
			"and", "break", "do", "else", "elseif",
			"end", "false", "for", "function", "if", 
			"in", "local", "nil", "not", "or",
			"repeat", "return", "then", "true", "until", "while"
		}
		
		local colors = {
			["keyword"]   	= { Color(160, 240, 240), false},
			["operator"]  	=  { Color(224, 224, 224), false},
			["expression"] 	=    { Color(160, 160, 240), false},
			
			["number"]    	=  { Color(240, 160, 160), false}, 
			["string"]    	=  { Color(128, 128, 128), false}, 
			["globals"]     = { Color(180, 180, 260), false},
			
			["comment"] 	=  { Color(0, 255, 0), false},
			["ppcommand"] 	= { Color(240, 240, 160), false},
			
			["notfound"]  	= { Color(240,  96,  96), false}, 
		}
		
		--- (Client) Highlight
		-- TODO (Hard) Do correct multiline things highlightion 
		-- In fact need to rewrite the whole editor component because of its highlight specialities
		function SF.Editor.highlighter(self, row)
			local cols = {}
			self:ResetTokenizer(row)
			self:NextCharacter()
			
			while self.character do
				local tokenname = ""
				self.tokendata = ""

				self:NextPattern(" *")
				if !self.character then break end
	
				-- Numbers
				if self:NextPattern("^0[xb][0-9A-F]+") then
					tokenname = "number"
				elseif self:NextPattern("^[0-9][0-9.e]*") then
					tokenname = "number"
					
				-- Keyword/expression
				elseif self:NextPattern("^[a-zA-Z0-9_]+") then
					local sstr = self.tokendata:Trim()
					
					if table.HasValue(keywords, sstr) then
						tokenname = "keyword"
					elseif SF.DefaultEnvironment[sstr] != nil then
						tokenname = "globals"
					else
						tokenname = "expression"
					end
				
				-- String
				elseif self.character == "'" or self.character == "\""  then
					self.stringDelimiter = self.character
					self:NextCharacter()
					
					while self.character and self.character != self.stringDelimiter do
						if self.character == "\\" then self:NextCharacter() end
						self:NextCharacter()
					end
					self:NextCharacter()
					
					tokenname = "string"
					
				-- Comment
				elseif self:NextPattern("^%-%-.*$") then
					if string.sub(self.tokendata, 1, 3) == "--@" then
						tokenname = "ppcommand"
					else
						tokenname = "comment"
					end
					
				-- Operator
				else
					self:NextCharacter()
					tokenname = "operator"
				end

				color = colors[tokenname]
				if #cols > 1 and color == cols[#cols][2] then
					cols[#cols][1] = cols[#cols][1] .. self.tokendata
				else
					cols[#cols + 1] = {self.tokendata, color}
				end
			end
			
			return cols
		end
	end
else
end
