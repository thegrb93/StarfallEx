-------------------------------------------------------------------------------
-- Clientside entity functions
-------------------------------------------------------------------------------

assert(SF.Entities)

local ents_lib = SF.Entities.Library
local ents_metatable = SF.Entities.Metatable
local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap

SF.Permissions:registerPermission({
	name = "Modify Entities",
	desc = "Allow modification of entities clientside",
	level = 1,
	value = false,
})

local isValid = SF.Entities.IsValid
local getPhysObject = SF.Entities.GetPhysObject

--- Returns whoever created the script
function ents_lib.owner()
	return wrap(SF.instance.player)
end

local localplayer = wrap(LocalPlayer())
--- Returns the local player
function ents_lib.player()
	return localplayer
end

-- TODO: Write special clientside functions
