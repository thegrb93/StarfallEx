-------------------------------------------------------------------------------
-- SF Editor.
-- Functions for setting up the code editor, as well as helper functions for
-- sending code over the network.
-------------------------------------------------------------------------------

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
	
	--[[
	-- E2 colors
	local colors = {
		["keyword"]		= { Color(160,240,240), false }, -- teal
		["operator"]	= { Color(224,224,224), false }, -- white
		["brackets"]	= { Color(224,224,224), false }, -- white
		
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
		["brackets"]	= { Color(224, 224, 224), false},
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
	local colors = {
		["keyword"]     = { Color(100, 100, 255), false},
		["operator"]    = { Color(150, 150, 200), false},
		["brackets"]    = { Color(120, 120, 255), false},
		["number"]      = { Color(174, 129, 255), false},
		["variable"]    = { Color(248, 248, 242), false},
		["string"]      = { Color(230, 219, 116), false},
		["comment"]     = { Color(133, 133, 133), false},
		["ppcommand"]   = { Color(170, 170, 170), false},
		["notfound"]    = { Color(240,  96,  96), false},
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
			local spaces = self:SkipPattern( "^%s*" )
			if spaces then addToken( "comment", spaces ) end
	
			if self:NextPattern( "^%a[%w_]*" ) then -- Variables and keywords
				if keywords[self.tokendata] then
					addToken( "keyword", self.tokendata )
				else
					addToken( "variable", self.tokendata )
				end
			elseif self:NextPattern( "^%d*%.?%d+" ) then -- Numbers
				addToken( "number", self.tokendata )
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
			elseif self:NextPattern( "^[\"']" ) then -- Single line string
				if findStringEnding( self,row, self.tokendata ) then -- String ending found
					addToken( "string", self.tokendata )
				else -- No ending found
					self:NextPattern( ".*" ) -- Eat everything
					addToken( "string", self.tokendata )
				end
			elseif self:NextPattern( "^%[%[" ) then -- Multi line strings
				if findMultilineEnding( self, row, "string" ) then -- Ending found
					addToken( "string", self.tokendata )
				else -- Ending not found
					self:NextPattern( ".*" )
					addToken( "string", self.tokendata )
				end
			elseif self:NextPattern( "^[%+%-/%*%^%%#=~,;:%._<>]" ) then -- Operators
				addToken( "operator", self.tokendata )
			elseif self:NextPattern("^[%(%)%[%]{}]") then
				addToken( "brackets", self.tokendata)
			else
				self:NextCharacter()
				addToken( "notfound", self.tokendata )
			end
			self.tokendata = ""
		end
		
		return cols
	end
	
	local code1 = "--@name \n--@author \n\n"
	local code2 = "--[[\n" .. [[    Starfall Scripting Environment

    More info: http://inpstarfall.github.io/Starfall
    Github: http://github.com/INPStarfall/Starfall
    Reference Page: http://sf.inp.io
    Development Thread: http://www.wiremod.com/forum/developers-showcase/22739-starfall-processor.html
]] .. "]]"

	--- (Client) Intializes the editor, if not initialized already
	function SF.Editor.init()
		if SF.Editor.editor then return end
		
		SF.Editor.editor = vgui.Create("Expression2EditorFrame")

		-- Change default event registration so we can have custom animations for starfall
		function SF.Editor.editor:SetV(bool)
			local wire_expression2_editor_worldclicker = GetConVar("wire_expression2_editor_worldclicker")

			if bool then
				self:MakePopup()
				self:InvalidateLayout(true)
				if self.E2 then self:Validate() end
			end
			self:SetVisible(bool)
			self:SetKeyBoardInputEnabled(bool)
			self:GetParent():SetWorldClicker(wire_expression2_editor_worldclicker:GetBool() and bool) -- Enable this on the background so we can update E2's without closing the editor
			if CanRunConsoleCommand() then
				RunConsoleCommand("starfall_event", bool and "editor_open" or "editor_close")
			end
		end


		SF.Editor.editor:Setup( "SF Editor", "starfall", "" ) -- Setting the editor type to not nil keeps the validator line
		
		if not file.Exists("starfall", "DATA") then
			file.CreateDir("starfall")
		end
		
		-- Set Existing 'Save As' & 'Save & Exit' Button Size.
		do
			local editor = SF.Editor.editor
			local sav = editor.C.SavAs
			local sae = editor.C.SaE

			sav:SetSize( 100, 20 )
			sae:SetSize( 100, 20 )
		end

		-- Add "Sound Browser" button
		do
			local editor = SF.Editor.editor
			local SoundBrw = vgui.Create( "DButton", editor.C.Menu )
			SoundBrw:SetText( "Sound Browser" )
			SoundBrw:SetSize( 100, 20 )
			SoundBrw:Dock( RIGHT )
			SoundBrw.DoClick = function ()
				RunConsoleCommand( "wire_sound_browser_open" )
			end
			editor.C.SoundBrw = SoundBrw
		end
		
		-- Add "SFHelper" button
		do
			local editor = SF.Editor.editor
			local SFHelp = vgui.Create( "DButton", editor.C.Menu )
			SFHelp:SetText( "SFHelper" )
			SFHelp:SetSize( 100, 20 )
			SFHelp:Dock( RIGHT )
			SFHelp.DoClick = function ()
				SF.Helper.show()
			end
			editor.C.SFHelp = SFHelp
		end
		
		SF.Editor.editor:SetSyntaxColorLine( SyntaxColorLine )
		--SF.Editor.editor:SetSyntaxColorLine( function(self, row) return {{self.Rows[row], Color(255,255,255)}} end)
		
		-- This prefills our code when a new 'tab' is made.
		function SF.Editor.editor:OnTabCreated ( tab )
			local editor = tab.Panel
			editor:SetText( code1 .. code2 )
			editor.Start = editor:MovePosition( { 1, 1 }, #code1 )
			editor.Caret = editor:MovePosition( editor.Start, #code2 )
		end
		
		local editor = SF.Editor.editor:GetCurrentEditor()
		
		function SF.Editor.editor:Validate ( gotoerror )
			local err = CompileString( self:GetCode(), "SF:" .. ( self:GetChosenFile() or "main" ), false )
			
			if type( err ) == "string" then
				self.C.Val:SetBGColor( 128, 0, 0, 180 )
				self.C.Val:SetFGColor( 255, 255, 255, 128 )
				self.C.Val:SetText( "   " .. err )
			else
				self.C.Val:SetBGColor( 0, 128, 0, 180 )
				self.C.Val:SetFGColor( 255, 255, 255, 128 )
				self.C.Val:SetText( "   No Syntax Errors" )
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
		tbl.filecount = 0
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
				code = file.Read("Starfall/"..path, "DATA") or error("Bad include: "..path,0)
			end
			
			tbl.files[path] = code
			SF.Preprocessor.ParseDirectives(path,code,{},ppdata)
			
			if ppdata.includes and ppdata.includes[path] then
				local inc = ppdata.includes[path]
				if not tbl.includes[path] then
					tbl.includes[path] = inc
					tbl.filecount = tbl.filecount + 1
				else
					assert(tbl.includes[path] == inc)
				end
				
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


	-- CLIENT ANIMATION

	local busy_players = {}
	hook.Add("EntityRemoved", "starfall_busy_animation", function(ply)
		busy_players[ply] = nil
	end)

	local emitter = ParticleEmitter(vector_origin)

	net.Receive("starfall_editor_status", function(len)
		local ply = net.ReadEntity()
		local status = net.ReadBit() ~= 0 -- net.ReadBit returns 0 or 1, despite net.WriteBit taking a boolean
		if not ply:IsValid() or ply == LocalPlayer() then return end

		busy_players[ply] = status or nil
	end)

	local rolldelta = math.rad(80)
	timer.Create("starfall_editor_status", 1/3, 0, function()
		rolldelta = -rolldelta
		for ply, _ in pairs(busy_players) do
			local BoneIndx = ply:LookupBone("ValveBiped.Bip01_Head1") or ply:LookupBone("ValveBiped.HC_Head_Bone") or 0
			local BonePos, BoneAng = ply:GetBonePosition(BoneIndx)
			local particle = emitter:Add("radon/starfall2", BonePos + Vector(math.random(-10,10), math.random(-10,10), 60+math.random(0,10)))
			if particle then
				particle:SetColor(math.random(30,50),math.random(40,150),math.random(180,220) )
				particle:SetVelocity(Vector(0, 0, -40))

				particle:SetDieTime(1.5)
				particle:SetLifeTime(0)

				particle:SetStartSize(10)
				particle:SetEndSize(5)

				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)

				particle:SetRollDelta(rolldelta)
			end
		end
	end)

else

	-- SERVER STUFF HERE
	-- -------------- client-side event handling ------------------
	-- this might fit better elsewhere

	util.AddNetworkString("starfall_editor_status")

	resource.AddFile( "materials/radon/starfall2.png" )
	resource.AddFile( "materials/radon/starfall2.vmt" )
	resource.AddFile( "materials/radon/starfall2.vtf" )

	local starfall_event = {}


	concommand.Add("starfall_event", function(ply, command, args)
		local handler = starfall_event[args[1]]
		if not handler then return end
		return handler(ply, args)
	end)


	-- actual editor open/close handlers


	function starfall_event.editor_open(ply, args)
		net.Start("starfall_editor_status")
		net.WriteEntity(ply)
		net.WriteBit(true)
		net.Broadcast()
	end


	function starfall_event.editor_close(ply, args)
		net.Start("starfall_editor_status")
		net.WriteEntity(ply)
		net.WriteBit(false)
		net.Broadcast()
	end

end
