-------------------------------------------------------------------------------
-- Render library
-------------------------------------------------------------------------------

--- Called when a frame is requested to be drawn on screen. (2D/3D Context)
-- @name render
-- @class hook
-- @client

--- Called when a frame is requested to be drawn on hud. (2D Context)
-- @name drawhud
-- @class hook
-- @client


---Called before drawing HUD (2D Context)
-- @name predrawhud
-- @class hook
-- @client

---Called after drawing HUD (2D Context)
-- @name postdrawhud
-- @class hook
-- @client

--- Called when a frame is requested to be drawn. Doesn't require a screen or HUD but only works on rendertargets. (2D Context)
-- @name renderoffscreen
-- @class hook
-- @client

--- Called when the player connects to a HUD component linked to the Starfall Chip
-- @name hudconnected
-- @class hook
-- @client

--- Called when the player disconnects from a HUD component linked to the Starfall Chip
-- @name huddisconnected
-- @class hook
-- @client

--- Called before opaque entities are drawn. (Only works with HUD) (3D context)
-- @name predrawopaquerenderables
-- @class hook
-- @client
-- @param boolean isDrawingDepth Whether the current draw is writing depth.
-- @param boolean isDrawSkybox  Whether the current draw is drawing the skybox.

--- Called after opaque entities are drawn. (Only works with HUD) (3D context)
-- @name postdrawopaquerenderables
-- @class hook
-- @client
-- @param boolean isDrawingDepth Whether the current draw is writing depth.
-- @param boolean isDrawSkybox  Whether the current draw is drawing the skybox.

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

local render_library = SF.Libraries.Register("render")

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
local vector_meta, matrix_meta, col_meta, ang_meta, ent_meta
local vwrap, cwrap, ewrap, vunwrap, munwrap, aunwrap, eunwrap

SF.Libraries.AddHook("postload", function()
	vector_meta = SF.Vectors.Metatable
	matrix_meta = SF.VMatrix.Metatable
	col_meta = SF.Color.Metatable
	ang_meta = SF.Angles.Metatable
	ent_meta = SF.Entities.Metatable

	vwrap = SF.Vectors.Wrap
	cwrap = SF.Color.Wrap
	ewrap = SF.Entities.Wrap
	vunwrap = SF.Vectors.Unwrap
	munwrap = SF.VMatrix.Unwrap
	aunwrap = SF.Angles.Unwrap
	eunwrap = SF.Entities.Unwrap
end)

SF.Permissions.registerPrivilege("render.screen", "Render Screen", "Allows the user to render to a starfall screen", { ["Client"] = {} })
SF.Permissions.registerPrivilege("render.offscreen", "Render Screen", "Allows the user to render without a screen", { ["Client"] = {} })
SF.Permissions.registerPrivilege("render.urlmaterial", "Render URL Materials", "Allows the user to load materials from online pictures", { ["Client"] = {} })
SF.Permissions.registerPrivilege("render.datamaterial", "Render Data Materials", "Allows the user to load materials from base64 encoded data", { ["Client"] = {} })

local cv_max_rendertargets = CreateConVar("sf_render_maxrendertargets", "20", { FCVAR_ARCHIVE })
local cv_max_url_materials = CreateConVar("sf_render_maxurlmaterials", "20", { FCVAR_ARCHIVE })
local cv_max_data_material_size = CreateConVar("sf_render_maxdatamaterialsize", "1000000", { FCVAR_ARCHIVE })

local currentcolor
local MATRIX_STACK_LIMIT = 8
local matrix_stack = {}
local view_matrix_stack = {}

local globalRTs = {}
local globalRTcount = 0
local plyRTcount = {}
local plyURLTexcount = {}

local renderhooks = {
	render = true,
	renderoffscreen = true,
	predrawopaquerenderables = true,
	postdrawopaquerenderables = true,
	predrawhud = true,
	drawhud = true,
	postdrawhud = true,
}

SF.Libraries.AddHook("prepare", function (instance, hook)
	if renderhooks[hook] then
		currentcolor = Color(255, 255, 255, 255)
		render.SetColorMaterial()
		draw.NoTexture()
		surface.SetDrawColor(255, 255, 255, 255)

		local data = instance.data.render
		data.isRendering = true

		if hook=="renderoffscreen" then
			data.needRT = true
			instance:runFunction(function()
				if not data.rendertargets["dummyrt"] then
					render_library.createRenderTarget ("dummyrt")
				end
				render_library.selectRenderTarget ("dummyrt")
			end)
		else
			data.needRT = false
		end
	end
end)

SF.Libraries.AddHook("cleanup", function (instance, hook)
	if renderhooks[hook] then
		render.OverrideDepthEnable(false, false)
		render.SetScissorRect(0, 0, 0, 0, false)
		for i = #matrix_stack, 1, -1 do
			cam.PopModelMatrix()
			matrix_stack[i] = nil
		end
		local data = instance.data.render
		if data.usingRT then
			render.SetRenderTarget()
			render.SetViewPort(unpack(data.oldViewPort))
			data.usingRT = false
		end
		for i = #view_matrix_stack, 1, -1 do
			cam[view_matrix_stack[i]]()
			view_matrix_stack[i] = nil
		end
		if data.changedFilterMag then
			data.changedFilterMag = false
			render.PopFilterMag()
		end
		if data.changedFilterMin then
			data.changedFilterMin = false
			render.PopFilterMin()
		end
		data.isRendering = false
		data.needRT = false
	end
end)

SF.Libraries.AddHook("initialize", function(instance)
	instance.data.render = {}
	instance.data.render.rendertargets = {}
	instance.data.render.rendertargetcount = 0
	instance.data.render.textures = {}
	instance.data.render.urltextures = {}
	instance.data.render.urltexturecount = 0
end)

SF.Libraries.AddHook("deinitialize", function (instance)
	for k, v in pairs(instance.data.render.rendertargets) do
		globalRTs[v][2] = true -- mark as available
	end
	for k, v in pairs(instance.data.render.textures) do
		instance.data.render.textures[k] = nil
	end
	for k, v in pairs(instance.data.render.urltextures) do
		v:SetUndefined("$basetexture")
		instance.data.render.urltextures[k] = nil
	end
	if plyRTcount[instance.playerid] then
		plyRTcount[instance.playerid] = plyRTcount[instance.playerid] - instance.data.render.rendertargetcount
		if plyRTcount[instance.playerid] == 0 then
			plyRTcount[instance.playerid] = nil
		end
	end
	if plyURLTexcount[instance.playerid] then
		plyURLTexcount[instance.playerid] = plyURLTexcount[instance.playerid] - instance.data.render.urltexturecount
		if plyURLTexcount[instance.playerid] == 0 then
			plyURLTexcount[instance.playerid] = nil
		end
	end
end)

local function sfCreateMaterial(name, skip_hack)
	local tbl = {
				["$nolod"] = 1,
				["$ignorez"] = 1,
				["$vertexcolor"] = 1,
				["$vertexalpha"] = 1,
				["$basetexturetransform"] = "center .5 .5 scale 1.032 1.032 rotate 0 translate 0 0"
			}
	if skip_hack then
		tbl["$basetexturetransform"] = nil
	end
	return CreateMaterial(name, "UnlitGeneric", tbl)
end
local RT_Material = sfCreateMaterial("SF_RT_Material")
---URL Textures
local LoadingURLQueue = {}
local function CheckURLDownloads()
	local requestTbl = LoadingURLQueue[1]
	if requestTbl then
		if requestTbl.Panel then
			if not requestTbl.Panel:IsLoading() then
				timer.Simple(0.2, function()
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
			local Panel = vgui.Create("DHTML")
			Panel:SetSize(1024, 1024)
			Panel:SetAlpha(0)
			Panel:SetMouseInputEnabled(false)
			Panel:SetHTML([[
				<html><head><style type="text/css">
					body {
						background-image: url(]] .. requestTbl.Url .. [[);
						background-size: contain;
						background-position: ]] .. requestTbl.Alignment .. [[;
						background-repeat: no-repeat;
					}
				</style></head><body></body></html>
			]])
			requestTbl.Timeout = CurTime() + 10
			requestTbl.Panel = Panel
		end
	else
		timer.Destroy("SF_URLMaterialChecker")
	end
end
local function LoadURLMaterial(url, alignment, cb, skip_hack)
	local urlmaterial = sfCreateMaterial("SF_TEXTURE_" .. util.CRC(url .. SysTime()), skip_hack)

	if #LoadingURLQueue == 0 then
		timer.Create("SF_URLMaterialChecker", 1, 0, CheckURLDownloads)
	end
	LoadingURLQueue[#LoadingURLQueue + 1] = { Material = urlmaterial, Url = url, Alignment = alignment, cb = cb }

	return urlmaterial
end

local validfonts = {
	akbar = "Akbar",
	coolvetica = "Coolvetica",
	roboto = "Roboto",
	["roboto mono"] = "Roboto Mono",
	["fontawesome"] = "FontAwesome",
	["courier new"] = "Courier New",
	verdana = "Verdana",
	arial = "Arial",
	halflife2 = "HalfLife2",
	hl2mp = "hl2mp",
	csd = "csd",
	tahoma = "Tahoma",
	trebuchet = "Trebuchet",
	["trebuchet ms"] = "Trebuchet MS",
	["dejavu sans mono"] = "DejaVu Sans Mono",
	["lucida console"] = "Lucida Console",
	["times new roman"] = "Times New Roman"
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

function render_library.setStencilEnable(enable)
	enable = (enable == true) -- Make sure it's a boolean
	local renderdata = SF.instance.data.render
	if not renderdata.usingRT then  SF.Throw("Stencil operations are allowed only inside RenderTarget!") end
	render.SetStencilEnable(enable)
end

function render_library.clearStencil()
	local renderdata = SF.instance.data.render
	if not renderdata.usingRT then  SF.Throw("Stencil operations are allowed only inside RenderTarget!") end
	render.ClearStencil()
end

function render_library.clearBuffersObeyStencil(r, g, b, a, depth)
	SF.CheckLuaType(r, TYPE_NUMBER)
	SF.CheckLuaType(g, TYPE_NUMBER)
	SF.CheckLuaType(b, TYPE_NUMBER)
	SF.CheckLuaType(a, TYPE_NUMBER)
	SF.CheckLuaType(depth, TYPE_NUMBER)

	local renderdata = SF.instance.data.render
	if not renderdata.usingRT then  SF.Throw("Stencil operations are allowed only inside RenderTarget!") end

	render.ClearBuffersObeyStencil(r, g, b, a, depth)
end

function render_library.clearStencilBufferRectangle(originX, originY, endX, endY, stencilValue)
	SF.CheckLuaType(originX, TYPE_NUMBER)
	SF.CheckLuaType(originY, TYPE_NUMBER)
	SF.CheckLuaType(endX, TYPE_NUMBER)
	SF.CheckLuaType(endY, TYPE_NUMBER)
	SF.CheckLuaType(stencilValue, TYPE_NUMBER)

	local renderdata = SF.instance.data.render
	if not renderdata.usingRT then  SF.Throw("Stencil operations are allowed only inside RenderTarget!") end

	render.ClearStencilBufferRectangle(originX, originY, endX, endY, stencilValue)
end

function render_library.setStencilCompareFunction(compareFunction)
	SF.CheckLuaType(compareFunction, TYPE_NUMBER)

	local renderdata = SF.instance.data.render
	if not renderdata.usingRT then  SF.Throw("Stencil operations are allowed only inside RenderTarget!") end

	render.SetStencilCompareFunction(compareFunction )
end

function render_library.setStencilFailOperation(operation)
	SF.CheckLuaType(operation, TYPE_NUMBER)

	local renderdata = SF.instance.data.render
	if not renderdata.usingRT then  SF.Throw("Stencil operations are allowed only inside RenderTarget!") end

	render.SetStencilFailOperation(operation)
end

function render_library.setStencilPassOperation(operation)
	SF.CheckLuaType(operation, TYPE_NUMBER)

	local renderdata = SF.instance.data.render
	if not renderdata.usingRT then  SF.Throw("Stencil operations are allowed only inside RenderTarget!") end

	render.SetStencilPassOperation(operation)
end

function render_library.setStencilZFailOperation(operation)
	SF.CheckLuaType(operation, TYPE_NUMBER)

	local renderdata = SF.instance.data.render
	if not renderdata.usingRT then  SF.Throw("Stencil operations are allowed only inside RenderTarget!") end

	render.SetStencilZFailOperation(operation)
end

function render_library.setStencilReferenceValue(referenceValue)
	SF.CheckLuaType(referenceValue, TYPE_NUMBER)

	local renderdata = SF.instance.data.render
	if not renderdata.usingRT then  SF.Throw("Stencil operations are allowed only inside RenderTarget!") end

	render.SetStencilReferenceValue(referenceValue)
end

function render_library.setStencilTestMask(mask)
	SF.CheckLuaType(mask, TYPE_NUMBER)

	local renderdata = SF.instance.data.render
	if not renderdata.usingRT then  SF.Throw("Stencil operations are allowed only inside RenderTarget!") end

	render.SetStencilTestMask(mask)
end

function render_library.setStencilWriteMask(mask)
	SF.CheckLuaType(mask, TYPE_NUMBER)

	local renderdata = SF.instance.data.render
	if not renderdata.usingRT then  SF.Throw("Stencil operations are allowed only inside RenderTarget!") end

	render.SetStencilWriteMask(mask)
end

-- ------------------------------------------------------------------ --

--- Pushes a matrix onto the matrix stack.
-- @param m The matrix
-- @param world Should the transformation be relative to the screen or world?
function render_library.pushMatrix(m, world)
	SF.CheckType(m, matrix_meta)
	local renderdata = SF.instance.data.render

	if world == nil then
		world = renderdata.usingRT
	end

	if not renderdata.isRendering then SF.Throw("Not in rendering hook.", 2) end
	local id = #matrix_stack
	if id + 1 > MATRIX_STACK_LIMIT then SF.Throw("Pushed too many matricies", 2) end
	local newmatrix
	if matrix_stack[id] then
		newmatrix = matrix_stack[id] * munwrap(m)
	else
		newmatrix = munwrap(m)
	end
	if not world and renderdata.renderEnt and renderdata.renderEnt.Transform then
		newmatrix = renderdata.renderEnt.Transform * newmatrix
	end
	matrix_stack[id + 1] = newmatrix
	cam.PushModelMatrix(newmatrix)
end

--- Enables a scissoring rect which limits the drawing area. Only works 2D contexts such as HUD or render targets.
-- @param startX X start coordinate of the scissor rect.
-- @param startY Y start coordinate of the scissor rect.
-- @param endX X end coordinate of the scissor rect.
-- @param endX Y end coordinate of the scissor rect.
function render_library.enableScissorRect(startX, startY, endX, endY)
	local data = SF.instance.data.render
	if not data.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(startX, TYPE_NUMBER)
	SF.CheckLuaType(startY, TYPE_NUMBER)
	SF.CheckLuaType(endX, TYPE_NUMBER)
	SF.CheckLuaType(endY, TYPE_NUMBER)
	render.SetScissorRect(startX, startY, endX, endY, true)
end

--- Disables a scissoring rect which limits the drawing area.
function render_library.disableScissorRect()
	local data = SF.instance.data.render
	if not data.isRendering then SF.Throw("Not in rendering hook.", 2) end
	render.SetScissorRect(0 , 0 , 0 , 0, false)

end

--- Pops a matrix from the matrix stack.
function render_library.popMatrix()
	local renderdata = SF.instance.data.render
	if not renderdata.isRendering then SF.Throw("Not in rendering hook.", 2) end
	if #matrix_stack <= 0 then SF.Throw("Popped too many matricies", 2) end
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
	if not renderdata.isRendering then SF.Throw("Not in rendering hook.", 2) end
	if #view_matrix_stack == MATRIX_STACK_LIMIT then SF.Throw("Pushed too many matricies", 2) end
	local endfunc
	if tbl.type == "2D" then
		endfunc = "End2D"
	elseif tbl.type == "3D" then
		endfunc = "End3D"
	else
		SF.Throw("Camera type must be \"3D\" or \"2D\"", 2)
	end

	local newtbl = {}
	for k, v in pairs(tbl) do
		if viewmatrix_checktypes[k] then
			SF.CheckType(v, viewmatrix_checktypes[k])
			newtbl[k] = v
		else
			SF.Throw("Invalid key found in view matrix: " .. k, 2)
		end
	end
	if newtbl.origin then newtbl.origin = vunwrap(newtbl.origin) end
	if newtbl.angles then newtbl.angles = aunwrap(newtbl.angles) end
	if newtbl.offcenter then
		SF.CheckLuaType(tbl.offcenter.left, TYPE_NUMBER)
		SF.CheckLuaType(tbl.offcenter.right, TYPE_NUMBER)
		SF.CheckLuaType(tbl.offcenter.bottom, TYPE_NUMBER)
		SF.CheckLuaType(tbl.offcenter.top, TYPE_NUMBER)
	end
	if newtbl.ortho then
		SF.CheckLuaType(tbl.ortho.left, TYPE_NUMBER)
		SF.CheckLuaType(tbl.ortho.right, TYPE_NUMBER)
		SF.CheckLuaType(tbl.ortho.bottom, TYPE_NUMBER)
		SF.CheckLuaType(tbl.ortho.top, TYPE_NUMBER)
	end

	cam.Start(newtbl)
	view_matrix_stack[#view_matrix_stack + 1] = endfunc
end

--- Pops a view matrix from the matrix stack.
function render_library.popViewMatrix()
	local renderdata = SF.instance.data.render
	if not renderdata.isRendering then SF.Throw("Not in rendering hook.", 2) end
	local i = #view_matrix_stack
	if i == 0 then SF.Throw("Popped too many matricies", 2) end

	cam[view_matrix_stack[i]]()
	view_matrix_stack[i] = nil
end

--- Sets the draw color
-- @param col Color of background
-- @screen (Optional) entity of screen
function render_library.setBackgroundColor(col, screen)
	local renderdata = SF.instance.data.render

	SF.CheckType(col, col_meta)

	if screen then
		SF.CheckType(screen, ent_meta)
		screen = eunwrap(screen)
		if screen.link ~= SF.instance.data.entity then
			SF.Throw("Entity has to be linked!", 2)
		end
	else
		if renderdata.isRendering then
			screen = renderdata.renderEnt
		end
	end

	if not screen then
		SF.Throw("Invalid rendering entity.", 2)
	end

	if screen.SetBackgroundColor then --Fail silently on HUD etc
		screen:SetBackgroundColor(col.r, col.g, col.b, col.a)
	end
end


--- Sets the draw color
-- @param clr Color type
function render_library.setColor(clr)
	SF.CheckType(clr, col_meta)
	currentcolor = clr
	surface.SetDrawColor(clr)
	surface.SetTextColor(clr)
end

--- Sets the draw color by RGBA values
function render_library.setRGBA(r, g, b, a)
	SF.CheckLuaType(r, TYPE_NUMBER) SF.CheckLuaType(g, TYPE_NUMBER) SF.CheckLuaType(b, TYPE_NUMBER) SF.CheckLuaType(a, TYPE_NUMBER)
	currentcolor = Color(r, g, b, a)
	surface.SetDrawColor(r, g, b, a)
	surface.SetTextColor(r, g, b, a)
end

--- Looks up a texture by file name. Use with render.setTexture to draw with it.
--- Make sure to store the texture to use it rather than calling this slow function repeatedly.
-- @param tx Texture file path, a http url, or image data: https://en.wikipedia.org/wiki/Data_URI_scheme
-- @param cb Optional callback for when a url texture finishes loading. param1 - The texture table, param2 - The texture url
-- @param alignment Optional alignment for the url texture. Default: "center", See http://www.w3schools.com/cssref/pr_background-position.asp
-- @param skip_hack Turns off texture hack so you can use UVs on 3D objects
-- @return Texture table. Use it with render.setTexture. Returns nil if max url textures is reached.
function render_library.getTextureID (tx, cb, alignment, skip_hack)
	SF.CheckLuaType(tx, TYPE_STRING)

	local instance = SF.instance
	local data = instance.data.render
	if #tx > cv_max_data_material_size:GetInt() then
		SF.Throw("Texture URL/Data too long!", 2)
	end
	local _1, _2, prefix = tx:find("^(%w-):")
	if prefix=="http" or prefix=="https" or prefix == "data" then
		if prefix=="http" or prefix=="https" then
			SF.Permissions.check(instance.player, nil, "render.urlmaterial")
			tx = string.gsub(tx, "[^%w _~%.%-/:]", function(str)
				return string.format("%%%02X", string.byte(str))
			end)
		else
			SF.Permissions.check(instance.player, nil, "render.datamaterial")
			tx = string.match(tx, "data:image/[%w%+]+;base64,[%w/%+%=]+") -- No $ at end etc so there can be cariage return etc, we'll skip that part anyway
			if not tx then --It's not valid
				SF.Throw("Texture data isnt proper base64 encoded image.", 2)
			end
		end
		if plyURLTexcount[instance.playerid] then
			if plyURLTexcount[instance.playerid] >= cv_max_url_materials:GetInt() then
				SF.Throw("URL Texture limit reached", 2)
			else
				plyURLTexcount[instance.playerid] = plyURLTexcount[instance.playerid] + 1
			end
		else
			plyURLTexcount[instance.playerid] = 1
		end
		data.urltexturecount = data.urltexturecount + 1

		if alignment then
			SF.CheckLuaType(alignment, TYPE_STRING)
			local args = string.Split(alignment, " ")
			local validargs = { ["left"] = true, ["center"] = true, ["right"] = true, ["top"] = true, ["bottom"] = true }
			if #args ~= 1 and #args ~= 2 then SF.Throw("Invalid urltexture alignment given.") end
			for i = 1, #args do
				if not validargs[args[i]] then SF.Throw("Invalid urltexture alignment given.") end
			end
		else
			alignment = "center"
		end

		local tbl = {}
		data.urltextures[tbl] = LoadURLMaterial(tx, alignment, function()
			if cb then
				instance:runFunction(cb, tbl, tx)
			end
		end, skip_hack)
		return tbl
	else
		local id = surface.GetTextureID(tx)
		if id then
			local mat = Material(tx) -- Hacky way to get ITexture, if there is a better way - do it!
			if not mat then return end
			local cacheentry = sfCreateMaterial("SF_TEXTURE_" .. id, skip_hack)
			cacheentry:SetTexture("$basetexture", mat:GetTexture("$basetexture"))

			local tbl = {}
			data.textures[tbl] = cacheentry
			return tbl
		end
	end

end

--- Releases the texture. Required if you reach the maximum url textures.
-- @param id Texture table. Aquired with render.getTextureID
function render_library.destroyTexture(id)
	local instance = SF.instance
	local data = instance.data.render
	if data.urltextures[id] then
		plyURLTexcount[instance.playerid] = plyURLTexcount[instance.playerid] - 1
		data.urltexturecount = data.urltexturecount - 1
		data.urltextures[id]:SetUndefined("$basetexture")
		data.urltextures[id] = nil
	elseif data.textures[id] then
		data.textures[id] = nil
	else
		SF.Throw("Cannot destroy an invalid texture.", 2)
	end
end

--- Sets the texture
-- @param id Texture table. Aquired with render.getTextureID
function render_library.setTexture (id)
	local data = SF.instance.data.render
	if not data.isRendering then SF.Throw("Not in rendering hook.", 2) end
	if id then
		if data.textures[id] then
			surface.SetMaterial(data.textures[id])
			render.SetMaterial(data.textures[id])
		elseif data.urltextures[id] then
			surface.SetMaterial(data.urltextures[id])
			render.SetMaterial(data.urltextures[id])
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
function render_library.createRenderTarget (name)
	SF.CheckLuaType(name, TYPE_STRING)

	local instance = SF.instance
	local data = instance.data.render
	if data.rendertargets[name] then SF.Throw("A rendertarget with this name already exists!", 2) end

	if plyRTcount[instance.playerid] then
		if plyRTcount[instance.playerid] >= cv_max_rendertargets:GetInt() then
			SF.Throw("Rendertarget limit reached", 2)
		else
			plyRTcount[instance.playerid] = plyRTcount[instance.playerid] + 1
		end
	else
		plyRTcount[instance.playerid] = 1
	end
	data.rendertargetcount = data.rendertargetcount + 1

	local rtname, rt
	for k, v in pairs(globalRTs) do
		if v[2] then rtname, rt = k, v break end
	end
	if rt then
		rt[2] = false
	else
		globalRTcount = globalRTcount + 1
		rtname = "Starfall_CustomRT_" .. globalRTcount
		rt = { GetRenderTarget(rtname, 1024, 1024), false }
		rt[3] = CreateMaterial("StarfallCustomModel_"..globalRTcount, "VertexLitGeneric", { ["$model"] = 1 })
		rt[3]:SetTexture("$basetexture", rt[1])
		globalRTs[rtname] = rt
	end

	data.rendertargets[name] = rtname
end

--- Releases the rendertarget. Required if you reach the maximum rendertargets.
-- @param name Rendertarget name
function render_library.destroyRenderTarget(name)
	local instance = SF.instance
	local data = instance.data.render
	local rtname = data.rendertargets[name]
	if rtname then
		globalRTs[rtname][2] = true
		data.rendertargets[name] = nil
	else
		SF.Throw("Cannot destroy an invalid rendertarget.", 2)
	end
end

--- Selects the render target to draw on.
-- Nil for the visible RT.
-- @param name Name of the render target to use
function render_library.selectRenderTarget (name)
	local data = SF.instance.data.render
	if not data.isRendering then SF.Throw("Not in rendering hook.", 2) end
	if name then
		SF.CheckLuaType(name, TYPE_STRING)

		local rtname = data.rendertargets[name]
		if not rtname then SF.Throw("Invalid Rendertarget", 2) end
		local rttbl = globalRTs[rtname]
		if not rttbl then SF.Throw("Invalid Rendertarget", 2) end
		local rt = rttbl[1]
		if not rt then SF.Throw("Invalid Rendertarget", 2) end

		if not data.usingRT then
			data.oldViewPort = { 0, 0, ScrW(), ScrH() }
			render.SetViewPort(0, 0, 1024, 1024)
			cam.Start2D()
			view_matrix_stack[#view_matrix_stack + 1] = "End2D"
			render.SetStencilEnable(false)
		end
		render.SetRenderTarget(rt)
		data.usingRT = true
	else
		if data.usingRT and not data.needRT then
			render.SetRenderTarget()
			local i = #view_matrix_stack
			if i>0 then
				cam[view_matrix_stack[i]]()
				view_matrix_stack[i] = nil
			end
			render.SetViewPort(unpack(data.oldViewPort))
			data.usingRT = false
			if data.useStencil then -- Revert ALL stencil settings from screen
				render.SetStencilEnable(true)
				render.SetStencilFailOperation(STENCILOPERATION_KEEP)
				render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
				render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
				render.SetStencilWriteMask(1)
				render.SetStencilReferenceValue(1)
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
				render.SetStencilTestMask(1)

			end
		end
	end
end

--- Sets the active texture to the render target with the specified name.
-- Nil to reset.
-- @param name Name of the render target to use
function render_library.setRenderTargetTexture (name)
	local data = SF.instance.data.render
	if not data.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(name, TYPE_STRING)

	local rtname = data.rendertargets[name]
	if rtname and globalRTs[rtname] then
		RT_Material:SetTexture("$basetexture", globalRTs[rtname][1])
		surface.SetMaterial(RT_Material)
		render.SetMaterial(RT_Material)
	else
		draw.NoTexture()
	end
end

--- Returns the model material name that uses the render target.
-- @param name Render target name
-- @return Model material name. Send this to the server to set the entity's material.
function render_library.getRenderTargetMaterial(name)
	local data = SF.instance.data.render
	SF.CheckLuaType(name, TYPE_STRING)

	local rtname = data.rendertargets[name]
	if rtname and globalRTs[rtname] then
		return "!"..globalRTs[rtname][3]:GetName()
	end
end

--- Sets the texture of a screen entity
-- @param ent Screen entity
function render_library.setTextureFromScreen (ent)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end

	ent = eunwrap(ent)
	if IsValid(ent) and ent.GPU and ent.GPU.RT then
		RT_Material:SetTexture("$basetexture", ent.GPU.RT)
		surface.SetMaterial(RT_Material)
	else
		draw.NoTexture()
	end

end

--- Sets the texture filtering function when viewing a close texture
-- @param val The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER
function render_library.setFilterMag(val)
	SF.CheckLuaType(val, TYPE_NUMBER)
	if SF.instance.data.render.changedFilterMag then
		render.PopFilterMag()
	end
	SF.instance.data.render.changedFilterMag = true
	render.PushFilterMag(val)
end

--- Sets the texture filtering function when viewing a far texture
-- @param val The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER
function render_library.setFilterMin(val)
	SF.CheckLuaType(val, TYPE_NUMBER)
	if SF.instance.data.render.changedFilterMin then
		render.PopFilterMin()
	end
	SF.instance.data.render.changedFilterMin = true
	render.PushFilterMin(val)
end

--- Clears the active render target
-- @param clr Color type to clear with
-- @param depth Boolean if should clear depth
function render_library.clear (clr, depth)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in a rendering hook.", 2) end
	if SF.instance.data.render.usingRT then
		if clr == nil then
			render.Clear(0, 0, 0, 255, depth)
		else
			SF.CheckType(clr, col_meta)
			render.Clear(clr.r, clr.g, clr.b, clr.a, depth)
		end
	end
end

--- Draws a rounded rectangle using the current color
-- @param r The corner radius
-- @param x Top left corner x coordinate
-- @param y Top left corner y coordinate
-- @param w Width
-- @param h Height
function render_library.drawRoundedBox (r, x, y, w, h)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(r, TYPE_NUMBER)
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	SF.CheckLuaType(w, TYPE_NUMBER)
	SF.CheckLuaType(h, TYPE_NUMBER)
	draw.RoundedBox(r, x, y, w, h, currentcolor)
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
function render_library.drawRoundedBoxEx (r, x, y, w, h, tl, tr, bl, br)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(r, TYPE_NUMBER)
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	SF.CheckLuaType(w, TYPE_NUMBER)
	SF.CheckLuaType(h, TYPE_NUMBER)
	SF.CheckLuaType(tl, TYPE_BOOL)
	SF.CheckLuaType(tr, TYPE_BOOL)
	SF.CheckLuaType(bl, TYPE_BOOL)
	SF.CheckLuaType(br, TYPE_BOOL)
	draw.RoundedBoxEx(r, x, y, w, h, currentcolor, tl, tr, bl, br)
end

--- Draws a rectangle using the current color.
-- @param x Top left corner x coordinate
-- @param y Top left corner y coordinate
-- @param w Width
-- @param h Height
function render_library.drawRect (x, y, w, h)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	SF.CheckLuaType(w, TYPE_NUMBER)
	SF.CheckLuaType(h, TYPE_NUMBER)
	surface.DrawRect(x, y, w, h)
end

--- Draws a rectangle outline using the current color.
-- @param x Top left corner x coordinate
-- @param y Top left corner y coordinate
-- @param w Width
-- @param h Height
function render_library.drawRectOutline (x, y, w, h)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	SF.CheckLuaType(w, TYPE_NUMBER)
	SF.CheckLuaType(h, TYPE_NUMBER)
	surface.DrawOutlinedRect(x, y, w, h)
end

--- Draws a circle outline
-- @param x Center x coordinate
-- @param y Center y coordinate
-- @param r Radius
function render_library.drawCircle (x, y, r)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	SF.CheckLuaType(r, TYPE_NUMBER)
	surface.DrawCircle(x, y, r, currentcolor)
end

--- Draws a textured rectangle.
-- @param x Top left corner x coordinate
-- @param y Top left corner y coordinate
-- @param w Width
-- @param h Height
function render_library.drawTexturedRect (x, y, w, h)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	SF.CheckLuaType(w, TYPE_NUMBER)
	SF.CheckLuaType(h, TYPE_NUMBER)
	surface.DrawTexturedRect (x, y, w, h)
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
function render_library.drawTexturedRectUV (x, y, w, h, startU, startV, endU, endV)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	SF.CheckLuaType(w, TYPE_NUMBER)
	SF.CheckLuaType(h, TYPE_NUMBER)
	SF.CheckLuaType(startU, TYPE_NUMBER)
	SF.CheckLuaType(startV, TYPE_NUMBER)
	SF.CheckLuaType(endU, TYPE_NUMBER)
	SF.CheckLuaType(endV, TYPE_NUMBER)
	surface.DrawTexturedRectUV(x, y, w, h, startU, startV, endU, endV)
end

--- Draws a rotated, textured rectangle.
-- @param x X coordinate of center of rect
-- @param y Y coordinate of center of rect
-- @param w Width
-- @param h Height
-- @param rot Rotation in degrees
function render_library.drawTexturedRectRotated (x, y, w, h, rot)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	SF.CheckLuaType(w, TYPE_NUMBER)
	SF.CheckLuaType(h, TYPE_NUMBER)
	SF.CheckLuaType(rot, TYPE_NUMBER)

	surface.DrawTexturedRectRotated(x, y, w, h, rot)
end

--- Draws a line
-- @param x1 X start coordinate
-- @param y1 Y start coordinate
-- @param x2 X end coordinate
-- @param y2 Y end coordinate
function render_library.drawLine (x1, y1, x2, y2)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(x1, TYPE_NUMBER)
	SF.CheckLuaType(y1, TYPE_NUMBER)
	SF.CheckLuaType(x2, TYPE_NUMBER)
	SF.CheckLuaType(y2, TYPE_NUMBER)
	surface.DrawLine(x1, y1, x2, y2)
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
-- @param extended Allows the font to display glyphs outside of Latin-1 range. Unicode code points above 0xFFFF are not supported. Required to use FontAwesome
-- @usage
-- Base font can be one of (keep in mind that these may not exist on all clients if they are not shipped with starfall):
-- \- Akbar
-- \- Coolvetica
-- \- Roboto
-- \- Roboto Mono
-- \- FontAwesome
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

function render_library.createFont(font, size, weight, antialias, additive, shadow, outline, blur, extended)
	font = validfonts[string.lower(font)]
	if not font then SF.Throw("invalid font", 2) end

	size = tonumber(size) or 16
	weight = tonumber(weight) or 400
	blur = tonumber(blur) or 0
	antialias = antialias and true or false
	additive = additive and true or false
	shadow = shadow and true or false
	outline = outline and true or false
	extended = extended and true or false

	local name = string.format("sf_screen_font_%s_%d_%d_%d_%d%d%d%d%d",
		font, size, weight, blur,
		antialias and 1 or 0,
		additive and 1 or 0,
		shadow and 1 or 0,
		outline and 1 or 0,
		extended and 1 or 0)

	if not defined_fonts[name] then
		surface.CreateFont(name, { size = size, weight = weight,
			antialias = antialias, additive = additive, font = font,
			shadow = shadow, outline = outline, blur = blur,
			extended = extended })
		defined_fonts[name] = true
	end
	return name
end
defaultFont = render_library.createFont("Default", 16, 400, false, false, false, false, 0)

--- Gets the size of the specified text. Don't forget to use setFont before calling this function
-- @param text Text to get the size of
-- @return width of the text
-- @return height of the text
function render_library.getTextSize(text)
	SF.CheckLuaType(text, TYPE_STRING)

	surface.SetFont(SF.instance.data.render.font or defaultFont)
	return surface.GetTextSize(text)
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
	if not defined_fonts[font] then SF.Throw("Font does not exist.", 2) end
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
function render_library.drawText (x, y, text, alignment)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	SF.CheckLuaType(text, TYPE_STRING)
	if alignment then
		SF.CheckLuaType(alignment, TYPE_NUMBER)
	end

	local font = SF.instance.data.render.font or defaultFont

	draw.DrawText(text, font, x, y, currentcolor, alignment)
end

--- Draws text more easily and quickly but no new lines or tabs.
-- @param x X coordinate
-- @param y Y coordinate
-- @param text Text to draw
-- @param xalign Text x alignment
-- @param yalign Text y alignment
function render_library.drawSimpleText (x, y, text, xalign, yalign)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	SF.CheckLuaType(text, TYPE_STRING)
	if xalign then SF.CheckLuaType(xalign, TYPE_NUMBER) end
	if yalign then SF.CheckLuaType(yalign, TYPE_NUMBER) end

	local font = SF.instance.data.render.font or defaultFont

	draw.SimpleText(text, font, x, y, currentcolor, xalign, yalign)
end

--- Constructs a markup object for quick styled text drawing.
-- @param str The markup string to parse
-- @param maxsize The max width of the markup
-- @return The markup object. See https://wiki.garrysmod.com/page/Category:MarkupObject
function render_library.parseMarkup(str, maxsize)
	SF.CheckLuaType(str, TYPE_STRING)
	SF.CheckLuaType(maxsize, TYPE_NUMBER)
	local marked = markup.Parse(str, maxsize)
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
	SF.CheckLuaType(poly, TYPE_TABLE)
	surface.DrawPoly(poly)
end

--- Enables or disables Depth Buffer
-- @param enable true to enable
function render_library.enableDepth (enable)
	SF.CheckLuaType(enable, TYPE_BOOL)
	render.OverrideDepthEnable(enable, enable)
end

--- Resets the depth buffer
function render_library.clearDepth()
	if not SF.instance.data.render.isRendering then SF.Throw("Not in a rendering hook.", 2) end
	if SF.instance.data.render.usingRT then
		render.ClearDepth()
	end
end

--- Draws a sprite in 3d space.
-- @param pos  Position of the sprite.
-- @param width Width of the sprite.
-- @param height Height of the sprite.
function render_library.draw3DSprite(pos, width, height)
	SF.CheckType(pos, vector_meta)
	SF.CheckLuaType(width, TYPE_NUMBER)
	SF.CheckLuaType(height, TYPE_NUMBER)
	pos = vunwrap(pos)
	render.DrawSprite(pos, width, height)
end

--- Draws a sphere
-- @param pos Position of the sphere
-- @param radius Radius of the sphere
-- @param longitudeSteps The amount of longitude steps. The larger this number is, the smoother the sphere is
-- @param latitudeSteps  The amount of latitude steps. The larger this number is, the smoother the sphere is
function render_library.draw3DSphere (pos, radius, longitudeSteps, latitudeSteps)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckType(pos, vector_meta)
	SF.CheckLuaType(radius, TYPE_NUMBER)
	SF.CheckLuaType(longitudeSteps, TYPE_NUMBER)
	SF.CheckLuaType(latitudeSteps, TYPE_NUMBER)
	pos = vunwrap(pos)
	longitudeSteps = math.min(longitudeSteps, 50)
	latitudeSteps = math.min(latitudeSteps, 50)
	render.DrawSphere(pos, radius, longitudeSteps, latitudeSteps, currentcolor, true)
end

--- Draws a wireframe sphere
-- @param pos Position of the sphere
-- @param radius Radius of the sphere
-- @param longitudeSteps The amount of longitude steps. The larger this number is, the smoother the sphere is
-- @param latitudeSteps  The amount of latitude steps. The larger this number is, the smoother the sphere is
function render_library.draw3DWireframeSphere (pos, radius, longitudeSteps, latitudeSteps)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckType(pos, vector_meta)
	SF.CheckLuaType(radius, TYPE_NUMBER)
	SF.CheckLuaType(longitudeSteps, TYPE_NUMBER)
	SF.CheckLuaType(latitudeSteps, TYPE_NUMBER)
	pos = vunwrap(pos)
	longitudeSteps = math.min(longitudeSteps, 50)
	latitudeSteps = math.min(latitudeSteps, 50)
	render.DrawWireframeSphere(pos, radius, longitudeSteps, latitudeSteps, currentcolor, true)
end

--- Draws a 3D Line
-- @param startPos Starting position
-- @param endPos Ending position
function render_library.draw3DLine (startPos, endPos)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckType(startPos, vector_meta)
	SF.CheckType(endPos, vector_meta)
	startPos = vunwrap(startPos)
	endPos = vunwrap(endPos)

	render.DrawLine(startPos, endPos, currentcolor, true)
end

--- Draws a box in 3D space
-- @param origin Origin of the box.
-- @param angle Orientation  of the box
-- @param mins Start position of the box, relative to origin.
-- @param maxs End position of the box, relative to origin.
function render_library.draw3DBox (origin, angle, mins, maxs)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckType(origin, vector_meta)
	SF.CheckType(mins, vector_meta)
	SF.CheckType(maxs, vector_meta)
	SF.CheckType(angle, ang_meta)
	origin = vunwrap(origin)
	mins = vunwrap(mins)
	maxs = vunwrap(maxs)
	angle = aunwrap(angle)

	render.DrawBox(origin, angle, mins, maxs, currentcolor, true)
end

--- Draws a wireframe box in 3D space
-- @param origin Origin of the box.
-- @param angle Orientation  of the box
-- @param mins Start position of the box, relative to origin.
-- @param maxs End position of the box, relative to origin.
function render_library.draw3DWireframeBox (origin, angle, mins, maxs)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckType(origin, vector_meta)
	SF.CheckType(mins, vector_meta)
	SF.CheckType(maxs, vector_meta)
	SF.CheckType(angle, ang_meta)
	origin = vunwrap(origin)
	mins = vunwrap(mins)
	maxs = vunwrap(maxs)
	angle = aunwrap(angle)

	render.DrawWireframeBox(origin, angle, mins, maxs, currentcolor, false)
end

--- Draws textured beam.
-- @param startPos Beam start position.
-- @param endPos Beam end position.
-- @param width The width of the beam.
-- @param textureStart The start coordinate of the texture used.
-- @param textureEnd The end coordinate of the texture used.
function render_library.draw3DBeam (startPos, endPos, width, textureStart, textureEnd)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckType(startPos, vector_meta)
	SF.CheckType(endPos, vector_meta)
	SF.CheckLuaType(width, TYPE_NUMBER)
	SF.CheckLuaType(textureStart, TYPE_NUMBER)
	SF.CheckLuaType(textureEnd, TYPE_NUMBER)

	startPos = vunwrap(startPos)
	endPos = vunwrap(endPos)

	render.DrawBeam(startPos, endPos, width, textureStart, textureEnd, currentcolor)
end

--- Draws 2 connected triangles.
-- @param vert1 First vertex.
-- @param vert2 The second vertex.
-- @param vert3 The third vertex.
-- @param vert4 The fourth vertex.
function render_library.draw3DQuad (vert1, vert2, vert3, vert4)
	if not SF.instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	SF.CheckType(vert1, vector_meta)
	SF.CheckType(vert2, vector_meta)
	SF.CheckType(vert3, vector_meta)
	SF.CheckType(vert4, vector_meta)

	vert1 = vunwrap(vert1)
	vert2 = vunwrap(vert2)
	vert3 = vunwrap(vert3)
	vert4 = vunwrap(vert4)

	render.DrawQuad(vert1, vert2, vert3, vert4, currentcolor)
end

--- Gets a 2D cursor position where ply is aiming.
-- @param ply player to get cursor position from(optional)
-- @return x position
-- @return y position
function render_library.cursorPos(ply)
	local screen = SF.instance.data.render.renderEnt
	if not screen or screen:GetClass()~="starfall_screen" then return input.GetCursorPos() end

	ply = ply and eunwrap(ply) or LocalPlayer()

	if not IsValid(ply) or not ply:IsPlayer() then SF.Throw("Invalid Player", 2) end

	local Normal, Pos
	-- Get monitor screen pos & size

	Pos = screen:LocalToWorld(screen.Origin)

	Normal = -screen.Transform:GetUp():GetNormalized()

	local Start = ply:GetShootPos()
	local Dir = ply:GetAimVector()

	local A = Normal:Dot(Dir)

	-- If ray is parallel or behind the screen
	if A == 0 or A > 0 then return nil end

	local B = Normal:Dot(Pos-Start) / A
	if (B >= 0) then
		local w = 512 / screen.Aspect
		local HitPos = WorldToLocal(Start + Dir * B, Angle(), screen.Transform:GetTranslation(), screen.Transform:GetAngles())
		local x = HitPos.x / screen.Scale
		local y = HitPos.y / screen.Scale
		if x < 0 or x > w or y < 0 or y > 512 then return nil end -- Aiming off the screen
		return x, y
	end

	return nil
end

--- Returns information about the screen, such as world offsets, dimentions, and rotation.
-- Note: this does a table copy so move it out of your draw hook
-- @param e The screen to get info from.
-- @return A table describing the screen.
function render_library.getScreenInfo(e)
	local screen = eunwrap(e)
	if screen then
		return SF.Sanitize(screen.ScreenInfo)
	end
end

--- Returns the entity currently being rendered to
-- @return Entity of the screen or hud being rendered
function render_library.getScreenEntity()
	return ewrap(SF.instance.data.render.renderEnt)
end

--- Dumps the current render target and allows the pixels to be accessed by render.readPixel.
function render_library.capturePixels ()
	local data = SF.instance.data.render
	if not data.isRendering then
		SF.Throw("Not in rendering hook.", 2)
	end
	if SF.instance.data.render.usingRT then
		render.CapturePixels()
	end
end

--- Reads the color of the specified pixel.
-- @param x Pixel x-coordinate.
-- @param y Pixel y-coordinate.
-- @return Color object with ( r, g, b, 255 ) from the specified pixel.
function render_library.readPixel (x, y)
	local data = SF.instance.data.render
	if not data.isRendering then
		SF.Throw("Not in rendering hook.", 2)
	end

	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)

	local r, g, b = render.ReadPixel(x, y)
	return cwrap(Color(r, g, b, 255))
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
function render_library.traceSurfaceColor(vec1, vec2)
	SF.CheckType(vec1, vector_meta)
	SF.CheckType(vec2, vector_meta)

	return vwrap(render.GetSurfaceColor(vunwrap(vec1), vunwrap(vec2)))
end

--- Checks if a hud component is connected to the Starfall Chip
function render_library.isHUDActive()
	return SF.instance:isHUDActive()
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
