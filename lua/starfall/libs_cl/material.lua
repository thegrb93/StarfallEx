SF.Materials = {}

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("material.load", "Load material", "Allows users to load a vmt material.", { client = {} })
	P.registerPrivilege("material.create", "Create material", "Allows users to create a new custom material.", { client = {} })
	P.registerPrivilege("material.imagecreate", "Create material from image", "Allows users to create a new material from an image file.", { client = {} })
	P.registerPrivilege("material.urlcreate", "Create material from online image", "Allows users to create a new material from an online image.", { client = {}, urlwhitelist = {} })
	P.registerPrivilege("material.datacreate", "Create material from base64 image data", "Allows users to create a new material from base64 image data.", { client = {} })
end

local cv_max_materials = CreateConVar("sf_render_maxusermaterials", "40", { FCVAR_ARCHIVE })
local cv_max_data_material_size = CreateConVar("sf_render_maxdatamaterialsize", "1000000", { FCVAR_ARCHIVE })

--- The `Material` type is used to control shaders in rendering.
-- @client
local material_methods, material_metamethods = SF.RegisterType("Material")
local lmaterial_methods, lmaterial_metamethods = SF.RegisterType("LockedMaterial") --Material that can't be modified
local wrap, unwrap = SF.CreateWrapper(material_metamethods, true, false)
local lwrap, lunwrap = SF.CreateWrapper(lmaterial_metamethods, true, false, nil, material_metamethods)

local vector_meta, col_meta, matrix_meta
local vwrap, cwrap, mwrap, vunwrap, cunwrap, munwrap

local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

--- `material` library is allows creating material objects which are used for controlling shaders in rendering.
-- @client
local material_library = SF.RegisterLibrary("material")

SF.Materials.Wrap = wrap
SF.Materials.Unwrap = unwrap
SF.Materials.Methods = material_methods
SF.Materials.Metatable = material_metamethods
SF.Materials.LMetatable = lmaterial_metamethods

SF.AddHook("postload", function()
	vector_meta = SF.Vectors.Metatable
	col_meta = SF.Color.Metatable
	matrix_meta = SF.VMatrix.Metatable

	vwrap = SF.Vectors.Wrap
	cwrap = SF.Color.Wrap
	mwrap = SF.VMatrix.Wrap
	vunwrap = SF.Vectors.Unwrap
	cunwrap = SF.Color.Unwrap
	munwrap = SF.VMatrix.Unwrap
end)

local allowed_shaders = {
	UnlitGeneric = true,
	VertexLitGeneric = true
}
local material_bank = SF.ResourceHandler(cv_max_materials:GetInt(),
	function(shader, i)
		return CreateMaterial("SF_TEXTURE_" .. i, shader, {})
	end,
	FindMetaTable("IMaterial").GetShader
)

cvars.AddChangeCallback( "sf_render_maxusermaterials", function()
	material_bank.max = cv_max_materials:GetInt()
end )

-- Register functions to be called when the chip is initialised and deinitialised
SF.AddHook("initialize", function (inst)
	inst.data.material = {
		usermaterials = {}
	}
end)

SF.AddHook("deinitialize", function (inst)
	for k, v in pairs(inst.data.material.usermaterials) do
		material_bank:free(inst.player, v)
		inst.data.material.usermaterials[k] = nil
	end
end)


--- Loads a .vmt material or existing material. Throws an error if the material fails to load
--- Existing created materials can be loaded with ! prepended to the name
-- @param path The path of the material (don't include .vmt in the path)
-- @return The material object. Can't be modified.
function material_library.load(path)
	checkluatype(path, TYPE_STRING)
	if string.GetExtensionFromFilename(path) then SF.Throw("The path cannot have an extension", 2) end
	checkpermission(SF.instance, path, "material.load")
	local m = SF.CheckMaterial(path)
	if not m then SF.Throw("The material is blacklisted", 2) end
	if m:IsError() then SF.Throw("The material path is invalid", 2) end
	return lwrap(m)
end

--- Creates a new blank material
-- @param name The name of the material
-- @param shader The shader of the material. (UnlitGeneric or VertexLitGeneric)
-- @param keyvalues A Keyvalue table to initialize the material with.
function material_library.create(name, shader, keyvalues)
	checkluatype(name, TYPE_STRING)
	checkluatype(shader, TYPE_STRING)
	local instance = SF.instance
	checkpermission(instance, nil, "material.create")
	if not allowed_shaders[shader] then SF.Throw("Tried to use unsupported shader: "..shader, 2) end
	local m = material_bank:use(instance.player, shader)
	if not m then SF.Throw("Exceeded the maximum user materials", 2) end
	return wrap(m)
end

--- Gets a previously created material
-- @param name The name given to the material
function material_library.get(name)
	checkluatype(name, TYPE_STRING)
	return wrap(SF.instance.data.material.usermaterials[name])
end

local image_params = {["vertexlitgeneric"] = true,["nocull"] = true,["alphatest"] = true,["mips"] = true,["noclamp"] = true,["smooth"] = true}
--- Creates a .jpg or .png material from file
-- @param path The path to the image file
-- @param params The shader parameters to apply to the material. See http://wiki.garrysmod.com/page/Material_Parameters
function material_library.createFromImage(path, params)
	checkluatype(path, TYPE_STRING)
	checkluatype(params, TYPE_STRING)
	local ext = string.GetExtensionFromFilename(path)
	if ext ~= "jpg" and ext ~= "png" then SF.Throw("Expected a .jpg or .png file", 2) end
	local paramlist = {}
	for s in string.gmatch(string.lower(params), "%S+") do
		if not image_params[s] then SF.Throw("Invalid parameter: "..s, 2) end
		paramlist[#paramlist + 1] = s
	end
	checkpermission(SF.instance, path, "material.imagecreate")
	local m = Material(path, table.concat(paramlist, " "))
	if m:IsError() then SF.Throw("The material path is invalid", 2) end
	return wrap(m)
end

local LoadingTextureQueue = {}
local Panel
local function NextInTextureQueue()
	local requestTbl = LoadingTextureQueue[1]
	if requestTbl then
		if requestTbl.Instance.error then
			table.remove(LoadingTextureQueue, 1)
			NextInTextureQueue()
			return
		end
		if Panel then
			Panel:RunJavascript("img.src = \""..requestTbl.Url.."\";")
		else
			Panel = vgui.Create("DHTML")
			Panel:SetSize(1024, 1024)
			Panel:SetAlpha(0)
			Panel:SetMouseInputEnabled(false)
			Panel:AddFunction("sf", "imageLoaded", function(w,h)
				timer.Simple(0.2, function()
					if not requestTbl.Instance.error then
						local tex = Panel:GetHTMLMaterial():GetTexture("$basetexture")
						requestTbl.Material:SetTexture("$basetexture", tex)
						if requestTbl.cb then
							requestTbl.Instance:runFunction(requestTbl.cb, requestTbl.Tbl, requestTbl.Url)
						end
					end
					table.remove(LoadingTextureQueue, 1)
					NextInTextureQueue()
				end)
			end)
			Panel:SetHTML([[<html style="overflow:hidden"><head><script>
var img = new Image();
img.onload = function (){
	sf.imageLoaded(img.width, img.height);
}
img.src = "]]..requestTbl.Url..[[";
</script></head><body></body></html>]])
		end
		timer.Create("SF_URLTextureTimeout", 10, 1, function()
			table.remove(LoadingTextureQueue, 1)
			NextInTextureQueue()
		end)
	elseif Panel then
		Panel:Remove()
		Panel = nil
	end
end

--- Creates a material from a url
-- @param name The name of the material
-- @param callback The function called when the material finishes loading.
local function OnlineTexture(mat, umat, url, prefix, callback)
	local instance = SF.instance

	if #url > cv_max_data_material_size:GetInt() then
		SF.Throw("Texture URL/Data too long!", 3)
	end

	if prefix=="http" or prefix=="https" then
		checkpermission (instance, url, "material.urlcreate")
		if #url>2000 then SF.Throw("URL is too long!", 3) end
		url = string.gsub(url, "[^%w _~%.%-/:]", function(str)
			return string.format("%%%02X", string.byte(str))
		end)
		SF.HTTPNotify(instance.player, url)
	else
		checkpermission (instance, nil, "material.datacreate")
		url = string.match(url, "data:image/[%w%+]+;base64,[%w/%+%=]+") -- No $ at end etc so there can be cariage return etc, we'll skip that part anyway
		if not url then
			SF.Throw("Texture data isnt proper base64 encoded image.", 3)
		end
	end

	-- if alignment then
		-- checkluatype (alignment, TYPE_STRING)
		-- local args = string.Split(alignment, " ")
		-- local validargs = { ["left"] = true, ["center"] = true, ["right"] = true, ["top"] = true, ["bottom"] = true }
		-- if #args ~= 1 and #args ~= 2 then SF.Throw("Invalid urltexture alignment given.") end
		-- for i = 1, #args do
			-- if not validargs[args[i]] then SF.Throw("Invalid urltexture alignment given.") end
		-- end
	-- else
		-- alignment = "center"
	-- end

	local inqueue = #LoadingTextureQueue
	LoadingTextureQueue[inqueue + 1] = { Instance = instance, Tbl = mat, Material = umat, Url = url, Alignment = alignment, cb = cb }
	if inqueue == 0 then timer.Simple(0, NextInTextureQueue) end
end

--- Returns the material's engine name
-- @return The name of the material. If this material is user created, add ! to the beginning of this to use it with entity.setMaterial
function material_methods:getName()
	checktype(self, material_metamethods)
	return unwrap(self):GetName()
end
function lmaterial_methods:getName()
	checktype(self, lmaterial_metamethods)
	return lunwrap(self):GetName()
end

--- Returns the shader name of the material
-- @return The shader name of the material
function material_methods:getShader()
	checktype(self, material_metamethods)
	return unwrap(self):GetShader()
end
function lmaterial_methods:getShader()
	checktype(self, lmaterial_metamethods)
	return lunwrap(self):GetShader()
end

--- Gets the base texture set to the material's width
-- @return The basetexture's width
function material_methods:getWidth()
	checktype(self, material_metamethods)
	return unwrap(self):Width()
end
function lmaterial_methods:getWidth()
	checktype(self, lmaterial_metamethods)
	return lunwrap(self):Width()
end

--- Gets the base texture set to the material's height
-- @return The basetexture's height
function material_methods:getHeight()
	checktype(self, material_metamethods)
	return unwrap(self):Height()
end
function lmaterial_methods:getHeight()
	checktype(self, lmaterial_metamethods)
	return lunwrap(self):Height()
end

--- Returns a color pixel value of the $basetexture a .png or .jpg material.
-- @param x The x coordinate of the pixel
-- @param y The y coordinate of the pixel
-- @return The color value
function material_methods:getColor(x, y)
	checktype(self, material_metamethods)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	return cwrap(unwrap(self):GetColor(x, y))
end
function lmaterial_methods:getColor(x, y)
	checktype(self, lmaterial_metamethods)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	return cwrap(lunwrap(self):GetColor(x, y))
end

--- Returns a float keyvalue
-- @param key The key to get the float from
-- @return The float value or nil if it doesn't exist
function material_methods:getFloat(key)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	return unwrap(self):GetFloat(key)
end
function lmaterial_methods:getFloat(key)
	checktype(self, lmaterial_metamethods)
	checkluatype(key, TYPE_STRING)
	return lunwrap(self):GetFloat(key)
end

--- Returns an int keyvalue
-- @param key The key to get the int from
-- @return The int value or nil if it doesn't exist
function material_methods:getInt(key)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	return unwrap(self):GetInt(key)
end
function lmaterial_methods:getInt(key)
	checktype(self, lmaterial_metamethods)
	checkluatype(key, TYPE_STRING)
	return lunwrap(self):GetInt(key)
end

--- Returns a table of material keyvalues
-- @return The table of keyvalues
function material_methods:getKeyValues()
	checktype(self, material_metamethods)
	return SF.Sanitize(unwrap(self):GetKeyValues())
end
function lmaterial_methods:getKeyValues()
	checktype(self, lmaterial_metamethods)
	return SF.Sanitize(lunwrap(self):GetKeyValues())
end

--- Returns a matrix keyvalue
-- @param key The key to get the matrix from
-- @return The matrix value or nil if it doesn't exist
function material_methods:getMatrix(key)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	return mwrap(unwrap(self):GetMatrix(key))
end
function lmaterial_methods:getMatrix(key)
	checktype(self, lmaterial_metamethods)
	checkluatype(key, TYPE_STRING)
	return mwrap(lunwrap(self):GetMatrix(key))
end

--- Returns a string keyvalue
-- @param key The key to get the string from
-- @return The string value or nil if it doesn't exist
function material_methods:getString(key)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	return unwrap(self):GetString(key)
end
function lmaterial_methods:getString(key)
	checktype(self, lmaterial_metamethods)
	checkluatype(key, TYPE_STRING)
	return lunwrap(self):GetString(key)
end

--- Returns a texture id keyvalue
-- @param key The key to get the texture from
-- @return The string id of the texture or nil if it doesn't exist
function material_methods:getTexture(key)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	local tex = unwrap(self):GetTexture(key)
	if tex then return tex:GetName() end 
end
function lmaterial_methods:getTexture(key)
	checktype(self, lmaterial_metamethods)
	checkluatype(key, TYPE_STRING)
	local tex = lunwrap(self):GetTexture(key)
	if tex then return tex:GetName() end 
end

--- Returns a vector keyvalue
-- @param key The key to get the vector from
-- @return The string id of the texture
function material_methods:getVector(key)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	return vwrap(unwrap(self):GetVector(key))
end
function lmaterial_methods:getVector(key)
	checktype(self, lmaterial_metamethods)
	checkluatype(key, TYPE_STRING)
	return vwrap(lunwrap(self):GetVector(key))
end

--- Returns a linear color-corrected vector keyvalue
-- @param key The key to get the vector from
-- @return The vector value or nil if it doesn't exist
function material_methods:getVectorLinear(key)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	return vwrap(unwrap(self):GetVectorLinear(key))
end
function lmaterial_methods:getVectorLinear(key)
	checktype(self, lmaterial_metamethods)
	checkluatype(key, TYPE_STRING)
	return vwrap(lunwrap(self):GetVectorLinear(key))
end

-- function material_methods:isError()
-- end

-- function material_methods:recompute()
-- end

--- Sets a float keyvalue
-- @param key The key name to set
-- @param v The value to set it to
function material_methods:setFloat(key, v)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	checkluatype(v, TYPE_NUMBER)
	unwrap(self):SetFloat(key, v)
end

--- Sets an int keyvalue
-- @param key The key name to set
-- @param v The value to set it to
function material_methods:setInt(key, v)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	checkluatype(v, TYPE_NUMBER)
	unwrap(self):SetInt(key, v)
end

--- Sets a matrix keyvalue
-- @param key The key name to set
-- @param v The value to set it to
function material_methods:setMatrix(key, v)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	checktype(v, matrix_meta)
	unwrap(self):SetMatrix(key, munwrap(v))
end

--- Sets a string keyvalue
-- @param key The key name to set
-- @param v The value to set it to
function material_methods:setString(key, v)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	checkluatype(v, TYPE_STRING)
	unwrap(self):SetString(key, v)
end

--- Sets a texture keyvalue
-- @param key The key name to set. $basetexture is the key name for most purposes.
-- @param v The texture name to set it to
function material_methods:setTexture(key, v)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	checkluatype(v, TYPE_STRING)
	
	local m = unwrap(self)
	
	local _1, _2, prefix = string.find(v, "^(%w-):")
	if prefix=="http" or prefix=="https" or prefix == "data" then
		OnlineTexture(self, m, v, prefix, cb, alignment, skip_hack)
	else
		m:SetTexture(key, v)
	end
end

--- Sets a keyvalue to be undefined
-- @param key The key name to set
function material_methods:setUndefined(key)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	unwrap(self):SetUndefined(key)
end

--- Sets a vector keyvalue
-- @param key The key name to set
-- @param v The value to set it to
function material_methods:setVector(key, v)
	checktype(self, material_metamethods)
	checkluatype(key, TYPE_STRING)
	checktype(v, vec_meta)
	unwrap(self):SetVector(key, vunwrap(v))
end


