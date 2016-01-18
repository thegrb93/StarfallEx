-------------------------------------------------------------------------------
-- Builtins.
-- Functions built-in to the default environment
-------------------------------------------------------------------------------

local dgetmeta = debug.getmetatable

--- Built in values. These don't need to be loaded; they are in the default environment.
-- @name builtin
-- @shared
-- @class library
-- @libtbl SF.DefaultEnvironment

-- ------------------------- Lua Ports ------------------------- --
-- This part is messy because of LuaDoc stuff.

local function pascalToCamel ( t, r )
	local r = r or {}
	for k, v in pairs( t ) do
		k = k:gsub( "^%l", string.lower )
		r[ k ] = v
	end
	return r
end

--- Returns the entity representing a processor that this script is running on.
-- @name SF.DefaultEnvironment.self
-- @class function
-- @return Starfall entity
SF.DefaultEnvironment.self = nil

--- Returns whoever created the chip
-- @name SF.DefaultEnvironment.owner
-- @class function
-- @return Owner entity
SF.DefaultEnvironment.owner = nil

--- Same as owner() on the server. On the client, returns the local player
-- @name SF.DefaultEnvironment.player
-- @class function
-- @return Either the owner (server) or the local player (client)
SF.DefaultEnvironment.player = nil

--- Returns the entity with index 'num'
-- @name SF.DefaultEnvironment.entity
-- @class function
-- @param num Entity index
-- @return entity
SF.DefaultEnvironment.entity = nil

--- Same as Lua's tostring
-- @name SF.DefaultEnvironment.tostring
-- @class function
-- @param obj
-- @return obj as string
SF.DefaultEnvironment.tostring = tostring
--- Same as Lua's tonumber
-- @name SF.DefaultEnvironment.tonumber
-- @class function
-- @param obj
-- @return obj as number
SF.DefaultEnvironment.tonumber = tonumber

--- Same as Lua's ipairs
-- @name SF.DefaultEnvironment.ipairs
-- @class function
-- @param tbl Table to iterate over
-- @return Iterator function
-- @return Table tbl
-- @return 0 as current index
SF.DefaultEnvironment.ipairs = ipairs

--- Same as Lua's pairs
-- @name SF.DefaultEnvironment.pairs
-- @class function
-- @param tbl Table to iterate over
-- @return Iterator function
-- @return Table tbl
-- @return nil as current index
SF.DefaultEnvironment.pairs = pairs

--- Same as Lua's type
-- @name SF.DefaultEnvironment.type
-- @class function
-- @param obj Object to get type of
-- @return The name of the object's type.
SF.DefaultEnvironment.type = function( obj )
	local tp = getmetatable( obj )
	return type(tp) == "string" and tp or type( obj )
end
--- Same as Lua's next
-- @name SF.DefaultEnvironment.next
-- @class function
-- @param tbl Table to get the next key-value pair of
-- @param k Previous key (can be nil)
-- @return Key or nil
-- @return Value or nil
SF.DefaultEnvironment.next = next
--- Same as Lua's assert.
-- @name SF.DefaultEnvironment.assert
-- @class function
-- @param condition
-- @param msg
SF.DefaultEnvironment.assert = function ( condition, msg ) if not condition then SF.throw( msg or "assertion failed!", 2 ) end end
--- Same as Lua's unpack
-- @name SF.DefaultEnvironment.unpack
-- @class function
-- @param tbl
-- @return Elements of tbl
SF.DefaultEnvironment.unpack = unpack

--- Same as Lua's setmetatable. Doesn't work on most internal metatables
-- @name SF.DefaultEnvironment.setmetatable
-- @class function
-- @param tbl The table to set the metatable of
-- @param meta The metatable to use
-- @return tbl with metatable set to meta
SF.DefaultEnvironment.setmetatable = setmetatable

--- Same as Lua's getmetatable. Doesn't work on most internal metatables
-- @param tbl Table to get metatable of
-- @return The metatable of tbl
SF.DefaultEnvironment.getmetatable = function(tbl)
	SF.CheckType(tbl,"table")
	return getmetatable(tbl)
end

--- Constant that denotes whether the code is executed on the client
-- @name SF.DefaultEnvironment.CLIENT
-- @class field
SF.DefaultEnvironment.CLIENT = CLIENT
--- Constant that denotes whether the code is executed on the server
-- @name SF.DefaultEnvironment.SERVER
-- @class field
SF.DefaultEnvironment.SERVER = SERVER

--- Returns the current count for this Think's CPU Time.
-- This value increases as more executions are done, may not be exactly as you want.
-- If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.
-- @return Current quota used this Think
function SF.DefaultEnvironment.quotaUsed ()
	return SF.instance.cpu_total
end

--- Gets the Average CPU Time in the buffer
-- @return Average CPU Time of the buffer.
function SF.DefaultEnvironment.quotaAverage ()
	return SF.instance.cpu_average
end

--- Gets the CPU Time max.
-- CPU Time is stored in a buffer of N elements, if the average of this exceeds quotaMax, the chip will error.
-- @return Max SysTime allowed to take for execution of the chip in a Think.
function SF.DefaultEnvironment.quotaMax ()
	return SF.instance.context.cpuTime.getMax()
end

-- The below modules have the Gmod functions removed (the ones that begin with a capital letter),
-- as requested by Divran

-- Filters Gmod Lua files based on Garry's naming convention.
local function filterGmodLua(lib, original, gm)
	original = original or {}
	gm = gm or {}
	for name, func in pairs(lib) do
		if name:match("^[A-Z]") then
			gm[name] = func
		else
			original[name] = func
		end
	end
	return original, gm
end

-- String library
local string_methods, string_metatable = SF.Typedef( "Library: string" )
filterGmodLua( string, string_methods )
string_metatable.__newindex = function () end

--- Lua's (not glua's) string library
-- @name SF.DefaultEnvironment.string
-- @class table
SF.DefaultEnvironment.string = setmetatable( {}, string_metatable )

-- Math library
local math_methods, math_metatable = SF.Typedef("Library: math")
filterGmodLua(math,math_methods)
math_metatable.__newindex = function() end
math_methods.clamp = math.Clamp
math_methods.angnorm = math.NormalizeAngle
math_methods.sign = function(a) return a>0 and 1 or -1 end
math_methods.round = math.Round
math_methods.randfloat = math.Rand
math_methods.calcBSplineN = nil
--- Lua's (not glua's) math library, plus clamp, angnorm, sign, round, and randfloat, calcBSplineN
-- @name SF.DefaultEnvironment.math
-- @class table
SF.DefaultEnvironment.math = setmetatable({},math_metatable)

local os_methods, os_metatable = SF.Typedef( "Library: os" )
filterGmodLua( os, os_methods )
os_metatable.__newindex = function () end
--- GLua's os library. http://wiki.garrysmod.com/page/Category:os, plus sortByKey, sortByMember
-- @name SF.DefaultEnvironment.os
-- @class table
SF.DefaultEnvironment.os = setmetatable( {}, os_metatable )

local table_methods, table_metatable = SF.Typedef("Library: table")
filterGmodLua(table,table_methods)
table_methods.sortByKey = table.SortByKey
table_methods.sortByMember = table.SortByMember
table_metatable.__newindex = function() end
--- Lua's (not glua's) table library
-- @name SF.DefaultEnvironment.table
-- @class table
SF.DefaultEnvironment.table = setmetatable({},table_metatable)

-- ------------------------- Functions ------------------------- --

--- Gets a list of all libraries
-- @return Table containing the names of each available library
function SF.DefaultEnvironment.getLibraries()
	local ret = {}
	for k,v in pairs( SF.Libraries.libraries ) do
		ret[#ret+1] = k
	end
	return ret
end



if SERVER then
	--- Prints a message to the player's chat.
	-- @shared
	-- @param ... Values to print
	function SF.DefaultEnvironment.print(...)
		local str = ""
		local tbl = {n=select('#', ...), ...}
		for i=1,tbl.n do str = str .. tostring(tbl[i]) .. (i == tbl.n and "" or "\t") end
		SF.instance.player:ChatPrint(str)
	end
else
	-- Prints a message to the player's chat.
	function SF.DefaultEnvironment.print(...)
		if SF.instance.player ~= LocalPlayer() then return end
		local str = ""
		local tbl = {n=select('#', ...), ...}
		for i=1,tbl.n do str = str .. tostring(tbl[i]) .. (i == tbl.n and "" or "\t") end
		LocalPlayer():ChatPrint(str)
	end
end

local function printTableX ( target, t, indent, alreadyprinted )
	for k,v in SF.DefaultEnvironment.pairs( t ) do
		if SF.GetType( v ) == "table" and not alreadyprinted[ v ] then
			alreadyprinted[ v ] = true
			target:ChatPrint( string.rep( "\t", indent ) .. tostring( k ) .. ":" )
			printTableX( target, v, indent + 1, alreadyprinted )
		else
			target:ChatPrint( string.rep( "\t", indent ) .. tostring( k ) .. "\t=\t" .. tostring( v ) )
		end
	end
end

--- Prints a table to player's chat
-- @param tbl Table to print
function SF.DefaultEnvironment.printTable ( tbl )
	if CLIENT and SF.instance.player ~= LocalPlayer() then return end
	SF.CheckType( tbl, "table" )

	printTableX( ( SERVER and SF.instance.player or LocalPlayer() ), tbl, 0, { t = true } )
end


--- Runs an included script and caches the result.
-- Works pretty much like standard Lua require()
-- @param file The file to include. Make sure to --@include it
-- @return Return value of the script
function SF.DefaultEnvironment.require(file)
	SF.CheckType(file, "string")
	local loaded = SF.instance.data.reqloaded
	if not loaded then
		loaded = {}
		SF.instance.data.reqloaded = loaded
	end
	
	if loaded[file] then
		return loaded[file]
	else
		local func = SF.instance.scripts[file]
		if not func then SF.throw( "Can't find file '" .. file .. "' (did you forget to --@include it?)", 2 ) end
		loaded[file] = func() or true
		return loaded[file]
	end
end

--- Runs an included script and caches the result.
-- Works pretty much like standard Lua require()
-- @param dir The directory to include. Make sure to --@includedir it
-- @param loadpriority Table of files that should be loaded before any others in the directory
-- @return Table of return values of the scripts
function SF.DefaultEnvironment.requiredir( dir, loadpriority )
    SF.CheckType( dir, "string")
    if loadpriority then SF.CheckType( loadpriority, "table" ) end
    
    local returns = {}

    if loadpriority then
        for i = 1, #loadpriority do
            for file, _ in pairs( SF.instance.scripts ) do
                if string.find( file, dir .. "/" .. loadpriority[ i ] , 1 ) == 1 then
                    returns[ file ] = SF.DefaultEnvironment.require( file )
                end
            end
        end
    end

	for file, _ in pairs( SF.instance.scripts ) do
		if string.find( file, dir, 1 ) == 1 and not returns[ file ] then
			returns[ file ] = SF.DefaultEnvironment.require( file )
		end
	end

    return returns
end

--- Runs an included script, but does not cache the result.
-- Pretty much like standard Lua dofile()
-- @param file The file to include. Make sure to --@include it
-- @return Return value of the script
function SF.DefaultEnvironment.dofile(file)
    SF.CheckType(file, "string")
    local func = SF.instance.scripts[file]
    if not func then SF.throw( "Can't find file '" .. file .. "' (did you forget to --@include it?)", 2 ) end
    return func()
end

--- Runs an included directory, but does not cache the result.
-- @param dir The directory to include. Make sure to --@includedir it
-- @param loadpriority Table of files that should be loaded before any others in the directory
-- @return Table of return values of the scripts
function SF.DefaultEnvironment.dodir( dir, loadpriority )
    SF.CheckType( dir, "string" )
    if loadpriority then SF.CheckType( loadpriority, "table" ) end

    local returns = {}

    if loadpriority then
        for i = 0, #loadpriority do
            for file, _ in pairs( SF.instance.scripts ) do
                if string.find( file, dir .. "/" .. loadpriority[ i ] , 1 ) == 1 then
                    returns[ file ] = SF.DefaultEnvironment.dofile( file )
                end
            end
        end
    end

    for file, _ in pairs( SF.instance.scripts ) do
		if string.find( file, dir, 1 ) == 1 then
			returns[ file ] = SF.DefaultEnvironment.dofile( file )
		end
    end

    return returns
end

--- GLua's loadstring
-- Works like loadstring, except that it executes by default in the main environment
-- @param str String to execute
-- @return Function of str
function SF.DefaultEnvironment.loadstring ( str )
	local func = CompileString( str, "SF: " .. tostring( SF.instance.env ), false )
	
	-- CompileString returns an error as a string, better check before setfenv
	if type( func ) == "function" then
		return setfenv( func, SF.instance.env )
	end
	
	return func
end

--- Lua's setfenv
-- Works like setfenv, but is restricted on functions
-- @param func Function to change environment of
-- @param tbl New environment
-- @return func with environment set to tbl
function SF.DefaultEnvironment.setfenv ( func, tbl )
	if type( func ) ~= "function" then SF.throw( "Main Thread is protected!", 2 ) end
	return setfenv( func, tbl )
end

--- Simple version of Lua's getfenv
-- Returns the current environment
-- @return Current environment
function SF.DefaultEnvironment.getfenv ()
	return getfenv()
end

--- Try to execute a function and catch possible exceptions
-- Similar to xpcall, but a bit more in-depth
-- @param func Function to execute
-- @param catch Optional function to execute in case func fails
function SF.DefaultEnvironment.try ( func, catch )
	local ok, err = pcall( func )
	if ok then return end

	if type( err ) == "table" then
		if err.uncatchable then
			error( err )
		end
	end
	if catch then catch( err ) end
end

--- Throws an exception
-- @param msg Message
-- @param level Which level in the stacktrace to blame. Defaults to one of invalid
-- @param uncatchable Makes this exception uncatchable
function SF.DefaultEnvironment.throw ( msg, level, uncatchable )
	local info = debug.getinfo( 1 + ( level or 1 ), "Sl" )
	local filename = info.short_src:match( "^SF:(.*)$" )
	if not filename then
		info = debug.getinfo( 2, "Sl" )
		filename = info.short_src:match( "^SF:(.*)$" )
	end
	local err = {
		uncatchable = false,
		file = filename,
		line = info.currentline,
		message = msg,
		uncatchable = uncatchable
	}
	error( err )
end

--- Throws a raw exception.
-- @param msg Exception message
function SF.DefaultEnvironment.error ( msg )
	error( msg or "an unspecified error occured", 2 )
end

--- Execute a console command
-- @param cmd Command to execute
function SF.DefaultEnvironment.concmd ( cmd )
	if CLIENT and SF.instance.player ~= LocalPlayer() then return end -- only execute on owner of screen
	SF.CheckType( cmd, "string" )
	SF.instance.player:ConCommand( cmd )
end

--- Set the value of a table index without invoking a metamethod
--@param table The table to modify
--@param key The index of the table
--@param value The value to set the index equal to
function SF.DefaultEnvironment.rawset( table, key, value )
    SF.CheckType( table, "table" )

    rawset( table, key, value )
end

--- Gets the value of a table index without invoking a metamethod
--@param table The table to get the value from
--@param key The index of the table
--@return The value of the index
function SF.DefaultEnvironment.rawget( table, key, value )
    SF.CheckType( table, "table" )

    return rawget( table, key )
end

-- ------------------------- Restrictions ------------------------- --
-- Restricts access to builtin type's metatables

local _R = debug.getregistry()
local function restrict(instance, hook, name, ok, err)
	_R.Vector.__metatable = "Vector"
	_R.Angle.__metatable = "Angle"
	_R.VMatrix.__metatable = "VMatrix"
end

local function unrestrict(instance, hook, name, ok, err)
	_R.Vector.__metatable = nil
	_R.Angle.__metatable = nil
	_R.VMatrix.__metatable = nil
end

SF.Libraries.AddHook("prepare", restrict)
SF.Libraries.AddHook("cleanup", unrestrict)


--------------------------- ENUMS -----------------------------------

local _KEY = {
	[ "FIRST" ] = 0,
	[ "NONE" ] = 0,
	[ "0" ] = 1,
	[ "1" ] = 2,
	[ "2" ] = 3,
	[ "3" ] = 4,
	[ "4" ] = 5,
	[ "5" ] = 6,
	[ "6" ] = 7,
	[ "7" ] = 8,
	[ "8" ] = 9,
	[ "9" ] = 10,
	[ "A" ] = 11,
	[ "B" ] = 12,
	[ "C" ] = 13,
	[ "D" ] = 14,
	[ "E" ] = 15,
	[ "F" ] = 16,
	[ "G" ] = 17,
	[ "H" ] = 18,
	[ "I" ] = 19,
	[ "J" ] = 20,
	[ "K" ] = 21,
	[ "L" ] = 22,
	[ "M" ] = 23,
	[ "N" ] = 24,
	[ "O" ] = 25,
	[ "P" ] = 26,
	[ "Q" ] = 27,
	[ "R" ] = 28,
	[ "S" ] = 29,
	[ "T" ] = 30,
	[ "U" ] = 31,
	[ "V" ] = 32,
	[ "W" ] = 33,
	[ "X" ] = 34,
	[ "Y" ] = 35,
	[ "Z" ] = 36,
	[ "KP_INS" ] = 37,
	[ "PAD_0" ] = 37,
	[ "KP_END" ] = 38,
	[ "PAD_1" ] = 38,
	[ "KP_DOWNARROW " ] = 39,
	[ "PAD_2" ] = 39,
	[ "KP_PGDN" ] = 40,
	[ "PAD_3" ] = 40,
	[ "KP_LEFTARROW" ] = 41,
	[ "PAD_4" ] = 41,
	[ "KP_5 " ] = 42,
	[ "PAD_5" ] = 42,
	[ "KP_RIGHTARROW" ] = 43,
	[ "PAD_6" ] = 43,
	[ "KP_HOME" ] = 44,
	[ "PAD_7" ] = 44,
	[ "KP_UPARROW" ] = 45,
	[ "PAD_8" ] = 45,
	[ "KP_PGUP" ] = 46,
	[ "PAD_9" ] = 46,
	[ "PAD_DIVIDE" ] = 47,
	[ "KP_SLASH" ] = 47,
	[ "KP_MULTIPLY" ] = 48,
	[ "PAD_MULTIPLY" ] = 48,
	[ "KP_MINUS" ] = 49,
	[ "PAD_MINUS" ] = 49,
	[ "KP_PLUS" ] = 50,
	[ "PAD_PLUS" ] = 50,
	[ "KP_ENTER" ] = 51,
	[ "PAD_ENTER" ] = 51,
	[ "KP_DEL" ] = 52,
	[ "PAD_DECIMAL" ] = 52,
	[ "[" ] = 53,
	[ "LBRACKET" ] = 53,
	[ "]" ] = 54,
	[ "RBRACKET" ] = 54,
	[ "SEMICOLON" ] = 55,
	[ "'" ] = 56,
	[ "APOSTROPHE" ] = 56,
	[ "`" ] = 57,
	[ "BACKQUOTE" ] = 57,
	[ "," ] = 58,
	[ "COMMA" ] = 58,
	[ "." ] = 59,
	[ "PERIOD" ] = 59,
	[ "/" ] = 60,
	[ "SLASH" ] = 60,
	[ "\\" ] = 61,
	[ "BACKSLASH" ] = 61,
	[ "-" ] = 62,
	[ "MINUS" ] = 62,
	[ "=" ] = 63,
	[ "EQUAL" ] = 63,
	[ "ENTER" ] = 64,
	[ "SPACE" ] = 65,
	[ "BACKSPACE" ] = 66,
	[ "TAB" ] = 67,
	[ "CAPSLOCK" ] = 68,
	[ "NUMLOCK" ] = 69,
	[ "ESCAPE" ] = 70,
	[ "SCROLLLOCK" ] = 71,
	[ "INS" ] = 72,
	[ "INSERT" ] = 72,
	[ "DEL" ] = 73,
	[ "DELETE" ] = 73,
	[ "HOME" ] = 74,
	[ "END" ] = 75,
	[ "PGUP" ] = 76,
	[ "PAGEUP" ] = 76,
	[ "PGDN" ] = 77,
	[ "PAGEDOWN" ] = 77,
	[ "PAUSE" ] = 78,
	[ "BREAK" ] = 78,
	[ "SHIFT" ] = 79,
	[ "LSHIFT" ] = 79,
	[ "RSHIFT" ] = 80,
	[ "ALT" ] = 81,
	[ "LALT" ] = 81,
	[ "RALT" ] = 82,
	[ "CTRL" ] = 83,
	[ "LCONTROL" ] = 83,
	[ "RCTRL" ] = 84,
	[ "RCONTROL" ] = 84,
	[ "LWIN" ] = 85,
	[ "RWIN" ] = 86,
	[ "APP" ] = 87,
	[ "UPARROW" ] = 88,
	[ "UP" ] = 88,
	[ "LEFTARROW" ] = 89,
	[ "LEFT" ] = 89,
	[ "DOWNARROW" ] = 90,
	[ "DOWN" ] = 90,
	[ "RIGHTARROW" ] = 91,
	[ "RIGHT" ] = 91,
	[ "F1" ] = 92,
	[ "F2" ] = 93,
	[ "F3" ] = 94,
	[ "F4" ] = 95,
	[ "F5" ] = 96,
	[ "F6" ] = 97,
	[ "F7" ] = 98,
	[ "F8" ] = 99,
	[ "F9" ] = 100,
	[ "F10" ] = 101,
	[ "F11" ] = 102,
	[ "F12" ] = 103,
	[ "CAPSLOCKTOGGLE" ] = 104,
	[ "NUMLOCKTOGGLE" ] = 105,
	[ "SCROLLLOCKTOGGLE" ] = 106,
	[ "LAST" ] = 106,
	[ "COUNT" ] = 106
}

--- ENUMs of keyboard keys for use with input library
-- @name SF.DefaultEnvironment.KEY
-- @class table
SF.DefaultEnvironment.KEY = setmetatable( {}, {
	__index = _KEY,
	__newindex = function( )
	end,
	__metatable = false
} )

local _MOUSE = {
	[ "MOUSE1" ] = 107,
	[ "LEFT" ] = 107,
	[ "MOUSE2" ] = 108,
	[ "RIGHT" ] = 108,
	[ "MOUSE3" ] = 109,
	[ "MIDDLE" ] = 109,
	[ "MOUSE4" ] = 110,
	[ "4" ] = 110,
	[ "MOUSE5"] = 111,
	[ "5" ] = 111,
	[ "MWHEELUP" ] = 112,
	[ "WHEEL_UP" ] = 112,
	[ "MWHEELDOWN" ] = 113,
	[ "WHEEL_DOWN" ] = 113,
	[ "COUNT" ] = 7,
	[ "FIRST" ] = 107,
	[ "LAST" ] = 113
}

--- ENUMs of mouse buttons for use with input library
-- @name SF.DefaultEnvironment.MOUSE
-- @class table
SF.DefaultEnvironment.MOUSE = setmetatable( {}, {
	__index = _MOUSE,
	__newindex = function( )
	end,
	__metatable = false
} )

local _INKEY = {
	[ "ALT1" ] = IN_ALT1,
	[ "ALT2" ] = IN_ALT2,
	[ "ATTACK" ] = IN_ATTACK,
	[ "ATTACK2" ] = IN_ATTACK2,
	[ "BACK" ] = IN_BACK,
	[ "DUCK" ] = IN_DUCK,
	[ "FORWARD" ] = IN_FORWARD,
	[ "JUMP" ] = IN_JUMP,
	[ "LEFT" ] = IN_LEFT,
	[ "MOVELEFT" ] = IN_MOVELEFT,
	[ "MOVERIGHT" ] = IN_MOVERIGHT,
	[ "RELOAD" ] = IN_RELOAD,
	[ "RIGHT" ] = IN_RIGHT,
	[ "SCORE" ] = IN_SCORE,
	[ "SPEED" ] = IN_SPEED,
	[ "USE" ] = IN_USE,
	[ "WALK" ] = IN_WALK,
	[ "ZOOM" ] = IN_ZOOM,
	[ "GRENADE1" ] = IN_GRENADE1,
	[ "GRENADE2" ] = IN_GRENADE2,
	[ "WEAPON1" ] = IN_WEAPON1,
	[ "WEAPON2" ] = IN_WEAPON2,
	[ "BULLRUSH" ] = IN_BULLRUSH,
	[ "CANCEL" ] = IN_CANCEL,
	[ "RUN" ] = IN_RUN,
}

--- ENUMs of in_keys for use with player:keyDown
-- @name SF.DefaultEnvironment.IN_KEY
-- @class table
SF.DefaultEnvironment.IN_KEY = setmetatable( {}, {
	__index = _INKEY,
	__newindex = function( )
	end,
	__metatable = false
} )
