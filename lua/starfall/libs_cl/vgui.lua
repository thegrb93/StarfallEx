-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local function checkoptional(val, chk)
	if val then checkluatype(val, chk) end
end

--- Panel type
-- @name Panel
-- @class type
-- @libtbl pnl_methods
-- @libtbl pnl_meta
SF.RegisterType("Panel", false, true, debug.getregistry().Panel)

--- DPanel type
-- @name DPanel
-- @class type
-- @libtbl dpnl_methods
-- @libtbl dpnl_meta
SF.RegisterType("DPanel", false, true, debug.getregistry().DPanel, "Panel")

--- DFileBrowser type
-- @name DFileBrowser
-- @class type
-- @libtbl dfb_methods
-- @libtbl dfb_meta
SF.RegisterType("DFileBrowser", false, true, debug.getregistry().DFileBrowser, "DPanel")

--- DNumSlider type
-- @name DNumSlider
-- @class type
-- @libtbl dnms_methods
-- @libtbl dnms_meta
SF.RegisterType("DNumSlider", false, true, debug.getregistry().DNumSlider, "Panel")

--- DFrame type
-- @name DFrame
-- @class type
-- @libtbl dfrm_methods
-- @libtbl dfrm_meta
SF.RegisterType("DFrame", false, true, debug.getregistry().DFrame, "Panel")

--- DScrollPanel type
-- @name DScrollPanel
-- @class type
-- @libtbl dscrl_methods
-- @libtbl dscrl_meta
SF.RegisterType("DScrollPanel", false, true, debug.getregistry().DScrollPanel, "DPanel")

--- DMenu type
-- @name DMenu
-- @class type
-- @libtbl dmen_methods
-- @libtbl dmen_meta
SF.RegisterType("DMenu", false, true, debug.getregistry().DMenu, "DScrollPanel")

--- DMenuOption type
-- @name DMenuOption
-- @class type
-- @libtbl dmeno_methods
-- @libtbl dmeno_meta
SF.RegisterType("DMenuOption", false, true, debug.getregistry().DMenuOption, "DButton")

--- DColorMixer type
-- @name DColorMixer
-- @class type
-- @libtbl dclm_methods
-- @libtbl dclm_meta
SF.RegisterType("DColorMixer", false, true, debug.getregistry().DColorMixer, "DPanel")

--- DLabel type
-- @name DLabel
-- @class type
-- @libtbl dlab_methods
-- @libtbl dlab_meta
SF.RegisterType("DLabel", false, true, debug.getregistry().DLabel, "Panel")

--- DButton type
-- @name DButton
-- @class type
-- @libtbl dbut_methods
-- @libtbl dbut_meta
SF.RegisterType("DButton", false, true, debug.getregistry().DButton, "DLabel")

--- DComboBox type
-- @name DComboBox
-- @class type
-- @libtbl dcom_methods
-- @libtbl dcom_meta
SF.RegisterType("DComboBox", false, true, debug.getregistry().DComboBox, "DButton")

--- DCheckBox type
-- @name DCheckBox
-- @class type
-- @libtbl dchk_methods
-- @libtbl dchk_meta
SF.RegisterType("DCheckBox", false, true, debug.getregistry().DCheckBox, "DButton")

--- AvatarImage type
-- @name AvatarImage
-- @class type
-- @libtbl aimg_methods
-- @libtbl aimg_meta
SF.RegisterType("AvatarImage", false, true, debug.getregistry().AvatarImage, "Panel")

--- DProgress type
-- @name DProgress
-- @class type
-- @libtbl dprg_methods
-- @libtbl dprg_meta
SF.RegisterType("DProgress", false, true, debug.getregistry().DProgress, "Panel")

--- DTextEntry type
-- @name DTextEntry
-- @class type
-- @libtbl dtxe_methods
-- @libtbl dtxe_meta
SF.RegisterType("DTextEntry", false, true, debug.getregistry().DTextEntry, "Panel")

--- DImage type
-- @name DImage
-- @class type
-- @libtbl dimg_methods
-- @libtbl dimg_meta
SF.RegisterType("DImage", false, true, debug.getregistry().DImage, "DPanel")

--- DImageButton type
-- @name DImageButton
-- @class type
-- @libtbl dimgb_methods
-- @libtbl dimgb_meta
SF.RegisterType("DImageButton", false, true, debug.getregistry().DImageButton, "DButton")

--- VGUI functions.
-- @name vgui
-- @class library
-- @libtbl vgui_library
SF.RegisterLibrary("vgui")

return function(instance)

local panels

instance:AddHook("initialize", function()
	panels = {}
end)

instance:AddHook("deinitialize", function()
	for panel, _ in pairs(panels) do
		panel:Remove()
	end
end)

local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local pnl_methods, pnl_meta, pnlwrap, pnlunwrap = instance.Types.Panel.Methods, instance.Types.Panel, instance.Types.Panel.Wrap, instance.Types.Panel.Unwrap
local dpnl_methods, dpnl_meta, dpnlwrap, dpnlunwrap = instance.Types.DPanel.Methods, instance.Types.DPanel, instance.Types.DPanel.Wrap, instance.Types.DPanel.Unwrap
local dfb_methods, dfb_meta, dfbwrap, dfbunwrap = instance.Types.DFileBrowser.Methods, instance.Types.DFileBrowser, instance.Types.DFileBrowser.Wrap, instance.Types.DFileBrowser.Unwrap
local dfrm_methods, dfrm_meta, dfrmwrap, dfrmunwrap = instance.Types.DFrame.Methods, instance.Types.DFrame, instance.Types.DFrame.Wrap, instance.Types.DFrame.Unwrap
local dscrl_methods, dscrl_meta, dscrlwrap, dscrlunwrap = instance.Types.DScrollPanel.Methods, instance.Types.DScrollPanel, instance.Types.DScrollPanel.Wrap, instance.Types.DScrollPanel.Unwrap
local dlab_methods, dlab_meta, dlabwrap, dlabunwrap = instance.Types.DLabel.Methods, instance.Types.DLabel, instance.Types.DLabel.Wrap, instance.Types.DLabel.Unwrap
local dbut_methods, dbut_meta, dbutwrap, dbutunwrap = instance.Types.DButton.Methods, instance.Types.DButton, instance.Types.DButton.Wrap, instance.Types.DButton.Unwrap
local dchk_methods, dchk_meta, dchkwrap, dchkunwrap = instance.Types.DCheckBox.Methods, instance.Types.DCheckBox, instance.Types.DCheckBox.Wrap, instance.Types.DCheckBox.Unwrap
local aimg_methods, aimg_meta, aimgwrap, aimgunwrap = instance.Types.AvatarImage.Methods, instance.Types.AvatarImage, instance.Types.AvatarImage.Wrap, instance.Types.AvatarImage.Unwrap
local dprg_methods, dprg_meta, dprgwrap, dprgunwrap = instance.Types.DProgress.Methods, instance.Types.DProgress, instance.Types.DProgress.Wrap, instance.Types.DProgress.Unwrap
local dtxe_methods, dtxe_meta, dtxewrap, dtxeunwrap = instance.Types.DTextEntry.Methods, instance.Types.DTextEntry, instance.Types.DTextEntry.Wrap, instance.Types.DTextEntry.Unwrap
local dimg_methods, dimg_meta, dimgwrap, dimgunwrap = instance.Types.DImage.Methods, instance.Types.DImage, instance.Types.DImage.Wrap, instance.Types.DImage.Unwrap
local dimgb_methods, dimgb_meta, dimgbwrap, dimgbunwrap = instance.Types.DImageButton.Methods, instance.Types.DImageButton, instance.Types.DImageButton.Wrap, instance.Types.DImageButton.Unwrap
local dnms_methods, dnms_meta, dnmswrap, dnmsunwrap = instance.Types.DNumSlider.Methods, instance.Types.DNumSlider, instance.Types.DNumSlider.Wrap, instance.Types.DNumSlider.Unwrap
local dcom_methods, dcom_meta, dcomwrap, dcomunwrap = instance.Types.DComboBox.Methods, instance.Types.DComboBox, instance.Types.DComboBox.Wrap, instance.Types.DComboBox.Unwrap
local dclm_methods, dclm_meta, dclmwrap, dclmunwrap = instance.Types.DColorMixer.Methods, instance.Types.DColorMixer, instance.Types.DColorMixer.Wrap, instance.Types.DColorMixer.Unwrap
local dmen_methods, dmen_meta, dmenwrap, dmenunwrap = instance.Types.DMenu.Methods, instance.Types.DMenu, instance.Types.DMenu.Wrap, instance.Types.DMenu.Unwrap
local dmeno_methods, dmeno_meta, dmenowrap, dmenounwrap = instance.Types.DMenuOption.Methods, instance.Types.DMenuOption, instance.Types.DMenuOption.Wrap, instance.Types.DMenuOption.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local plyunwrap = instance.Types.Player.Unwrap
local vgui_library = instance.Libraries.vgui

function pnl_meta:__tostring()
	return "Panel"
end

function dpnl_meta:__tostring()
	return "DPanel"
end

function dfrm_meta:__tostring()
	return "DFrame"
end

function dscrl_meta:__tostring()
	return "DScrollPanel"
end

function dbut_meta:__tostring()
	return "DButton"
end

function dlab_meta:__tostring()
	return "DLabel"
end

function aimg_meta:__tostring()
	return "AvatarImage"
end

function dprg_meta:__tostring()
	return "DProgress"
end

function dtxe_meta:__tostring()
	return "DTextEntry"
end

function dimg_meta:__tostring()
	return "DImage"
end

function dimgb_meta:__tostring()
	return "DImageButton"
end

function dchk_meta:__tostring()
	return "DCheckBox"
end

function dnms_meta:__tostring()
	return "DNumSlider"
end

function dcom_meta:__tostring()
	return "DComboBox"
end

function dclm_meta:__tostring()
	return "DColorMixer"
end

function dfb_meta:__tostring()
	return "DFileBrowser"
end

function dmen_meta:__tostring()
	return "DMenu"
end

function dmeno_meta:__tostring()
	return "DMenuOption"
end

local function unwrap(pnl)
	local pnc = tostring(pnl)
	local unwrapFunc = instance.Types[pnc].Unwrap
	
	return unwrapFunc(pnl)
end


--- Sets the position of the panel's top left corner.
--@param number x The x coordinate of the position.
--@param number y The y coordinate of the position.
function pnl_methods:setPos(x, y)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:SetPos(x, y)
end

--- Returns the position of the panel relative to its Panel:getParent.
--@return number X coordinate, relative to this panels parents top left corner.
--@return number Y coordinate, relative to this panels parents top left corner.
function pnl_methods:getPos()
	local uwp = unwrap(self)
	
	return uwp:GetPos()
end

--- Returns the value the panel holds.
--- In engine is only implemented for CheckButton, Label and TextEntry as a string.
--@param any The value the panel holds.
function pnl_methods:getValue()
	local uwp = unwrap(self)

	return uwp:GetValue()
end

--- Sets the size of the panel.
--@param number x Width of the panel.
--@param number y Height of the panel.
function pnl_methods:setSize(x, y)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:SetSize(x, y)
end

--- Returns the size of the panel.
--@return number width
--@return number height
function pnl_methods:getSize()
	local uwp = unwrap(self)
	
	return uwp:GetSize()
end

--- Sets the height of the panel.
--@param number newHeight The height to be set.
function pnl_methods:setHeight(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = unwrap(self)

	uwp:SetHeight(val)
end

--- Gets the height of the panel.
--@return number The height of the panel.
function pnl_methods:getHeight()
	local uwp = unwrap(self)

	return uwp:GetTall()
end

--- Sets the width of the panel.
--@param number newWidth The width to be set.
function pnl_methods:setWidth(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = unwrap(self)

	uwp:SetWidth(val)
end

--- Gets the width of the panel.
--@return number The width of the panel.
function pnl_methods:getWidth()
	local uwp = unwrap(self)

	return uwp:GetWide()
end

--- Sets the text value of a panel object containing text, such as DLabel, DTextEntry or DButton.
--@param string text The text value to set.
function pnl_methods:setText(text)
	checkluatype(text, TYPE_STRING)
	local uwp = unwrap(self)
	
	uwp:SetText(text)
end

--- Sets the tooltip to be displayed when a player hovers over the panel object with their cursor.
--@param string text The text to be displayed in the tooltip.
function pnl_methods:setTooltip(text)
	checkluatype(text, TYPE_STRING)
	local uwp = unwrap(self)

	uwp:SetTooltip(text)
end

--- Removes the tooltip on the panel set with Panel:setTooltip
function pnl_methods:unsetTooltip()
	local uwp = unwrap(self)

	uwp:SetTooltip(false)
end

--- Sets the panel to be displayed as contents of a DTooltip when a player hovers over the panel object with their cursor.
--@param Panel The panel to use as the tooltip.
function pnl_methods:setTooltipPanel(setPnl)
	local uwp = unwrap(self)
	local uwsp = pnlunwrap(setPnl)

	uwp:SetTooltipPanel(uwsp)
end

--- Removes the tooltip panel set on this panel with Panel:setTooltipPanel
function pnl_methods:unsetTooltipPanel()
	local uwp = unwrap(self)

	uwp:SetTooltipPanel(nil)
end

--- Sets whether text wrapping should be enabled or disabled on Label and DLabel panels. 
--- Use DLabel:setAutoStretchVertical to automatically correct vertical size; Panel:sizeToContents will not set the correct height.
--@param boolean wrap True to enable text wrapping, false otherwise.
function pnl_methods:setWrap(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = unwrap(self)

	uwp:SetWrap(enable)
end

--- Marks all of the panel's children for deletion.
function pnl_methods:clear()
	local uwp = unwrap(self)
	
	uwp:Clear()
end

--- Returns a table with all the child panels of the panel.
--@return table Children
function pnl_methods:getChildren()
	local uwp = unwrap(self)
	
	return instance.Sanitize(uwp:GetChildren())
end

--- Returns the amount of children of the of panel.
--@return number The amount of children the panel has.
function pnl_methods:getChildCount()
	local uwp = unwrap(self)
	
	return uwp:ChildCount()
end

--- Places the panel above the passed panel with the specified offset.
--@param Panel panel Panel to position relatively to.
--@param number? offset The align offset.
function pnl_methods:moveAbove(pnl, off)
	if off ~= nil then checkluatype(off, TYPE_NUMBER) end
	local uwp = unwrap(self)
	pnl = unwrap(pnl)
	
	uwp:MoveAbove(pnl, off)
end

--- Places the panel below the passed panel with the specified offset.
--@param Panel panel Panel to position relatively to.
--@param number? offset The align offset.
function pnl_methods:moveBelow(pnl, off)
	if off ~= nil then checkluatype(off, TYPE_NUMBER) end
	local uwp = unwrap(self)
	pnl = unwrap(pnl)
	
	uwp:MoveBelow(pnl, off)
end

--- Places the panel left to the passed panel with the specified offset.
--@param Panel panel Panel to position relatively to.
--@param number? offset The align offset.
function pnl_methods:moveLeftOf(pnl, off)
	if off ~= nil then checkluatype(off, TYPE_NUMBER) end
	local uwp = unwrap(self)
	pnl = unwrap(pnl)
	
	uwp:MoveLeftOf(pnl, off)
end

--- Places the panel right to the passed panel with the specified offset.
--@param Panel panel Panel to position relatively to.
--@param number? offset The align offset.
function pnl_methods:moveRightOf(pnl, off)
	if off ~= nil then checkluatype(off, TYPE_NUMBER) end
	local uwp = unwrap(self)
	pnl = unwrap(pnl)
	
	uwp:MoveRightOf(pnl, off)
end

--- Moves this panel object in front of the specified sibling (child of the same parent) in the render order, and shuffles up the Z-positions of siblings now behind.
--@param Panel sibling The panel to move this one in front of. Must be a child of the same parent panel.
--@return boolean false if the passed panel is not a sibling, otherwise nil.
function pnl_methods:moveToAfter(pnl)
	local uwp = unwrap(self)
	pnl = unwrap(pnl)
	
	return uwp:MoveToAfter(pnl)
end

--- Moves this panel object behind the specified sibling (child of the same parent) in the render order, and shuffles up the Panel:setZPos of siblings now in front.
--@param Panel sibling The panel to move this one behind. Must be a child of the same parent panel.
--@return boolean false if the passed panel is not a sibling, otherwise nil.
function pnl_methods:moveToBefore(pnl)
	local uwp = unwrap(self)
	pnl = unwrap(pnl)
	
	return uwp:MoveToBefore(pnl)
end

--- Sets the panels z position which determines the rendering order.
--- Panels with lower z positions appear behind panels with higher z positions.
--- This also controls in which order panels docked with Panel:dock appears.
--@param number zindex The z position of the panel. Can't be lower than -32768 or higher than 32767.
function pnl_methods:setZPos(pos)
	checkluatype(pos, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:SetZPos(pos)
end

--- Moves the panel object behind all other panels on screen. If the panel has been made a pop-up with Panel:MakePopup, it will still draw in front of any panels that haven't.
function pnl_methods:moveToBack()
	local uwp = unwrap(self)
	
	uwp:MoveToBack()
end

--- Moves the panel in front of all other panels on screen. Unless the panel has been made a pop-up using Panel:makePopup, it will still draw behind any that have.
function pnl_methods:moveToFront()
	local uwp = unwrap(self)
	
	uwp:MoveToFront()
end

--- Resizes the panel object's width so that its right edge is aligned with the left of the passed panel. 
--- An offset greater than zero will reduce the panel's width to leave a gap between it and the passed panel.
--@param Panel targetPanel The panel to align the bottom of this one with.
--@param number offset The gap to leave between this and the passed panel. Negative values will cause the panel's height to increase, forming an overlap.
function pnl_methods:stretchRightTo(target, off)
	local uwp = unwrap(self)
	local uwtp = unwrap(target)
	checkluatype(off, TYPE_NUMBER)

	uwp:StretchRightTo(uwtp, off)
end

--- Resizes the panel object's height so that its bottom is aligned with the top of the passed panel. 
--- An offset greater than zero will reduce the panel's height to leave a gap between it and the passed panel.
--@param Panel targetPanel The panel to align the bottom of this one with.
--@param number offset The gap to leave between this and the passed panel. Negative values will cause the panel's height to increase, forming an overlap.
function pnl_methods:stretchBottomTo(target, off)
	local uwp = unwrap(self)
	local uwtp = unwrap(target)
	checkluatype(off, TYPE_NUMBER)

	uwp:StretchBottomTo(uwtp, off)
end

--- Focuses the panel and enables it to receive input.
function pnl_methods:makePopup()
	local uwp = unwrap(self)
	
	uwp:MakePopup()
end

--- Parents the panel to the HUD. Makes it invisible on the escape-menu and disables controls.
function pnl_methods:parentToHUD()
	local uwp = unwrap(self)
	
	uwp:ParentToHUD()
end

--- Sets the alignment of the contents. Check https://wiki.facepunch.com/gmod/Panel:SetContentAlignment for directions.
--@param number align The direction of the content, based on the number pad.
function pnl_methods:setContentAlignment(align)
	checkluatype(align, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:SetContentAlignment(align)
end

--- Sets whenever all the default border of the panel should be drawn or not.
--param boolean paint Whenever to draw the border or not.
function pnl_methods:setPaintBorderEnabled(paint)
	checkluatype(paint, TYPE_BOOL)
	local uwp = unwrap(self)
	
	uwp:SetPaintBorderEnabled(paint)
end

--- Centers the panel.
function pnl_methods:center()
	local uwp = unwrap(self)
	
	uwp:Center()
end

--- Centers the panel horizontally with specified fraction.
--@param number frac The center fraction.
function pnl_methods:centerHorizontal(frac)
	checkluatype(frac, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:CenterHorizontal(frac)
end

--- Centers the panel vertically with specified fraction.
--@param number frac The center fraction.
function pnl_methods:centerVertical(frac)
	checkluatype(frac, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:CenterVertical(frac)
end

--- Sets the appearance of the cursor. You can find a list of all available cursors with image previews at https://wiki.facepunch.com/gmod/Cursors.
--@param string type The cursor to be set. Check the page in the description for valid types.
function pnl_methods:setCursor(str)
	checkluatype(str, TYPE_STRING)
	local uwp = unwrap(self)
	
	uwp:SetCursor(str)
end

--- Removes the panel and all its children.
function pnl_methods:remove()
	local uwp = unwrap(self)
	
	panels[uwp] = nil
	uwp:Remove()
end

--- Sets the alpha multiplier for the panel
--@param number alpha The alpha value in the range of 0-255.
function pnl_methods:setAlpha(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:SetAlpha(val)
end

--- Sets the dock type for the panel, making the panel "dock" in a certain direction, modifying it's position and size.
--@param number Dock type using https://wiki.facepunch.com/gmod/Enums/DOCK.
function pnl_methods:dock(enum)
	checkluatype(enum, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:Dock(enum)
end

--- Sets the dock margin of the panel.
--- The dock margin is the extra space that will be left around the edge when this element is docked inside its parent element.
--@param number left The left margin.
--@param number top The top margin.
--@param number right The right margin.
--@param number botton The bottom margin.
function pnl_methods:dockMargin(left, top , right, bottom)
	checkluatype(left, TYPE_NUMBER)
	checkluatype(right, TYPE_NUMBER)
	checkluatype(top, TYPE_NUMBER)
	checkluatype(bottom, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:DockMargin(left, top, right, bottom)
end

--- Sets the dock padding of the panel.
--- The dock padding is the extra space that will be left around the edge when child elements are docked inside this element.
--@param number left The left padding.
--@param number top The top padding.
--@param number right The right padding.
--@param number botton The bottom padding.
function pnl_methods:dockPadding(left, top , right, bottom)
	checkluatype(left, TYPE_NUMBER)
	checkluatype(right, TYPE_NUMBER)
	checkluatype(top, TYPE_NUMBER)
	checkluatype(bottom, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:DockPadding(left, top, right, bottom)
end

--- Aligns the panel on the top of its parent with the specified offset.
--@param number offset The align offset.
function pnl_methods:alignTop(off)
	checkluatype(off, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:AlignTop(off)
end

--- Aligns the panel on the left of its parent with the specified offset.
--@param number offset The align offset.
function pnl_methods:alignLeft(off)
	checkluatype(off, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:AlignLeft(off)
end

--- Aligns the panel on the right of its parent with the specified offset.
--@param number offset The align offset.
function pnl_methods:alignRight(off)
	checkluatype(off, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:AlignRight(off)
end

--- Aligns the panel on the bottom of its parent with the specified offset.
--@param number offset The align offset.
function pnl_methods:alignBottom(off)
	checkluatype(off, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:AlignBottom(off)
end

--- Translates global screen coordinate to coordinates relative to the panel.
--@param number screenX The x coordinate of the screen position to be translated.
--@param number screenY The y coordinate of the screen position to be translated.
--@return number Relative position X
--@return number Relative position Y
function pnl_methods:screenToLocal(x, y)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	return uwp:ScreenToLocal(x, y)
end

--- Gets the absolute screen position of the position specified relative to the panel.
--@param number posX The X coordinate of the position on the panel to translate.
--@param number posY The Y coordinate of the position on the panel to translate.
--@return number The X coordinate relative to the screen.
--@return number The Y coordinate relative to the screen.
function pnl_methods:localToScreen(x, y)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	return uwp:LocalToScreen(x, y)
end

--- Returns the internal name of the panel. Can be set via Panel:setName.
--@return string The internal name of the panel.
function pnl_methods:getName()
	local uwp = unwrap(self)

	return uwp:GetName()
end

--- Sets the internal name of the panel. Can be retrieved with Panel:getName.
--@param string newname New internal name for the panel.
function pnl_methods:setName(val)
	checkluatype(val, TYPE_STRING)
	local uwp = unwrap(self)

	uwp:SetName(val)
end

--- Sets the enabled state of a disable-able panel object, such as a DButton or DTextEntry.
--- See Panel:isEnabled for a function that retrieves the "enabled" state of a panel.
--@param boolean enabled Whether to enable or disable the panel object.
function pnl_methods:setEnabled(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = unwrap(self)

	uwp:SetEnabled(enable)
end

--- Returns whether the the panel is enabled or disabled.
--- See Panel:setEnabled for a function that makes the panel enabled or disabled.
--@return boolean Whether the panel is enabled or disabled.
function pnl_methods:isEnabled()
	local uwp = unwrap(self)

	return uwp:IsEnabled()
end

--- Resizes the panel to fit the bounds of its children.
--- The sizeW and sizeH parameters are false by default. Therefore, calling this function with no arguments will result in a no-op.
--@param boolean sizeW Resize with width of the panel.
--@param boolean sizeH Resize the height of the panel.
function pnl_methods:sizeToChildren(w, h)
	checkluatype(w, TYPE_BOOL)
	checkluatype(h, TYPE_BOOL)	
	local uwp = unwrap(self)

	uwp:SizeToChildren(w, h)
	uwp:InvalidateLayout()
end

--- Resizes the panel so that its width and height fit all of the content inside.
--- Only works on Label derived panels such as DLabel by default, and on any panel that manually implemented the Panel:SizeToContents method, such as DNumberWang and DImage.
function pnl_methods:sizeToContents()
	local uwp = unwrap(self)

	uwp:SizeToContents()
end

--- Resizes the panel object's width to accommodate all child objects/contents.
--- Only works on Label derived panels such as DLabel.
--- You must call this function AFTER setting text/font or adjusting child panels.
--@param number addValue The number of extra pixels to add to the width. Can be a negative number, to reduce the width.
function pnl_methods:sizeToContentsX(addVal)
	checkluatype(addVal, TYPE_NUMBER)
	local uwp = unwrap(self)

	uwp:SizeToContentsX(addVal)
end

--- Resizes the panel object's height to accommodate all child objects/contents.
--- Only works on Label derived panels such as DLabel.
--- You must call this function AFTER setting text/font or adjusting child panels.
--@param number addValue The number of extra pixels to add to the height. Can be a negative number, to reduce the height.
function pnl_methods:sizeToContentsY(addVal)
	checkluatype(addVal, TYPE_NUMBER)
	local uwp = unwrap(self)

	uwp:SizeToContentsY(addVal)
end

--- Enables or disables the mouse input for the panel.
--@param boolean mouseInput Whenever to enable or disable mouse input.
function pnl_methods:setMouseInputEnabled(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = unwrap(self)
	
	uwp:SetMouseInputEnabled(enable)
end

--- Returns true if the panel can receive mouse input.
--return boolean mouseInputEnabled
function pnl_methods:getMouseInputEnabled()
	local uwp = unwrap(self)
	
	return uwp:IsMouseInputEnabled()
end

--- Enables or disables the keyboard input for the panel.
--@param boolean keyboardInput Whenever to enable or disable keyboard input.
function pnl_methods:setKeyboardInputEnabled(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = unwrap(self)
	
	uwp:SetKeyboardInputEnabled(enable)
end

--- Returns true if the panel can receive keyboard input.
--return boolean keyboardInputEnabled
function pnl_methods:getKeyboardInputEnabled()
	local uwp = unwrap(self)
	
	return uwp:IsKeyboardInputEnabled()
end

--- Set a function to run when the panel's size changes
--@param function callback The function to run when the size changes. Has 2 arguments, which are the new width and height.
function pnl_methods:setOnSizeChanged(func)
	local uwp = unwrap(self)
	checkluatype(func, TYPE_FUNCTION)
	if !uwp.scf then
		local oldsc
		if uwp.OnSizeChanged then
			oldsc = uwp.OnSizeChanged
			function uwp:OnSizeChanged(nw, nh)
				oldsc(self, nw, nh)
				instance:runFunction(self.scf, nw, nh)
			end
		else
			function uwp:OnSizeChanged(nw, nh)
				instance:runFunction(self.scf, nw, nh)
			end
		end
	end
	
	uwp.scf = func
end

--- Set a function to run when the panel is pressed while in focus.
--@param function callback The function to run when the panel is pressed. Has 1 argument which is the keycode of the mouse button pressed. Check the MOUSE enums.
function pnl_methods:setOnMousePressed(func)
	local uwp = unwrap(self)
	checkluatype(func, TYPE_FUNCTION)
	if !uwp.mcf then
		local oldmc = uwp.OnMousePressed
		function uwp:OnMousePressed(mk)
			oldmc(self, mk)
			instance:runFunction(self.mcf, mk)
		end
	end
	
	uwp.mcf = func
end

--- Set a function to run when a mouse button is released while the panel is in focus.
--@param function callback The function to run when the mouse is released. Has 1 argument which is the keycode of the mouse button pressed. Check the MOUSE enums.
function pnl_methods:setOnMouseReleased(func)
	local uwp = unwrap(self)
	checkluatype(func, TYPE_FUNCTION)
	if !uwp.mrf then
		local oldmr = uwp.OnMouseReleased
		function uwp:OnMouseReleased(mk)
			oldmr(self, mk)
			instance:runFunction(self.mrf, mk)
		end
	end
	
	uwp.mrf = func
end

--- Enables or disables painting of the panel manually with Panel:paintManual.
--@param boolean enable True if the panel should be painted manually.
function pnl_methods:setPaintedManually(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = unwrap(self)
	
	uwp:SetPaintedManually(enable)
end

--- Paints the panel at its current position. To use this you must call Panel:setPaintedManually(true).
function pnl_methods:paintManual()
	local uwp = unwrap(self)
	
	uwp:PaintManual()
end

--- Creates a DPanel. A simple rectangular box, commonly used for parenting other elements to. Pretty much all elements are based on this. Inherits from Panel
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DPanel The new DPanel
function vgui_library.createDPanel(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DPanel", parent, name)
	if !parent then panels[new] = true end -- Only insert parent panels as they will have all their children removed anyway.
	return dpnlwrap(new)
end

--- Sets the background color of the panel.
--@param Color bgcolor The background color.
function dpnl_methods:setBackgroundColor(clr)
	local uwp = dpnlunwrap(self)
	local uwc = cunwrap(clr)

	uwp:SetBackgroundColor(uwc)
end

--- Gets the background color of the panel.
--@return Color Background color of the panel.
function dpnl_methods:getBackgroundColor()
	local uwp = dpnlunwrap(self)

	return cwrap(uwp:GetBackgroundColor())
end

--- Sets whether or not to paint/draw the panel background.
--@param boolean paint True to show the panel's background, false to hide it.
function dpnl_methods:setPaintBackground(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dpnlunwrap(self)

	uwp:SetPaintBackground(enable)
end

--- Returns whether or not the panel background is being drawn.
--@return boolean True if the panel background is drawn, false otherwise.
function dpnl_methods:getPaintBackground()
	local uwp = dpnlunwrap(self)

	return uwp:getPaintBackground()
end

--- Sets whether or not to disable the panel.
--@param boolean disable True to disable the panel (mouse input disabled and background alpha set to 75), false to enable it (mouse input enabled and background alpha set to 255).
function dpnl_methods:setDisabled(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dpnlunwrap(self)

	uwp:SetDisabled(enable)
end

--- Returns whether or not the panel is disabled.
--@return boolean True if the panel is disabled (mouse input disabled and background alpha set to 75), false if its enabled (mouse input enabled and background alpha set to 255).
function dpnl_methods:getDisabled()
	local uwp = dpnlunwrap(self)

	return uwp:getDisabled()
end

--- Creates a DFileBrowser. A simple rectangular box, commonly used for parenting other elements to. Pretty much all elements are based on this. Inherits from Panel
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DFileBrowser The new DFileBrowser
function vgui_library.createDFileBrowser(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DFileBrowser", parent, name)
	if !parent then panels[new] = true end -- Only insert parent panels as they will have all their children removed anyway.
	return dfbwrap(new)
end

--- Clears the file tree and list, and resets all values.
function dfb_methods:clear()
	local uwp = dfbunwrap(self)
	
	uwp:Clear()
end

--- Sets the root directory/folder of the file tree. This needs to be set for the file tree to be displayed.
--@param string baseDir The path to the folder to use as the root.
function dfb_methods:setBaseFolder(dir)
	checkluatype(dir, TYPE_STRING)
	local uwp = dfbunwrap(self)
	
	uwp:SetBaseFolder(dir)
end

--- Returns the root directory/folder of the file tree.
--@return string The path to the root folder.
function dfb_methods:getBaseFolder()
	local uwp = dfbunwrap(self)
	
	return uwp:GetBaseFolder()
end

--- Sets the directory/folder from which to display the file list.
--@param string currentDir The directory to display files from.
function dfb_methods:setCurrentFolder(dir)
	checkluatype(dir, TYPE_STRING)
	local uwp = dfbunwrap(self)
	
	uwp:SetCurrentFolder(dir)
end

--- Returns the current directory/folder being displayed.
--@return string The directory the file list is currently displaying.
function dfb_methods:getCurrentFolder()
	local uwp = dfbunwrap(self)
	
	return uwp:GetCurrentFolder()
end

--- Sets the file type filter for the file list. This accepts the same file extension wildcards as file.find.
--@param string fileTypes A list of file types to display, separated by spaces e.g. "*.lua *.txt *.mdl"
function dfb_methods:setFileTypes(fTypes)
	checkluatype(fTypes, TYPE_STRING)
	local uwp = dfbunwrap(self)
	
	uwp:SetFileTypes(fTypes)
end

--- Returns the current file type filter on the file list.
--@return string The current filter applied to the file list.
function dfb_methods:getFileTypes()
	local uwp = dfbunwrap(self)
	
	return uwp:GetFileTypes()
end

--- Enables or disables the model viewer mode. In this mode, files are displayed as SpawnIcons instead of a list.
--- This should only be used for .mdl files; the spawn icons will display error models for others. See DFileBrowser:setFileTypes
--@param boolean enable Whether or not to display files using SpawnIcons.
function dfb_methods:setModels(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dfbunwrap(self)
	
	uwp:SetModels(enable)
end

--- Returns whether or not the model viewer mode is enabled. In this mode, files are displayed as SpawnIcons instead of a list.
--@return boolean Whether or not files will be displayed using SpawnIcons.
function dfb_methods:getModels()
	local uwp = dfbunwrap(self)
	
	return uwp:GetModels()
end

--- Sets the name to use for the file tree.
--@param string treeName The name for the root of the file tree. Passing no value causes this to be the base folder name. See DFileBrowser:setBaseFolder.
function dfb_methods:setName(name)
	checkluatype(name, TYPE_STRING)
	local uwp = dfbunwrap(self)
	
	uwp:SetName(name)
end

--- Returns the name being used for the file tree.
--@return string The name used for the root of the file tree.
function dfb_methods:getName()
	local uwp = dfbunwrap(self)
	
	return uwp:SetName()
end

--- Opens or closes the file tree.
--@param boolean? open true to open the tree, false to close it.
--@param boolean? useAnim If true, the DTree's open/close animation is used.
function dfb_methods:setOpen(open, useAnim)
	local uwp = dfbunwrap(self)
	
	uwp:SetOpen(open, useAnim)
end

--- Returns whether or not the file tree is open.
--@return boolean Whether or not the file tree is open.
function dfb_methods:getOpen()
	local uwp = dfbunwrap(self)
	
	return uwp:GetOpen()
end

--- Sets the access path for the file tree. This is set to GAME by default.
--@param string path The access path i.e. "GAME", "LUA", "DATA" etc.
function dfb_methods:setPath(path)
	checkluatype(path, TYPE_STRING)
	local uwp = dfbunwrap(self)
	
	uwp:SetPath(path)
end

--- Returns the access path of the file tree. This is GAME unless changed with DFileBrowser:setPath.
--@return string The current access path i.e. "GAME", "LUA", "DATA" etc.
function dfb_methods:getPath()
	local uwp = dfbunwrap(self)
	
	return uwp:GetPath()
end

--- Sets the search filter for the file tree. This accepts the same wildcards as file.find.
--@param string filter The filter to use on the file tree.
function dfb_methods:setSearch(filter)
	checkluatype(filter, TYPE_STRING)
	local uwp = dfbunwrap(self)
	
	uwp:SetSearch(filter)
end

--- Returns the current search filter on the file tree.
--@return string The filter in use on the file tree.
function dfb_methods:getSearch()
	local uwp = dfbunwrap(self)
	
	return uwp:GetSearch()
end

--- Sorts the file list.
--- This is only functional when not using the model viewer. See DFileBrowser:setModels
--@param boolean? descending The sort order. true for descending (z-a), false for ascending (a-z).
function dfb_methods:sortFiles(desc)
	local uwp = dfbunwrap(self)
	
	uwp:SortFiles(desc)
end

--- Set a function to run when a file is selected.
--@param function callback Function to run. Has 1 argument which is the filepath to the selected file.
function dfb_methods:onSelect(func)
	local uwp = dfbunwrap(self)
	
	function uwp:OnSelect(filepath, selpnl)
		instance:runFunction(func, filepath)
	end
end

--- Set a function to run when a file is right-clicked.
--- When not in model viewer mode, DFileBrowser:onSelect will also be called if the file is not already selected.
--@param function callback Function to run. Has 1 argument which is the filepath to the selected file.
function dfb_methods:onRightClick(func)
	local uwp = dfbunwrap(self)
	
	function uwp:OnRightClick(filepath)
		instance:runFunction(func, filepath)
	end
end

--- Set a function to run when a file is double-clicked.
--- Double-clicking a file or icon will trigger both this and DFileBrowser:onSelect.
--@param function callback Function to run. Has 1 argument which is the filepath to the selected file.
function dfb_methods:onDoubleClick(func)
	local uwp = dfbunwrap(self)
	
	function uwp:OnDoubleClick(filepath)
		instance:runFunction(func, filepath)
	end
end

--- Creates a DFrame. The DFrame is the momma of basically all VGUI elements. 98% of the time you will parent your element to this.
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DFrame The new DFrame
function vgui_library.createDFrame(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DFrame", parent, name)
	if !parent then panels[new] = true end
	return dfrmwrap(new)
end

--- Sets a callback function to run when the frame is closed. This applies when the close button in the DFrame's control box is clicked. 
--- This is not called when the DFrame is removed with Panel:remove, see PANEL:onRemove for that.
--@param function callback The function to run when the frame is closed.
function dfrm_methods:onClose(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dfrmunwrap(self)
	
	function uwp:OnClose() instance:runFunction(func) end
end

--- Centers the frame relative to the whole screen and invalidates its layout.
function dfrm_methods:center()
	local uwp = dfrmunwrap(self)
	
	uwp:Center()
end

--- Sets whether the frame should be draggable by the user. The DFrame can only be dragged from its title bar.
--@param boolean draggable Whether to be draggable or not.
function dfrm_methods:setDraggable(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = unwrap(self)
	
	uwp:SetDraggable(enable)
end

--- Gets whether the frame can be dragged by the user.
--@return boolean Whether the frame is draggable.
function dfrm_methods:getDraggable()
	local uwp = unwrap(self)
	
	return uwp:GetDraggable()
end

--- Sets the title of the frame.
--@param string title New title of the frame.
function dfrm_methods:setTitle(val)
	checkluatype(val, TYPE_STRING)
	local uwp = unwrap(self)
	
	uwp:SetTitle(val)
end

--- Gets the title of the frame.
--@return string The title of the frame.
function dfrm_methods:getTitle()
	local uwp = unwrap(self)
	
	return uwp:GetTitle(val)
end

--- Determines if the frame or one of its children has the screen focus.
--@return boolean Whether or not the frame has focus.
function dfrm_methods:isActive()
	local uwp = unwrap(self)
	
	return uwp:IsActive()
end

--- Sets whether or not the DFrame can be resized by the user.
--- This is achieved by clicking and dragging in the bottom right corner of the frame.
--- You can set the minimum size using DFrame:setMinWidth and DFrame:setMinHeight.
--@param boolean sizable Whether the frame should be resizeable or not.
function dfrm_methods:setSizable(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = unwrap(self)
	
	uwp:SetSizable(enable)
end

--- Gets whether the DFrame can be resized by the user.
--@return boolean Whether the DFrame can be resized.
function dfrm_methods:getSizable()
	local uwp = unwrap(self)
	
	return uwp:GetSizable()
end

--- Sets the minimum width the DFrame can be resized to by the user.
--@param number minwidth The minimum width the user can resize the frame to.
function dfrm_methods:setMinWidth(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:SetMinWidth(val)
end

--- Gets the minimum width the DFrame can be resized to by the user.
--@return number The minimum width.
function dfrm_methods:getMinWidth()
	local uwp = unwrap(self)
	
	return uwp:GetMinWidth()
end

--- Sets the minimum height the DFrame can be resized to by the user.
--@param number minheight The minimum height the user can resize the frame to.
function dfrm_methods:setMinHeight(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = unwrap(self)
	
	uwp:SetMinHeight(val)
end

--- Gets the minimum height the DFrame can be resized to by the user.
--@return number The minimum height.
function dfrm_methods:getMinHeight()
	local uwp = unwrap(self)
	
	return uwp:GetMinHeight()
end

--- Sets whether the DFrame is restricted to the boundaries of the screen resolution.
--@param boolean locked If true, the frame cannot be dragged outside of the screen bounds.
function dfrm_methods:setScreenLock(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = unwrap(self)
	
	uwp:SetScreenLock(enable)
end

--- Adds or removes an icon on the left of the DFrame's title.
--@param string iconpath Set to nil to remove the icon. Otherwise, set to file path to create the icon.
function dfrm_methods:setIcon(path)
	checkluatype(path, TYPE_STRING)
	local uwp = unwrap(self)
	
	uwp:SetIcon(path)
end

--- Blurs background behind the frame.
--@param boolean blur Whether or not to create background blur or not.
function dfrm_methods:setBackgroundBlur(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = unwrap(self)
	
	uwp:SetBackgroundBlur(enable)
end

--- Returns whether the background is being blurred by DFrame:setBackGroundBlur.
--@return boolean Whether the background is blurred.
function dfrm_methods:getBackgroundBlur()
	local uwp = unwrap(self)
	
	return uwp:GetBackgroundBlur()
end

--- Determines whether the DFrame's control box (close, minimise and maximise buttons) is displayed.
--@param boolean show false hides the control box; this is true by default.
function dfrm_methods:showCloseButton(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = unwrap(self)
	
	uwp:ShowCloseButton(enable)
end

--- Gets whether or not the shadow effect bordering the DFrame is being drawn.
--@return boolean Whether or not the shadow is being drawn.
function dfrm_methods:getPaintShadow()
	local uwp = unwrap(self)
	
	return uwp:GetPaintShadow()
end

--- Sets whether or not the shadow effect bordering the DFrame should be drawn.
--@param boolean draw Whether or not to draw the shadow. This is true by default.
function dfrm_methods:setPaintShadow(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = unwrap(self)
	
	uwp:SetPaintShadow(enable)
end

--- Creates a DScrollPanel. DScrollPanel is a VGUI Element similar to DPanel however it has a vertical scrollbar docked to the right which can be used to put more content in a smaller area.
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DScrollPanel The new DScrollPanel
function vgui_library.createDScrollPanel(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DScrollPanel", parent, name)
	if !parent then panels[new] = true end
	return dscrlwrap(new)
end

--- Returns the canvas ( The panel all child panels are parented to ) of the DScrollPanel.
--@return Panel The canvas.
function dscrl_methods:getCanvas()
	local uwp = dscrlunwrap(self)
	
	return pnlwrap(uwp:GetCanvas())
end

--- Clears the DScrollPanel's canvas, removing all added items.
function dscrl_methods:clear()
	local uwp = dscrlunwrap(self)
	
	uwp:Clear()
end

--- Creates a DMenu. A simple menu with sub menu, icon and convar support. Inherits from DScrollPanel.
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DMenu The new DMenu
function vgui_library.createDMenu(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DMenu", parent, name)
	if !parent then panels[new] = true end
	return dmenwrap(new)
end

--- Add an option to the DMenu
--@param string name Name of the option.
--@param function func Function to execute when this option is clicked.
--@return DMenuOption Returns the created DMenuOption panel.
function dmen_methods:addOption(name, func)
	checkluatype(name, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dmenunwrap(self)
	
	local dmo = uwp:AddOption(name, function()
		instance:runFunction(func)
	end)
	return dmenowrap(dmo)
end

--- Adds a panel to the DMenu as if it were an option.
--@param Panel pnl The panel that you want to add.
function dmen_methods:addPanel(pnl)
	local uwp = dmenunwrap(self)
	local uwp2 = unwrap(pnl)
	
	uwp:AddPanel(uwp2)
end

--- Adds a horizontal line spacer.
function dmen_methods:addSpacer()
	local uwp = dmenunwrap(self)
	
	uwp:AddSpacer()
end

--- Add a sub menu to the DMenu.
--@param string name Name of the sub menu.
--@param function? func Function to execute when this sub menu is clicked.
--@return DMenu The created sub DMenu.
--@return DMenuOption Function to execute when this sub menu is clicked.
function dmen_methods:addSubMenu(name, func)
	checkluatype(name, TYPE_STRING)
	if func != nil then checkluatype(func, TYPE_FUNCTION) end
	local uwp = dmenunwrap(self)
	
	local dm, dmo = uwp:AddSubMenu(name, function()
		if func then
			instance:runFunction(func)
		end
	end)
	return dmenwrap(dm), dmenowrap(dm)
end

--- Returns the number of child elements of the DMenu.
--@return number The number of child elements.
function dmen_methods:getChildCount()
	local uwp = dmenunwrap(self)
	
	return uwp:ChildCount()
end

--- Sets the maximum height the DMenu can have. If the height of all menu items exceed this value, a scroll bar will be automatically added.
--@param number maxHeight The maximum height of the DMenu to set, in pixels.
function dmen_methods:setMaxHeight(mh)
	checkluatype(mh, TYPE_NUMBER)
	local uwp = dmenunwrap(self)
	
	uwp:SetMaxHeight(mh)
end

--- Returns the maximum height of the DMenu.
--@return number The maximum height in pixels.
function dmen_methods:getMaxHeight()
	local uwp = dmenunwrap(self)
	
	return uwp:GetMaxHeight()
end

--- Sets the minimum width of the DMenu. The menu will be stretched to match the given value.
--@param number minimumWidth The minimum width of the DMenu in pixels
function dmen_methods:setMinimumWidth(mh)
	checkluatype(mh, TYPE_NUMBER)
	local uwp = dmenunwrap(self)
	
	uwp:SetMinimumWidth(mh)
end

--- Returns the minimum width of the DMenu in pixels
--@return number The minimum width of the DMenu.
function dmen_methods:getMinimumWidth()
	local uwp = dmenunwrap(self)
	
	return uwp:GetMinimumWidth()
end

--- Opens the DMenu at the specified position or cursor position if X and Y are not given.
--@param number? x Position (X coordinate) to open the menu at.
--@param number? y Position (Y coordinate) to open the menu at.
function dmen_methods:open(x, y)
	local uwp = dmenunwrap(self)
	
	uwp:Open(x, y)
end

--- Creates a sub DMenu and returns it. Has no duplicate call protection.
--@return DMenu The created DMenu to add options to.
function dmeno_methods:addSubMenu()
	local uwp = dmenounwrap(self)
	
	return dmenwrap(uwp:AddSubMenu())
end

--- Sets the checked state of the DMenuOption. Does not invoke DMenuOption:onChecked.
--@param boolean checked New checked state.
function dmeno_methods:setChecked(chk)
	checkluatype(chk, TYPE_BOOL)
	local uwp = dmenounwrap(self)
	
	uwp:SetChecked(chk)
end

--- Returns the checked state of DMenuOption.
--@return boolean Are we checked or not.
function dmeno_methods:getChecked()
	local uwp = dmenounwrap(self)
	
	return uwp:GetChecked()
end

--- Sets whether the DMenuOption is a checkbox option or a normal button option.
--@param boolean checkable Checkable?
function dmeno_methods:setIsCheckable(chk)
	checkluatype(chk, TYPE_BOOL)
	local uwp = dmenounwrap(self)
	
	uwp:SetIsCheckable(chk)
end

--- Returns whether the DMenuOption is a checkbox option or a normal button option.
--@return boolean Is checkable?
function dmeno_methods:getIsCheckable()
	local uwp = dmenounwrap(self)
	
	return uwp:GetIsCheckable()
end

--- Set a function to run when the DMenuOption's checked state changes.
--@param function callback Function to run. Has one argument which is the new checked state.
function dmeno_methods:onChecked(func)
	local uwp = dmenunwrap(self)
	
	function uwp:OnChecked(new)
		instance:runFunction(func, new)
	end
end

--- Creates a DLabel. A standard Derma text label. A lot of this panels functionality is a base for button elements, such as DButton.
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DLabel The new DLabel.
function vgui_library.createDLabel(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DLabel", parent, name)
	if !parent then panels[new] = true end
	return dlabwrap(new)
end

--- Called when the label is left clicked (on key release) by the player.
--- This will be called after DLabel:onDepressed and DLabel:onReleased.
--- This can be overridden; by default, it calls DLabel:toggle.
--@param function callback The function to run when the label is pressed.
function dlab_methods:onClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)
	
	function uwp:DoClick() instance:runFunction(func) end
end

--- Called when the label is double clicked by the player with left clicks.
--- DLabel:setDoubleClickingEnabled must be set to true for this hook to work, which it is by default.
--- This will be called after DLabel:onDepressed and DLabel:onReleased and DLabel:onClick.
--@param function callback The function to run when the label is double clicked.
function dlab_methods:onDoubleClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	function uwp:DoDoubleClick() instance:runFunction(func) end
end

--- Sets whether or not double clicking should call DLabel:DoDoubleClick.
--- This is enabled by default.
--@param boolean enabled True to enable, false to disable.
function dlab_methods:setDoubleClickingEnabled(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dlabunwrap(self)

	uwp:SetDoubleClickingEnabled(enable)
end

--- Returns whether or not double clicking will call DLabel:onDoubleClick.
--@return boolean Whether double clicking functionality is enabled.
function dlab_methods:getDoubleClickingEnabled()
	local uwp = dlabunwrap(self)

	return uwp:GetDoubleClickingEnabled()
end

--- Called when the label is right clicked (on key release) by the player.
--- This will be called after DLabel:onDepressed and DLabel:onReleased.
--@param function callback The function to run when the label is right clicked.
function dlab_methods:onRightClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	function uwp:DoRightClick() instance:runFunction(func) end
end

--- Called when the label is middle clicked (on key release) by the player.
--- This will be called after DLabel:onDepressed and DLabel:onReleased.
--@param function callback The function to run when the label is middle clicked.
function dlab_methods:onMiddleClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	function uwp:DoMiddleClick() instance:runFunction(func) end
end

--- Called when the player presses the label with any mouse button.
--@param function callback The function to run when the label is pressed.
function dlab_methods:onDepressed(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	function uwp:OnDepressed() instance:runFunction(func) end
end

--- Called when the player releases any mouse button on the label. This is always called after DLabel:onDepressed.
--@param function callback The function to run when the label is released.
function dlab_methods:onReleased(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	function uwp:OnReleased() instance:runFunction(func) end
end

--- Called when the toggle state of the label is changed by DLabel:Toggle.
--- In order to use toggle functionality, you must first call DLabel:setIsToggle with true, as it is disabled by default.
--@param function callback The function to run when the label is toggled. Has one argument which is the new toggle state.
function dlab_methods:onToggled(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dlabunwrap(self)

	function uwp:OnToggled(toggleState) instance:runFunction(func, toggleState) end
end

--- Enables or disables toggle functionality for a label. Retrieved with DLabel:getIsToggle.
--- You must call this before using DLabel:setToggle, DLabel:getToggle or DLabel:toggle.
--@param boolean enable Whether or not to enable toggle functionality.
function dlab_methods:setIsToggle(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dlabunwrap(self)

	uwp:SetIsToggle(enable)
end

--- Returns whether the toggle functionality is enabled for a label. Set with DLabel:setIsToggle.
--@return boolean Whether toggle functionality is enabled.
function dlab_methods:getIsToggle()
	local uwp = dlabunwrap(self)

	return uwp:GetIsToggle()
end

--- Toggles the label's state. This can be set and retrieved with DLabel:SetToggle and DLabel:GetToggle.
---In order to use toggle functionality, you must first call DLabel:setIsToggle with true, as it is disabled by default.
function dlab_methods:toggle()
	local uwp = dlabunwrap()

	uwp:Toggle()
end

--- Sets the toggle state of the label. This can be retrieved with DLabel:getToggle and toggled with DLabel:toggle.
--- In order to use toggle functionality, you must first call DLabel:setIsToggle with true, as it is disabled by default.
--@param boolean newState The new state of the toggle.
function dlab_methods:setToggle(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dlabunwrap(self)

	uwp:SetToggle(enable)
end

--- Returns the current toggle state of the label. This can be set with DLabel:setToggle and toggled with DLabel:toggle.
--- In order to use toggle functionality, you must first call DLabel:setIsToggle with true, as it is disabled by default.
--@return boolean The state of the toggleable label.
function dlab_methods:getToggle()
	local uwp = dlabunwrap(self)

	return uwp:GetToggle()
end

--- Sets the font in the DLabel.
--@param string fontName The name of the font. Check render.setFont for a list of default fonts.
function dlab_methods:setFont(fontName)
	checkluatype(fontName, TYPE_STRING)
	local uwp = dlabunwrap(self)

	uwp:SetFont(fontName)
end

--- Gets the font in the DLabel.
--@return string The font name.
function dlab_methods:getFont()
	local uwp = dlabunwrap(self)

	return uwp:GetFont()
end

--- Sets the text color of the DLabel.
--@param Color textColor The text color.
function dlab_methods:setTextColor(clr)
	local uwp = dlabunwrap(self)

	uwp:SetTextColor(cunwrap(clr))
end

--- Returns the "override" text color, set by DLabel:setTextColor.
--@return Color The color of the text, or nil.
function dlab_methods:getTextColor()
	local uwp = dlabunwrap(self)

	return cwrap(uwp:GetTextColor())
end

--- Automatically adjusts the height of the label dependent of the height of the text inside of it.
--@param boolean stretch Whether to stretch the label vertically or not.
function dlab_methods:setAutoStretchVertical(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dlabunwrap(self)

	uwp:SetAutoStretchVertical(enable)
end

--- Gets whether the label will automatically adjust its height based on the height of the text inside of it.
--@return boolean Whether the label stretches vertically or not.
function dlab_methods:getAutoStretchVertical()
	local uwp = dlabunwrap(self)

	return uwp:GetAutoStretchVertical()
end

--- Creates a DButton. Inherits functions from DLabel.
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DButton The new DButton.
function vgui_library.createDButton(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DButton", parent, name)
	if !parent then panels[new] = true end
	return dbutwrap(new)
end

--- Called when the button is left clicked (on key release) by the player. This will be called after DButton:isDown.
--@param function callback The function to run when the button is pressed.
function dbut_methods:onClick(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dbutunwrap(self)
	
	function uwp:DoClick() instance:runFunction(func) end
end

--- Sets an image to be displayed as the button's background.
--@param string imagePath The image file to use, relative to /materials. If this is nil, the image background is removed.
function dbut_methods:setImage(image)
	checkluatype(image, TYPE_STRING)
	local uwp = dbutunwrap(self)

	uwp:SetImage(image)
end

--- Returns true if the DButton is currently depressed (a user is clicking on it).
--@return boolean Whether or not the button is depressed.
function dbut_methods:isDown()
	local uwp = dbutunwrap(self)

	return uwp:IsDown()
end

--- Creates an AvatarImage. Inherits functions from Panel.
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return AvatarImage The new AvatarImage.
function vgui_library.createAvatarImage(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("AvatarImage", parent, name)
	if !parent then panels[new] = true end
	return aimgwrap(new)
end

--- Sets the image to the specified player's avatar.
--@param Player player The player to use avatar of.
--@param number size The resolution size of the avatar to use. Acceptable sizes are 32, 64, 184.
function aimg_methods:setPlayer(ply, size)
	checkluatype(size, TYPE_NUMBER)
	local uwp = unwrap(self)
	local uwply = plyunwrap(ply)

	uwp:SetPlayer(uwply, size)
end

--- Sets the image to the specified user's avatar using 64-bit SteamID.
--@param string steamid The 64bit SteamID of the player to load avatar of.
--@param number size The resolution size of the avatar to use. Acceptable sizes are 32, 64, 184.
function aimg_methods:setSteamID(steamid, size)
	checkluatype(size, TYPE_NUMBER)
	checkluatype(steamid, TYPE_STRING)
	local uwp = unwrap(self)

	uwp:SetSteamID(steamid, size)
end

--- Creates a DProgress. A progressbar, works with a fraction between 0 and 1 where 0 is 0% and 1 is 100%. Inherits functions from Panel.
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DProgress The new DProgress.
function vgui_library.createDProgress(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DProgress", parent, name)
	if !parent then panels[new] = true end
	return dprgwrap(new)
end

--- Sets the fraction of the progress bar. 0 is 0% and 1 is 100%.
--@param number fraction Fraction of the progress bar. Range is 0 to 1 (0% to 100%).
function dprg_methods:setFraction(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = dprgunwrap(self)

	uwp:SetFraction(val)
end

--- Returns the progress bar's fraction. 0 is 0% and 1 is 100%.
--@return number Current fraction of the progress bar.
function dprg_methods:getFraction()
	local uwp = dprgunwrap(self)

	return uwp:GetFraction()
end

--- Creates a DTextEntry. A form which may be used to display text the player is meant to select and copy or alternately allow them to enter some text of their own. Inherits functions from Panel.
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DTextEntry The new DTextEntry.
function vgui_library.createDTextEntry(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DTextEntry", parent, name)
	if !parent then panels[new] = true end
	return dtxewrap(new)
end

--- Sets the placeholder text that will be shown while the text entry has no user text. The player will not need to delete the placeholder text if they decide to start typing.
--@param string placeholder The placeholder text.
function dtxe_methods:setPlaceholderText(text)
	checkluatype(text, TYPE_STRING)
	local uwp = dtxeunwrap(self)

	uwp:SetPlaceholderText(text)
end

--- Gets the DTextEntry's placeholder text.
--@return string The placeholder text.
function dtxe_methods:getPlaceholderText()
	local uwp = dtxeunwrap(self)

	return uwp:GetPlaceholderText()
end

--- Allow you to set placeholder color.
--@param Color placeholderColor The color of the placeholder.
function dtxe_methods:setPlaceholderColor(clr)
	local uwp = dtxeunwrap(self)

	uwp:SetPlaceholderColor(cunwrap(clr))
end

--- Returns the placeholder color.
--@return Color The placeholder color.
function dtxe_methods:getPlaceholderColor()
	local uwp = dtxeunwrap(self)

	return cwrap(uwp:GetPlaceholderColor())
end

--- Sets whether or not to decline non-numeric characters as input.
--- Numeric characters are 1234567890.-
--@param boolean numericOnly Whether to accept only numeric characters.
function dtxe_methods:setNumeric(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dtxeunwrap(self)

	uwp:SetNumeric(enable)
end

--- Returns whether only numeric characters (123456789.-) can be entered into the DTextEntry.
--@return boolean Whether the DTextEntry is numeric or not.
function dtxe_methods:getNumeric()
	local uwp = dtxeunwrap(self)

	return uwp:GetNumeric()
end

--- Sets whether we should fire DTextEntry:onValueChange every time we type or delete a character or only when Enter is pressed.
--@param boolean enable Fire onValueChange every time the entry is modified?
function dtxe_methods:setUpdateOnType(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dtxeunwrap(self)

	uwp:SetUpdateOnType(enable)
end

--- Gets whether the DTextEntry fires onValueChange every time it is modified.
--@return boolean Fire onValueChange on every update?
function dtxe_methods:getUpdateOnType()
	local uwp = dtxeunwrap(self)

	return uwp:GetUpdateOnType()
end

--- Sets the text of the DTextEntry and calls DTextEntry:onValueChange.
--@param string value The value to set.
function dtxe_methods:setValue(text)
	checkluatype(text, TYPE_STRING)
	local uwp = dtxeunwrap(self)

	uwp:SetValue(text)
end

--- Disables Input on a DTextEntry. This differs from Panel:SetDisabled - SetEditable will not affect the appearance of the textbox.
--@param boolean enabled Whether the DTextEntry should be editable.
function dtxe_methods:setEditable(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dtxeunwrap(self)

	uwp:SetEditable(enable)
end

--- Returns the contents of the DTextEntry as a number.
--@return number Text of the DTextEntry as a float, or nil if it cannot be converted to a number using tonumber.
function dtxe_methods:getFloat()
	local uwp = dtxeunwrap(self)

	return uwp:GetFloat()
end

--- Same as DTextEntry:GetFloat(), but rounds value to nearest integer.
--@return number Text of the DTextEntry as an int, or nil if it cannot be converted to a number.
function dtxe_methods:getInt()
	local uwp = dtxeunwrap(self)

	return uwp:GetInt()
end

--- Sets the cursor's color in DTextEntry (the blinking line).
--@param Color cursorColor The color to set the cursor to.
function dtxe_methods:setCursorColor(clr)
	local uwp = dtxeunwrap(self)

	uwp:SetCursorColor(cunwrap(clr))
end

--- Returns the cursor color of a DTextEntry.
--@param Color The color of the cursor as a Color.
function dtxe_methods:getCursorColor()
	local uwp = dtxeunwrap(self)

	return cwrap(uwp:GetCursorColor())
end

--- Changes the font of the DTextEntry.
--@param string fontName The name of the font. Check render.setFont for a list of default fonts.
function dtxe_methods:setFont(fontName)
	checkluatype(fontName, TYPE_STRING)
	local uwp = dtxeunwrap(self)

	uwp:SetFont(fontName)
end

--- Sets whether or not to paint/draw the DTextEntry's background.
--@param boolean paint True to show the entry's background, false to hide it.
function dtxe_methods:setPaintBackground(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dtxeunwrap(self)

	uwp:SetPaintBackground(enable)
end

--- Returns whether or not the entry background is being drawn.
--@return boolean True if the entry background is drawn, false otherwise.
function dtxe_methods:getPaintBackground()
	local uwp = dtxeunwrap(self)

	return uwp:getPaintBackground()
end

--- Called internally by DTextEntry:OnTextChanged when the user modifies the text in the DTextEntry.
--- You should override this function to define custom behavior when the DTextEntry text changes.
--@param function callback The function to run when the user modifies the text.
function dtxe_methods:onChange(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dtxeunwrap(self)

	function uwp:OnChange() instance:runFunction(func) end
end

--- Called internally when the text changes of the DTextEntry are applied.
--- See also DTextEntry:onChange for a function that is called on every text change.
--- You should override this function to define custom behavior when the text changes.
--- This method is called:
--- 	When Enter is pressed after typing
--- 	When DTextEntry:setValue is used
--- 	For every key typed - only if DTextEntry:setUpdateOnType was set to true (default is false)
--@param function callback The function to run when the text changes are applied. Has one argument which is the value that was applied.
function dtxe_methods:onValueChange(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dtxeunwrap(self)

	function uwp:OnValueChange(value) instance:runFunction(func, value) end
end

--- Called whenever enter is pressed on a DTextEntry.
--- DTextEntry:isEditing will still return true in this callback!
--@param function callback The function to run when the text changes are applied. Has one argument which is the value that was applied.
function dtxe_methods:onEnter(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dtxeunwrap(self)

	function uwp:OnEnter(value) instance:runFunction(func, value) end
end

--- Returns whether this DTextEntry is being edited or not. (i.e. has focus)
--@return boolean Whether this DTextEntry is being edited or not.
function dtxe_methods:isEditing()
	local uwp = dtxeunwrap(self)

	return uwp:IsEditing()
end

--- Called whenever the DTextEntry gains focus.
--@param function callback The function to run when entry gains focus.
function dtxe_methods:onGetFocus(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dtxeunwrap(self)

	function uwp:OnGetFocus() instance:runFunction(func) end
end

--- Called whenever the DTextEntry loses focus.
--@param function callback The function to run when the entry loses focus.
function dtxe_methods:onLoseFocus(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dtxeunwrap(self)

	function uwp:OnLoseFocus() instance:runFunction(func) end
end

--- Sets the text color of the DTextEntry.
--@param Color textColor The text color.
function dtxe_methods:setTextColor(clr)
	local uwp = dtxeunwrap(self)

	uwp:SetTextColor(cunwrap(clr))
end

--- Returns the "override" text color, set by DTextEntry:setTextColor.
--@return Color The color of the text, or nil.
function dtxe_methods:getTextColor()
	local uwp = dtxeunwrap(self)

	return cwrap(uwp:GetTextColor())
end

--- Creates a DImage. A panel which displays an image. Inherits functions from DPanel.
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DImage The new DImage.
function vgui_library.createDImage(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DImage", parent, name)
	if !parent then panels[new] = true end
	return dimgwrap(new)
end

--- Sets the image to load into the frame. If the first image can't be loaded and strBackup is set, that image will be loaded instead.
--@param string imagePath The path of the image to load. When no file extension is supplied the VMT file extension is used.
--@param string? backup The path of the backup image.
function dimg_methods:setImage(imagePath, backup)
	checkluatype(imagePath, TYPE_STRING)
	local uwp = dimgunwrap(self)

	uwp:SetImage(imagePath, backup)
end

--- Returns the image loaded in the image panel.
--@return string The path to the image that is loaded.
function dimg_methods:getImage()
	local uwp = dimgunwrap(self)

	return uwp:GetImage()
end

--- Sets the image's color override.
--@param Color imgColor The color override of the image. Uses the Color.
function dimg_methods:setImageColor(clr)
	local uwp = dimgunwrap(self)
	local uwc = cunwrap(clr)

	uwp:SetImageColor(uwc)
end

--- Gets the image's color override.
--@return Color The color override of the image.
function dimg_methods:getImageColor()
	local uwp = dimgunwrap(self)

	return cwrap(uwp:GetImageColor())
end

--- Sets whether the DImage should keep the aspect ratio of its image when being resized.
--- Note that this will not try to fit the image inside the button, but instead it will fill the button with the image.
--@param boolean keep True to keep the aspect ratio, false not to.
function dimg_methods:setKeepAspect(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dimgunwrap(self)

	uwp:SetKeepAspect(enable)
end

--- Returns whether the DImage should keep the aspect ratio of its image when being resized.
--@return boolean Whether the DImage should keep the aspect ratio of its image when being resized.
function dimg_methods:getKeepAspect()
	local uwp = dimgunwrap(self)

	return uwp:GetKeepAspect()
end

--- Creates a DImageButton. An image button. This panel inherits all methods of DButton, such as DLabel:onClick.
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DImageButton The new DImageButton.
function vgui_library.createDImageButton(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DImageButton", parent, name)
	if !parent then panels[new] = true end
	return dimgbwrap(new)
end

--- Sets the image to load into the frame. If the first image can't be loaded and strBackup is set, that image will be loaded instead.
--@param string imagePath The path of the image to load. When no file extension is supplied the VMT file extension is used.
--@param string? backup The path of the backup image.
function dimgb_methods:setImage(imagePath, backup)
	checkluatype(imagePath, TYPE_STRING)
	local uwp = dimgbunwrap(self)

	uwp:SetImage(imagePath, backup)
end

--- Returns the image loaded in the image panel.
--@return string The path to the image that is loaded.
function dimgb_methods:getImage()
	local uwp = dimgbunwrap(self)

	return uwp:GetImage()
end

--- Sets whether the DImageButton should keep the aspect ratio of its image when being resized.
--- Note that this will not try to fit the image inside the button, but instead it will fill the button with the image.
--@param boolean keep True to keep the aspect ratio, false not to.
function dimgb_methods:setKeepAspect(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dimgbunwrap(self)

	uwp:SetKeepAspect(enable)
end

--- Sets the image's color override.
--@param Color imgColor The color override of the image. Uses the Color.
function dimgb_methods:setImageColor(clr)
	local uwp = dimgbunwrap(self)
	local uwc = cunwrap(clr)

	uwp:SetColor(uwc)
end

--- Sets whether the image inside the DImageButton should be stretched to fill the entire size of the button, without preserving aspect ratio. If set to false, the image will not be resized at all.
--@param boolean stretch True to stretch, false to not to stretch.
function dimgb_methods:setStretchToFit(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dimgbunwrap(self)
	
	uwp:SetStretchToFit(enable)
end

--- Returns whether the image inside the button should be stretched to fit it or not.
--@return boolean Stretch?
function dimgb_methods:getStretchToFit()
	local uwp = dimgbunwrap(self)
	
	return uwp:GetStretchToFit()
end

--- Creates a DCheckBox. The DCheckBox is a checkbox. It allows you to get a boolean value from the user. Inherits functions from DButton.
--@param any parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DCheckBox The new DCheckBox.
function vgui_library.createDCheckBox(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DCheckBox", parent, name)
	if !parent then panels[new] = true end
	return dchkwrap(new)
end

--- Sets the checked state of the checkbox, and calls the checkbox's DCheckBox:onChange method.
--@param boolean checked Whether the box should be checked or not.
function dchk_methods:setValue(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dchkunwrap(self)

	uwp:SetValue(enable)
end

--- Sets the checked state of the checkbox. Does not call the checkbox's DCheckBox:onChange method, unlike DCheckBox:setValue.
--@param boolean checked Whether the box should be checked or not.
function dchk_methods:setChecked(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dchkunwrap(self)

	uwp:SetChecked(enable)
end

--- Toggles the checked state of the checkbox, and calls the checkbox's DCheckBox:onChange method. This is called by DCheckBox:onClick.
function dchk_methods:toggle()
	local uwp = dchkunwrap(self)
	
	uwp:Toggle()
end

--- Gets the checked state of the checkbox.
--@return boolean Whether the box is checked or not.
function dchk_methods:getChecked()
	local uwp = dchkunwrap(self)
	
	return uwp:GetChecked()
end

--- Returns whether the state of the checkbox is being edited. This means whether the user is currently clicking (mouse-down) on the checkbox, and applies to both the left and right mouse buttons.
--@return boolean Whether the checkbox is being clicked.
function dchk_methods:isEditing()
	local uwp = dchkunwrap(self)
	
	return uwp:IsEditing()
end

--- Called when the "checked" state is changed.
--@param function callback The function to run when the checked state is changed. Has one argument which is the new checked value of the checkbox.
function dchk_methods:onChange(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dchkunwrap(self)
	
	function uwp:OnChange(bval) instance:runFunction(func, bval) end
end

--- Creates a DNumSlider. The DNumSlider allows you to create a slider, allowing the user to slide it to set a value, or changing the value in the box. Inherits functions from Panel.
--@param any? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DCheckBox The new DCheckBox.
function vgui_library.createDNumSlider(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DNumSlider", parent, name)
	if !parent then panels[new] = true end
	return dnmswrap(new)
end

--- Sets the minimum value for the slider.
--@param number min The value to set as minimum for the slider.
function dnms_methods:setMin(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = dnmsunwrap(self)
	
	uwp:SetMin(val)
end

--- Returns the minimum value of the slider.
--@return number The minimum value of the slider
function dnms_methods:getMin()
	local uwp = dnmsunwrap(self)
	
	return uwp:GetMin()
end

--- Sets the maximum value for the slider.
--@param number max The value to set as maximum for the slider.
function dnms_methods:setMax(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = dnmsunwrap(self)
	
	uwp:SetMax(val)
end

--- Returns the maximum value of the slider.
--@return number The maximum value of the slider
function dnms_methods:getMax()
	local uwp = dnmsunwrap(self)
	
	return uwp:GetMax()
end

--- Sets the desired amount of numbers after the decimal point.
--@param number decimals 0 for whole numbers only, 1 for one number after the decimal point, etc.
function dnms_methods:setDecimals(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = dnmsunwrap(self)
	
	uwp:SetDecimals(val)
end

--- Returns the amount of numbers after the decimal point.
--@return number 0 for whole numbers only, 1 for one number after the decimal point, etc.
function dnms_methods:getDecimals()
	local uwp = dnmsunwrap(self)
	
	return uwp:GetDecimals()
end

--- Returns the DTextEntry component of the slider.
--@return DTextEntry The DTextEntry.
function dnms_methods:getTextArea()
	local uwp = dnmsunwrap(self)
	
	return dtxewrap(uwp:GetTextArea())
end

--- Sets the minimum and the maximum value of the slider.
--@param number min The minimum value of the slider.
--@param number max The maximum value of the slider.
function dnms_methods:setMinMax(min, max)
	checkluatype(min, TYPE_NUMBER)
	checkluatype(max, TYPE_NUMBER)
	local uwp = dnmsunwrap(self)
	
	uwp:SetMinMax(min, max)
end

--- Sets the default value of the slider, to be used by DNumSlider:resetToDefaultValue or by middle mouse clicking the draggable knob of the slider.
--@param number default The new default value of the slider to set.
function dnms_methods:setDefaultValue(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = dnmsunwrap(self)
	
	uwp:SetDefaultValue(val)
end

--- Returns the default value of the slider, if one was set by DNumSlider:setDefaultValue
--@return number The default value of the slider
function dnms_methods:getDefaultValue()
	local uwp = dnmsunwrap(self)
	
	return uwp:GetDefaultValue()
end

--- Sets the value of the DNumSlider. Calls the slider's onValueChange method.
--@param number value The value to set.
function dnms_methods:setValue(val)
	checkluatype(val, TYPE_NUMBER)
	local uwp = dnmsunwrap(self)
	
	uwp:SetValue(val)
end

--- Returns the value of the DNumSlider.
--@return number The value of the slider.
function dnms_methods:getValue()
	local uwp = dnmsunwrap(self)
	
	return uwp:GetValue()
end

--- Returns true if either the DTextEntry, the DSlider or the DNumberScratch are being edited.
--@return boolean Whether or not the DNumSlider is being edited by the player.
function dnms_methods:isEditing()
	local uwp = dnmsunwrap(self)
	
	return uwp:IsEditing()
end

--- Resets the slider to the default value, if one was set by DNumSlider:setDefaultValue.
--- This function is called by the DNumSlider when user middle mouse clicks on the draggable knob of the slider.
function dnms_methods:resetToDefaultValue()
	local uwp = dnmsunwrap(self)
	
	uwp:ResetToDefaultValue()
end

--- Returns the range of the slider, basically maximum value - minimum value.
--@return number The range of the slider.
function dnms_methods:getRange()
	local uwp = dnmsunwrap(self)
	
	return uwp:GetRange()
end

--- Called when the value of the slider is changed, through code or changing the slider.
--@param function callback The function to run when the value is changed. Has one argument which is the new value that was set.
function dnms_methods:onValueChange(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dnmsunwrap(self)
	
	function uwp:OnValueChanged(val) instance:runFunction(func, val) end
end

--- Creates a DComboBox. A field with multiple selectable values. Inherits functions from DButton.
--@param any? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DComboBox The new DComboBox.
function vgui_library.createDComboBox(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DComboBox", parent, name)
	if !parent then panels[new] = true end
	return dcomwrap(new)
end

--- Adds a choice to the combo box.
--@param string name The text show to the user.
--@param any? value The data accompanying this string. If left empty, the value argument is used instead.
--@param boolean? selected Should this be the default selected text show to the user or not.
--@param string? icon Adds an icon for this choice.
--@return number The index of the new option.
function dcom_methods:addChoice(name, val, def, icon)
	checkluatype(name, TYPE_STRING)
	checkoptional(def, TYPE_BOOL)
	checkoptional(icon, TYPE_STRING)
	local uwp = dcomunwrap(self)
	
	return uwp:AddChoice(name, val, def, icon)
end

--- Adds a spacer below the currently last item in the drop down. Recommended to use with DComboBox:setSortItems set to false.
function dcom_methods:addSpacer()
	local uwp = dcomunwrap(self)
	
	uwp:AddSpacer()
end

--- Sets whether or not the items should be sorted alphabetically in the dropdown menu of the DComboBox. If set to false, items will appear in the order they were added by DComboBox:addChoice calls. Enabled by default.
--@param boolean sort true to enable, false to disable.
function dcom_methods:setSortItems(enable)
	checkluatype(enable, TYPE_BOOL)
	local uwp = dcomunwrap(self)
	
	uwp:SetSortItems(enable)
end

--- Opens the combo box drop down menu. Called when the combo box is clicked.
function dcom_methods:openMenu()
	local uwp = dcomunwrap(self)
	
	uwp:OpenMenu()
end

--- Closes the combo box menu. Called when the combo box is clicked while open.
function dcom_methods:closeMenu()
	local uwp = dcomunwrap(self)
	
	uwp:CloseMenu()
end

--- Sets the text shown in the combo box when the menu is not collapsed.
--@param string txt The text in the DComboBox.
function dcom_methods:setValue(txt)
	checkluatype(txt, TYPE_STRING)
	local uwp = dcomunwrap(self)
	
	uwp:SetValue(txt)
end

--- Returns whether or not the combo box's menu is opened.
--@return boolean True if the menu is open, false otherwise.
function dcom_methods:isMenuOpen()
	local uwp = dcomunwrap(self)
	
	return uwp:IsMenuOpen()
end

--- Returns the currently selected option's text and data
--@return string The option's text value.
--@return any The option's stored data.
function dcom_methods:getSelected()
	local uwp = dcomunwrap(self)
	
	return uwp:GetSelected()
end

--- Returns the index (ID) of the currently selected option.
--@return number The ID of the currently selected option.
function dcom_methods:getSelectedID()
	local uwp = dcomunwrap(self)
	
	return uwp:GetSelectedID()
end

--- Returns an option's text based on the given index.
--@param number index The option index.
--@return string The option's text value.
function dcom_methods:getOptionText(id)
	checkluatype(id, TYPE_NUMBER)
	local uwp = dcomunwrap(self)
	
	return uwp:GetOptionText(id)
end

--- Returns an option's text based on the given data.
--@param string data The data to look up the name of. If given a number and no matching data was found, the function will test given data against each tonumber'd data entry.
--@return string The option's text value. If no matching data was found, the data itself will be returned. If multiple identical data entries exist, the first instance will be returned.
function dcom_methods:getOptionTextByData(data)
	checkluatype(data, TYPE_STRING)
	local uwp = dcomunwrap(self)
	
	return uwp:GetOptionTextByData(data)
end

--- Returns an option's data based on the given index.
--@param number index The option index.
--@return any The option's data value.
function dcom_methods:getOptionData(id)
	checkluatype(id, TYPE_NUMBER)
	local uwp = dcomunwrap(self)
	
	return uwp:GetOptionData(id)
end

--- Clears the combo box's text value, choices, and data values.
function dcom_methods:clear()
	local uwp = dcomunwrap(self)
	
	uwp:Clear()
end

--- Selects a combo box option by its index and changes the text displayed at the top of the combo box.
--@param string value The text to display at the top of the combo box.
--@param number index The option index.
function dcom_methods:chooseOption(val, index)
	checkluatype(val, TYPE_STRING)
	checkluatype(index, TYPE_NUMBER)
	local uwp = dcomunwrap(self)
	
	uwp:ChooseOption(val, index)
end

--- Selects an option within a combo box based on its table index.
--@param number index Selects the option with given index.
function dcom_methods:chooseOptionID(index)
	checkluatype(index, TYPE_NUMBER)
	local uwp = dcomunwrap(self)
	
	uwp:ChooseOptionID(index)
end

--- Called when an option in the combo box is selected.
--@param function callback The function to run when an option is selected. Has three arguments: (The index of the option, the name of the option, the data assigned to the option)
function dcom_methods:onSelect(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dcomunwrap(self)

	function uwp:OnSelect(id, val, data) instance:runFunction(func, id, val, data) end
end

--- Creates a DColorMixer. A standard Derma color mixer. Inherits functions from DPanel.
--@param any? parent Panel to parent to.
--@param string? name Custom name of the created panel for scripting/debugging purposes. Can be retrieved with Panel:getName.
--@return DColorMixer The new DColorMixer.
function vgui_library.createDColorMixer(parent, name)
	if parent then parent = unwrap(parent) end
	
	local new = vgui.Create("DColorMixer", parent, name)
	if !parent then panels[new] = true end
	return dclmwrap(new)
end

--- Called when the player changes the color of the DColorMixer.
--@param function callback The function to run when the color is changed. Has one argument which is the new color as a table.
function dclm_methods:valueChanged(func)
	checkluatype(func, TYPE_FUNCTION)
	local uwp = dclmunwrap(self)

	function uwp:ValueChanged(clr)
		instance:runFunction(func, {r = clr.r, g = clr.g, b = clr.b, a = clr.a}) 
	end
end

--- Show / Hide the colors indicators in DColorMixer.
--@param boolean show Show / Hide the colors indicators.
function dclm_methods:setWangs(show)
	checkluatype(show, TYPE_BOOL)
	local uwp = dclmunwrap(self)
	
	uwp:SetWangs(show)
end

--- Returns whether the wangs are hidden.
--@return boolean Are wangs hidden?
function dclm_methods:getWangs()
	local uwp = dclmunwrap(self)
	
	return uwp:GetWangs()
end


--- Show or hide the palette panel.
--@param boolean show Show or hide the palette panel?
function dclm_methods:setPalette(show)
	checkluatype(show, TYPE_BOOL)
	local uwp = dclmunwrap(self)
	
	uwp:SetPalette(show)
end

--- Returns whether the palette panel is hidden.
--@return boolean Is palette panel hidden?
function dclm_methods:getPalette()
	local uwp = dclmunwrap(self)
	
	return uwp:GetPalette()
end

--- Returns whether the alpha bar is hidden.
--@param boolean show Show or hide the alpha bar?
function dclm_methods:setAlphaBar(show)
	checkluatype(show, TYPE_BOOL)
	local uwp = dclmunwrap(self)
	
	uwp:SetAlphaBar(show)
end

--- Show or hide the alpha bar.
--@return boolean Is alpha bar hidden?
function dclm_methods:getAlphaBar()
	local uwp = dclmunwrap(self)
	
	return uwp:GetAlphaBar()
end

--- Sets the label's text to show.
--@param string text Set to non empty string to show the label and its text. Give it an empty string or nothing and the label will be hidden.
function dclm_methods:setLabel(txt)
	checkluatype(txt, TYPE_STRING)
	local uwp = dclmunwrap(self)
	
	uwp:SetLabel(txt)
end

--- Sets the color of the DColorMixer.
--@param Color clr The color to set.
function dclm_methods:setColor(clr)
	clr = cunwrap(clr)
	local uwp = dclmunwrap(self)
	
	uwp:SetColor(clr)
end

--- Returns the current selected color.
--@return Color The current selected color.
function dclm_methods:getColor()
	local uwp = dclmunwrap(self)
	
	return cwrap(uwp:GetColor())
end

end