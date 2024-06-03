
local checkluatype = SF.CheckLuaType

--- Lua string library https://wiki.garrysmod.com/page/Category:string
-- @name string
-- @class library
-- @libtbl string_library
SF.RegisterLibrary("string")

return function(instance)

local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap

local string_library = instance.Libraries.string
local sfstring = SF.SafeStringLib

--- Converts color to a string.
-- @class function
-- @param Color col The color to put in the string
-- @return string String with the color RGBA values separated by spaces
function string_library.fromColor(color)
	return string.FromColor(cunwrap(color))
end

--- Converts string with RGBA values separated by spaces into a color.
-- @class function
-- @param string str The string to convert from
-- @return Color The color object
function string_library.toColor(str)
	return cwrap(string.ToColor(str))
end

--- Returns the given string's characters in their numeric ASCII representation.
-- @class function
-- @param string str The string to get the chars from
-- @param number start The first character of the string to get the byte of
-- @param number end The last character of the string to get the byte of
-- @return ... Vararg numerical bytes
string_library.byte = sfstring.byte

--- Takes the given numerical bytes and converts them to a string.
-- @class function
-- @param ... bytes The bytes to create the string from
-- @return string String built from given bytes
string_library.char = sfstring.char

--- Inserts commas for every third digit.
-- @class function
-- @param number num The number to be separated by commas
-- @return string String with commas inserted
string_library.comma = sfstring.Comma

--- Returns the binary bytecode of the given function.
-- @class function
-- @param function func The function to get the bytecode of
-- @param boolean? strip True to strip the debug data, false to keep it. Defaults to false
-- @return string The bytecode
string_library.dump = sfstring.dump

--- Whether or not the second passed string matches the end of the first.
-- @class function
-- @param string str The string whose end is to be checked
-- @param string end The string to be matched with the end of the first
-- @return boolean True if the first string ends with the second, or the second is empty
string_library.endsWith = sfstring.EndsWith

--- Splits a string up wherever it finds the given separator
-- @class function
-- @param string separator The separator that will split the string
-- @param string str The string to split up
-- @param boolean? patterns Set this to true if your separator is a pattern. Defaults to false
-- @return table Table with the separated strings in numerical sequential order
string_library.explode = sfstring.Explode

--- Attempts to find the specified substring in a string, uses Patterns by default. https://wiki.facepunch.com/gmod/Patterns
-- @class function
-- @param string haystack The string to search in
-- @param string needle The string to find, can contain patterns if enabled
-- @param number start The position to start the search from, negative start position will be relative to the end position
-- @param boolean? noPatterns Disable patterns. Defaults to false
-- @return number? Starting position of the found text, or nil if the text wasn't found
-- @return number? Ending position of found text, or nil if the text wasn't found
-- @return string? Matched text for each group if patterns are enabled and used, or nil if the text wasn't found
string_library.find = sfstring.find

--- Formats the specified values into the string given. http://www.cplusplus.com/reference/cstdio/printf/
-- @class function
-- @param string str The string to be formatted
-- @param ... params Vararg values to be formatted into the string
-- @return string The formatted string
string_library.format = sfstring.format

--- Returns the time as a formatted string or table. http://www.cplusplus.com/reference/cstdio/printf/
-- If format is not specified, the table will contain the following keys: ms (milliseconds); s (seconds); m (minutes); h (hours).
-- @class function
-- @param number time The time in seconds to format
-- @param string? format An optional formatting to use. If no format it specified, a table will be returned instead
-- @return string|table Formatted string or a table
string_library.formattedTime = sfstring.FormattedTime

--- Returns extension of the file-path.
-- @class function
-- @param string str File-path to get the file extensions from
-- @return string The extension
string_library.getExtensionFromFilename = sfstring.GetExtensionFromFilename

--- Returns file name and extension.
-- @class function
-- @param string str File-path to get the file extensions from
-- @return string The filename along with it's extension
string_library.getFileFromFilename = sfstring.GetFileFromFilename

--- Returns the path only from a file's path, excluding the file itself.
-- @class function
-- @param string str File-path to get the file extensions from
-- @return string The path
string_library.getPathFromFilename = sfstring.GetPathFromFilename

--- Using Patterns, returns an iterator which will return either one value if no capture groups are defined, or any capture group matches.
-- @class function
-- @param string data The string to search in
-- @param string pattern The pattern to search for
-- @return function The iterator function that can be used in a for-in loop
string_library.gmatch = sfstring.gmatch

--- This functions main purpose is to replace certain character sequences in a string using Patterns.
-- @class function
-- @param string str String which should be modified.
-- @param string pattern The pattern that defines what should be matched and eventually be replaced.
-- @param string|table|function replacement If string: matched sequence will be replaced with it; If table: matched sequence will be used as key; If function: matches will be passed as parameters to the function (return to replace)
-- @param number? max Optional maximum number of replacements to be made
-- @return string String with replaced parts
-- @return number Replacements count
string_library.gsub = sfstring.gsub

--- Escapes special characters for JavaScript in a string, making the string safe for inclusion in to JavaScript strings.
-- @class function
-- @param string str The string that should be escaped
-- @return string The safe string
string_library.javascriptSafe = sfstring.javascriptSafe

--- Returns everything left of supplied place of that string.
-- @class function
-- @param string str The string to extract from
-- @param number num Amount of chars relative to the beginning (starting from 1)
-- @return string Returns a string containing a specified number of characters from the left side of a string
string_library.left = sfstring.Left

--- Counts the number of characters in the string. This is equivalent to using the # operator.
-- @class function
-- @param string str The string to find the length of
-- @return number Length of the string
string_library.len = sfstring.len

--- Changes any upper-case letters in a string to lower-case letters.
-- @class function
-- @param string str The string to convert
-- @return string String with all uppercase letters replaced with their lowercase variants
string_library.lower = sfstring.lower

--- Finds a Pattern in a string.
-- @class function
-- @param string str String which should be searched in for matches
-- @param string pattern The pattern that defines what should be matched
-- @param number? start The start index to start the matching from, negative to start the match from a position relative to the end. Default 1
-- @return ... Vararg matched string(s)
string_library.match = sfstring.match

--- Converts a digital filesize to human-readable text.
-- @class function
-- @param number size The filesize in bytes
-- @return string The human-readable filesize, in Bytes/KB/MB/GB (whichever is appropriate)
string_library.niceSize = sfstring.NiceSize

--- Formats the supplied number (in seconds) to the highest possible time unit
-- @class function
-- @param number time The number to format, in seconds
-- @return string A nicely formatted time string
string_library.niceTime = sfstring.NiceTime

--- Escapes all special characters within a string, making the string safe for inclusion in a Lua pattern.
-- @class function
-- @param string str The string to be sanitized
-- @return string The sanitized string
string_library.patternSafe = sfstring.patternSafe

--- Sanitizes text to be used in `render.parseMarkup`
-- @param string str Text to sanitize
-- @return string Sanitized text
function string_library.escapeMarkup(str)
	checkluatype(str, TYPE_STRING)
	return ( string.gsub(str, "[&<>]", {["&"]="&amp;",["<"]="&lt;",[">"]="&gt;"}) )
end

--- Repeats the given string n times
-- @class function
-- @param string str The string to repeat
-- @param number rep Number of times to repeat the string
-- @param string? sep (Optional) seperator string between each repeated string
-- @return string String result
string_library.rep = sfstring.rep

--- Replaces all occurrences of the supplied second string.
-- @class function
-- @param string str The string we are seeking to replace an occurrence(s)
-- @param string find What we are seeking to replace
-- @param string replace What to replace find with
-- @return string String with parts replaced
string_library.replace = sfstring.Replace

--- Reverses a string.
-- @class function
-- @param string str String to be reversed
-- @return string Reversed string
string_library.reverse = sfstring.reverse

--- Returns the last n-th characters of the string.
-- @class function
-- @param string str The string to extract from
-- @param number num Amount of chars relative to the end (starting from 1)
-- @return string String containing a specified number of characters from the right side of a string
string_library.right = sfstring.Right

--- Sets the character at the specific index of the string.
-- @class function
-- @param string str The input string
-- @param number index The character index, 1 is the first from left
-- @param string replacement String to replace with
-- @return string Modified string
string_library.setChar = sfstring.SetChar

--- Splits the string into a table of strings, separated by the second argument
-- @class function
-- @param string str String to split
-- @param string separator Character(s) to split with
-- @return table Table with the separated strings in numerical sequential order
string_library.split = sfstring.Split

--- Whether or not the first string starts with the second
-- @class function
-- @param string str String to be checked
-- @param string start String to check with
-- @return boolean True if the first string starts with the second
string_library.startWith = sfstring.StartWith

--- Removes the extension of a path
-- @class function
-- @param string path The file-path to change
-- @return string Path without the extension
string_library.stripExtension = sfstring.StripExtension

--- Returns a sub-string, starting from the character at position startPos of the string (inclusive)
-- and optionally ending at the character at position endPos of the string (also inclusive).
-- If EndPos is not given, the rest of the string is returned.
-- @class function
-- @param string str The string you'll take a sub-string out of
-- @param number startPos The position of the first character that will be included in the sub-string
-- @param number? endPos The position of the last character to be included in the sub-string. It can be negative to count from the end
-- @return string The sub-string
string_library.sub = sfstring.sub

--- Converts time to minutes and seconds string.
-- @class function
-- @param number time Time in seconds
-- @return string Given time in "MM:SS" format
string_library.toMinutesSeconds = sfstring.ToMinutesSeconds

--- Converts time to minutes, seconds and milliseconds string.
-- @class function
-- @param number time Time in seconds
-- @return string Returns given time in "MM:SS:MS" format
string_library.toMinutesSecondsMilliseconds = sfstring.ToMinutesSecondsMilliseconds

--- Converts time to hours, minutes and seconds string.
-- @class function
-- @param number time Time in seconds
-- @return string Given time in "HH:MM:SS" format
function string_library.toHoursMinutesSeconds( seconds )
	local formattedTime = sfstring.FormattedTime( seconds )
	return sfstring.format("%02i:%02i:%02i", formattedTime.h, formattedTime.m, formattedTime.s)
end

--- Converts time to hours, minutes, seconds and milliseconds string.
-- @class function
-- @param number time Time in seconds
-- @return string Returns given time in "HH:MM:SS.MS" format
function string_library.toHoursMinutesSecondsMilliseconds( seconds )
	local formattedTime = sfstring.FormattedTime( seconds )
	return sfstring.format("%02i:%02i:%02i.%03i", formattedTime.h, formattedTime.m, formattedTime.s, formattedTime.ms)
end

--- Splits the string into characters and creates a sequential table of characters.
-- As a result of the encoding, non-ASCII characters will be split into more than one character in the output table.
-- Each character value in the output table will always be 1 byte.
-- @class function
-- @param string str The string to turn into a table
-- @return table A sequential table where each value is a character from the given string
string_library.toTable = sfstring.ToTable

--- Removes leading and trailing spaces/characters of a string
-- @class function
-- @param string str The string to trim
-- @param string? char Optional character to be trimmed. Defaults to space character
-- @return string Trimmed string
string_library.trim = sfstring.Trim

--- Removes leading spaces/characters from a string
-- @class function
-- @param string str The string to trim
-- @param string? char Optional character to be trimmed. Defaults to space character
-- @return string Trimmed string
string_library.trimLeft = sfstring.TrimLeft

--- Removes trailing spaces/characters from a string.
-- @class function
-- @param string str The string to trim
-- @param string char Optional character to be trimmed. Defaults to space character
-- @return string Trimmed string
string_library.trimRight = sfstring.TrimRight

--- Changes any lower-case letters in a string to upper-case letters.
-- @class function
-- @param string str The string to convert
-- @return string String with all letters upper case
string_library.upper = sfstring.upper

--- Returns a path with all .. accounted for
-- @class function
-- @param string str Path
-- @return string Path with all .. replaced
string_library.normalizePath = SF.NormalizePath



--- Receives zero or more integers, converts each one to its corresponding UTF-8 byte sequence
-- and returns a string with the concatenation of all these sequences
-- @class function
-- @param ... codepoints Unicode code points to be converted in to a UTF-8 string
-- @return string UTF-8 string generated from given arguments
string_library.utf8char = utf8.char

--- Returns the codepoints (as numbers) from all characters in the given string that start between byte position startPos and endPos.
-- It raises an error if it meets any invalid byte sequence.
-- @class function
-- @param string str The string that you will get the code(s) from
-- @param number? startPos The starting byte of the string to get the codepoint of
-- @param number? endPos The ending byte of the string to get the codepoint of
-- @return ... The codepoint number(s)
string_library.utf8codepoint = utf8.codepoint

--- Returns an iterator (like string.gmatch) which returns both the position and codepoint of each utf8 character in the string.
-- It raises an error if it meets any invalid byte sequence.
-- @class function
-- @param string str The string that you will get the codes from
-- @return function The iterator (to be used in a for loop)
string_library.utf8codes = utf8.codes

--- Forces a string to contain only valid UTF-8 data. Invalid sequences are replaced with U+FFFD (the Unicode replacement character).
-- @class function
-- @param string str The string that will become a valid UTF-8 string
-- @return string The UTF-8 string
string_library.utf8force = utf8.force

--- Returns the number of UTF-8 sequences in the given string between positions startPos and endPos (both inclusive).
-- If it finds any invalid UTF-8 byte sequence, returns false as well as the position of the first invalid byte.
-- @class function
-- @param string str The string to calculate the length of
-- @param number? startPos The starting position to get the length from
-- @param number? endPos The ending position to get the length from
-- @return number|boolean The number of UTF-8 characters in the string. If there are invalid bytes, this will be false
-- @return number? The position of the first invalid byte. If there were no invalid bytes, this will be nil
string_library.utf8len = utf8.len

--- Returns the byte-index of the n'th UTF-8-character after the given startPos (nil if none).
-- startPos defaults to 1 when n is positive and -1 when n is negative. If n is zero,
-- this function instead returns the byte-index of the UTF-8-character startPos lies within.
-- @class function
-- @param string str The string that you will get the byte position from
-- @param number n The position to get the beginning byte position from
-- @param number? startPos The offset for n. Defaults to 1 if n >= 0, otherwise -1
-- @return number Starting byte-index of the given position
string_library.utf8offset = utf8.offset


end
