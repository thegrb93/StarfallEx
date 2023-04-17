
--- Library for retreiving translated phrase from a query
-- @name language
-- @class library
-- @libtbl language_lib
SF.RegisterLibrary("language")


return function(instance)

--- Adds a language item. Language placeholders preceded with "#" are replaced with full text in Garry's Mod once registered with this function.
-- @param string placeholder
-- @param string fulltext
language_lib.add = language.Add

--- Retrieves the translated version of inputted string. Useful for concentrating multiple translated strings.
--- Also work with default phrase in gmod listed in this folder > https://github.com/Facepunch/garrysmod/tree/master/garrysmod/resource/localization/en
-- @param string Phrase
-- @return string Matched phrase
language_lib.getPhrase = language.GetPhrase

end
