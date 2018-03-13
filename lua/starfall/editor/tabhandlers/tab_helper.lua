local TabHandler = {
	ControlName = "sf_helper", -- Its name of vgui panel used by handler, there has to be one
	IsEditor = false, -- If it should be treated as editor of file, like ACE or Wire
 }
local PANEL = {} -- It's our VGUI

-------------------------------
-- Handler part (Tab Handler)
-------------------------------

function TabHandler:init() -- It's caled when editor is initalized, you can create library map there etc
end

function TabHandler:registerSettings() -- Setting panels should be registered there

end

function TabHandler:registerTabMenu(menu, content)
	menu:AddOption("Undock",function()
		local helper = vgui.Create("StarfallFrame")
		helper:SetSize(1280, 615)
		helper:Center()
		helper:SetTitle("SF Helper")
		content.html:SetParent(helper)
		helper.html = content.html

		helper.html:AddFunction( "sf", "updateTitle", function( str )
			helper:SetTitle(str)
		end )
		helper.html.OnDocumentReady = function(_, url )
			helper.url = url
			helper.html:RunJavascript( "sf.updateTitle( document.title );" )
		end
		local _mpressed = helper.OnMousePressed
		helper.OnMousePressed = function(pnl, keycode, ...)
			if keycode == MOUSE_RIGHT then
				local menu = DermaMenu()
				menu:AddOption("Dock",function()
					local editor = SF.Editor.editor
					local sheet = editor:CreateTab("","helper")
					local content = sheet.Tab.content
					editor:SetActiveTab(sheet.Tab)
					content.html:Remove()
					content.html = helper.html
					content.html:SetParent(content)
					content.html:AddFunction( "sf", "updateTitle", function( str )
						content.title = str
					end )
					content.html.OnDocumentReady = function(self, url )
						content.url = url
						html:RunJavascript( "sf.updateTitle( document.title );" )
						content:UpdateTitle(content.title)
					end
					helper:Remove()
				end)
				menu:AddOption("Close",function() helper:Remove() end)
				menu:Open()
			end
			_mpressed(pnl, keycode, ...)
		end



		content:CloseTab()
		helper:Open()
	end)
end

function TabHandler:cleanup() -- Called when editor is reloaded/removed
end


-----------------------
-- VGUI part (content)
-----------------------
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
		self:UpdateTitle(self.title)
	end
	self.html = html
end

function PANEL:getCode() -- Return name of hanlder or code if it's editor
	return "@name "..(self.title or "StarfallEx Reference")
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
