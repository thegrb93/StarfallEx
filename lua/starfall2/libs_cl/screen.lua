--- Screen library
-- @author Colonel Thirty Two
-- Screens are 512x512 units. Most, if not all, functions require
-- that you be in the rendering hook to call, otherwise an error is
-- thrown. +x is right, +y is down

SF.Libraries.Local.Screen = SF.Typedef("Library: screen")

local render = render
local surface = surface
local clamp = math.Clamp
local max = math.max

local validfonts = {
	DebugFixed = true,
	DebugFixedSmall = true,
	DefaultFixedOutline = true,
	MenuItem = true,
	Default = true,
	TabLarge = true,
	DefaultBold = true,
	DefaultUnderline = true,
	DefaultSmall = true,
	DefaultSmallDropShadow = true,
	DefaultVerySmall = true,
	DefaultLarge = true,
	UiBold = true,
	MenuLarge = true,
	ConsoleText = true,
	Marlett = true,
	Trebuchet18 = true,
	Trebuchet19 = true,
	Trebuchet20 = true,
	Trebuchet22 = true,
	Trebuchet24 = true,
	HUDNumber = true,
	HUDNumber1 = true,
	HUDNumber2 = true,
	HUDNumber3 = true,
	HUDNumber4 = true,
	HUDNumber5 = true,
	HudHintTextLarge = true,
	HudHintTextSmall = true,
	CenterPrintText = true,
	HudSelectionText = true,
	DefaultFixed = true,
	DefaultFixedDropShadow = true,
	CloseCaption_Normal = true,
	CloseCaption_Bold = true,
	CloseCaption_BoldItalic = true,
	TitleFont = true,
	TitleFont2 = true,
	ChatFont = true,
	TargetID = true,
	TargetIDSmall = true,
	HL2MPTypeDeath = true,
	BudgetLabel = true,
}

local defined_fonts = {}

local function fixcolor(r,g,b)
	return clamp(tonumber(r) or 0,0,255),
		clamp(tonumber(g) or 0,0,255),
		clamp(tonumber(b) or 0,0,255)
end

local function fixcolorA(r,g,b,a)
	return clamp(tonumber(r) or 0,0,255),
		clamp(tonumber(g) or 0,0,255),
		clamp(tonumber(b) or 0,0,255),
		clamp(tonumber(a) or 255,0,255)
end

local function fixcolorT(tbl)
	return {
		r = clamp(tonumber(tbl and tbl.r) or 0,0,255),
		g = clamp(tonumber(tbl and tbl.g) or 0,0,255),
		b = clamp(tonumber(tbl and tbl.b) or 0,0,255),
		a = clamp(tonumber(tbl and tbl.a) or 255,0,255),
	}
end

-- ------------------------------------------------------------------ --

--- Sets the draw color
-- @param r Red value or 0
-- @param g Green value or 0
-- @param b Blue value or 0
-- @param a Alpha value or 0
function SF.Libraries.Local.Screen.setColor(r,g,b,a)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	surface.SetDrawColor(fixcolorA(r,g,b,a))
end

--- Sets the text color
-- @param r Red value or 0
-- @param g Green value or 0
-- @param b Blue value or 0
-- @param a Alpha value or 0
function SF.Libraries.Local.Screen.setTextColor(r,g,b,a)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	surface.SetTextColor(fixcolorA(r,g,b,a))
end

--- Clears the screen.
-- @param r Red value or 0
-- @param g Green value or 0
-- @param b Blue value or 0
function SF.Libraries.Local.Screen.clear(r,g,b)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	render.Clear( fixcolor(r,g,b), 255 )
end

--- Draws a rectangle using the current color. 
-- @param x Bottom left corner x coordinate
-- @param y Bottom left corner y coordinate
-- @param w Width
-- @param h Height
function SF.Libraries.Local.Screen.drawRect(x,y,w,h)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	surface.DrawRect(tonumber(x) or 0, tonumber(y) or 0,
		max(tonumber(w) or 0, 0), max(tonumber(h) or 0, 0))
end

--- Draws a rectangle outline using the current color.
-- @param x Bottom left corner x coordinate
-- @param y Bottom left corner y coordinate
-- @param w Width
-- @param h Height
function SF.Libraries.Local.Screen.drawRectOutline(x,y,w,h)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	surface.DrawOutlinedRect(tonumber(x) or 0, tonumber(y) or 0,
		max(tonumber(w) or 0, 0), max(tonumber(h) or 0, 0))
end

--- Draws a circle
-- @param x Center x coordinate
-- @param y Center y coordinate
-- @param r Radius
-- @param c Color (doesn't follow setColor...)
function SF.Libraries.Local.Screen.drawCircle(x,y,r,c)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	surface.DrawCircle(tonumber(x) or 0, tonumber(y) or 0, max(tonumber(r) or 1, 0),
		fixcolorT(c))
end

--- Draws a line
-- @param x1 X start coordinate
-- @param y1 Y start coordinate
-- @param x2 X end coordinate
-- @param y2 Y end coordinate
function SF.Libraries.Local.Screen.drawLine(x1,y1,x2,y2)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	surface.DrawLine(tonumber(x1) or 0, tonumber(y1) or 0, tonumber(x2) or 0, tonumber(y2) or 0)
end

-- Creates a font
-- @param font Base font to use
-- @param size Font size
-- @param weight Font weight (default: 400)
-- @param antialias Antialias font?
-- @param additive If true, adds brightness to pixels behind it rather than drawing over them.
-- @param shadow Enable drop shadow?
-- @param outline Enable outline?
-- @param A table representing the font (doesn't contain anything)
--function SF.Libraries.Local.Screen.createFont(font,size,weight,antialias,additive,shadow,outline,blur)
	--if not validfonts[font] then return nil, "invalid font" end
	
	--size = tonumber(size) or 12
	--weight = tonumber(weight) or 400
	--blur = tonumber(blur) or 0
	--antialias = antialias and true or false
	--additive = additive and true or false
	--shadow = shadow and true or false
	--outline = outline and true or false
	
	--local name = string.format("sf_screen_font_%s_%d_%d_%d_%d%d%d%d",
		--font, size, weight, blur,
		--antialias and 1 or 0,
		--additive and 1 or 0,
		--shadow and 1 or 0,
		--outline and 1 or 0)
	
	--if not defined_fonts[name] then
		--surface.CreateFont(font, size, weight, antialias, additive, name,
			--shadow, outline, blur)
		--defined_fonts[name] = true
	--end
	--return name
--end

--- Draws text using a font
-- @param font Font table returned by createFont
-- @param x X coordinate
-- @param y Y coordinate
-- @param text Text to draw
function SF.Libraries.Local.Screen.drawText(font,x,y,text)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	SF.CheckType(text,"string")
	surface.SetTextPos(tonumber(x) or 0, tonumber(y) or 0)
	surface.SetFont(font)
	surface.DrawText(text)
end
