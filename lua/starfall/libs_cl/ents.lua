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

-- TODO: Write special clientside functions
