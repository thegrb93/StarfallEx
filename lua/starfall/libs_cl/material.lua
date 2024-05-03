local checkluatype = SF.CheckLuaType
local dsetmeta = debug.setmetatable
local registerprivilege = SF.Permissions.registerPrivilege

-- Register privileges
registerprivilege("material.load", "Load material", "Allows users to load a vmt material.", { client = {} })
registerprivilege("material.create", "Create material", "Allows users to create a new custom material.", { client = {} })
registerprivilege("material.imagecreate", "Create material from image", "Allows users to create a new material from an image file.", { client = {} })
registerprivilege("material.urlcreate", "Create material from online image", "Allows users to create a new material from an online image.", { client = {}, urlwhitelist = {} })
registerprivilege("material.datacreate", "Create material from base64 image data", "Allows users to create a new material from base64 image data.", { client = {} })

local cv_max_data_material_size = CreateConVar("sf_render_maxdatamaterialsize", "1000000", { FCVAR_ARCHIVE })

-- Make sure to update the material.create doc if you add stuff to this list.
local allowed_shaders = {
	UnlitGeneric = true,
	VertexLitGeneric = true,
	Wireframe = true,
	Refract_DX90 = true,
	Water_DX90 = true,
	Sky_DX9 = true,
	gmodscreenspace = true,
	Modulate_DX9 = true,
}

local default_values = {
	["$alpha"] = {"SetInt", 1},
	["$alphatestreference"] = {"SetInt", 0},
	["$ambientonly"] = {"SetInt", 0},
	["$basemapalphaphongmask"] = {"SetInt", 0},
	["$basetexture"] = {"SetUndefined"},
	["$basetexturetransform"] = {"SetMatrix", Matrix()},
	["$blendtintbybasealpha"] = {"SetInt", 0},
	["$blendtintcoloroverbase"] = {"SetInt", 0},
	["$bumpframe"] = {"SetInt", 0},
	["$bumptransform"] = {"SetMatrix", Matrix()},
	["$cloakcolortint"] = {"SetVector", Vector(1.000000, 1.000000, 1.000000)},
	["$cloakfactor"] = {"SetFloat", 0},
	["$cloakpassenabled"] = {"SetInt", 0},
	["$color"] = {"SetVector", Vector(1.000000, 1.000000, 1.000000)},
	["$color2"] = {"SetVector", Vector(1.000000, 1.000000, 1.000000)},
	["$depthblend"] = {"SetInt", 0},
	["$depthblendscale"] = {"SetFloat", 50},
	["$detail"] = {"SetUndefined"},
	["$detailblendfactor"] = {"SetFloat", 1},
	["$detailblendmode"] = {"SetInt", 0},
	["$detailframe"] = {"SetInt", 0},
	["$detailscale"] = {"SetInt", 4},
	["$detailtexturetransform"] = {"SetMatrix", Matrix()},
	["$detailtint"] = {"SetVector", Vector(1.000000, 1.000000, 1.000000)},
	["$displacementmap"] = {"SetUndefined"},
	["$emissiveblendenabled"] = {"SetInt", 0},
	["$emissiveblendscrollvector"] = {"SetVector", Vector(0.000000, 0.000000, 0.000000)},
	["$emissiveblendstrength"] = {"SetFloat", 0},
	["$emissiveblendtint"] = {"SetVector", Vector(1.000000, 1.000000, 1.000000)},
	["$envmap"] = {"SetUndefined"},
	["$envmapcontrast"] = {"SetFloat", 0},
	["$envmapframe"] = {"SetInt", 0},
	["$envmapfresnel"] = {"SetFloat", 0},
	["$envmapfresnelminmaxexp"] = {"SetVector", Vector(0.000000, 0.000000, 0.000000)},
	["$envmaplightscale"] = {"SetFloat", 0},
	["$envmaplightscaleminmax"] = {"SetVector", Vector(0.000000, 0.000000, 0.000000)},
	["$envmapmask"] = {"SetUndefined"},
	["$envmapmaskframe"] = {"SetInt", 0},
	["$envmapmasktransform"] = {"SetMatrix", Matrix()},
	["$envmapsaturation"] = {"SetFloat", 1},
	["$envmaptint"] = {"SetVector", Vector(1.000000, 1.000000, 1.000000)},
	["$flags"] = {"SetInt", 201334784},
	["$flashlightnolambert"] = {"SetInt", 0},
	["$flashlighttexture"] = {"SetUndefined"},
	["$flashlighttextureframe"] = {"SetInt", 0},
	["$fleshbordernoisescale"] = {"SetFloat", 0},
	["$fleshbordersoftness"] = {"SetFloat", 0},
	["$fleshbordertint"] = {"SetVector", Vector(1.000000, 1.000000, 1.000000)},
	["$fleshborderwidth"] = {"SetFloat", 0},
	["$fleshdebugforcefleshon"] = {"SetInt", 0},
	["$flesheffectcenterradius1"] = {"SetVector", Vector(0.000000, 0.000000, 0.000000)},
	["$flesheffectcenterradius2"] = {"SetVector", Vector(0.000000, 0.000000, 0.000000)},
	["$flesheffectcenterradius3"] = {"SetVector", Vector(0.000000, 0.000000, 0.000000)},
	["$flesheffectcenterradius4"] = {"SetVector", Vector(0.000000, 0.000000, 0.000000)},
	["$fleshglobalopacity"] = {"SetFloat", 0},
	["$fleshglossbrightness"] = {"SetFloat", 0},
	["$fleshinteriorenabled"] = {"SetInt", 0},
	["$fleshscrollspeed"] = {"SetFloat", 0},
	["$fleshsubsurfacetint"] = {"SetVector", Vector(1.000000, 1.000000, 1.000000)},
	["$frame"] = {"SetInt", 0},
	["$invertphongmask"] = {"SetInt", 0},
	["$lightwarptexture"] = {"SetUndefined"},
	["$linearwrite"] = {"SetInt", 0},
	["$phong"] = {"SetInt", 0},
	["$phongalbedotint"] = {"SetFloat", 0},
	["$phongboost"] = {"SetFloat", 0},
	["$phongexponent"] = {"SetFloat", 0},
	["$phongexponenttexture"] = {"SetUndefined"},
	["$phongfresnelranges"] = {"SetVector", Vector(0.000000, 0.000000, 0.000000)},
	["$phongtint"] = {"SetVector", Vector(0.000000, 0.000000, 0.000000)},
	["$phongwarptexture"] = {"SetUndefined"},
	["$refractamount"] = {"SetFloat", 0},
	["$rimlight"] = {"SetInt", 0},
	["$rimlightboost"] = {"SetFloat", 0},
	["$rimlightexponent"] = {"SetFloat", 0},
	["$rimmask"] = {"SetInt", 0},
	["$seamless_base"] = {"SetInt", 0},
	["$seamless_detail"] = {"SetInt", 0},
	["$seamless_scale"] = {"SetFloat", 0},
	["$selfillum_envmapmask_alpha"] = {"SetInt", 0},
	["$selfillumfresnel"] = {"SetInt", 0},
	["$selfillumfresnelminmaxexp"] = {"SetVector", Vector(0.000000, 0.000000, 0.000000)},
	["$selfillumtint"] = {"SetVector", Vector(1.000000, 1.000000, 1.000000)},
	["$separatedetailuvs"] = {"SetInt", 0},
	["$srgbtint"] = {"SetVector", Vector(1.000000, 1.000000, 1.000000)},
	["$time"] = {"SetInt", 0},
	["$treesway"] = {"SetInt", 0},
	["$treeswayfalloffexp"] = {"SetFloat", 1.5},
	["$treeswayheight"] = {"SetFloat", 1000},
	["$treeswayradius"] = {"SetFloat", 300},
	["$treeswayscrumblefalloffexp"] = {"SetFloat", 1},
	["$treeswayscrumblefrequency"] = {"SetFloat", 12},
	["$treeswayscrumblespeed"] = {"SetFloat", 5},
	["$treeswayscrumblestrength"] = {"SetFloat", 10},
	["$treeswayspeed"] = {"SetFloat", 1},
	["$treeswayspeedhighwindmultiplier"] = {"SetFloat", 2},
	["$treeswayspeedlerpend"] = {"SetFloat", 6},
	["$treeswayspeedlerpstart"] = {"SetFloat", 3},
	["$treeswaystartheight"] = {"SetFloat", 0.10000000149012},
	["$treeswaystartradius"] = {"SetFloat", 0.20000000298023},
	["$treeswaystatic"] = {"SetInt", 0},
	["$treeswaystrength"] = {"SetFloat", 10},
}

local material_bank = SF.ResourceHandler("render_usermaterials", "user materials", 40, "The max number of user created materials",
	function(shader, i)
		return CreateMaterial("sf_material_" .. shader .. "_" .. i, shader, {})
	end,
	function(shader, mat)
		if shader == "UnlitGeneric" then
			mat:SetInt("$flags",32816) --MATERIAL_VAR_VERTEXCOLOR + MATERIAL_VAR_VERTEXALPHA + MATERIAL_VAR_IGNOREZ
		end
	end,
	function(shader, material)
		-- This is necessary because when the material is going to be reused
		-- it will set some of its undefined parameters to old values (engine bug?)
		material:SetFloat("$alpha", 1)
		material:SetVector("$color", Vector(1, 1, 1))

		for k, v in pairs(default_values) do
			material[v[1]](material, k, v[2])
		end
	end
)

local blacklisted_keys = {
	["$flags2"] = true,
	["$frame"] = true,
	["$frame2"] = true,
}
local function checkkey(key)
	checkluatype(key, TYPE_STRING, 2)
	if blacklisted_keys[string.lower(key)] then SF.Throw("Blocked material key: "..key, 3) end
end

local function tex2str(t)
	for k, v in pairs(t)
	do
		if type(v) == "ITexture"
		then
			t[k] = v:GetName()
		end
	end

	return t
end

local USE_AWESOMIUM_HACK = BRANCH == "unknown" or BRANCH == "dev" or BRANCH == "prerelease"
local HttpTextureLoader = {}
local HttpTexture = {
	__index = {
		INIT=function(self, new) return new~=self.LOAD and new~=self.DESTROY end,
		LOAD=function(self, new) return new~=self.FETCH and new~=self.LAYOUT and new~=self.DESTROY end,
		FETCH=function(self, new) return new~=self.LOAD and new~=self.DESTROY end,
		LAYOUT=function(self, new) return new~=self.RENDER and new~=self.LAYOUT and new~=self.DESTROY end,
		RENDER=function(self, new) return new~=self.DESTROY end,
		DESTROY=function(self, new) return true end,

		badnewstate = function(self, new)
			if self.instance.error and new~=self.DESTROY then self:destroy() return true end
			if self:state(new) then return true end
			self.state = new
			return false
		end,

		load = function(self)
			if self:badnewstate(self.LOAD) then return end

			if USE_AWESOMIUM_HACK and not string.match(self.url, "^data:") then
				self:loadAwesomium()
				return
			end

			HttpTextureLoader.Panel:AddFunction("sf", "imageLoaded", function(w, h) timer.Simple(0, function() self:layout(w, h) end) end)
			HttpTextureLoader.Panel:AddFunction("sf", "imageErrored", function() timer.Simple(0, function() self:destroy() end) end)
			HttpTextureLoader.Panel:RunJavascript(
			[[img.removeAttribute("width");
			img.removeAttribute("height");
			img.style.left="0px";
			img.style.top="0px";
			img.src="]] .. string.JavascriptSafe(self.url) .. [[";]]..
			(BRANCH == "unknown" and "\nif(img.complete)renderImage();" or ""))
		end,

		loadAwesomium = function(self)
			if self:badnewstate(self.FETCH) then return end

			http.Fetch(self.url, function(body, _, headers, code)
				if code >= 300 then self:destroy() return end

				local content_type = headers["Content-Type"] or headers["content-type"]
				local data = util.Base64Encode(body, true)
				
				self.url = table.concat({"data:", content_type, ";base64,", data})

				self:load()
			end, function() self:destroy() end)
		end,

		layout = function(self, w, h)
			if self:badnewstate(self.LAYOUT) then return end

			if self.usedlayout then self:render() return end

			if self.callback then
				self.callback(w, h, function(x,y,w,h,pixelated)
					self:applyLayout(x,y,w,h,pixelated)
				end)
			end

			if not self.usedlayout then
				self.usedlayout = true
				self:render()
			end
		end,

		applyLayout = function(self,x,y,w,h,pixelated)
			if self.usedlayout then SF.Throw("You can only use layout once", 3) end
			checkluatype(x, TYPE_NUMBER, 2)
			checkluatype(y, TYPE_NUMBER, 2)
			checkluatype(w, TYPE_NUMBER, 2)
			checkluatype(h, TYPE_NUMBER, 2)
			if pixelated~=nil then checkluatype(pixelated, TYPE_BOOL, 2) end
			self.usedlayout = true
			HttpTextureLoader.Panel:RunJavascript([[
				img.style.left=']]..x..[[px';img.style.top=']]..y..[[px';img.width=]]..w..[[;img.height=]]..h..[[;img.style.imageRendering=']]..(pixelated and "pixelated" or "auto")..[[';
				renderImage();
			]])
		end,

		render = function(self)
			if self:badnewstate(self.RENDER) then return end
			local frame = 0
			hook.Add("PreRender","SF_HTMLPanelCopyTexture",function()
				HttpTextureLoader.Panel:UpdateHTMLTexture()
				-- Running UpdateHTMLTexture a few times seems to fix materials not rendering
				if frame<2 then frame = frame + 1 return end
				local mat = HttpTextureLoader.Panel:GetHTMLMaterial()
				if mat then
					render.PushRenderTarget(self.texture)
						render.Clear(0, 0, 0, 0, false, false)
						cam.Start2D()
						surface.SetMaterial(mat)
						surface.SetDrawColor(255, 255, 255)
						surface.DrawTexturedRect(0, 0, 1024, 1024)
						cam.End2D()
					render.PopRenderTarget()
				end
				hook.Remove("PreRender","SF_HTMLPanelCopyTexture")
				timer.Simple(0, function() self:destroy(true) end)
			end)
		end,
		
		destroy = function(self, success)
			if self:badnewstate(self.DESTROY) then return end
			if success then
				if self.donecallback then self.donecallback() end
			else
				if self.callback then self.callback() end
			end
			HttpTextureLoader.pop()
		end,
	},
	__call = function(t, instance, texture, url, callback, donecallback)
		return setmetatable({
			instance = instance,
			texture = texture,
			url = url,
			callback = callback,
			donecallback = donecallback,
			usedlayout = false,
			state = t.INIT,
		}, t)
	end
}
setmetatable(HttpTexture, HttpTexture)

HttpTextureLoader.Queue = {}

function HttpTextureLoader.initialize()
	local Panel = SF.URLTextureLoader
	if not Panel then
		Panel = vgui.Create("DHTML")
		Panel:SetSize(1024, 1024)
		Panel:SetMouseInputEnabled(false)
		Panel:SetHTML(
		[[<html style="overflow:hidden"><body><script>
		if (!requestAnimationFrame)
			var requestAnimationFrame = webkitRequestAnimationFrame;
		function renderImage(){
			requestAnimationFrame(function(){
				requestAnimationFrame(function(){
					document.body.offsetWidth
					requestAnimationFrame(function(){
						sf.imageLoaded(img.width, img.height);
					});
				});
			});
		}
		var img = new Image();
		img.style.position="absolute";
		img.onload = renderImage;
		img.onerror = function (){sf.imageErrored();}
		document.body.appendChild(img);
		</script></body></html>]])
		Panel:Hide()
		SF.URLTextureLoader = Panel
	end
	HttpTextureLoader.Panel = Panel
end

function HttpTextureLoader.request_preInit(request)
	HttpTextureLoader.initialize()
	HttpTextureLoader.request = HttpTextureLoader.request_postInit
	HttpTextureLoader.Queue[1] = request
	HttpTextureLoader.Panel.OnFinishLoadingDocument = HttpTextureLoader.nextRequest
end
HttpTextureLoader.request = HttpTextureLoader.request_preInit

function HttpTextureLoader.request_postInit(request)
	local len = #HttpTextureLoader.Queue
	HttpTextureLoader.Queue[len + 1] = request
	if len==0 then timer.Simple(0, HttpTextureLoader.nextRequest) end
end

function HttpTextureLoader.nextRequest()
	local request = HttpTextureLoader.Queue[1]
	request:load()
	timer.Create("SF_URLTextureTimeout", 10, 1, function() request:destroy() end)
end

function HttpTextureLoader.pop()
	table.remove(HttpTextureLoader.Queue, 1)
	if #HttpTextureLoader.Queue > 0 then
		HttpTextureLoader.nextRequest()
	else
		timer.Remove("SF_URLTextureTimeout")
	end
end

--- `material` library is allows creating material objects which are used for controlling shaders in rendering.
-- @name material
-- @class library
-- @libtbl material_library
SF.RegisterLibrary("material")

--- The `Material` type is used to control shaders in rendering.
--- For a list of shader parameters, see https://developer.valvesoftware.com/wiki/Category:List_of_Shader_Parameters
--- For a list of $flags and $flags2, see https://developer.valvesoftware.com/wiki/Material_Flags
-- @name Material
-- @class type
-- @libtbl material_methods
SF.RegisterType("Material", true, false, nil, "LockedMaterial")
SF.RegisterType("LockedMaterial", true, false) --Material that can't be modified


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end


local material_library = instance.Libraries.material
local material_methods, material_meta, wrap, unwrap = instance.Types.Material.Methods, instance.Types.Material, instance.Types.Material.Wrap, instance.Types.Material.Unwrap
local lmaterial_methods, lmaterial_meta, lwrap, lunwrap = instance.Types.LockedMaterial.Methods, instance.Types.LockedMaterial, instance.Types.LockedMaterial.Wrap, instance.Types.LockedMaterial.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local matrix_meta, mwrap, munwrap = instance.Types.VMatrix, instance.Types.VMatrix.Wrap, instance.Types.VMatrix.Unwrap

local usermaterials = {}
instance:AddHook("deinitialize", function()
	for k in pairs(usermaterials) do
		material_bank:free(instance.player, k, k:GetShader())
	end
end)

--- Loads a .vmt material or existing material. Throws an error if the material fails to load
--- Existing created materials can be loaded with ! prepended to the name
--- Can't be modified
-- @param string path The path of the material (don't include .vmt in the path)
-- @return Material The material object. Can't be modified.
function material_library.load(path)
	checkluatype(path, TYPE_STRING)
	if string.GetExtensionFromFilename(path) then SF.Throw("The path cannot have an extension", 2) end
	checkpermission(instance, path, "material.load")
	local m = SF.CheckMaterial(path)
	if not m or m:IsError() then SF.Throw("This material doesn't exist or is blacklisted", 2) end
	return lwrap(m)
end

--- Gets a texture from a material
-- @param string path The path of the material (don't include .vmt in the path)
-- @param string texture The texture key to get
-- @return string? The texture's name or nil if texture key isn't found
function material_library.getTexture(path, texture)
	checkluatype(path, TYPE_STRING)
	checkluatype(texture, TYPE_STRING)
	local tex = Material(path):GetTexture(texture)
	if tex then return tex:GetName() end
end

--- Returns a table of keyvalues from a material
-- @param string path The path of the material (don't include .vmt in the path)
-- @return table The table of keyvalues
function material_library.getKeyValues(path)
	checkluatype(path, TYPE_STRING)
	return instance.Sanitize(tex2str(Material(path):GetKeyValues()))
end

--- Returns a material's engine name
-- @param string path The path of the material (don't include .vmt in the path)
-- @return string The name of a material. If this material is user created, add ! to the beginning of this to use it with entity.setMaterial
function material_library.getName(path)
	checkluatype(path, TYPE_STRING)
	return Material(path):GetName()
end

--- Returns the shader name of a material
-- @param string path The path of the material (don't include .vmt in the path)
-- @return string The shader name of the material
function material_library.getShader(path)
	checkluatype(path, TYPE_STRING)
	return Material(path):GetShader()
end

--- Returns the width of the member texture set for $basetexture of a material
-- @param string path The path of the material (don't include .vmt in the path)
-- @return number The basetexture's width
function material_library.getWidth(path)
	checkluatype(path, TYPE_STRING)
	return Material(path):Width()
end

--- Returns the height of the member texture set for $basetexture of a material
-- @param string path The path of the material (don't include .vmt in the path)
-- @return number The basetexture's height
function material_library.getHeight(path)
	checkluatype(path, TYPE_STRING)
	return Material(path):Height()
end

--- Returns a color pixel value of the $basetexture of a .png or .jpg material.
-- @param string path The path of the material (don't include .vmt in the path)
-- @param number x The x coordinate of the pixel
-- @param number y The y coordinate of the pixel
-- @return Color The color value
function material_library.getColor(path, x, y)
	checkluatype(path, TYPE_STRING)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	return cwrap(Material(path):GetColor(x, y))
end

--- Returns a float keyvalue of a material
-- @param string path The path of the material (don't include .vmt in the path)
-- @param string key The key to get the float from
-- @return number? The float value or nil if it doesn't exist
function material_library.getFloat(path, key)
	checkluatype(path, TYPE_STRING)
	checkluatype(key, TYPE_STRING)
	return Material(path):GetFloat(key)
end

--- Returns an int keyvalue of a material
-- @param string path The path of the material (don't include .vmt in the path)
-- @param string key The key to get the int from
-- @return number? The int value or nil if it doesn't exist
function material_library.getInt(path, key)
	checkluatype(path, TYPE_STRING)
	checkluatype(key, TYPE_STRING)
	return Material(path):GetInt(key)
end

--- Returns a matrix keyvalue of a material
-- @param string path The path of the material (don't include .vmt in the path)
-- @param string key The key to get the matrix from
-- @return VMatrix? The matrix value or nil if it doesn't exist
function material_library.getMatrix(path, key)
	checkluatype(path, TYPE_STRING)
	checkluatype(key, TYPE_STRING)
	return mwrap(Material(path):GetMatrix(key))
end

--- Returns a string keyvalue
-- @param string path The path of the material (don't include .vmt in the path)
-- @param string key The key to get the string from
-- @return string? The string value or nil if it doesn't exist
function material_library.getString(path, key)
	checkluatype(path, TYPE_STRING)
	checkluatype(key, TYPE_STRING)
	return Material(path):GetString(key)
end

--- Returns a vector keyvalue of a material
-- @param string path The path of the material (don't include .vmt in the path)
-- @param string key The key to get the vector from
-- @return Vector? The vector value or nil if it doesn't exist
function material_library.getVector(path, key)
	checkluatype(path, TYPE_STRING)
	checkluatype(key, TYPE_STRING)
	return vwrap(Material(path):GetVector(key))
end

--- Returns a linear color-corrected vector keyvalue of a material
-- @param string path The path of the material (don't include .vmt in the path)
-- @param string key The key to get the vector from
-- @return Vector? The vector value or nil if it doesn't exist
function material_library.getVectorLinear(path, key)
	checkluatype(path, TYPE_STRING)
	checkluatype(key, TYPE_STRING)
	return vwrap(Material(path):GetVectorLinear(key))
end

--- Creates a new blank material
-- @param string shader The shader of the material. Must be one of
--- UnlitGeneric
--- VertexLitGeneric
--- Refract_DX90
--- Water_DX90
--- Sky_DX9
--- gmodscreenspace
--- Modulate_DX9
-- @return Material The Material created.
function material_library.create(shader)
	checkluatype(shader, TYPE_STRING)
	checkpermission(instance, nil, "material.create")
	if not allowed_shaders[shader] then SF.Throw("Tried to use unsupported shader: "..shader, 2) end
	local m = material_bank:use(instance.player, shader)
	usermaterials[m] = true
	return wrap(m)
end

local image_params = {["nocull"] = true,["alphatest"] = true,["mips"] = true,["noclamp"] = true,["smooth"] = true}
--- Creates a .jpg or .png material from file
--- Can't be modified
-- @param string path The path to the image file, must be a jpg or png image
-- @param string params The shader parameters to apply to the material. See https://wiki.facepunch.com/gmod/Material_Parameters
-- @return Material The Material created.
function material_library.createFromImage(path, params)
	checkluatype(path, TYPE_STRING)
	checkluatype(params, TYPE_STRING)

	path = SF.NormalizePath(path)
	local ext = string.GetExtensionFromFilename(path)
	if ext ~= "jpg" and ext ~= "png" then SF.Throw("Expected a .jpg or .png file", 2) end

	if not (file.Exists("materials/" .. path, "GAME") or (string.sub(path,1,5)=="data/" and file.Exists(path,"GAME"))) then
		SF.Throw("The material path is invalid", 2)
	end

	local paramlist = {}
	for s in string.gmatch(string.lower(params), "%S+") do
		if not image_params[s] then SF.Throw("Invalid parameter: "..s, 2) end
		paramlist[#paramlist + 1] = s
	end
	checkpermission(instance, path, "material.imagecreate")
	local m = Material(path, table.concat(paramlist, " "))
	if m:IsError() then SF.Throw("The material path is invalid", 2) end
	return lwrap(m)
end

--- Frees a user created material allowing you to create others
function material_methods:destroy()

	local m = unwrap(self)
	if not m then SF.Throw("The material is already destroyed?", 2) end

	local name = m:GetName()
	local rt = instance.data.render.rendertargets[name]
	if rt then
		instance.env.render.destroyRenderTarget(name)
	end

	local sensitive2sf, sf2sensitive = material_meta.sensitive2sf, material_meta.sf2sensitive
	sensitive2sf[m] = nil
	sf2sensitive[self] = nil
	dsetmeta(self, nil)

	usermaterials[m] = nil
	material_bank:free(instance.player, m, m:GetShader())
end
function lmaterial_methods:destroy()
end

--- Returns the material's engine name
-- @name material_methods.getName
-- @return string The name of the material. If this material is user created, add ! to the beginning of this to use it with entity.setMaterial
function lmaterial_methods:getName()
	return lunwrap(self):GetName()
end

--- Returns the shader name of the material
-- @name material_methods.getShader
-- @return string The shader name of the material
function lmaterial_methods:getShader()
	return lunwrap(self):GetShader()
end

--- Gets the base texture set to the material's width
-- @name material_methods.getWidth
-- @return number The basetexture's width
function lmaterial_methods:getWidth()
	return lunwrap(self):Width()
end

--- Gets the base texture set to the material's height
-- @name material_methods.getHeight
-- @return number The basetexture's height
function lmaterial_methods:getHeight()
	return lunwrap(self):Height()
end

--- Returns a color pixel value of the $basetexture of a .png or .jpg material.
-- @name material_methods.getColor
-- @param number x The x coordinate of the pixel
-- @param number y The y coordinate of the pixel
-- @return Color The color value
function lmaterial_methods:getColor(x, y)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	return cwrap(lunwrap(self):GetColor(x, y))
end

--- Returns a float keyvalue
-- @name material_methods.getFloat
-- @param string key The key to get the float from
-- @return number? The float value or nil if it doesn't exist
function lmaterial_methods:getFloat(key)
	checkluatype(key, TYPE_STRING)
	return lunwrap(self):GetFloat(key)
end

--- Returns an int keyvalue
-- @name material_methods.getInt
-- @param string key The key to get the int from
-- @return number? The int value or nil if it doesn't exist
function lmaterial_methods:getInt(key)
	checkluatype(key, TYPE_STRING)
	return lunwrap(self):GetInt(key)
end

--- Returns a table of material keyvalues
-- @name material_methods.getKeyValues
-- @return table The table of keyvalues
function lmaterial_methods:getKeyValues()
	return instance.Sanitize(tex2str(lunwrap(self):GetKeyValues()))
end

--- Returns a matrix keyvalue
-- @name material_methods.getMatrix
-- @param string key The key to get the matrix from
-- @return VMatrix? The matrix value or nil if it doesn't exist
function lmaterial_methods:getMatrix(key)
	checkluatype(key, TYPE_STRING)
	return mwrap(lunwrap(self):GetMatrix(key))
end

--- Returns a string keyvalue
-- @name material_methods.getString
-- @param string key The key to get the string from
-- @return string? The string value or nil if it doesn't exist
function lmaterial_methods:getString(key)
	checkluatype(key, TYPE_STRING)
	return lunwrap(self):GetString(key)
end

--- Returns a texture id keyvalue
-- @name material_methods.getTexture
-- @param string key The key to get the texture from
-- @return string? The string id of the texture or nil if it doesn't exist
function lmaterial_methods:getTexture(key)
	checkluatype(key, TYPE_STRING)
	local tex = lunwrap(self):GetTexture(key)
	if tex then return tex:GetName() end
end

--- Returns a vector keyvalue
-- @name material_methods.getVector
-- @param string key The key to get the vector from
-- @return Vector? The vector value or nil if it doesn't exist
function lmaterial_methods:getVector(key)
	checkluatype(key, TYPE_STRING)
	return vwrap(lunwrap(self):GetVector(key))
end

--- Returns a linear color-corrected vector keyvalue
-- @name material_methods.getVectorLinear
-- @param string key The key to get the vector from
-- @return Vector? The vector value or nil if it doesn't exist
function lmaterial_methods:getVectorLinear(key)
	checkluatype(key, TYPE_STRING)
	return vwrap(lunwrap(self):GetVectorLinear(key))
end

--- Refreshes the material. Sometimes needed for certain parameters to update
function material_methods:recompute()
	unwrap(self):Recompute()
end

--- Sets a float keyvalue
-- @param string key The key name to set
-- @param number v The value to set it to
function material_methods:setFloat(key, v)
	checkkey(key)
	checkluatype(v, TYPE_NUMBER)
	unwrap(self):SetFloat(key, v)
end

--- Sets an int keyvalue
-- @param string key The key name to set
-- @param number v The value to set it to
function material_methods:setInt(key, v)
	checkkey(key)
	checkluatype(v, TYPE_NUMBER)
	unwrap(self):SetInt(key, v)
end

--- Sets a matrix keyvalue
-- @param string key The key name to set
-- @param VMatrix v The value to set it to
function material_methods:setMatrix(key, v)
	checkkey(key)
	unwrap(self):SetMatrix(key, munwrap(v))
end

--- Sets a string keyvalue
-- @param string key The key name to set
-- @param string v The value to set it to
function material_methods:setString(key, v)
	checkkey(key)
	checkluatype(v, TYPE_STRING)
	unwrap(self):SetString(key, v)
end

--- Sets a texture keyvalue
-- @param string key The key name to set. $basetexture is the key name for most purposes.
-- @param string v The texture name to set it to.
function material_methods:setTexture(key, v)
	checkkey(key)
	checkluatype(v, TYPE_STRING)

	unwrap(self):SetTexture(key, v)
end

--- Loads an online image or base64 data to the specified texture key
-- If the texture in key is not set to a rendertarget, a rendertarget will be created and used.
-- @param string key The key name to set. $basetexture is the key name for most purposes.
-- @param string url The url or base64 data
-- @param function? cb An optional callback called when image is loaded. Passes nil if it fails or Passes the material, url, width, height, and layout function which can be called with x, y, w, h, pixelated to reposition the image in the texture. Setting the optional 'pixelated' argument to True tells the image to use nearest-neighbor interpolation
-- @param function? done An optional callback called when the image is done loading. Passes the material, url
function material_methods:setTextureURL(key, url, cb, done)
	checkkey(key)
	checkluatype(url, TYPE_STRING)
	if cb ~= nil then checkluatype(cb, TYPE_FUNCTION) end
	if done ~= nil then checkluatype(done, TYPE_FUNCTION) end

	local m = unwrap(self)
	local texture = m:GetTexture(key)
	if not (texture and instance.data.render.validrendertargets[texture:GetName()]) then
		local name = self:getName() .. key
		instance.env.render.createRenderTarget(name)
		self:setTextureRenderTarget(key, name)
		texture = instance.data.render.rendertargets[name]
	end

	if #url > cv_max_data_material_size:GetInt() then
		SF.Throw("Texture URL/Data too long!", 2)
	end

	local _1, _2, prefix = string.find(url, "^(%w-):")
	if prefix=="http" or prefix=="https" then
		checkpermission (instance, url, "material.urlcreate")
		if #url>2000 then SF.Throw("URL is too long!", 2) end
		url = string.gsub(url, "[^%w _~%.%-/:=%?&]", function(str)
			return string.format("%%%02X", string.byte(str))
		end)
		SF.HTTPNotify(instance.player, url)
	else
		checkpermission (instance, nil, "material.datacreate")
		-- Capture 'data' so that a huge return isn't generated
		if not string.match(url, "^(data):image/[%w%+]+;base64,[%w/%+%=]+$") then
			SF.Throw("Texture data isn't proper base64 encoded image.", 2)
		end
	end

	local callback, donecallback
	if cb then
		callback = function(w, h, layout)
			if w then instance:runFunction(cb, self, url, w, h, layout) else instance:runFunction(cb) end
		end
	end
	if done then
		donecallback = function()
			instance:runFunction(done, self, url)
		end
	end
	
	HttpTextureLoader.request(HttpTexture(instance, texture, url, callback, donecallback))
end

--- Sets a rendertarget texture to the specified texture key
-- @param string key The key name to set. $basetexture is the key name for most purposes.
-- @param string name The name of the rendertarget
function material_methods:setTextureRenderTarget(key, name)
	checkkey(key)
	checkluatype(name, TYPE_STRING)

	local rt = instance.data.render.rendertargets[name]
	if not rt then SF.Throw("Invalid rendertarget: "..name, 2) end

	local m = unwrap(self)
	m:SetTexture(key, rt)
end

--- Sets a keyvalue to be undefined
-- @param string key The key name to set
function material_methods:setUndefined(key)
	checkkey(key)
	unwrap(self):SetUndefined(key)
end

--- Sets a vector keyvalue
-- @param string key The key name to set
-- @param Vector v The value to set it to
function material_methods:setVector(key, v)
	checkkey(key)
	unwrap(self):SetVector(key, vunwrap(v))
end

end
