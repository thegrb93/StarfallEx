--- Screen library
-- @author Colonel Thirty Two

--- Screen library. Screens are 512x512 units. Most functions require
-- that you be in the rendering hook to call, otherwise an error is
-- thrown. +x is right, +y is down
-- @entity wire_starfall_screen
local screen_library, _ = SF.Libraries.RegisterLocal("screen")

--- Vertex format
-- @name Vertex Format
-- @class table
-- @field x X coordinate
-- @field y Y coordinate
-- @field u U coordinate (optional, default is 0)
-- @field v V coordinate (optional, default is 0)

local render = render
local surface = surface
local clamp = math.Clamp
local max = math.max
local cam = cam
local dgetmeta = debug.getmetatable
local matrix_meta = _R.VMatrix

local matrix = Matrix()
SF.Libraries.AddHook("prepare",function(instance, hook)
	if hook == "render" then
		matrix = Matrix() -- Reset transformation matrix
	end
end)

local texturecache = {}

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

local mesh_methods, mesh_metamethods = SF.Typedef("Mesh")
local wrapmesh, unwrapmesh = SF.CreateWrapper(meshmt)

local function checkvertex(vert)
	print("\tVertex:")
	print(string.format("\t\tx= %s",vert.x))
	print(string.format("\t\ty= %s",vert.y))
	print(string.format("\t\tu= %s",vert.u))
	print(string.format("\t\tv= %s",vert.v))
	print("\tEnd vertex.")
	local copy = {
		x = SF.CheckType(vert.x,"number",1),
		y = SF.CheckType(vert.y,"number",1),
		u = tonumber(vert.u) or 0,
		v = tonumber(vert.v) or 0,
	}
	return copy
end

function mesh_metamethods:__index(k)
	SF.CheckType(self,mesh_metamethods)
	SF.CheckType(k,"number")
	local mesh = unwrapmesh(self)
	if not mesh then return nil end
	if k <= 0 or k > #mesh then return nil end
	return table.Copy(mesh[i])
end

function mesh_metamethods:__len()
	SF.CheckType(self,mesh_metamethods)
	local mesh = unwrapmesh(self)
	return mesh and #mesh or nil
end

function mesh_metamethods:__newindex(k,v)
	SF.CheckType(self,mesh_metamethods)
	SF.CheckType(k,"number")
	SF.CheckType(v,"table")
	local mesh = unwrapmesh(self)
	if not mesh then return end
	if k <= 0 or k > (#mesh)+1 then return error("mesh index out of bounds: "..k.." out of "..#mesh,2) end
	mesh[k] = checkvertex(v)
end

-- ------------------------------------------------------------------ --

--- Sets the transformation matrix
-- @param m The matrix
function screen_library.setMatrix(m)
	SF.CheckType(m,matrix_meta)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	matrix = m
end

--- Gets the transformation matrix
-- @return The matrix
function screen_library.getMatrix()
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	return matrix
end

--- Sets the draw color
-- @param r Red value or 0
-- @param g Green value or 0
-- @param b Blue value or 0
-- @param a Alpha value or 0
function screen_library.setColor(r,g,b,a)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	surface.SetDrawColor(fixcolorA(r,g,b,a))
end

--- Sets the text color
-- @param r Red value or 0
-- @param g Green value or 0
-- @param b Blue value or 0
-- @param a Alpha value or 0
function screen_library.setTextColor(r,g,b,a)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	surface.SetTextColor(fixcolorA(r,g,b,a))
end

function screen_library.getTextureID(tx)
	if #file.Find("materials/"..tx..".*",true) > 0 then
		 local id = surface.GetTextureID(tx)
		 texturecache[id] = tx
		 return id
	end
end

--- Sets the texture
function screen_library.setTexture(id)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	if not id then
		surface.SetTexture(nil)
	elseif texturecache[id] then
		surface.SetTexture(id)
	end
end

--- Clears the screen.
-- @param r Red value or 0
-- @param g Green value or 0
-- @param b Blue value or 0
function screen_library.clear(r,g,b)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	render.Clear( fixcolor(r,g,b), 255 )
end

--- Draws a rectangle using the current color. 
-- @param x Bottom left corner x coordinate
-- @param y Bottom left corner y coordinate
-- @param w Width
-- @param h Height
function screen_library.drawRect(x,y,w,h)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	
	cam.PushModelMatrix(matrix)
	surface.DrawRect(tonumber(x) or 0, tonumber(y) or 0,
		max(tonumber(w) or 0, 0), max(tonumber(h) or 0, 0))
	cam.PopModelMatrix()
end

--- Draws a rectangle outline using the current color.
-- @param x Bottom left corner x coordinate
-- @param y Bottom left corner y coordinate
-- @param w Width
-- @param h Height
function screen_library.drawRectOutline(x,y,w,h)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	
	cam.PushModelMatrix(matrix)
	surface.DrawOutlinedRect(tonumber(x) or 0, tonumber(y) or 0,
		max(tonumber(w) or 0, 0), max(tonumber(h) or 0, 0))
	cam.PopModelMatrix()
end

--- Draws a circle
-- @param x Center x coordinate
-- @param y Center y coordinate
-- @param r Radius
-- @param c Color (doesn't follow setColor...)
function screen_library.drawCircle(x,y,r,c)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	cam.PushModelMatrix(matrix)
	surface.DrawCircle(tonumber(x) or 0, tonumber(y) or 0, max(tonumber(r) or 1, 0),
		fixcolorT(c))
	cam.PopModelMatrix()
end

--- Draws a textured rectangle.
-- @param x X coordinate
-- @param y Y coordinate
-- @param w Width
-- @param h Height
function screen_library.drawTexturedRect(x,y,w,h)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	cam.PushModelMatrix(matrix)
	surface.DrawTexturedRect(tonumber(x) or 0, tonumber(y) or 0,
		max(tonumber(w) or 0, 0), max(tonumber(h) or 0, 0))
	cam.PopModelMatrix(matrix)
end

--- Draws a textured rectangle with UV coordinates
-- @param x X coordinate
-- @param y Y coordinate
-- @param w Width
-- @param h Height
-- @param tw Texture width
-- @param th Texture height
function screen_library.drawTexturedRectUV(x,y,w,h,tw,th)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	cam.PushModelMatrix(matrix)
	surface.DrawTexturedRectUV(tonumber(x) or 0, tonumber(y) or 0,
		max(tonumber(w) or 0, 0), max(tonumber(h) or 0, 0),
		max(tonumber(tw) or 0, 0), max(tonumber(th) or 0, 0))
	cam.PopModelMatrix(matrix)
end

--- Draws a line
-- @param x1 X start coordinate
-- @param y1 Y start coordinate
-- @param x2 X end coordinate
-- @param y2 Y end coordinate
function screen_library.drawLine(x1,y1,x2,y2)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	
	cam.PushModelMatrix(matrix)
	surface.DrawLine(tonumber(x1) or 0, tonumber(y1) or 0, tonumber(x2) or 0, tonumber(y2) or 0)
	cam.PopModelMatrix()
end

-- Creates a font. Does not require rendering hook
-- @param font Base font to use
-- @param size Font size
-- @param weight Font weight (default: 400)
-- @param antialias Antialias font?
-- @param additive If true, adds brightness to pixels behind it rather than drawing over them.
-- @param shadow Enable drop shadow?
-- @param outline Enable outline?
-- @param A table representing the font (doesn't contain anything)
--function screen_library.createFont(font,size,weight,antialias,additive,shadow,outline,blur)
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
function screen_library.drawText(font,x,y,text)
	if not SF.instance.data.screen.isRendering then error("Not in rendering hook.",2) end
	SF.CheckType(text,"string")
	surface.SetTextPos(tonumber(x) or 0, tonumber(y) or 0)
	surface.SetFont(font)
	
	cam.PushModelMatrix(matrix)
	surface.DrawText(text)
	cam.PopModelMatrix()
end

--- Compiles a 2D mesh. This is needed so that meshes don't have to be
-- type-checked each frame. Meshes can be indexed by a number, in which
-- a copy of the vertex at that spot is returned. They can also be assigned
-- a new vertex at 1 <= i <= #mesh+1. And the length of the mesh can be taken.
-- @param verts Array of verticies to convert.
function screen_library.createMesh(verts)
	SF.CheckType(verts,"table")
	local mesh = {}
	local meshtbl = wrapmesh(mesh)
	print(string.format("DEBUG: Creating mesh from %d verticies!",#verts))
	for i=1,#verts do
		local v = verts[i]
		SF.CheckType(v,"table")
		mesh[i] = checkvertex(v)
	end
	print("DEBUG: End creating mesh")
	return meshtbl
end

--- Draws a polygon (mesh). Takes a compiled/uncompiled mesh to draw.
-- Note that if you do use an uncompiled mesh, you will use up ops
-- very quickly!
-- @param Compiled mesh or array of vertexes
function screen_library.drawPoly(mesh)
	if dgetmeta(mesh) ~= mesh_metamethods then
		print("DEBUG: Compiling mesh at runtime!")
		SF.CheckType(mesh,"table")
		verts = mesh
		mesh = {}
		for i=1,#verts do
			local v = verts[i]
			SF.CheckType(v,"table")
			mesh[i] = checkvertex(v)
		end
	end
	cam.PushModelMatrix(matrix)
	surface.DrawPoly(mesh)
	cam.PopModelMatrix()
end

-- Use handling
-- Copied from GPULib
local function ScaleCursor( this, x, y )
	if (this.Scaling) then			
		local xMin = this.xScale[1]
		local xMax = this.xScale[2]
		local yMin = this.yScale[1]
		local yMax = this.yScale[2]
		
		x = (x * (xMax-xMin)) / 512 + xMin
		y = (y * (yMax-yMin)) / 512 + yMin
	end
	
	return x, y
end

-- Copied from GPULib
function screen_library.screenPos( ply )
	local Normal, Pos, monitor, Ang
	local screen = SF.instance.data.entity
	
	ply = SF.Entities.Unwrap( ply )
	
	-- Get monitor screen pos & size
	monitor = WireGPU_Monitors[ screen:GetModel() ]
		
	-- Monitor does not have a valid screen point
	if (!monitor) then return nil end
		
	Ang = screen:LocalToWorldAngles( monitor.rot )
	Pos = screen:LocalToWorld( monitor.offset )
		
	Normal = Ang:Up()
	
	local Start = ply:GetShootPos()
	local Dir = ply:GetAimVector()
	
	local A = Normal:Dot(Dir)
	
	-- If ray is parallel or behind the screen
	if (A == 0 or A > 0) then return nil end
	
	local B = Normal:Dot(Pos-Start) / A
		if (B >= 0) then
		local HitPos = WorldToLocal( Start + Dir * B, Angle(), Pos, Ang )
		local x = (0.5+HitPos.x/(monitor.RS*512/monitor.RatioX)) * 512
		local y = (0.5-HitPos.y/(monitor.RS*512)) * 512	
		if (x < 0 or x > 512 or y < 0 or y > 512) then return nil end -- Aiming off the screen 
		x, y = ScaleCursor( screen, x, y )
		return x, y
	end
	
	return nil
end
