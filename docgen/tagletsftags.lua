
--- Taglet Tags for Starfall, mostly copied from LuaDocs.

local luadoc = require "luadoc"
local util = require "luadoc.util"
local string = require "string"
local table = require "table"
local assert, type, tostring = assert, type, tostring

module "tagletsftags"

-------------------------------------------------------------------------------

local function author (tag, block, text)
	block[tag] = block[tag] or {}
	if not text then
		luadoc.logger:warn("author `name' not defined [["..text.."]]: skipping")
		return
	end
	table.insert (block[tag], text)
end

local function check_class( line )
	line = util.trim( line )

	local tblref = line:match( "^%s*local%s+([%w_]+).-=" )

	return tblref
end

-------------------------------------------------------------------------------
-- Set the class of a comment block. Classes can be "module", "function", 
-- "table". The first two classes are automatic, extracted from the source code

local function class (tag, block, text)
	block[tag] = text
	if text == "hook" then block.param = block.param or {} end
	if text == "class" then
		block.typtbl = check_class( block.code[ 1 ] )
	end
	block.classForced = true
end

local function copyright (tag, block, text)
	block[tag] = text
end

local function description (tag, block, text)
	block[tag] = text
end

local function library(tag, block, text)
	block[tag] = text
end

local function libtbl(tag, block, text)
	block[tag] = text
end

local function entity(tag, block, text)
	block[tag] = text
end

local function include(tag, block, text)
	-- Supress "undefined handler for tag `include'" warnings as the --@include
	-- preprocessing parameter appears a couple of times.
end

-------------------------------------------------------------------------------

local function field ( tag, block, text )
	if block.class ~= "table" and block.class ~= "library" and block.class ~= "class" then
		luadoc.logger:warn( "documenting `field' for block that is not a table, library or class" )
	end
	block[tag] = block[tag] or {}

	local _, _, name, desc = string.find(text, "^([_%w%.]+)%s*(.*)")
	assert(name, "field name not defined")
	
	table.insert(block[tag], name)
	block[tag][name] = desc
end

-------------------------------------------------------------------------------
-- Set the name of the comment block. If the block already has a name, issue
-- an error and do not change the previous value

local function name (tag, block, text)
	if block[tag] and block[tag] ~= text then
		luadoc.logger:error(string.format("block name conflict: `%s' -> `%s'", block[tag], text))
	end
	
	block[tag] = text
end

-------------------------------------------------------------------------------
-- Processes a parameter documentation.
-- @param tag String with the name of the tag (it must be "param" always).
-- @param block Table with previous information about the block.
-- @param text String with the current line beeing processed.

local function param (tag, block, text)
	block[tag] = block[tag] or {}
	local i
	
	local _, _, name, desc = string.find(text, "^([_%w%.]+)%s*(.*)")
	if not name then
		luadoc.logger:warn("parameter `name' not defined [["..text.."]]: skipping")
		return
	end
	
	i = table.foreachi(block[tag], function (i, v)
		if v == name then
			return i
		end
	end)
	
	if i == nil then
		if not block.classForced then
			luadoc.logger:warn(string.format("documenting undefined parameter `%s'", name))
		end
		table.insert(block[tag], name)
	end
	block[tag][name] = desc
end

-------------------------------------------------------------------------------

local function release (tag, block, text)
	block[tag] = text
end

-------------------------------------------------------------------------------

local function ret (tag, block, text)
	tag = "ret"
	if type(block[tag]) == "string" then
		block[tag] = { block[tag], text }
	elseif type(block[tag]) == "table" then
		table.insert(block[tag], text)
	else
		block[tag] = text
	end
end

-------------------------------------------------------------------------------
-- @see ret

local function see (tag, block, text)
	-- see is always an array
	block[tag] = block[tag] or {}
	
	-- remove trailing "."
	text = string.gsub(text, "(.*)%.$", "%1")
	
	local s = util.split("%s*,%s*", text)			
	
	table.foreachi(s, function (_, v)
		table.insert(block[tag], v)
	end)
end

-------------------------------------------------------------------------------
-- @see ret

local function usage (tag, block, text)
	if type(block[tag]) == "string" then
		block[tag] = { block[tag], text }
	elseif type(block[tag]) == "table" then
		table.insert(block[tag], text)
	else
		block[tag] = text
	end
end

-------------------------------------------------------------------------------

local function deprecated ( tag, block, text )
	block[tag] = text
end

local function side(tag, block, text)
	block[tag] = true
end

local function shared(tag, block, text)
	block.client = true
	block.server = true
end

-------------------------------------------------------------------------------

local handlers = {}
handlers[ "author" ] = author
handlers[ "class" ] = class
handlers[ "copyright" ] = copyright
handlers[ "description" ] = description
handlers[ "field" ] = field
handlers[ "name" ] = name
handlers[ "param" ] = param
handlers[ "release" ] = release
handlers[ "return" ] = ret
handlers[ "see" ] = see
handlers[ "usage" ] = usage
handlers[ "deprecated" ] = deprecated
handlers[ "library" ] = library
handlers[ "libtbl" ] = libtbl
handlers[ "entity" ] = entity
handlers[ "client" ] = side
handlers[ "server" ] = side
handlers[ "shared" ] = shared
handlers[ "include" ] = include

-------------------------------------------------------------------------------

function handle (tag, block, text)
	if not handlers[tag] then
		luadoc.logger:error(string.format("undefined handler for tag `%s'", tag))
		return
	end
--	assert(handlers[tag], string.format("undefined handler for tag `%s'", tag))
	return handlers[tag](tag, block, text)
end
