SF.Material = {}

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("material.load", "Load an existing material.", "Allows users to create sound channels by file path.", { client = {} })
	P.registerPrivilege("material.create", "Create a new material.", "Allows users to create sound channels by URL.", { client = {} })
end

--- For playing music there is `Material` type. You can pause and set current playback time in it. If you're looking to apply DSP effects on present game sounds, use `Sound` instead.
-- @client
local material_methods, material_metamethods = SF.RegisterType("Material")
local wrap, unwrap = SF.CreateWrapper(material_metamethods, true, false)
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

--- `material` library is intended to be used only on client side. It's good for streaming local and remote sound files and playing them directly in player's "2D" context.
-- @client
local material_library = SF.RegisterLibrary("material")

SF.Material.Wrap = wrap
SF.Material.Unwrap = unwrap
SF.Material.Methods = material_methods
SF.Material.Metatable = material_metamethods


-- Register functions to be called when the chip is initialised and deinitialised
SF.AddHook("initialize", function (inst)
	inst.data.material = {
		materials = {}
	}
end)

SF.AddHook("deinitialize", function (inst)
	local materials = inst.data.material.materials
	local s = next(materials)
	while s do
		s = next(materials)
	end
end)

