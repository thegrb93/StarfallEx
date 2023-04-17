-- Global to each starfall
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

--- Library for retreiving translated phrase from a query
-- @name language
-- @class library
-- @libtbl language_lib
SF.RegisterLibrary("language")

registerprivilege("language.add", "Add language query", "Allows the user to add languages query", { client = {} })

return function(instance)
local language_lib = instance.Libraries.language
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end


--- Adds a language item. Language placeholders preceded with "#" are replaced with full text in Garry's Mod once registered with this function.
-- @param string placeholder Query id
-- @param string fulltext Phrase from query
function language_lib.add(placeholder,fulltext)
	checkpermission(instance, placeholder, "language.add")
	checkluatype(placeholder, TYPE_STRING)
	checkluatype(fulltext, TYPE_STRING)
	language.Add(placeholder,fulltext)
end

--- Retrieves the translated version of inputted string. Useful for concentrating multiple translated strings.
--- Also work with default phrase in gmod listed in this folder > https://github.com/Facepunch/garrysmod/tree/master/garrysmod/resource/localization/en
-- @param string Query id of query
-- @return string Matched phrase
function language_lib.getPhrase(id)
	checkluatype(id, TYPE_STRING)
	return language.GetPhrase(id)
end

end