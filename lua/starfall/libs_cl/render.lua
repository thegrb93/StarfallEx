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
local matrix_meta = SF.VMatrix.Metatable
local vector_meta = SF.Vectors.Metatable

local m_unwrap = SF.VMatrix.Unwrap
local v_unwrap = SF.Vectors.Unwrap
local aunwrap = SF.Angles.Unwrap

local vwrap = SF.Vectors.Wrap

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
local view_matrix_stack = {}

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
		currentcolor = Color(255,255,255,255)
		render.SetColorMaterial()
	end
end )

SF.Libraries.AddHook( "cleanup", function ( instance, hook )
	if hook == "render" then
		render.OverrideDepthEnable(false, false)
		render.SetScissorRect(0,0,0,0,false)
		for i=#matrix_stack,1,-1 do
			cam.PopModelMatrix()
			matrix_stack[i] = nil
		end
		local data = instance.data.render
		if data.usingRT then
			render.SetRenderTarget()
			render.SetViewPort(unpack(data.oldViewPort))
			data.usingRT = false
		end
		for i=#view_matrix_stack,1,-1 do
			cam[view_matrix_stack[i]]()
			view_matrix_stack[i] = nil
		end
	end
end )


SF.Libraries.AddHook("initialize",function(instance)
	instance.data.render.rendertargets = {}
	instance.data.render.rendertargetcount = 0
end)

SF.Libraries.AddHook( "deinitialize", function ( instance )
	for k, v in pairs( instance.data.render.rendertargets ) do
		globalRTs[ v ][ 2 ] = true -- mark as available
	end
end )

---URL Textures
local LoadingURLQueue = {}

local texturecache, texturecachehttp


local function CheckURLDownloads()
	local requestTbl = LoadingURLQueue[1]
	if requestTbl then
		if requestTbl.Panel then
			if not requestTbl.Panel:IsLoading() then
				timer.Simple(0.2,function()
					local tex = requestTbl.Panel:GetHTMLMaterial():GetTexture("$basetexture")
					requestTbl.Material:SetTexture("$basetexture", tex)
					requestTbl.Panel:Remove()
					if requestTbl.cb then requestTbl.cb() end
				end)
				table.remove(LoadingURLQueue, 1)
			else
				if CurTime() > requestTbl.Timeout then
					requestTbl.Panel:Remove()
					table.remove(LoadingURLQueue, 1)
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
					body {
						background-image: url(]] .. requestTbl.Url .. [[);
						background-size: contain;
						background-position: ]] .. requestTbl.Alignment .. [[;
						background-repeat: no-repeat;
					}
				</style></head><body></body></html>
			]]
			)
			requestTbl.Timeout = CurTime()+10
			requestTbl.Panel = Panel
		end
	else
		timer.Destroy("SF_URLMaterialChecker")
	end
end

local cv_max_url_materials = CreateConVar( "sf_render_maxurlmaterials", "30", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )

local function LoadURLMaterial( url, alignment, cb )
	if table.Count(texturecachehttp) + #LoadingURLQueue >= cv_max_url_materials:GetInt() then return end

	local urlmaterial = sfCreateMaterial("SF_TEXTURE_" .. util.CRC(url .. SysTime()))

	if #LoadingURLQueue == 0 then
		timer.Create("SF_URLMaterialChecker",1,0,CheckURLDownloads)
	end
	LoadingURLQueue[#LoadingURLQueue + 1] = {Material = urlmaterial, Url = url, Alignment = alignment, cb = cb}

	return urlmaterial

end

texturecache = setmetatable({},{__mode = "k"})
texturecachehttp = setmetatable({},{__mode = "k"})

local validfonts = {
	akbar = "Akbar",
	coolvetica = "Coolvetica",
	roboto = "Roboto",
	["courier new"] = "Courier New",
	verdana = "Verdana",
	arial = "Arial",
	halflife2 = "HalfLife2",
	hl2mp = "hl2mp",
	csd = "csd",
	tahoma = "Tahoma",
	trebuchet = "Trebuchet",
	["trebuchet ms"] = "Trebuchet MS",
	[ "dejavu sans mono" ] = "DejaVu Sans Mono",
	[ "lucida console" ] = "Lucida Console",
	[ "times new roman" ] = "Times New Roman"
}

local defined_fonts = {
	DebugFixed = true,
	DebugFixedSmall = true,
	Default = true,
	Marlett = true,
	Trebuchet18 = true,
	Trebuchet24 = true,
	HudHintTextLarge = true,
	HudHintTextSmall = true,
	CenterPrintText = true,
	HudSelectionText = true,
	CloseCaption_Normal = true,
	CloseCaption_Bold = true,
	CloseCaption_BoldItalic = true,
	ChatFont = true,
	TargetID = true,
	TargetIDSmall = true,
	HL2MPTypeDeath = true,
	BudgetLabel = true,
	HudNumbers = true,
	DermaDefault = true,
	DermaDefaultBold = true,
	DermaLarge = true,
}
-- Using an already defined font's name will use its font
for k, v in pairs(defined_fonts) do
	validfonts[string.lower(k)] = k
end

local defaultFont

-- ------------------------------------------------------------------ --

--- Pushes a matrix onto the matrix stack.
-- @param m The matrix
-- @param world Should the transformation be relative to the screen or world?
function render_library.pushMatrix(m, world)
	SF.CheckType(m,matrix_meta)
	local renderdata = SF.instance.data.render
	if not renderdata.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	local id = #matrix_stack
	if id + 1 > MATRIX_STACK_LIMIT then SF.throw( "Pushed too many matricies", 2 ) end
	local newmatrix
	if matrix_stack[id] then
		newmatrix = matrix_stack[id] * m_unwrap(m)
	else
		newmatrix = m_unwrap(m)
	end
	if not world and renderdata.renderEnt and renderdata.renderEnt.Transform then
		newmatrix = renderdata.renderEnt.Transform * newmatrix
	end
	matrix_stack[id+1] = newmatrix
	cam.PushModelMatrix(newmatrix)
end

--- Enables a scissoring rect which limits the drawing area. Only works 2D contexts such as HUD or render targets.
-- @param startX X start coordinate of the scissor rect.
-- @param startY Y start coordinate of the scissor rect.
-- @param endX X end coordinate of the scissor rect.
-- @param endX Y end coordinate of the scissor rect.
function render_library.enableScissorRect( startX, startY, endX, endY )
	local data = SF.instance.data.render
	if not data.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( startX, "number" )
	SF.CheckType( startY, "number" )
	SF.CheckType( endX, "number" )
	SF.CheckType( endY, "number" )
	render.SetScissorRect( startX, startY, endX, endY, true )
end

--- Disables a scissoring rect which limits the drawing area.
function render_library.disableScissorRect()
	local data = SF.instance.data.render
	if not data.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	render.SetScissorRect( 0 ,0 ,0 , 0, false )

end

--- Pops a matrix from the matrix stack.
function render_library.popMatrix()
	local renderdata = SF.instance.data.render
	if not renderdata.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	if #matrix_stack <= 0 then SF.throw( "Popped too many matricies", 2 ) end
	matrix_stack[#matrix_stack] = nil
	cam.PopModelMatrix()
end


local viewmatrix_checktypes =
{
	x = "number", y = "number", w = "number", h = "number", type = "string",
	origin = SF.Vectors.Metatable, angles = SF.Angles.Metatable, fov = "number",
	aspect = "number", zfar = "number", znear = "number", subrect = "boolean",
	bloomtone = "boolean", offcenter = "table", ortho = "table"
}
--- Pushes a perspective matrix onto the view matrix stack.
-- @param tbl The view matrix data. See http://wiki.garrysmod.com/page/Structures/RenderCamData
function render_library.pushViewMatrix(tbl)
	local renderdata = SF.instance.data.render
	if not renderdata.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	if #view_matrix_stack == MATRIX_STACK_LIMIT then SF.throw( "Pushed too many matricies", 2 ) end
	local endfunc
	if tbl.type == "2D" then
		endfunc = "End2D"
	elseif tbl.type == "3D" then
		endfunc = "End3D"
	else
		SF.throw( "Camera type must be \"3D\" or \"2D\"", 2 )
	end

	local newtbl = {}
	for k, v in pairs(tbl) do
		if viewmatrix_checktypes[k] then
			SF.CheckType( v, viewmatrix_checktypes[k] )
			newtbl[k] = v
		else
			SF.throw( "Invalid key found in view matrix: " .. k, 2 )
		end
	end
	if newtbl.origin then newtbl.origin = SF.Vectors.Unwrap( newtbl.origin ) end
	if newtbl.angles then newtbl.angles = SF.Angles.Unwrap( newtbl.angles ) end
	if newtbl.offcenter then
		SF.CheckType( tbl.offcenter.left, "number" )
		SF.CheckType( tbl.offcenter.right, "number" )
		SF.CheckType( tbl.offcenter.bottom, "number" )
		SF.CheckType( tbl.offcenter.top, "number" )
	end
	if newtbl.ortho then
		SF.CheckType( tbl.ortho.left, "number" )
		SF.CheckType( tbl.ortho.right, "number" )
		SF.CheckType( tbl.ortho.bottom, "number" )
		SF.CheckType( tbl.ortho.top, "number" )
	end

	cam.Start(newtbl)
	view_matrix_stack[#view_matrix_stack+1] = endfunc
end

--- Pops a view matrix from the matrix stack.
function render_library.popViewMatrix()
	local renderdata = SF.instance.data.render
	if not renderdata.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	local i = #view_matrix_stack
	if i == 0 then SF.throw( "Popped too many matricies", 2 ) end

	cam[view_matrix_stack[i]]()
	view_matrix_stack[i] = nil
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
			render.SetMaterial( texturecache[ id ] )
		elseif texturecachehttp[ id ] then
			surface.SetMaterial( texturecachehttp[ id ] )
			render.SetMaterial( texturecachehttp[ id ] )
		else
			draw.NoTexture()
			render.SetColorMaterial()
		end
	else
		draw.NoTexture()
		render.SetColorMaterial()
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
	rt[ 3 ] = CreateMaterial( "StarfallCustomModel_"..name..SF.instance.data.entity:EntIndex(), "VertexLitGeneric", {
		[ "$model" ] = 1,
	} )
	rt[3]:SetTexture("$basetexture", rt[1])

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
			view_matrix_stack[#view_matrix_stack+1] = "End2D"
			render.SetStencilEnable( false )
		end
		render.SetRenderTarget( rt )
		data.usingRT = true
	else
		if data.usingRT then
			render.SetRenderTarget()
			local i = #view_matrix_stack
			if i>0 then
				cam[view_matrix_stack[i]]()
				view_matrix_stack[i] = nil
			end
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

--- Returns the model material name that uses the render target.
--- Alternatively, just construct the name yourself with "!StarfallCustomModel_"..name..chip():entIndex()
-- @param name Render target name
-- @return Model material name. Send this to the server to set the entity's material.
function render_library.getRenderTargetMaterial( name )
	local data = SF.instance.data.render
	SF.CheckType( name, "string" )

	local rtname = data.rendertargets[ name ]
	if rtname and globalRTs[ rtname ] then
		return "!"..tostring(globalRTs[ rtname ][ 3 ])
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
	if not SF.instance.data.render.isRendering then SF.throw( "Not in a rendering hook.", 2 ) end
	if SF.instance.data.render.usingRT then
		if clr == nil then
			render.Clear( 0, 0, 0, 255 )
		else
			SF.CheckType( clr, SF.Types[ "Color" ] )
			render.Clear( clr.r, clr.g, clr.b, clr.a )
		end
	end
end

--- Draws a rounded rectangle using the current color
-- @param r The corner radius
-- @param x Top left corner x coordinate
-- @param y Top left corner y coordinate
-- @param w Width
-- @param h Height
function render_library.drawRoundedBox ( r, x, y, w, h )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( r, "number" )
	SF.CheckType( x, "number" )
	SF.CheckType( y, "number" )
	SF.CheckType( w, "number" )
	SF.CheckType( h, "number" )
	draw.RoundedBox( r, x, y, w, h, currentcolor )
end

--- Draws a rounded rectangle using the current color
-- @param r The corner radius
-- @param x Top left corner x coordinate
-- @param y Top left corner y coordinate
-- @param w Width
-- @param h Height
-- @param tl Boolean Top left corner
-- @param tr Boolean Top right corner
-- @param bl Boolean Bottom left corner
-- @param br Boolean Bottom right corner
function render_library.drawRoundedBoxEx ( r, x, y, w, h, tl, tr, bl, br )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( r, "number" )
	SF.CheckType( x, "number" )
	SF.CheckType( y, "number" )
	SF.CheckType( w, "number" )
	SF.CheckType( h, "number" )
	SF.CheckType( tl, "boolean" )
	SF.CheckType( tr, "boolean" )
	SF.CheckType( bl, "boolean" )
	SF.CheckType( br, "boolean" )
	draw.RoundedBoxEx( r, x, y, w, h, currentcolor, tl, tr, bl, br )
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
-- \- Akbar
-- \- Coolvetica
-- \- Roboto
-- \- Courier New
-- \- Verdana
-- \- Arial
-- \- HalfLife2
-- \- hl2mp
-- \- csd
-- \- Tahoma
-- \- Trebuchet
-- \- Trebuchet MS
-- \- DejaVu Sans Mono
-- \- Lucida Console
-- \- Times New Roman

function render_library.createFont(font,size,weight,antialias,additive,shadow,outline,blur)
	font = validfonts[string.lower(font)]
	if not font then SF.throw( "invalid font", 2 ) end

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
defaultFont = render_library.createFont("Default", 16, 400, false, false, false, false, 0)

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
-- @usage Use a font created by render.createFont or use one of these already defined fonts:
-- \- DebugFixed
-- \- DebugFixedSmall
-- \- Default
-- \- Marlett
-- \- Trebuchet18
-- \- Trebuchet24
-- \- HudHintTextLarge
-- \- HudHintTextSmall
-- \- CenterPrintText
-- \- HudSelectionText
-- \- CloseCaption_Normal
-- \- CloseCaption_Bold
-- \- CloseCaption_BoldItalic
-- \- ChatFont
-- \- TargetID
-- \- TargetIDSmall
-- \- HL2MPTypeDeath
-- \- BudgetLabel
-- \- HudNumbers
-- \- DermaDefault
-- \- DermaDefaultBold
-- \- DermaLarge
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

--- Draws text with newlines and tabs
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

	draw.DrawText( text, font, x, y, currentcolor, alignment )
end

--- Draws text more easily and quickly but no new lines or tabs.
-- @param x X coordinate
-- @param y Y coordinate
-- @param text Text to draw
-- @param xalign Text x alignment
-- @param yalign Text y alignment
function render_library.drawSimpleText ( x, y, text, xalign, yalign )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( x, "number" )
	SF.CheckType( y, "number" )
	SF.CheckType( text, "string" )
	if xalign then SF.CheckType( xalign, "number" ) end
	if yalign then SF.CheckType( yalign, "number" ) end

	local font = SF.instance.data.render.font or defaultFont

	draw.SimpleText( text, font, x, y, currentcolor, xalign, yalign )
end

--- Constructs a markup object for quick styled text drawing.
-- @param markup The markup string to parse
-- @param maxsize The max width of the markup
-- @return The markup object. See https://wiki.garrysmod.com/page/Category:MarkupObject
function render_library.parseMarkup( str, maxsize )
	SF.CheckType( str, "string" )
	SF.CheckType( maxsize, "number" )
	local marked = markup.Parse( str, maxsize )
	local markedindex = marked.__index
	return setmetatable(marked, {
		__newindex = function() end,
		__index = markedindex,
		__metatable = ""
	})
end

--- Draws a polygon.
-- @param poly Table of polygon vertices. Texture coordinates are optional. {{x=x1, y=y1, u=u1, v=v1}, ... }
function render_library.drawPoly(poly)
	SF.CheckType(poly,"table")
	surface.DrawPoly(poly)
end

--- Enables or disables Depth Buffer
-- @param enable true to enable
function render_library.enableDepth ( enable )
	SF.CheckType( enable, "boolean" )
	render.OverrideDepthEnable(enable, enable)
end

--- Draws a sphere
-- @param pos Position of the sphere
-- @param radius Radius of the sphere
-- @param longitudeSteps The amount of longitude steps. The larger this number is, the smoother the sphere is
-- @param latitudeSteps  The amount of latitude steps. The larger this number is, the smoother the sphere is
function render_library.draw3DSphere ( pos, radius, longitudeSteps, latitudeSteps )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( pos, vector_meta )
	SF.CheckType( radius, "number" )
	SF.CheckType( longitudeSteps, "number" )
	SF.CheckType( latitudeSteps, "number" )
	pos = v_unwrap( pos )
	longitudeSteps = math.min( longitudeSteps, 50 )
	latitudeSteps = math.min( latitudeSteps, 50 )
	render.DrawSphere( pos, radius, longitudeSteps, latitudeSteps, currentcolor, true )
end

--- Draws a wireframe sphere
-- @param pos Position of the sphere
-- @param radius Radius of the sphere
-- @param longitudeSteps The amount of longitude steps. The larger this number is, the smoother the sphere is
-- @param latitudeSteps  The amount of latitude steps. The larger this number is, the smoother the sphere is
function render_library.draw3DWireframeSphere ( pos, radius, longitudeSteps, latitudeSteps )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( pos, vector_meta )
	SF.CheckType( radius, "number" )
	SF.CheckType( longitudeSteps, "number" )
	SF.CheckType( latitudeSteps, "number" )
	pos = v_unwrap( pos )
	longitudeSteps = math.min( longitudeSteps, 50 )
	latitudeSteps = math.min( latitudeSteps, 50 )
	render.DrawWireframeSphere( pos, radius, longitudeSteps, latitudeSteps, currentcolor, true )
end

--- Draws a 3D Line
-- @param startPos Starting position
-- @param endPos Ending position
function render_library.draw3DLine ( startPos, endPos )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( startPos, vector_meta )
	SF.CheckType( endPos, vector_meta )
	startPos = v_unwrap( startPos )
	endPos = v_unwrap( endPos )

	render.DrawLine( startPos, endPos, currentcolor, true )
end

--- Draws a box in 3D space
-- @param origin Origin of the box.
-- @param angle Orientation  of the box
-- @param mins Start position of the box, relative to origin.
-- @param maxs End position of the box, relative to origin.
function render_library.draw3DBox ( origin, angle, mins, maxs )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( origin, vector_meta )
	SF.CheckType( mins, vector_meta )
	SF.CheckType( maxs, vector_meta )
	SF.CheckType( angle, SF.Types[ "Angle" ] )
	origin = v_unwrap( origin )
	mins = v_unwrap( mins )
	maxs = v_unwrap( maxs )
	angle = aunwrap( angle )

	render.DrawBox( origin, angle, mins, maxs, currentcolor, true )
end

--- Draws a wireframe box in 3D space
-- @param origin Origin of the box.
-- @param angle Orientation  of the box
-- @param mins Start position of the box, relative to origin.
-- @param maxs End position of the box, relative to origin.
function render_library.draw3DWireframeBox ( origin, angle, mins, maxs )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( origin, vector_meta )
	SF.CheckType( mins, vector_meta )
	SF.CheckType( maxs, vector_meta )
	SF.CheckType( angle, SF.Types[ "Angle" ] )
	origin = v_unwrap( origin )
	mins = v_unwrap( mins )
	maxs = v_unwrap( maxs )
	angle = aunwrap( angle )

	render.DrawWireframeBox( origin, angle, mins, maxs, currentcolor, false )
end

--- Draws textured beam.
-- @param startPos Beam start position.
-- @param endPos Beam end position.
-- @param width The width of the beam.
-- @param textureStart The start coordinate of the texture used.
-- @param textureEnd The end coordinate of the texture used.
function render_library.draw3DBeam ( startPos, endPos, width, textureStart, textureEnd )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( startPos, vector_meta )
	SF.CheckType( endPos, vector_meta )
	SF.CheckType( width, "number" )
	SF.CheckType( textureStart, "number" )
	SF.CheckType( textureEnd, "number" )

	startPos = v_unwrap( startPos )
	endPos = v_unwrap( endPos )

	render.DrawBeam( startPos, endPos, width, textureStart, textureEnd, currentcolor )
end

--- Draws 2 connected triangles.
-- @param vert1 First vertex.
-- @param vert2 The second vertex.
-- @param vert3 The third vertex.
-- @param vert4 The fourth vertex.
function render_library.draw3DQuad ( vert1, vert2, vert3, vert4 )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( vert1, vector_meta )
	SF.CheckType( vert2, vector_meta )
	SF.CheckType( vert3, vector_meta )
	SF.CheckType( vert4, vector_meta )

	vert1 = v_unwrap( vert1 )
	vert2 = v_unwrap( vert2 )
	vert3 = v_unwrap( vert3 )
	vert4 = v_unwrap( vert4 )

	render.DrawQuad( vert1, vert2, vert3, vert4, currentcolor )
end

--[[
function render_library.drawModel ( pos, ang, model )
	if not SF.instance.data.render.isRendering then SF.throw( "Not in rendering hook.", 2 ) end
	SF.CheckType( pos, vector_meta )
	SF.CheckType( ang, SF.Types[ "Angle" ] )
	SF.CheckType( model, "string" )
	pos = v_unwrap( pos )
	ang = aunwrap( ang )
	render.Model({["model"] = model, ["pos"] = pos, ["angle"] = ang})
end
--]]


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
	if SF.instance.data.render.usingRT then
		render.CapturePixels()
	end
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

--- Does a trace and returns the color of the textel the trace hits.
-- @param vec1 The starting vector
-- @param vec2 The ending vector
-- @return The color vector. use vector:toColor to convert it to a color.
function render_library.traceSurfaceColor( vec1, vec2 )
	SF.CheckType( vec1, vector_meta )
	SF.CheckType( vec2, vector_meta )

	return vwrap( render.GetSurfaceColor( v_unwrap( vec1 ), v_unwrap( vec2 ) ) )
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
