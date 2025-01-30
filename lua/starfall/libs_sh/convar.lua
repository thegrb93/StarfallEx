
local checkluatype = SF.CheckLuaType
local PLY_META = FindMetaTable("Player")

if CLIENT then
	SF.Permissions.registerPrivilege("convar", "Read ConVars", "Allows Starfall to read your game settings", { client = {} })
end


--- ConVar library https://wiki.facepunch.com/gmod/ConVar
-- @name convar
-- @class library
-- @libtbl convar_library
SF.RegisterLibrary("convar")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ply_GetInfo = PLY_META.GetInfo

local convar_library = instance.Libraries.convar

if CLIENT then

local function getValidConVar(name)
	checkpermission(instance, nil, "convar")
	checkluatype(name, TYPE_STRING)

	local cvar = GetConVar(name)
	if not cvar then SF.Throw("Trying to access non-existent ConVar", 3) end
	return cvar
end


--- Check if the given ConVar exists
-- @client
-- @param string name Name of the ConVar
-- @return boolean True if exists
function convar_library.exists(name)
	checkpermission(instance, nil, "convar")
	checkluatype(name, TYPE_STRING)
	return GetConVar(name)~=nil
end

--- Returns default value of the ConVar
-- @client
-- @param string name Name of the ConVar
-- @return string Default value as a string
function convar_library.getDefault(name)
	return getValidConVar(name):GetDefault()
end

--- Returns the minimum value of the convar
-- @client
-- @param string name Name of the ConVar
-- @return number The minimum value or nil if not specified
function convar_library.getMin(name)
	return getValidConVar(name):GetMin()
end

--- Returns the maximum value of the convar
-- @client
-- @param string name Name of the ConVar
-- @return number? The maximum value or nil if not specified
function convar_library.getMax(name)
	return getValidConVar(name):GetMax()
end

--- Returns value of the ConVar as a boolean.
-- True for numeric ConVars with the value of 1, false otherwise.
-- @client
-- @param string name Name of the ConVar
-- @return boolean The boolean value
function convar_library.getBool(name)
	return getValidConVar(name):GetBool()
end

--- Returns value of the ConVar as a whole number.
-- Floats values will be floored.
-- @client
-- @param string name Name of the ConVar
-- @return number The integer value or 0 if converting fails
function convar_library.getInt(name)
	return getValidConVar(name):GetInt()
end

--- Returns value of the ConVar as a floating-point number.
-- @client
-- @param string name Name of the ConVar
-- @return number The float value or 0 if converting fails
function convar_library.getFloat(name)
	return getValidConVar(name):GetFloat()
end

--- Returns value of the ConVar as a string.
-- @client
-- @param string name Name of the ConVar
-- @return string Value as a string
function convar_library.getString(name)
	return getValidConVar(name):GetString()
end

--- Returns FCVAR flags of the given ConVar.
-- https://wiki.facepunch.com/gmod/Enums/FCVAR
-- @client
-- @param string name Name of the ConVar
-- @return number Number consisting of flag values
function convar_library.getFlags(name)
	return getValidConVar(name):GetFlags()
end

--- Returns true if a given FCVAR flag is set for this ConVar.
-- @client
-- @param string name Name of the ConVar
-- @param number flag Convar Flag, see https://wiki.facepunch.com/gmod/Enums/FCVAR
-- @return boolean Whether the flag is set
function convar_library.hasFlag(name, flag)
	checkluatype(flag, TYPE_NUMBER)
	return getValidConVar(name):IsFlagSet(flag)
end

end

--- Retrieves the value of a client-side userinfo ConVar.
-- @param string name The name of userinfo variable.
-- @return string Returns the value of the given client-side userinfo ConVar (truncated to 31 bytes).
function convar_library.getUserInfo(name)
	checkluatype(name, TYPE_STRING)
	if CLIENT then
		checkpermission(instance, name, "convar")
	end
	local ply = SERVER and instance.player or LocalPlayer()
	return IsValid(ply) and Ply_GetInfo(ply, name) or ""
end

end
