----------------------------------------------------
-- That's not implemented hovewer it shows template
----------------------------------------------------

local TabHandler = {
	ControlName = "sf_helper", -- Its name of vgui panel used by handler, there has to be one
	IsEditor = false, -- If it should be treated as editor of file, like ACE or Wire
 }
local PANEL = {} -- It's our VGUI

----------------
-- Handler part
----------------

function TabHandler:init() -- It's caled when editor is initalized, you can create library map there etc

end

function TabHandler:registerSettings() -- Setting panels should be registered there

end

function TabHandler:cleanup() -- Called when editor is reloaded/removed

end


-------------
-- VGUI part
-------------

function PANEL:Init() --That's init of VGUI like other PANEL:Methods(), separate for each tab
	local html = vgui.Create("DHTML", self)
	html:Dock(FILL)
	html:DockMargin(0, 0, 0, 0)
	html:DockPadding(0, 0, 0, 0)
	html:SetKeyboardInputEnabled(true)
	html:SetMouseInputEnabled(true)
	html:OpenURL("http://thegrb93.github.io/StarfallEx/libraries/bass.html")
	html:AddFunction( "sf", "updateTitle", function( str )
		self.title = str
	end )
	html.OnDocumentReady = function(_, url )
		self.url = url
		html:RunJavascript( "sf.updateTitle( document.title );" )
	end
end

function PANEL:getCode() -- Return name of hanlder or code if it's editor
	return "@name "..self.title
end

function PANEL:setCode()

end

function PANEL:OnFocusChanged(gained) -- When this tab is opened

end

function PANEL:validate(movecarret) -- Validate request, has to return success,message

end
--------------
-- We're done
--------------
vgui.Register(TabHandler.ControlName, PANEL, "DPanel") -- Registering VGUI element of handler
return TabHandler -- Our file has to return table of handler
