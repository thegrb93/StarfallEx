----------------------------------------------------
-- That's not implemented hovewer it shows template
----------------------------------------------------

local TabHandler = {
  ControlName = "sf_tab_ace", -- Its name of vgui panel used by handler, there has to be one
  IsEditor = false, -- If it should be treated as editor of file, like ACE or Wire
}
local PANEL = {} -- It's our VGUI

----------------
-- Handler part
----------------
TabHandler.SessionTabs = {}

local runJS = function ( ... )
  TabHandler.html:QueueJavascript( ... )
end

local function getSessionID(tab)
	return table.KeyFromValue( TabHandler.SessionTabs, tab )
end

local function createSession(tab)
	local settings = util.TableToJSON({
			wrap = GetConVarNumber( "sf_editor_wordwrap" )
		}):JavascriptSafe()
		runJS( "newEditSession(\"" .. string.JavascriptSafe( tab.code or "" ) .. "\", JSON.parse(\"" .. settings .. "\"))" )
		table.insert(TabHandler.SessionTabs,tab)
end

local function removeSession(tab)
	local id = getSessionID(tab)
	runJS( "removeEditSession("..id..")" )
	table.remove(TabHandler.SessionTabs,id)
end

local function selectSession(tab)
	runJS( "selectEditSession("..getSessionID(tab)..")" )
end

local function createLibraryMap ()

  local libMap, libs = {}, {}

  libMap[ "Environment" ] = {}
  for name, val in pairs( SF.DefaultEnvironment ) do
    table.insert( libMap[ "Environment" ], name )
    table.insert( libs, name )
  end

  for lib, tbl in pairs( SF.Libraries.libraries ) do
    libMap[ lib ] = {}
    for name, val in pairs( tbl ) do
      table.insert( libMap[ lib ], name )
      table.insert( libs, lib.."\\."..name )
    end
  end

  for lib, tbl in pairs( SF.Types ) do
    if type( tbl.__index ) == "table" then
      for name, val in pairs( tbl.__index ) do
        table.insert( libs, "\\:"..name )
      end
    end
  end

  return libMap, table.concat( libs, "|" )
end

function TabHandler:init() -- It's caled when editor is initalized, you can create library map there etc
  local html = vgui.Create( "DHTML" )
  html:Dock( FILL )
  html:DockMargin( 5, 59, 5, 5 )
  html:SetKeyboardInputEnabled( true )
  html:SetMouseInputEnabled( true )

  local files = file.Find("html/starfalleditor*","GAME")
  local version if files[1] then version = string.match(files[1], "starfalleditor(%d+)%.html") end
  if version then
    html:OpenURL( "asset://garrysmod/html/starfalleditor"..version..".html" )
  else
    --Files failed to send, use github
    html:OpenURL( "http://thegrb93.github.io/StarfallEx/starfall/starfalleditor1.html" )
  end

  html:AddFunction( "console", "copyCode", function( code )
      self.code = code
    end)
  html:AddFunction( "console", "copyClipboard", function( code )
      timer.Simple(0, function() SetClipboardText( code ) end)
    end)

  html:AddFunction( "console", "doValidation", SF.Editor.doValidation) --TODO: FIX THAT LATER
  if system.IsWindows() then
    html:AddFunction( "console", "fixConsole",function() if tobool( GetConVarNumber( "sf_editor_fixconsolebug" ) ) then gui.ActivateGameUI() end end)
  else
    html:AddFunction( "console", "fixConsole",function() end) --Dummy
  end

  local function FinishedLoadingEditor()
    local libMap, libs = createLibraryMap()
    html:QueueJavascript( "libraryMap = " .. util.TableToJSON( libMap ) )
    html:QueueJavascript( "createStarfallMode(\"" .. libs .. "\")" )
    function html:OnKeyCodePressed ( key, notfirst )
      local function repeatKey ()
        timer.Create( "repeatKey"..key, not notfirst and 0.5 or 0.02, 1, function () self:OnKeyCodePressed( key, true ) end )
      end

      if GetConVarNumber( "sf_editor_fixkeys" ) == 0 then return end
      if ( input.IsKeyDown( KEY_LSHIFT ) or input.IsKeyDown( KEY_RSHIFT ) ) and
      ( input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) ) and
      not input.IsKeyDown( KEY_LALT ) then
        if key == KEY_UP and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.modifyNumber(1)" )
          repeatKey()
        elseif key == KEY_DOWN and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.modifyNumber(-1)" )
          repeatKey()
        elseif key == KEY_LEFT and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.selection.selectWordLeft()" )
          repeatKey()
        elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.selection.selectWordRight()" )
          repeatKey()
        end
      elseif input.IsKeyDown( KEY_LSHIFT ) or input.IsKeyDown( KEY_RSHIFT ) then
        if key == KEY_LEFT and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.selection.selectLeft()" )
          repeatKey()
        elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.selection.selectRight()" )
          repeatKey()
        elseif key == KEY_UP and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.selection.selectUp()" )
          repeatKey()
        elseif key == KEY_DOWN and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.selection.selectDown()" )
          repeatKey()
        elseif key == KEY_HOME and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.selection.selectLineStart()" )
          repeatKey()
        elseif key == KEY_END and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.selection.selectLineEnd()" )
          repeatKey()
        end
      elseif input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) and not input.IsKeyDown( KEY_LALT ) then
        if key == KEY_LEFT and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.navigateWordLeft()" )
          repeatKey()
        elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.navigateWordRight()" )
          repeatKey()
        elseif key == KEY_BACKSPACE and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.removeWordLeft()" )
          repeatKey()
        elseif key == KEY_DELETE and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.removeWordRight()" )
          repeatKey()
        elseif key == KEY_SPACE and input.IsKeyDown( key ) then
          SF.Editor.doValidation( true )
        elseif key == KEY_C and input.IsKeyDown( key ) then
          self:QueueJavascript( "console.copyClipboard(editor.getSelectedText())" )
        end
      elseif input.IsKeyDown( KEY_LALT ) or input.IsKeyDown( KEY_RALT ) then
        if key == KEY_UP and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.moveLinesUp()" )
          repeatKey()
        elseif key == KEY_DOWN and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.moveLinesDown()" )
          repeatKey()
        end
      else
        if key == KEY_LEFT and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.navigateLeft(1)" )
          repeatKey()
        elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.navigateRight(1)" )
          repeatKey()
        elseif key == KEY_UP and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.navigateUp(1)" )
          repeatKey()
        elseif key == KEY_DOWN and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.navigateDown(1)" )
          repeatKey()
        elseif key == KEY_HOME and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.navigateLineStart()" )
          repeatKey()
        elseif key == KEY_END and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.navigateLineEnd()" )
          repeatKey()
        elseif key == KEY_PAGEUP and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.navigateFileStart()" )
          repeatKey()
        elseif key == KEY_PAGEDOWN and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.navigateFileEnd()" )
          repeatKey()
        elseif key == KEY_BACKSPACE and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.remove('left')" )
          repeatKey()
        elseif key == KEY_DELETE and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.remove('right')" )
          repeatKey()
        elseif key == KEY_ENTER and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.splitLine(); editor.navigateDown(1); editor.navigateLineStart()" )
          repeatKey()
        elseif key == KEY_INSERT and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.toggleOverwrite()" )
          repeatKey()
        elseif key == KEY_TAB and input.IsKeyDown( key ) then
          self:QueueJavascript( "editor.indent()" )
          repeatKey()
        end
      end

    end
  end
  local readyTime
  hook.Add("Think","SF_LoadingAce",function()
      if not html:IsLoading() then
        if not readyTime then readyTime = CurTime()+0.1 end
        if CurTime() > readyTime then
          hook.Remove("Think","SF_LoadingAce")
					print("LOADING FINISHED")
          FinishedLoadingEditor()
        end
      end
    end)
  TabHandler.html = html
  TabHandler.html:SetVisible(false)
end
-------------
-- VGUI part
-------------

function PANEL:Init() --That's init of VGUI like other PANEL:Methods(), separate for each tab
	createSession(self)
	self:SetBackgroundColor(Color(39, 40, 34))
end

function PANEL:getCode() -- Return name of hanlder or code if it's editor
  return self.code or ""
end

function PANEL:setCode(code)
	self.code = code
end

function PANEL:OnFocusChanged(gained) -- When this tab is opened
	if gained then
		selectSession(self)
	  TabHandler.html:SetParent(self)
	  self:DockPadding(0, 0, 0, 0)
	  TabHandler.html:DockMargin(0, 0, 0, 0)
	  TabHandler.html:Dock(FILL)
	  TabHandler.html:SetVisible(true)
		TabHandler.html:RequestFocus()
	end --We dont do anything when lost, because it loses focus even when child is interacted
end

function PANEL:OnRemove() -- We dont want html to get removed with tab as its shared
	removeSession(self)
	if TabHandler.html:GetParent() == self then
		TabHandler.html:SetVisible(false)
	  TabHandler.html:SetParent(nil)
	end
end

function PANEL:validate(movecarret) -- Validate request, has to return success,message

end
--------------
-- We're done
--------------
vgui.Register(TabHandler.ControlName, PANEL, "DPanel") -- Registering VGUI element of handler
return TabHandler -- Our file has to return table of handler
