
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
		
		--SF.Editor.editor:SetSyntaxColorLine( highlighter )
		SF.Editor.editor:SetSyntaxColorLine( function(self, row) return {{self.Rows[row], Color(255,255,255)}} end)
		
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
