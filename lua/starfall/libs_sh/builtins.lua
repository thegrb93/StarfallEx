-------------------------------------------------------------------------------
-- Builtins.
-- Functions built-in to the default environment
-------------------------------------------------------------------------------

SF.DefaultEnvironment = {}

--- Built in values. These don't need to be loaded; they are in the default environment.
-- @name builtin
-- @shared
-- @class library
-- @libtbl SF.DefaultEnvironment

--- Returns the entity representing a processor that this script is running on.
-- @name SF.DefaultEnvironment.chip
-- @class function
-- @return Starfall entity
SF.DefaultEnvironment.chip = nil

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

--- Generates the CRC checksum of the specified string. (https://en.wikipedia.org/wiki/Cyclic_redundancy_check)
-- @name SF.DefaultEnvironment.crc
-- @class function
-- @param stringToHash The string to calculate the checksum of
-- @return The unsigned 32 bit checksum as a string
SF.DefaultEnvironment.crc = util.CRC

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

--- Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.
-- @param quota The threshold where the soft error will be thrown. Ratio of current cpu to the max cpu usage. 0.5 is 50% 
function SF.DefaultEnvironment.setSoftQuota ( quota )
	SF.CheckType( quota, "number" )
	SF.instance.cpu_softquota = quota
end

-- String library
local string_methods = SF.Libraries.Register("string" )
string_methods.byte=string.byte
string_methods.char=string.char
string_methods.comma=string.Comma
string_methods.dump=string.dump
string_methods.endsWith=string.EndsWith
string_methods.explode=string.Explode
string_methods.find=string.find
string_methods.format=string.format
string_methods.formattedTime=string.FormattedTime
string_methods.getChar=string.GetChar
string_methods.getExtensionFromFilename=string.GetExtensionFromFilename
string_methods.getFileFromFilename=string.GetFileFromFilename
string_methods.getPathFromFilename=string.GetPathFromFilename
string_methods.gfind=string.gfind
string_methods.gmatch=string.gmatch
string_methods.gsub=string.gsub
string_methods.implode=string.Implode
string_methods.javascriptSafe=string.JavascriptSafe
string_methods.left=string.Left
string_methods.len=string.len
string_methods.lower=string.lower
string_methods.match=string.match
string_methods.niceSize=string.NiceSize
string_methods.niceTime=string.NiceTime
string_methods.patternSafe=string.PatternSafe
string_methods.replace=string.Replace
string_methods.reverse=string.reverse
string_methods.right=string.Right
string_methods.setChar=string.SetChar
string_methods.split=string.Split
string_methods.startWith=string.StartWith
string_methods.stripExtension=string.StripExtension
string_methods.sub=string.sub
string_methods.toMinutesSeconds=string.ToMinutesSeconds
string_methods.toMinutesSecondsMilliseconds=string.ToMinutesSecondsMilliseconds
string_methods.toTable=string.ToTable
string_methods.trim=string.Trim
string_methods.trimLeft=string.TrimLeft
string_methods.trimRight=string.TrimRight
string_methods.upper=string.upper
local rep_chunk = 1000000
function string_methods.rep(str, rep, sep)
	if rep < 0.5 then return "" end
	
	local ret = {}
	for i = 1, rep / rep_chunk do
		ret[#ret+1] = string.rep( str, rep_chunk, sep )
	end
	
	local r = rep%rep_chunk
	if r>0.5 then
		ret[#ret+1] = string.rep(str, r, sep)
	end
	
	return table.concat(ret, sep)
end
function string_methods.fromColor( color )
	return string.FromColor( SF.UnwrapObject( color ) )
end
function string_methods.toColor( str )
	return SF.WrapObject( string.ToColor( str ) )
end
--- String library http://wiki.garrysmod.com/page/Category:string
-- @name SF.DefaultEnvironment.string
-- @class table
SF.DefaultEnvironment.string = nil

-- Math library
local math_methods = SF.Libraries.Register("math")
math_methods.abs=math.abs
math_methods.acos=math.acos
math_methods.angleDifference=math.AngleDifference
math_methods.approach=math.Approach
math_methods.approachAngle=math.ApproachAngle
math_methods.asin=math.asin
math_methods.atan=math.atan
math_methods.atan2=math.atan2
math_methods.binToInt=math.BinToInt
math_methods.calcBSplineN=math.calcBSplineN
math_methods.ceil=math.ceil
math_methods.clamp=math.Clamp
math_methods.cos=math.cos
math_methods.cosh=math.cosh
math_methods.deg=math.deg
math_methods.dist=math.Dist
math_methods.distance=math.Distance
math_methods.easeInOut=math.EaseInOut
math_methods.exp=math.exp
math_methods.floor=math.floor
math_methods.fmod=math.fmod
math_methods.frexp=math.frexp
math_methods.huge=math.huge
math_methods.intToBin=math.IntToBin
math_methods.ldexp=math.ldexp
math_methods.log=math.log
math_methods.log10=math.log10
math_methods.max=math.max
math_methods.min=math.Min
math_methods.mod=math.mod
math_methods.modf=math.modf
math_methods.normalizeAngle=math.NormalizeAngle
math_methods.pi=math.pi
math_methods.pow=math.pow
math_methods.rad=math.rad
math_methods.rand=math.Rand
math_methods.random=math.random
math_methods.randomseed=math.randomseed
math_methods.remap=math.Remap
math_methods.round=math.Round
math_methods.sin=math.sin
math_methods.sinh=math.sinh
math_methods.sqrt=math.sqrt
math_methods.tan=math.tan
math_methods.tanh=math.tanh
math_methods.timeFraction=math.TimeFraction
math_methods.truncate=math.Truncate
function math_methods.bSplinePoint( tDiff, tPoints, tMax )
	return SF.WrapObject( math.BSplinePoint( tDiff, SF.Unsanitize( tPoints ), tMax ) )
end
function math_methods.lerp( percent, from, to )
	SF.CheckType( percent, "number" )
	SF.CheckType( from, "number" )
	SF.CheckType( to, "number" )
	
	return Lerp( percent, from, to )
end
function math_methods.lerpAngle( percent, from, to )
	SF.CheckType( percent, "number" )
	SF.CheckType( from, SF.Types[ "Angle" ] )
	SF.CheckType( to, SF.Types[ "Angle" ] )
	
	return SF.WrapObject( LerpAngle( percent, SF.UnwrapObject( from ), SF.UnwrapObject( to ) ) )
end
function math_methods.lerpVector( percent, from, to )
	SF.CheckType( percent, "number" )
	SF.CheckType( from, SF.Types[ "Vector" ] )
	SF.CheckType( to, SF.Types[ "Vector" ] )
	
	return SF.WrapObject( LerpVector( percent, SF.UnwrapObject( from ), SF.UnwrapObject( to ) ) )
end
--- The math library. http://wiki.garrysmod.com/page/Category:math
-- @name SF.DefaultEnvironment.math
-- @class table
SF.DefaultEnvironment.math = nil

local os_methods = SF.Libraries.Register( "os" )
os_methods.clock=os.clock
os_methods.date=os.date
os_methods.difftime=os.difftime
os_methods.time=os.time
--- The os library. http://wiki.garrysmod.com/page/Category:os
-- @name SF.DefaultEnvironment.os
-- @class table
SF.DefaultEnvironment.os = nil

local table_methods = SF.Libraries.Register("table")
table_methods.add=table.Add
table_methods.clearKeys=table.ClearKeys
table_methods.collapseKeyValue=table.CollapseKeyValue
table_methods.concat=table.concat
table_methods.copy=table.Copy
table_methods.copyFromTo=table.CopyFromTo
table_methods.count=table.Count
table_methods.empty=table.Empty
table_methods.findNext=table.FindNext
table_methods.findPrev=table.FindPrev
table_methods.forceInsert=table.ForceInsert
table_methods.forEach=table.ForEach
table_methods.foreachi=table.foreachi
table_methods.getFirstKey=table.GetFirstKey
table_methods.getFirstValue=table.GetFirstValue
table_methods.getKeys=table.GetKeys
table_methods.getLastKey=table.GetLastKey
table_methods.getLastValue=table.GetLastValue
table_methods.getn=table.getn
table_methods.getWinningKey=table.GetWinningKey
table_methods.hasValue=table.HasValue
table_methods.inherit=table.Inherit
table_methods.insert=table.insert
table_methods.isSequential=table.IsSequential
table_methods.keyFromValue=table.KeyFromValue
table_methods.keysFromValue=table.KeysFromValue
table_methods.lowerKeyNames=table.LowerKeyNames
table_methods.maxn=table.maxn
table_methods.merge=table.Merge
table_methods.random=table.Random
table_methods.remove=table.remove
table_methods.removeByValue=table.RemoveByValue
table_methods.reverse=table.Reverse
table_methods.sort=table.sort
table_methods.sortByKey=table.SortByKey
table_methods.sortByMember=table.SortByMember
table_methods.sortDesc=table.SortDesc
table_methods.toString=table.ToString
--- Table library. http://wiki.garrysmod.com/page/Category:table
-- @name SF.DefaultEnvironment.table
-- @class table
SF.DefaultEnvironment.table = nil

local bit_methods = SF.Libraries.Register("bit")
bit_methods.arshift=bit.arshift
bit_methods.band=bit.band
bit_methods.bnot=bit.bnot
bit_methods.bor=bit.bor
bit_methods.bswap=bit.bswap
bit_methods.bxor=bit.bxor
bit_methods.lshift=bit.lshift
bit_methods.rol=bit.rol
bit_methods.ror=bit.ror
bit_methods.rshift=bit.rshift
bit_methods.tobit=bit.tobit
bit_methods.tohex=bit.tohex
--- Bit library. http://wiki.garrysmod.com/page/Category:bit
-- @name SF.DefaultEnvironment.bit
-- @class table
SF.DefaultEnvironment.bit = nil

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


local luaTypes = {
	nil,
	true,
	0,
	function() end,
	coroutine.create(function() end)
}
for i=1, 5 do
	local luaType = luaTypes[i]
	local meta = debug.getmetatable(luaType)
	if meta then
		SF.Libraries.AddHook( "prepare", function()
			debug.setmetatable( luaType, nil )
		end )
		SF.Libraries.AddHook( "cleanup", function() 
			debug.setmetatable( luaType, meta )
		end )
	end
end
local gluastr = debug.getmetatable( "" )
SF.Libraries.AddHook( "prepare", function()
	debug.setmetatable( "", {__index = function(self, key)
		local val = string_methods[ key ]
		if ( val ) then
			return val
		elseif ( tonumber( key ) ) then
			return self:sub( key, key )
		else
			SF.throw( "attempt to index a string value with bad key ('" .. tostring( key ) .. "' is not part of the string library)", 2 )
		end
	end} )
end )
SF.Libraries.AddHook( "cleanup", function() 
	debug.setmetatable( "", gluastr )
end )


if CLIENT then	
	--- Sets the chip's display name
	-- @client
	-- @param name Name
	function SF.DefaultEnvironment.setName( name )
		SF.CheckType( name, "string" )
		local e = SF.instance.data.entity
		if IsValid( e ) then
			e.name = name
		end
	end
	
	--- Sets clipboard text. Only works on the owner of the chip.
	-- @param txt Text to set to the clipboard
	function SF.DefaultEnvironment.setClipboardText( txt )
		if SF.instance.player ~= LocalPlayer() then return end
		SF.CheckType( txt, "string" )
		SetClipboardText( txt )
	end
	
	--- Prints a message to your chat, console, or the center of your screen.
	-- @param mtype How the message should be displayed. See http://wiki.garrysmod.com/page/Enums/HUD
	-- @param text The message text.
	function SF.DefaultEnvironment.printMessage( mtype, text )
		if SF.instance.player ~= LocalPlayer() then return end
		SF.CheckType( text, "string" )
		SF.instance.player:PrintMessage( mtype, text )
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

-- Prints a message to the player's chat.
-- @shared
-- @param ... Values to print
function SF.DefaultEnvironment.print(...)
	if CLIENT and SF.instance.player ~= LocalPlayer() then return end
	local str = ""
	local tbl = {n=select('#', ...), ...}
	for i=1,tbl.n do str = str .. tostring(tbl[i]) .. (i == tbl.n and "" or "\t") end
	( SERVER and SF.instance.player or LocalPlayer() ):ChatPrint(str)
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
	
	
	local path
	if string.sub(file,1,1)=="/" then
		path = SF.NormalizePath( file )
	else
		path = SF.NormalizePath( string.GetPathFromFilename( string.sub( debug.getinfo( 2, "S" ).source, 5 ) ) .. file )
		if not SF.instance.scripts[path] then
			path = SF.NormalizePath( file )
		end
	end
	
	if loaded[path] then
		return loaded[path]
	else
		local func = SF.instance.scripts[path]
		if not func then SF.throw( "Can't find file '" .. path .. "' (did you forget to --@include it?)", 2 ) end
		loaded[path] = func() or true
		return loaded[path]
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
	local path
	if string.sub(file,1,1)=="/" then
		path = SF.NormalizePath( file )
	else
		path = SF.NormalizePath( string.GetPathFromFilename( string.sub( debug.getinfo( 2, "S" ).source, 5 ) ) .. file )
		if not SF.instance.scripts[path] then
			path = SF.NormalizePath( file )
		end
	end
    local func = SF.instance.scripts[path]
    if not func then SF.throw( "Can't find file '" .. path .. "' (did you forget to --@include it?)", 2 ) end
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
	if type( func ) ~= "function" or getfenv( func ) == _G then SF.throw( "Main Thread is protected!", 2 ) end
	return setfenv( func, tbl )
end

--- Simple version of Lua's getfenv
-- Returns the current environment
-- @return Current environment
function SF.DefaultEnvironment.getfenv ()
	local fenv = getfenv(2)
	if fenv ~= _G then return fenv end
end

--- GLua's getinfo()
-- Returns a DebugInfo structure containing the passed function's info (https://wiki.garrysmod.com/page/Structures/DebugInfo)
-- @param funcOrStackLevel Function or stack level to get info about. Defaults to stack level 0.
-- @param fields A string that specifies the information to be retrieved. Defaults to all (flnSu).
-- @return DebugInfo table
function SF.DefaultEnvironment.debugGetInfo ( funcOrStackLevel, fields )
	local TfuncOrStackLevel = type(funcOrStackLevel)
	if TfuncOrStackLevel~="function" and TfuncOrStackLevel~="number" then SF.throw( "Type mismatch (Expected function or number, got " .. TfuncOrStackLevel .. ") in function debugGetInfo", 2 ) end
	if fields then SF.CheckType(fields, "string") end
	
	local ret = debug.getinfo( funcOrStackLevel, fields )
	if ret then
		ret.func = nil
		return ret
	end
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
	elseif err == "not enough memory" then
		SF.throw( err, 0, true )
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


SF.Permissions.registerPrivilege( "console.command", "Console command", "Allows the starfall to run console commands", {Client = {default = 4}} )
--- Execute a console command
-- @param cmd Command to execute
function SF.DefaultEnvironment.concmd ( cmd )
	SF.CheckType( cmd, "string" )
	SF.Permissions.check( SF.instance.player, nil, "console.command" )
	if CLIENT then
		LocalPlayer():ConCommand( cmd )
	else
		SF.instance.player:ConCommand( cmd )
	end
end

--- Returns if the table has an isValid function and isValid returns true.
--@param object Table to check
--@return If it is valid
function SF.DefaultEnvironment.isValid( object )

	if ( !object ) then return false end
	if ( !object.isValid ) then return false end

	return object:isValid()

end
