
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
-- @param color The color to put in the string
-- @return String with the color RGBA values separated by spaces
function string_library.fromColor(color)
	return string.FromColor(cunwrap(color))
end

--- Converts string with RGBA values separated by spaces into a color.
-- @class function
-- @param str The string to convert from
-- @return The color object
function string_library.toColor(str)
	return cwrap(string.ToColor(str))
end

--- Returns the given string's characters in their numeric ASCII representation.
-- @class function
-- @param str The string to get the chars from
-- @param start The first character of the string to get the byte of
-- @param end The last character of the string to get the byte of
-- @return Vararg numerical bytes
string_library.byte = sfstring.byte

--- Takes the given numerical bytes and converts them to a string.
-- @class function
-- @param ... The bytes to create the string from
-- @return String built from given bytes
string_library.char = sfstring.char

--- Inserts commas for every third digit.
-- @class function
-- @param num The number to be separated by commas
-- @return String with commas inserted
string_library.comma = sfstring.Comma

--- Returns the binary bytecode of the given function.
-- @class function
-- @param The function to get the bytecode of
-- @param True to strip the debug data, false to keep it. Defaults to false
-- @return The bytecode
string_library.dump = sfstring.dump

--- Whether or not the second passed string matches the end of the first.
-- @class function
-- @param str The string whose end is to be checked
-- @param end The string to be matched with the end of the first
-- @return True if the first string ends with the second, or the second is empty
string_library.endsWith = sfstring.EndsWith

--- Splits a string up wherever it finds the given separator
-- @class function
-- @param separator The separator that will split the string
-- @param str The string to split up
-- @param patterns Set this to true if your separator is a pattern. Defaults to false
-- @return Table with the separated strings in numerical sequential order
string_library.explode = sfstring.Explode

--- Attempts to find the specified substring in a string, uses Patterns by default. https://wiki.facepunch.com/gmod/Patterns
-- @class function
-- @param haystack The string to search in
-- @param needle The string to find, can contain patterns if enabled
-- @param start The position to start the search from, negative start position will be relative to the end position
-- @param noPatterns Disable patterns. Defaults to false
-- @return Starting position of the found text, or nil if the text wasn't found
-- @return Ending position of found text, or nil if the text wasn't found
-- @return Matched text for each group if patterns are enabled and used, or nil if the text wasn't found
string_library.find = sfstring.find

--- Formats the specified values into the string given. http://www.cplusplus.com/reference/cstdio/printf/
-- @class function
-- @param str The string to be formatted
-- @param ... Vararg values to be formatted into the string
-- @return The formatted string
string_library.format = sfstring.format

--- Returns the time as a formatted string or table. http://www.cplusplus.com/reference/cstdio/printf/
-- If format is not specified, the table will contain the following keys: ms (miliseconds); s (seconds); m (minutes); h (hours).
-- @class function
-- @param time The time in seconds to format
-- @param format An optional formatting to use. If no format it specified, a table will be returned instead
-- @return Formatted string or a table
string_library.formattedTime = sfstring.FormattedTime

--- Returns char value from the specified index in the supplied string. (DEPRECATED! You should use string.sub instead)
-- @class function
-- @param str The string that you will be searching with the supplied index
-- @param index The index's value of the string to be returned
-- @return The selected character
string_library.getChar = sfstring.GetChar

--- Returns extension of the file-path.
-- @class function
-- @param str File-path to get the file extensions from
-- @return The extension
string_library.getExtensionFromFilename = sfstring.GetExtensionFromFilename

--- Returns file name and extension.
-- @class function
-- @param str File-path to get the file extensions from
-- @return The filename along with it's extension
string_library.getFileFromFilename = sfstring.GetFileFromFilename

--- Returns the path only from a file's path, excluding the file itself.
-- @class function
-- @param str File-path to get the file extensions from
-- @return The path
string_library.getPathFromFilename = sfstring.GetPathFromFilename

--- Returns an iterator function that is called for every complete match of the pattern, all sub matches will be passed as to the loop. (DEPRECATED! You should use string.gmatch instead)
-- @class function
-- @param data The string to search in
-- @param pattern The pattern to search for
-- @return The iterator function that can be used in a for-in loop
string_library.gfind = sfstring.gfind

--- Using Patterns, returns an iterator which will return either one value if no capture groups are defined, or any capture group matches.
-- @class function
-- @param data The string to search in
-- @param pattern The pattern to search for
-- @return The iterator function that can be used in a for-in loop
string_library.gmatch = sfstring.gmatch

--- This functions main purpose is to replace certain character sequences in a string using Patterns.
-- @class function
-- @param str String which should be modified.
-- @param pattern The pattern that defines what should be matched and eventually be replaced.
-- @param replacement If string: matched sequence will be replaced with it; If table: matched sequence will be used as key; If function: matches will be passed as parameters to the function (return to replace)
-- @param Optional maximum number of replacements to be made
-- @return String with replaced parts
-- @return Replacements count
string_library.gsub = sfstring.gsub

--- Joins the values of a table together to form a string. (DEPRECATED! You should use table.concat instead)
-- @class function
-- @param separator The separator to insert between each piece
-- @param pieces The table of pieces to concatenate. The keys for these must be numeric and sequential
-- @return Imploded string
string_library.implode = sfstring.Implode

--- Escapes special characters for JavaScript in a string, making the string safe for inclusion in to JavaScript strings.
-- @class function
-- @param str The string that should be escaped
-- @return The safe string
string_library.javascriptSafe = sfstring.javascriptSafe

--- Returns everything left of supplied place of that string.
-- @class function
-- @param str The string to extract from
-- @param num Amount of chars relative to the beginning (starting from 1)
-- @return Returns a string containing a specified number of characters from the left side of a string
string_library.left = sfstring.Left

--- Counts the number of characters in the string. This is equivalent to using the # operator.
-- @class function
-- @param str The string to find the length of
-- @return Length of the string
string_library.len = sfstring.len

--- Changes any upper-case letters in a string to lower-case letters.
-- @class function
-- @param str The string to convert
-- @return String with all uppercase letters replaced with their lowercase variants
string_library.lower = sfstring.lower

--- Finds a Pattern in a string.
-- @class function
-- @param str String which should be searched in for matches
-- @param pattern The pattern that defines what should be matched
-- @param start The start index to start the matching from, negative to start the match from a position relative to the end
-- @return Vararg matched string(s)
string_library.match = sfstring.match

--- Converts a digital filesize to human-readable text.
-- @class function
-- @param size The filesize in bytes
-- @return The human-readable filesize, in Bytes/KB/MB/GB (whichever is appropriate)
string_library.niceSize = sfstring.NiceSize

--- Formats the supplied number (in seconds) to the highest possible time unit
-- @class function
-- @param time The number to format, in seconds
-- @return A nicely formatted time string
string_library.niceTime = sfstring.NiceTime

--- Escapes all special characters within a string, making the string safe for inclusion in a Lua pattern.
-- @class function
-- @param str The string to be sanitized
-- @return The sanitized string
string_library.patternSafe = sfstring.patternSafe

--- Repeats the given string n times
-- @class function
-- @param str The string to repeat
-- @param rep Number of times to repeat the string
-- @param sep (Optional) seperator string between each repeated string
-- @return String result
string_library.rep = sfstring.rep

--- Replaces all occurrences of the supplied second string.
-- @class function
-- @param str The string we are seeking to replace an occurrence(s)
-- @param find What we are seeking to replace
-- @param replace What to replace find with
-- @return String with parts replaced
string_library.replace = sfstring.Replace

--- Reverses a string.
-- @class function
-- @param str String to be reversed
-- @return Reversed string
string_library.reverse = sfstring.reverse

--- Returns the last n-th characters of the string.
-- @class function
-- @param str The string to extract from
-- @param num Amount of chars relative to the end (starting from 1)
-- @return String containing a specified number of characters from the right side of a string
string_library.right = sfstring.Right

--- Sets the character at the specific index of the string.
-- @class function
-- @param str The input string
-- @param index The character index, 1 is the first from left
-- @param replacement String to replace with
-- @return Modified string
string_library.setChar = sfstring.SetChar

--- Splits the string into a table of strings, separated by the second argument
-- @class function
-- @param str String to split
-- @param separator Character(s) to split with
-- @return Table with the separated strings in numerical sequential order 
string_library.split = sfstring.Split

--- Whether or not the first string starts with the second
-- @class function
-- @param str String to be checked
-- @param start String to check with
-- @return True if the first string starts with the second
string_library.startWith = sfstring.StartWith

--- Removes the extension of a path
-- @class function
-- @param The file-path to change
-- @return Path without the extension
string_library.stripExtension = sfstring.StripExtension

---Returns a sub-string, starting from the character at position startPos of the string (inclusive)
-- and optionally ending at the character at position endPos of the string (also inclusive).
-- If EndPos is not given, the rest of the string is returned.
-- @class function
-- @param str The string you'll take a sub-string out of
-- @param startPos The position of the first character that will be included in the sub-string
-- @param endPos The position of the last character to be included in the sub-string. It can be negative to count from the end
string_library.sub = sfstring.sub

--- Converts time to minutes and seconds string.
-- @class function
-- @param time Time in seconds
-- @return Given time in "MM:SS" format
string_library.toMinutesSeconds = sfstring.ToMinutesSeconds

--- Converts time to minutes, seconds and miliseconds string.
-- @class function
-- @param time Time in seconds
-- @return Returns given time in "MM:SS:MS" format
string_library.toMinutesSecondsMilliseconds = sfstring.ToMinutesSecondsMilliseconds

--- Splits the string into characters and creates a sequential table of characters.
-- As a result of the encoding, non-ASCII characters will be split into more than one character in the output table.
-- Each character value in the output table will always be 1 byte.
-- @class function
-- @param str The string to turn into a table
-- @return A sequential table where each value is a character from the given string
string_library.toTable = sfstring.ToTable

--- Removes leading and trailing spaces/characters of a string
-- @class function
-- @param str The string to trim
-- @param char Optional character to be trimmed. Defaults to space character
-- @return Trimmed string
string_library.trim = sfstring.Trim

--- Removes leading spaces/characters from a string
-- @class function
-- @param str The string to trim
-- @param char Optional character to be trimmed. Defaults to space character
-- @return Trimmed string
string_library.trimLeft = sfstring.TrimLeft

--- Removes trailing spaces/characters from a string.
-- @class function
-- @param str The string to trim
-- @param char Optional character to be trimmed. Defaults to space character
-- @return Trimmed string
string_library.trimRight = sfstring.TrimRight

--- Changes any lower-case letters in a string to upper-case letters.
-- @class function
-- @param str The string to convert
-- @return String with all letters upper case
string_library.upper = sfstring.upper

--- Returns a path with all .. accounted for
-- @class function
-- @param str Path
-- @return Path with all .. replaced
string_library.normalizePath = SF.NormalizePath



--- Receives zero or more integers, converts each one to its corresponding UTF-8 byte sequence
-- and returns a string with the concatenation of all these sequences
-- @class function
-- @param ... Unicode code points to be converted in to a UTF-8 string
-- @return UTF-8 string generated from given arguments
string_library.utf8char = utf8.char

--- Returns the codepoints (as numbers) from all characters in the given string that start between byte position startPos and endPos.
-- It raises an error if it meets any invalid byte sequence.
-- @class function
-- @param str The string that you will get the code(s) from
-- @param startPos The starting byte of the string to get the codepoint of
-- @param endPos The ending byte of the string to get the codepoint of
-- @return The codepoint number(s)
string_library.utf8codepoint = utf8.codepoint

--- Returns an iterator (like string.gmatch) which returns both the position and codepoint of each utf8 character in the string.
-- It raises an error if it meets any invalid byte sequence.
-- @class function
-- @param str The string that you will get the codes from
-- @return The iterator (to be used in a for loop)
string_library.utf8codes = utf8.codes

--- Forces a string to contain only valid UTF-8 data. Invalid sequences are replaced with U+FFFD (the Unicode replacement character).
-- @class function
-- @param str The string that will become a valid UTF-8 string
-- @return The UTF-8 string
string_library.utf8force = utf8.force

--- Returns the number of UTF-8 sequences in the given string between positions startPos and endPos (both inclusive).
-- If it finds any invalid UTF-8 byte sequence, returns false as well as the position of the first invalid byte.
-- @class function
-- @param str The string to calculate the length of
-- @param startPos The starting position to get the length from
-- @param endPos The ending position to get the length from
-- @return The number of UTF-8 characters in the string. If there are invalid bytes, this will be false
-- @return The position of the first invalid byte. If there were no invalid bytes, this will be nil
string_library.utf8len = utf8.len

--- Returns the byte-index of the n'th UTF-8-character after the given startPos (nil if none).
-- startPos defaults to 1 when n is positive and -1 when n is negative. If n is zero,
-- this function instead returns the byte-index of the UTF-8-character startPos lies within.
-- @class function
-- @param str The string that you will get the byte position from
-- @param n The position to get the beginning byte position from
-- @param startPos The offset for n. Defaults to 1 if n >= 0, otherwise -1
-- @return Starting byte-index of the given position
string_library.utf8offset = utf8.offset


end