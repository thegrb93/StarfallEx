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
local lwrap, lunwrap = SF.CreateWrapper(lmaterial_metamethods, true, false, material_metamethods)
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
-- @param shader The shader of the material
-- @param keyvalues A Keyvalue table to initialize the material with.
function material_library.create(name)
	checkpermission(SF.instance, path, "material.create")
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

local LoadingURLQueue = {}
--- Creates a material from a url
-- @param name The name of the material
-- @param callback The function called when the material finishes loading.
function material_library.createFromURL(url, callback)
	checkpermission(SF.instance, url, "material.urlcreate")
	checkpermission(SF.instance, url, "material.datacreate")


	if #tx > cv_max_data_material_size:GetInt() then
		SF.Throw("Texture URL/Data too long!", 2)
	end

	if prefix=="http" or prefix=="https" then
		checkpermission (instance, tx, "render.urlmaterial")
		if #tx>2000 then SF.Throw("URL is too long!", 2) end
		tx = string.gsub(tx, "[^%w _~%.%-/:]", function(str)
			return string.format("%%%02X", string.byte(str))
		end)
		SF.HTTPNotify(instance.player, tx)
	else
		checkpermission (instance, nil, "render.datamaterial")
		tx = string.match(tx, "data:image/[%w%+]+;base64,[%w/%+%=]+") -- No $ at end etc so there can be cariage return etc, we'll skip that part anyway
		if not tx then --It's not valid
			SF.Throw("Texture data isnt proper base64 encoded image.", 2)
		end
	end

	if alignment then
		checkluatype (alignment, TYPE_STRING)
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

	local urlmaterial = sfCreateMaterial("SF_TEXTURE_" .. util.CRC(url .. SysTime()), skip_hack)

	---URL Textures
	local Panel
	local function NextInQueue()

		local requestTbl = LoadingURLQueue[1]
		if requestTbl then
			if requestTbl.Instance.error then
				table.remove(LoadingURLQueue, 1)
				NextInQueue()
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
					-- timer.Simple(0.2, function()
						local tex = Panel:GetHTMLMaterial():GetTexture("$basetexture")
						requestTbl.Material:SetTexture("$basetexture", tex)
						if requestTbl.cb then requestTbl.cb() end
						table.remove(LoadingURLQueue, 1)
						timer.Simple(0, NextInQueue)
					-- end)
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
				table.remove(LoadingURLQueue, 1)
				NextInQueue()
			end)
		elseif Panel then
			Panel:Remove()
			Panel = nil
		end
	end

	local inqueue = #LoadingURLQueue
	LoadingURLQueue[inqueue + 1] = { Instance = SF.instance, Material = urlmaterial, Url = url, Alignment = alignment, cb = cb }
	if inqueue == 0 then downloadFinished() end

	return urlmaterial
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

--- Returns a color pixel value of a .png or .jpg material.
-- @param x The x coordinate of the pixel
-- @param y The y coordinate of the pixel
-- @return The color value
function material_methods:getColor(x, y)
end

--- Returns a float keyvalue
-- @param key The key to get the float from
-- @return The float value or nil if it doesn't exist
function material_methods:getFloat(key)
end

--- Returns an int keyvalue
-- @param key The key to get the int from
-- @return The int value or nil if it doesn't exist
function material_methods:getInt(key)
end

--- Returns a table of material keyvalues
-- @return The table of keyvalues
function material_methods:getKeyValues()
end

--- Returns a matrix keyvalue
-- @param key The key to get the matrix from
-- @return The matrix value or nil if it doesn't exist
function material_methods:getMatrix(key)
end

--- Returns a string keyvalue
-- @param key The key to get the string from
-- @return The string value or nil if it doesn't exist
function material_methods:getString(key)
end

--- Returns a texture id keyvalue
-- @param key The key to get the texture from
-- @return The string id of the texture or nil if it doesn't exist
function material_methods:getTexture(key)
end

--- Returns a vector keyvalue
-- @param key The key to get the vector from
-- @return The string id of the texture
function material_methods:getVector(key)
end

--- Returns a linear color-corrected vector keyvalue
-- @param key The key to get the vector from
-- @return The vector value or nil if it doesn't exist
function material_methods:getVectorLinear(key)
end

-- function material_methods:isError()
-- end

-- function material_methods:recompute()
-- end

--- Sets a float keyvalue
-- @param key The key name to set
-- @param v The value to set it to
function material_methods:setFloat(key, v)
end

--- Sets an int keyvalue
-- @param key The key name to set
-- @param v The value to set it to
function material_methods:setInt(key, v)
end

--- Sets a matrix keyvalue
-- @param key The key name to set
-- @param v The value to set it to
function material_methods:setMatrix(key, v)
end

--- Sets a string keyvalue
-- @param key The key name to set
-- @param v The value to set it to
function material_methods:setString(key, v)
end

--- Sets a texture keyvalue
-- @param key The key name to set
-- @param v The texture name to set it to
function material_methods:setTexture(key, v)
end

--- Sets a keyvalue to be undefined
-- @param key The key name to set
function material_methods:setUndefined(key)
end

--- Sets a vector keyvalue
-- @param key The key name to set
-- @param v The value to set it to
function material_methods:setVector(key, v)
end


