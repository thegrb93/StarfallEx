-------------------------------------------------------------------------------
-- Render library
-------------------------------------------------------------------------------

--- Called when a frame is requested to be drawn.
-- @name render
-- @class hook
-- @client


--- Called when the engine wants to calculate the player's view
-- @name calcview
-- @class hook
-- @client
-- @param pos Current position of the camera
-- @param ang Current angles of the camera
-- @param fov Current fov of the camera
-- @param znear Current near plane of the camera
-- @param zfar Current far plane of the camera
-- @return table Table containing information for the camera. {origin=camera origin, angles=camera angles, fov=camera fov, znear=znear, zfar=zfar, drawviewer=drawviewer}

--- Render library. Screens are 512x512 units. Most functions require
-- that you be in the rendering hook to call, otherwise an error is
-- thrown. +x is right, +y is down
-- @entity starfall_screen
-- @field TEXT_ALIGN_LEFT
-- @field TEXT_ALIGN_CENTER
-- @field TEXT_ALIGN_RIGHT
-- @field TEXT_ALIGN_TOP
-- @field TEXT_ALIGN_BOTTOM

local render_library, _ = SF.Libraries.RegisterLocal("render")

render_library.TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT
render_library.TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
render_library.TEXT_ALIGN_RIGHT = TEXT_ALIGN_RIGHT
render_library.TEXT_ALIGN_TOP = TEXT_ALIGN_TOP
render_library.TEXT_ALIGN_BOTTOM = TEXT_ALIGN_BOTTOM

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
local matrix_meta = SF.VMatrix.Metatable --debug.getregistry().VMatrix

local v_unwrap = SF.VMatrix.Unwrap


local function sfCreateMaterial( name )
	return CreateMaterial( name, "UnlitGeneric", {
				[ "$nolod" ] = 1,
				[ "$ignorez" ] = 1,
				[ "$vertexcolor" ] = 1,
				[ "$vertexalpha" ] = 1,
				[ "$basetexturetransform"] = "center .5 .5 scale 1.032 1.032 rotate 0 translate 0 0"
			} )
end

local currentcolor
local MATRIX_STACK_LIMIT = 8
local matrix_stack = {}

local globalRTs = {}
local globalRTcount = 0
local RT_Material = sfCreateMaterial( "SF_RT_Material" )

local function findAvailableRT ()
	for k, v in pairs( globalRTs ) do
		if v[ 2 ] then
			return k, v
		end
	end
	return nil
end

SF.Libraries.AddHook( "prepare", function ( instance, hook )
	if hook == "render" then
		currentcolor = Color(0,0,0,0)
	end
end )

SF.Libraries.AddHook( "cleanup", function ( instance )
	for i=#matrix_stack,1,-1 do
		cam.PopModelMatrix()
		matrix_stack[i] = nil
	end
	local data = instance.data.render
	if data.usingRT then
		render.SetRenderTarget()
		cam.End2D()
		render.SetViewPort(unpack(data.oldViewPort))
		data.usingRT = false
	end
end )


SF.Libraries.AddHook("initialize",function(instance)
	instance.data.render.rendertargets = {}
	instance.data.render.rendertargetcount = 0
end)

SF.Libraries.AddHook( "deinitialize", function ( instance )
	local data = instance.data.render
	for k, v in pairs( data.rendertargets ) do
		globalRTs[ v ][ 2 ] = true -- mark as available
	end
end )

---URL Textures
local LoadingURLQueue = {}

local texturecache, texturecachehttp

local function CheckURLDownloads()
	local numqueued = #LoadingURLQueue
	local urltable = LoadingURLQueue[numqueued]

	if urltable then
		if urltable.Panel then
			if not urltable.Panel:IsLoading() then
				timer.Simple(0.2,function()
					local tex = urltable.Panel:GetHTMLMaterial():GetTexture("$basetexture")
					tex:Download()
					urltable.Material:SetTexture("$basetexture", tex)
					tex:Download()
					urltable.Panel:Remove()
					if urltable.cb then urltable.cb() end
				end)
				LoadingURLQueue[numqueued] = nil
			else
				if CurTime() > urltable.Timeout then
					urltable.Panel:Remove()
					LoadingURLQueue[numqueued] = nil
				end
			end

		else
			local Panel = vgui.Create( "DHTML" )
			Panel:SetSize( 1024, 1024 )
			Panel:SetAlpha( 0 )
			Panel:SetMouseInputEnabled( false )
			Panel:SetHTML(
			[[
				<html><head><style type="text/css">
					html
					{
						overflow:hidden;
						margin: -8px -8px;
					}
					body {
						background-image: url(]] .. urltable.Url .. [[);
						background-size: contain;
						background-position: ]] .. urltable.Alignment .. [[;
						background-repeat: no-repeat;
						height: 100%;
						width: 100%;
					}
				</style></head><body></body></html>
			]]
			)
			urltable.Timeout = CurTime()+20
			urltable.Panel = Panel
		end
	end

	if #LoadingURLQueue == 0 then
		timer.Destroy("SF_URLMaterialChecker")
	end
end

local cv_max_url_materials = CreateConVar( "sf_render_maxurlmaterials", "30", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )

local function LoadURLMaterial( url, alignment, cb )
	--Count the number of materials
	local totalMaterials = 0, key
	while true do
		key = next(texturecachehttp, key)
		if not key then break end
		totalMaterials = totalMaterials + 1
	end

	local queuesize = #LoadingURLQueue
	totalMaterials = totalMaterials + queuesize

	if totalMaterials>=cv_max_url_materials:GetInt() then
		return
	end

	local urlmaterial = sfCreateMaterial("SF_TEXTURE_" .. util.CRC(url .. SysTime()))

	if queuesize == 0 then
		timer.Create("SF_URLMaterialChecker",1,0,function() CheckURLDownloads() end)
	end

	LoadingURLQueue[queuesize + 1] = {Material = urlmaterial, Url = url, Alignment = alignment, cb = cb}
	return urlmaterial
end

texturecache = setmetatable({},{__mode = "k"})
texturecachehttp = setmetatable({},{__mode = "k"})

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
	[ "DejaVu Sans Mono" ] = true
}

surface.CreateFont("sf_screen_font_Default_16_400_9_0000", {size = 16, weight = 400,
		antialias=false, additive = false, font = "Default",
		shadow = false, outline = false, blur = 0})

local defined_fonts = {
	["sf_screen_font_Default_16_400_9_0000"] = true
}

local defaultFont = "sf_screen_font_Default_16_400_9_0000"

local poly_methods, poly_metamethods = SF.Typedef("Polygon")
local wrappoly, unwrappoly = SF.CreateWrapper(poly_metamethods)

local function checkvertex(vert)
	return {
		x = SF.CheckType(vert.x or vert[1],"number",1),
		y = SF.CheckType(vert.y or vert[2],"number",1),
		u = tonumber(vert.u or vert[3]) or 0,
		v = tonumber(vert.v or vert[4]) or 0,
	}
end

function poly_metamethods:__index(k)
	SF.CheckType(self,poly_metamethods)
	SF.CheckType(k,"number")
	local poly = unwrappoly(self)
	if not poly then return nil end
	if k <= 0 or k > #poly then return nil end
	return table.Copy(poly[k])
end

function poly_metamethods:__len()
	SF.CheckType(self,poly_metamethods)
	local poly = unwrappoly(self)
	return poly and #poly or nil
end

function poly_metamethods:__newindex(k,v)
	SF.CheckType(self,poly_metamethods)
	SF.CheckType(k,"number")
	SF.CheckType(v,"table")
	local poly = unwrappoly(self)
	if not poly then return end
	if k <= 0 or k > (#poly)+1 then return SF.throw( "poly index out of bounds: " .. k .. " out of " .. #poly, 2 ) end
	poly[k] = checkvertex(v)
end

-- ------------------------------------------------------------------ --

--- Pushes a matrix onto the matrix stack.
-- @param m The matrix
function render_library.pushMatrix(m)
	SF.CheckType(m,matrix_meta)
	local renderdata = SF.instance.data.render
	if not renderdata.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	local id = #matrix_stack
	if id + 1 > MATRIX_STACK_LIMIT then SF.throw( "Pushed too many matricies", 2 ) end
	local newmatrix
	if matrix_stack[id] then
		newmatrix = matrix_stack[id] * v_unwrap(m)
	else
		newmatrix = v_unwrap(m)
	end
	if renderdata.renderEnt and renderdata.renderEnt.Transform then
		newmatrix = renderdata.renderEnt.Transform * newmatrix
	end
	matrix_stack[id+1] = newmatrix
	cam.PushModelMatrix(newmatrix)
end

--- Pops a matrix from the matrix stack.
function render_library.popMatrix()
	local renderdata = SF.instance.data.render
	if not renderdata.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	if #matrix_stack <= 0 then SF.throw( "Popped too many matricies", 2 ) end
	matrix_stack[#matrix_stack] = nil
	cam.PopModelMatrix()
end

--- Sets the draw color
-- @param clr Color type
function render_library.setColor( clr )
	SF.CheckType( clr, SF.Types[ "Color" ] )
	currentcolor = clr
	surface.SetDrawColor( clr )
	surface.SetTextColor( clr )
end

--- Sets the draw color by RGBA values
function render_library.setRGBA( r, g, b, a )
	SF.CheckType( r, "number" ) SF.CheckType( g, "number" ) SF.CheckType( b, "number" ) SF.CheckType( a, "number" )
	currentcolor = Color( r, g, b, a )
	surface.SetDrawColor( r, g, b, a )
	surface.SetTextColor( r, g, b, a )
end

--- Looks up a texture by file name. Use with render.setTexture to draw with it.
--- Make sure to store the texture to use it rather than calling this slow function repeatedly.
-- @param tx Texture file path, or a http url
-- @param cb Optional callback for when a url texture finishes loading. param1 - The texture url, param2 - The texture table
-- @param alignment Optional alignment for the url texture. Default: "center", See http://www.w3schools.com/cssref/pr_background-position.asp
-- @return Texture table. Use it with render.setTexture. Returns nil if max url textures is reached.
function render_library.getTextureID ( tx, cb, alignment )

	if tx:sub(1,4)=="http" then
		tx = string.gsub( tx, "[^%w _~%.%-/:]", function( str )
			return string.format( "%%%02X", string.byte( str ) )
		end )

		if alignment then
			SF.CheckType( alignment, "string" )
			local args = string.Split( alignment, " " )
			local validargs = {["left"]=true,["center"]=true,["right"]=true,["top"]=true,["bottom"]=true}
			if #args ~= 1 and #args ~= 2 then SF.throw( "Invalid urltexture alignment given." ) end
			for i=1, #args do
				if not validargs[args[i]] then SF.throw( "Invalid urltexture alignment given." ) end
			end
		else
			alignment = "center"
		end
		
		local instance = SF.instance

		local tbl = {}
		texturecachehttp[ tbl ] = LoadURLMaterial( tx, alignment, function()
			if cb then
				local ok, msg, traceback = instance:runFunction( cb, tbl, tx )
				if not ok then
					instance:Error( msg, traceback )
				end
			end
		end)
		if not texturecachehttp[ tbl ] then return end
		return tbl
	else
		local id = surface.GetTextureID( tx )
		if id then
			local mat = Material( tx ) -- Hacky way to get ITexture, if there is a better way - do it!
			if not mat then return end
			local cacheentry = sfCreateMaterial( "SF_TEXTURE_" .. id )
			cacheentry:SetTexture( "$basetexture", mat:GetTexture( "$basetexture" ) )

			local tbl = {}
			texturecache[ tbl ] = cacheentry
			return tbl
		end
	end

end

--- Sets the texture
-- @param id Texture table. Get it with render.getTextureID
function render_library.setTexture ( id )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	if id then
		if texturecache[ id ] then
			surface.SetMaterial( texturecache[ id ] )
		elseif texturecachehttp[ id ] then
			surface.SetMaterial( texturecachehttp[ id ] )
		else
			draw.NoTexture()
		end
	else
		draw.NoTexture()
	end
end

--- Creates a new render target to draw onto.
-- The dimensions will always be 1024x1024
-- @param name The name of the render target
function render_library.createRenderTarget ( name )
	SF.CheckType( name, "string" )

	local data = SF.instance.data.render

	if data.rendertargetcount >= 2 then
		SF.throw( "Rendertarget limit reached", 2 )
	end

	data.rendertargetcount = data.rendertargetcount + 1
	local rtname, rt = findAvailableRT()
	if not rt then
		globalRTcount = globalRTcount + 1
		rtname = "Starfall_CustomRT_" .. globalRTcount
		rt = { GetRenderTarget( rtname, 1024, 1024 ), false }
		globalRTs[ rtname ] = rt
	end
	rt[ 2 ] = false
	data.rendertargets[ name ] = rtname
end

--- Selects the render target to draw on.
-- Nil for the visible RT.
-- @param name Name of the render target to use
function render_library.selectRenderTarget ( name )
	local data = SF.instance.data.render
	if not data.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	if name then
		SF.CheckType( name, "string" )
		local rt = globalRTs[ data.rendertargets[ name ] ][ 1 ]
		if not rt then SF.Throw( "Invalid Rendertarget", 2 ) end

		if not data.usingRT then
			data.oldViewPort = {0, 0, ScrW(), ScrH()}
			render.SetViewPort( 0, 0, 1024, 1024 )
			cam.Start2D()
			render.SetStencilEnable( false )
		end
		render.SetRenderTarget( rt )
		data.usingRT = true
	else
		if data.usingRT then
			render.SetRenderTarget()
			cam.End2D()
			render.SetViewPort(unpack(data.oldViewPort))
			data.usingRT = false
			render.SetStencilEnable( true )
		end
	end
end

--- Sets the active texture to the render target with the specified name.
-- Nil to reset.
-- @param name Name of the render target to use
function render_library.setRenderTargetTexture ( name )
	local data = SF.instance.data.render
	if not data.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( name, "string" )

	local rtname = data.rendertargets[ name ]
	if rtname and globalRTs[ rtname ] then
		RT_Material:SetTexture( "$basetexture", globalRTs[ rtname ][ 1 ] )
		surface.SetMaterial( RT_Material )
	else
		draw.NoTexture()
	end
end

--- Sets the texture of a screen entity
-- @param ent Screen entity
function render_library.setTextureFromScreen ( ent )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end

	ent = SF.Entities.Unwrap( ent )
	if IsValid( ent ) and ent.GPU and ent.GPU.RT then
		RT_Material:SetTexture("$basetexture", ent.GPU.RT)
		surface.SetMaterial( RT_Material )
	else
		draw.NoTexture()
	end

end

--- Clears the surface
-- @param clr Color type to clear with
function render_library.clear ( clr )
	if SF.instance.data.render.usingRT then
		if clr == nil then
			if not SF.instance.data.render.isRendering then SF.throw( "Not in a rendering hook.", 2 ) end
			render.Clear( 0, 0, 0, 255 )
		else
			SF.CheckType( clr, SF.Types[ "Color" ] )
			if not SF.instance.data.render.isRendering then SF.throw( "Not in a rendering hook.", 2 ) end
			render.Clear( clr.r, clr.g, clr.b, clr.a )
		end
	end
end

--- Draws a rectangle using the current color.
-- @param x Top left corner x coordinate
-- @param y Top left corner y coordinate
-- @param w Width
-- @param h Height
function render_library.drawRect ( x, y, w, h )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( x, "number" )
	SF.CheckType( y, "number" )
	SF.CheckType( w, "number" )
	SF.CheckType( h, "number" )
	surface.DrawRect( x, y, w, h )
end

--- Draws a rectangle outline using the current color.
-- @param x Top left corner x coordinate
-- @param y Top left corner y coordinate
-- @param w Width
-- @param h Height
function render_library.drawRectOutline ( x, y, w, h )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( x, "number" )
	SF.CheckType( y, "number" )
	SF.CheckType( w, "number" )
	SF.CheckType( h, "number" )
	surface.DrawOutlinedRect( x, y, w, h )
end

--- Draws a circle outline
-- @param x Center x coordinate
-- @param y Center y coordinate
-- @param r Radius
function render_library.drawCircle ( x, y, r )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( x, "number" )
	SF.CheckType( y, "number" )
	SF.CheckType( r, "number" )
	surface.DrawCircle( x, y, r, currentcolor )
end

--- Draws a textured rectangle.
-- @param x Top left corner x coordinate
-- @param y Top left corner y coordinate
-- @param w Width
-- @param h Height
function render_library.drawTexturedRect ( x, y, w, h )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( x, "number" )
	SF.CheckType( y, "number" )
	SF.CheckType( w, "number" )
	SF.CheckType( h, "number" )
	surface.DrawTexturedRect ( x, y, w, h )
end

--- Draws a textured rectangle with UV coordinates
-- @param x Top left corner x coordinate
-- @param y Top left corner y coordinate
-- @param w Width
-- @param h Height
-- @param startU Texture mapping at rectangle origin
-- @param startV Texture mapping at rectangle origin
-- @param endV Texture mapping at rectangle end
-- @param endV Texture mapping at rectangle end
function render_library.drawTexturedRectUV ( x, y, w, h, startU, startV, endU, endV )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( x, "number" )
	SF.CheckType( y, "number" )
	SF.CheckType( w, "number" )
	SF.CheckType( h, "number" )
	SF.CheckType( startU, "number" )
	SF.CheckType( startV, "number" )
	SF.CheckType( endU, "number" )
	SF.CheckType( endV, "number" )
	surface.DrawTexturedRectUV( x, y, w, h, startU, startV, endU, endV )
end

--- Draws a rotated, textured rectangle.
-- @param x X coordinate of center of rect
-- @param y Y coordinate of center of rect
-- @param w Width
-- @param h Height
-- @param rot Rotation in degrees
function render_library.drawTexturedRectRotated ( x, y, w, h, rot )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( x, "number" )
	SF.CheckType( y, "number" )
	SF.CheckType( w, "number" )
	SF.CheckType( h, "number" )
	SF.CheckType( rot, "number" )

	surface.DrawTexturedRectRotated( x, y, w, h, rot )
end

--- Draws a line
-- @param x1 X start coordinate
-- @param y1 Y start coordinate
-- @param x2 X end coordinate
-- @param y2 Y end coordinate
function render_library.drawLine ( x1, y1, x2, y2 )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( x1, "number" )
	SF.CheckType( y1, "number" )
	SF.CheckType( x2, "number" )
	SF.CheckType( y2, "number" )
	surface.DrawLine( x1, y1, x2, y2 )
end

--- Creates a font. Does not require rendering hook
-- @param font Base font to use
-- @param size Font size
-- @param weight Font weight (default: 400)
-- @param antialias Antialias font?
-- @param additive If true, adds brightness to pixels behind it rather than drawing over them.
-- @param shadow Enable drop shadow?
-- @param outline Enable outline?
-- @param blur Enable blur?
-- @usage
-- Base font can be one of (keep in mind that these may not exist on all clients if they are not shipped with starfall):
-- \- DebugFixed
-- \- DebugFixedSmall
-- \- DefaultFixedOutline
-- \- MenuItem
-- \- Default
-- \- TabLarge
-- \- DefaultBold
-- \- DefaultUnderline
-- \- DefaultSmall
-- \- DefaultSmallDropShadow
-- \- DefaultVerySmall
-- \- DefaultLarge
-- \- UiBold
-- \- MenuLarge
-- \- ConsoleText
-- \- Marlett
-- \- Trebuchet18
-- \- Trebuchet19
-- \- Trebuchet20
-- \- Trebuchet22
-- \- Trebuchet24
-- \- HUDNumber
-- \- HUDNumber1
-- \- HUDNumber2
-- \- HUDNumber3
-- \- HUDNumber4
-- \- HUDNumber5
-- \- HudHintTextLarge
-- \- HudHintTextSmall
-- \- CenterPrintText
-- \- HudSelectionText
-- \- DefaultFixed
-- \- DefaultFixedDropShadow
-- \- CloseCaption_Normal
-- \- CloseCaption_Bold
-- \- CloseCaption_BoldItalic
-- \- TitleFont
-- \- TitleFont2
-- \- ChatFont
-- \- TargetID
-- \- TargetIDSmall
-- \- HL2MPTypeDeath
-- \- BudgetLabel
-- \- DejaVu Sans Mono (shipped, monospaced)
function render_library.createFont(font,size,weight,antialias,additive,shadow,outline,blur)
	if not validfonts[font] then SF.throw( "invalid font", 2 ) end

	size = tonumber(size) or 16
	weight = tonumber(weight) or 400
	blur = tonumber(blur) or 0
	antialias = antialias and true or false
	additive = additive and true or false
	shadow = shadow and true or false
	outline = outline and true or false

	local name = string.format("sf_screen_font_%s_%d_%d_%d_%d%d%d%d",
		font, size, weight, blur,
		antialias and 1 or 0,
		additive and 1 or 0,
		shadow and 1 or 0,
		outline and 1 or 0)

	if not defined_fonts[name] then
		surface.CreateFont(name, {size = size, weight = weight,
			antialias=antialias, additive = additive, font = font,
			shadow = shadow, outline = outline, blur = blur})
		defined_fonts[name] = true
	end
	return name
end

--- Gets the size of the specified text. Don't forget to use setFont before calling this function
-- @param text Text to get the size of
-- @return width of the text
-- @return height of the text
function render_library.getTextSize( text )
	SF.CheckType(text,"string")

	surface.SetFont(SF.instance.data.render.font or defaultFont)
	return surface.GetTextSize( text )
end

--- Sets the font
-- @param font The font to use
function render_library.setFont(font)
	if not defined_fonts[font] then SF.throw( "Font does not exist.", 2 ) end
	SF.instance.data.render.font = font
	--surface.SetFont(font)
end

--- Gets the default font
-- @return Default font
function render_library.getDefaultFont()
	return defaultFont
end

--- Draws text.
-- @param x X coordinate
-- @param y Y coordinate
-- @param text Text to draw
-- @param alignment Text alignment
function render_library.drawText ( x, y, text, alignment )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( x, "number" )
	SF.CheckType( y, "number" )
	SF.CheckType( text, "string" )
	if alignment then
		SF.CheckType( alignment, "number" )
	end

	local font = SF.instance.data.render.font or defaultFont

	draw.DrawText( text, font, x, y, currentcolor, alignment or TEXT_ALIGN_LEFT )
end

--- Compiles a 2D poly. This is needed so that poly don't have to be
-- type-checked each frame. Polys can be indexed by a number, in which
-- a copy of the vertex at that spot is returned. They can also be assigned
-- a new vertex at 1 <= i <= #poly+1. And the length of the poly can be taken.
-- @param verts Array of verticies to convert.
-- @return compiled polygon
function render_library.createPoly(verts)
	SF.CheckType(verts,"table")
	local poly = {}
	local wrappedpoly = wrappoly(poly)
	for i=1,#verts do
		local v = verts[i]
		SF.CheckType(v,"table")
		poly[i] = checkvertex(v)
	end
	return wrappedpoly
end

--- Draws a polygon. Takes a compiled/uncompiled poly to draw.
-- Note that if you do use an uncompiled poly, you will use up ops
-- very quickly!
-- @param poly Compiled poly or array of vertexes
function render_library.drawPoly(poly)
	if dgetmeta(poly) ~= poly_metamethods then
		SF.CheckType(poly,"table")
		local verts = poly
		poly = {}
		for i=1,#verts do
			local v = verts[i]
			SF.CheckType(v,"table")
			poly[i] = checkvertex(v)
		end
	else
		poly = unwrappoly(poly)
	end
	surface.DrawPoly(poly)
end

--- Gets a 2D cursor position where ply is aiming.
-- @param ply player to get cursor position from
-- @return x position
-- @return y position
function render_library.cursorPos( ply )
	local screen = SF.instance.data.render.renderEnt
	if not screen or screen:GetClass()~="starfall_screen" then return input.GetCursorPos() end

	ply = SF.Entities.Unwrap( ply )
	if not ply then SF.throw("Invalid Player", 2) end

	local Normal, Pos
	-- Get monitor screen pos & size

	Pos = screen:LocalToWorld( screen.Origin )

	Normal = -screen.Transform:GetUp():GetNormalized()

	local Start = ply:GetShootPos()
	local Dir = ply:GetAimVector()

	local A = Normal:Dot(Dir)

	-- If ray is parallel or behind the screen
	if A == 0 or A > 0 then return nil end

	local B = Normal:Dot(Pos-Start) / A
	if (B >= 0) then
		local w = 512/screen.Aspect
		local HitPos = WorldToLocal( Start + Dir * B, Angle(), screen.Transform:GetTranslation(), screen.Transform:GetAngles() )
		local x = HitPos.x/screen.Scale
		local y = HitPos.y/screen.Scale
		if x < 0 or x > w or y < 0 or y > 512 then return nil end -- Aiming off the screen
		return x, y
	end

	return nil
end

--- Returns information about the screen, such as world offsets, dimentions, and rotation.
-- Note: this does a table copy so move it out of your draw hook
-- @param e The screen to get info from.
-- @return A table describing the screen.
function render_library.getScreenInfo( e )
	local screen = SF.Entities.Unwrap( e )
	if screen then
		return SF.Sanitize( screen.ScreenInfo )
	end
end

--- Returns the entity currently being rendered to
-- @return Entity of the screen or hud being rendered
function render_library.getScreenEntity()
	return SF.Entities.Wrap( SF.instance.data.render.renderEnt )
end

--- Dumps the current render target and allows the pixels to be accessed by render.readPixel.
function render_library.capturePixels ()
	local data = SF.instance.data.render
	if not data.isRendering then
		SF.throw( "Not in rendering hook.", 2 )
	end
	render.CapturePixels()
end

--- Reads the color of the specified pixel.
-- @param x Pixel x-coordinate.
-- @param y Pixel y-coordinate.
-- @return Color object with ( r, g, b, 255 ) from the specified pixel.
function render_library.readPixel ( x, y )
	local data = SF.instance.data.render
	if not data.isRendering then
		SF.throw( "Not in rendering hook.", 2 )
	end

	SF.CheckType( x, "number" )
	SF.CheckType( y, "number" )

	local r, g, b = render.ReadPixel( x, y )
	return SF.Color.Wrap( Color( r, g, b, 255 ) )
end

--- Returns the render context's width and height
-- @class function
-- @return the X size of the current render context
-- @return the Y size of the current render context
function render_library.getResolution()
	return SF.instance.data.render.renderEnt:GetResolution()
end

--- Called when a player uses the screen
-- @name starfallUsed
-- @class hook
-- @param activator Player using the screen

---
-- @name Screen information table
-- @class table
-- @field Name Pretty name of model
-- @field offset Offset of screen from prop
-- @field RS Resolution/scale
-- @field RatioX Inverted Aspect ratio (height divided by width)
-- @field x1 Corner of screen in local coordinates (relative to offset?)
-- @field x2 Corner of screen in local coordinates (relative to offset?)
-- @field y1 Corner of screen in local coordinates (relative to offset?)
-- @field y2 Corner of screen in local coordinates (relative to offset?)
-- @field z Screen plane offset in local coordinates (relative to offset?)
-- @field rot Screen rotation
