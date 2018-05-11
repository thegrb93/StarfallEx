SF.Materials = {}

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("material.load", "Load material", "Allows users to load a vmt material.", { client = {} })
	P.registerPrivilege("material.create", "Create material", "Allows users to create a new custom material.", { client = {} })
	P.registerPrivilege("material.imagecreate", "Create material from image", "Allows users to create a new material from an image file.", { client = {} })
	P.registerPrivilege("material.urlcreate", "Create material from online image", "Allows users to create a new material from an online image.", { client = {}, urlwhitelist = {} })
	P.registerPrivilege("material.datacreate", "Create material from raw image data", "Allows users to create a new material from raw image data.", { client = {} })
end

local cv_max_materials = CreateConVar("sf_render_maxusermaterials", "40", { FCVAR_ARCHIVE })
local cv_max_data_material_size = CreateConVar("sf_render_maxdatamaterialsize", "1000000", { FCVAR_ARCHIVE })

--- The `Material` type is used to control shaders in rendering.
-- @client
local material_methods, material_metamethods = SF.RegisterType("Material")
local wrap, unwrap = SF.CreateWrapper(material_metamethods, true, false)
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
-- @return The material object
function material_library.load(path)
	checkluatype(path, TYPE_STRING)
	if string.GetExtensionFromFilename(path) then SF.Throw("The path cannot have an extension", 2) end
	checkpermission(SF.instance, path, "material.load")
	local m = SF.CheckMaterial(path)
	if not m then SF.Throw("The material is blacklisted", 2) end
	if m:IsError() then SF.Throw("The material path is invalid", 2) end
	return wrap(m)
end

--- Creates a new blank material
-- @param name The name of the material
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
		return tbl
	
	local urlmaterial = sfCreateMaterial("SF_TEXTURE_" .. util.CRC(url .. SysTime()), skip_hack)

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
	
	if #LoadingURLQueue == 0 then
		timer.Create("SF_URLMaterialChecker", 1, 0, CheckURLDownloads)
	end
	LoadingURLQueue[#LoadingURLQueue + 1] = { Material = urlmaterial, Url = url, Alignment = alignment, cb = cb }

	return urlmaterial
end
