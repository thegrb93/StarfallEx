local Editor = {}
local defaultCode = [=[--@name
--@author
--@shared

--[[
Starfall Scripting Environment

Github: https://github.com/thegrb93/StarfallEx
Reference Page: http://thegrb93.github.io/Starfall/

Default Keyboard shortcuts: https://github.com/ajaxorg/ace/wiki/Default-Keyboard-Shortcuts
]]]=]
function Editor:NewScript(incurrent)
  if not incurrent and self.NewTabOnOpen:GetBool() then
    self:NewTab()
  else
    self:AutoSave()
    self:ChosenFile()
    -- Set title
    self:GetActiveTab():SetText("generic")
    self.C.TabHolder:InvalidateLayout()

    self:SetCode(defaultCode)
  end
end

function Editor:Validate(gotoerror)

  local err = CompileString( self:GetCode(), "Validation", false )
  if type( err ) != "string" then
    self:SetValidatorStatus("Validation successful!", 0, 110, 20, 255)
    return
  end
  local row = tonumber( err:match( "%d+" ) ) - 1 or 0
  local message = err:match( ": .+$" ):sub( 3 ) or "Unknown"
  message = "Line "..row..":"..message
  if gotoerror then
    if row then self:GetCurrentEditor():SetCaret({ tonumber(row), 0 }) end
  end
  self.C.Val:SetBGColor(110, 0, 20, 255)
  self.C.Val:SetText(" " .. message)

  return true
end
local controlpanel_blacklist = {
  ["Expression 2"] = true,
  ["Remote Updater"] = true,
}

function Editor:Setup(nTitle, nLocation, nEditorType)
  self.Title = nTitle
  self.Location = nLocation
  self.EditorType = nEditorType
  self.C.Browser:Setup(nLocation)

  self:SetEditorMode(nEditorType)

  local SFHelp = vgui.Create("Button", self.C.Menu)
  SFHelp:SetSize(58, 20)
  SFHelp:Dock(RIGHT)
  SFHelp:SetText("SFHelper")
  SFHelp.DoClick = function()
    if SF.Helper.Frame and SF.Helper.Frame:IsVisible() then
      SF.Helper.Frame:close()
    else
      SF.Helper.show()
    end
  end
  self.C.SFHelp = SFHelp

  -- Add "Sound Browser" button
  local SoundBrw = vgui.Create("Button", self.C.Menu)
  SoundBrw:SetSize(85, 20)
  SoundBrw:Dock(RIGHT)
  SoundBrw:SetText("Sound Browser")
  SoundBrw.DoClick = function() RunConsoleCommand("wire_sound_browser_open") end
  self.C.SoundBrw = SoundBrw
  self:OpenOldTabs()
  for I = #self.C.Control.TabHolder.Items, 1, -1 do --Removing blacklisted panels
    local v = self.C.Control.TabHolder.Items[I]
    if controlpanel_blacklist[v.Name] then
      self.C.Control.TabHolder:CloseTab(v.Tab,true)
    end
  end
	--Add "Model Viewer" button
	local ModelViewer = vgui.Create("Button", self.C.Menu)
	ModelViewer:SetSize(85, 20)
	ModelViewer:Dock(RIGHT)
	ModelViewer:SetText("Movel Viewer")
	ModelViewer.DoClick = function() 
		if SF.Editor.modelViewer:IsVisible() then
			SF.Editor.modelViewer:close()
		else
			SF.Editor.modelViewer:open()
		end
	end
	self.C.ModelViewer = ModelViewer
	self:OpenOldTabs()
	for I = #self.C.Control.TabHolder.Items, 1, -1 do --Removing blacklisted panels
		local v = self.C.Control.TabHolder.Items[I]
		if controlpanel_blacklist[v.Name] then
			self.C.Control.TabHolder:CloseTab(v.Tab,true)
		end
	end	
	
  self:InvalidateLayout()
end
---[[[Tab's editor modifications]]]

local function OpenContextMenu(editor) -- Tab's editor control menu
  editor:AC_SetVisible( false )
  local menu = DermaMenu()

  if editor:CanUndo() then
    menu:AddOption("Undo", function()
        editor:DoUndo()
      end)
  end
  if editor:CanRedo() then
    menu:AddOption("Redo", function()
        editor:DoRedo()
      end)
  end

  if editor:CanUndo() or editor:CanRedo() then
    menu:AddSpacer()
  end

  if editor:HasSelection() then
    menu:AddOption("Cut", function()
        if editor:HasSelection() then
          editor.clipboard = editor:GetSelection()
          editor.clipboard = string_gsub(editor.clipboard, "\n", "\r\n")
          SetClipboardText(editor.clipboard)
          editor:SetSelection()
        end
      end)
    menu:AddOption("Copy", function()
        if editor:HasSelection() then
          editor.clipboard = editor:GetSelection()
          editor.clipboard = string_gsub(editor.clipboard, "\n", "\r\n")
          SetClipboardText(editor.clipboard)
        end
      end)
  end

  menu:AddOption("Paste", function()
      if editor.clipboard then
        editor:SetSelection(editor.clipboard)
      else
        editor:SetSelection()
      end
    end)

  if editor:HasSelection() then
    menu:AddOption("Delete", function()
        editor:SetSelection()
      end)
  end

  menu:AddSpacer()

  menu:AddOption("Select all", function()
      editor:SelectAll()
    end)

  menu:AddSpacer()

  menu:AddOption("Indent", function()
      editor:Indent(false)
    end)
  menu:AddOption("Outdent", function()
      editor:Indent(true)
    end)

  if editor:HasSelection() then
    menu:AddSpacer()

    menu:AddOption("Comment Block", function()
        editor:CommentSelection(false)
      end)
    menu:AddOption("Uncomment Block", function()
        editor:CommentSelection(true)
      end)

    menu:AddOption("Comment Selection",function()
        editor:BlockCommentSelection( false )
      end)
    menu:AddOption("Uncomment Selection",function()
        editor:BlockCommentSelection( true )
      end)
  end

  editor:DoAction("PopulateMenu", menu)

  menu:AddSpacer()

  menu:AddOption( "Copy with BBCode colors", function()
      local str = string_format( "[code][font=%s]", editor:GetParent().FontConVar:GetString() )

      local prev_colors
      local first_loop = true

      for i=1,#editor.Rows do
        local colors = editor:SyntaxColorLine(i)

        for k,v in pairs( colors ) do
          local color = v[2][1]

          if (prev_colors and prev_colors == color) or string_Trim(v[1]) == "" then
            str = str .. v[1]
          else
            prev_colors = color

            if first_loop then
              str = str .. string_format( '[color="#%x%x%x"]', color.r - 50, color.g - 50, color.b - 50 ) .. v[1]
              first_loop = false
            else
              str = str .. string_format( '[/color][color="#%x%x%x"]', color.r - 50, color.g - 50, color.b - 50 ) .. v[1]
            end
          end
        end

        str = str .. "\r\n"

      end

      str = str .. "[/color][/font][/code]"

      editor.clipboard = str
      SetClipboardText( str )
    end)
  menu:AddOption( "Auto-Intend", function() -- Still looking for some good intendation script in lua

    end)
  menu:Open()
  return menu

end

--Applying those modifications
function Editor:OnTabCreated(sheet)
  local editor = sheet.Panel
  editor.OpenContextMenu = OpenContextMenu
end

vgui.Register("StarfallEditorFrame", Editor, "Expression2EditorFrame")
