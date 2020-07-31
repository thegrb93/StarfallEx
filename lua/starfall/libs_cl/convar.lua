
local checkluatype = SF.CheckLuaType

SF.Permissions.registerPrivilege("convar", "Read ConVars", "Allows Starfall to read your game settings", { client = { default = 1 } })


--- ConVar library https://wiki.facepunch.com/gmod/ConVar
-- @name convar
-- @class library
-- @libtbl convar_library
SF.RegisterLibrary("convar")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local convar_library = instance.Libraries.convar


local function getValidConVar(name)
	checkpermission(instance, nil, "convar")
	checkluatype(name, TYPE_STRING)
	
	local cvar = GetConVar(name)
	if not cvar then SF.Throw("Trying to access non-existent ConVar", 3) end
	return cvar
end


--- Check if the given ConVar exists
-- @param name Name of the ConVar
-- @return True if exists
function convar_library.exists(name)
	checkpermission(instance, nil, "convar")
	checkluatype(name, TYPE_STRING)
	return GetConVar(name)~=nil
end

--- Returns default value of the ConVar
-- @param name Name of the ConVar
-- @return Default value as a string
function convar_library.getDefault(name)
	return getValidConVar(name):GetDefault()
end

--- Returns the minimum value of the convar
-- @param name Name of the ConVar
-- @return The minimum value or nil if not specified
function convar_library.getMin(name)
	return getValidConVar(name):GetMin()
end

--- Returns the maximum value of the convar
-- @param name Name of the ConVar
-- @return The maximum value or nil if not specified
function convar_library.getMax(name)
	return getValidConVar(name):GetMax()
end

--- Returns value of the ConVar as a boolean.
-- True for numeric ConVars with the value of 1, false otherwise.
-- @param name Name of the ConVar
-- @return The boolean value
function convar_library.getBool(name)
	return getValidConVar(name):GetBool()
end

--- Returns value of the ConVar as a whole number.
-- Floats values will be floored.
-- @param name Name of the ConVar
-- @return The integer value or 0 if converting fails
function convar_library.getInt(name)
	return getValidConVar(name):GetInt()
end

--- Returns value of the ConVar as a floating-point number.
-- @param name Name of the ConVar
-- @return The float value or 0 if converting fails
function convar_library.getFloat(name)
	return getValidConVar(name):GetFloat()
end

--- Returns value of the ConVar as a string.
-- @param name Name of the ConVar
-- @return Value as a string
function convar_library.getString(name)
	return getValidConVar(name):GetString()
end

--- Returns FCVAR flags of the given ConVar.
-- https://wiki.facepunch.com/gmod/Enums/FCVAR
-- @param name Name of the ConVar
-- @return Number consisting of flag values
function convar_library.getFlags(name)
	return getValidConVar(name):GetFlags()
end

--- Returns true if a given FCVAR flag is set for this ConVar.
-- https://wiki.facepunch.com/gmod/Enums/FCVAR
-- @param name Name of the ConVar
-- @return True if has the flag
function convar_library.hasFlag(name, flag)
	checkluatype(flag, TYPE_NUMBER)
	return getValidConVar(name):IsFlagSet(flag)
end


end
