--[[---------------------------------------]
   [ Starfall Library                      ]
   [ By Colonel Thirty Two                 ]
   [---------------------------------------]]

AddCSLuaFile("SFLib.lua")
SFLib = SFLib or {}

function SFLib.limitString(text, length)
	if #text <= length then
		return text
	else
		return string.sub(text, 1, length) .. "..."
	end
end

-- TODO: Load this
SFLib.builtins = {}

-- Operators
SFLib.optree_inv = {
	add  = "+",
	sub  = "-",
	mul  = "*",
	div  = "/",
	mod  = "%",
	exp  = "^",
	
	ass  = "=",
	aadd = "+=",
	asub = "-=",
	amul = "*=",
	adiv = "/=",
	
	inc  = "++",
	dec  = "--",
	
	eq   = "==",
	neq  = "!=",
	lth  = "<",
	geq  = ">=",
	leq  = "<=",
	gth  = ">",
	
	["not"] = "not",
	["and"] = "and",
	["or"] = "or",
	
	qsm  = "?",
	col  = ":",
	def  = "?:",
	com  = ",",
	
	lpa  = "(",
	rpa  = ")",
	rcb  = "{",
	lcb  = "}",
	lsb  = "[",
	rsb  = "]",
	
	trg  = "~",
	imp  = "->",
}

SFLib.optree = {}
for token,op in pairs(SFLib.optree_inv) do
	local current = SFLib.optree
	for i = 1,#op do
		local c = op:sub(i,i)
		local nxt = current[c]
		if not nxt then
			nxt = {}
			current[c] = nxt
		end

		if i == #op then
			nxt[1] = token
		else
			if not nxt[2] then
				nxt[2] = {}
			end

			current = nxt[2]
		end
	end
end

function SFLib.GetType(data)
	local lua_type = type(data)
	if lua_type ~= "table" then return lua_type end
	return data.type
end

function SFLib.GetClass(data)
	local lua_type = type(data)
	if lua_type ~= "table" then
		return SFLib.builtins[lua_type:sub(1,1):upper()..lua_type:sub(2)]
	end
	
	return getmetatable(data)
end

-- ---------------------------------------- --
-- Lua Function Overloading                 --
-- ---------------------------------------- --
-[[ Copyright 2010, Declan White (Deco Da Man), All rights reserved. ]]

local new_data =
        debug.getuservalue
    and function(data, mt)
        local o = newproxy()
        debug.setuservalue(o, data)
        debug.setmetatable(o, mt)
        return o
    end
    or  function(data, mt)
        return setmetatable(data, mt)
    end
;
local get_data =
        debug.getuservalue
    or  function(o) return o end
;

local OVERLOAD_META = {
    __call = function(self, ...)
        local args, args_n = {...}, select('#', ...)
        local sublevel = get_data(self)
        local levels = {sublevel}
        for arg_i = 1, args_n do
            sublevel = sublevel[type(args[arg_i])]
            if not sublevel then
                for level_i = #levels, 1, -1 do
                    if levels[level_i]._ then
                        return levels[level_i]._(unpack(args))
                    end
                end
                local type_stack = {}
                for arg_2i = 1, args_n do
                    table.insert(type_stack, type(args[arg_2i])..(arg_2i == arg_i and "*" or ""))
                end
                error("no matching overload ("..table.concat(type_stack, ",")..")", 2)
            end
            table.insert(levels, sublevel)
        end
        if sublevel._ then
            sublevel._(unpack(args))
        end
    end,
}

function SFLib.overload(overloads)
    return new_data(overloads, OVERLOAD_META)
end

-- Adds newfunc, an actual lua function, to oldfunc, an overloaded function,
-- with the additional types being arguments
-- Added by Colonel Thirty Two
function SFLib.addoverload(oldfunc,newfunc,...)
	local node = oldfunc
	for _,d in ipairs(...) do
		if node[d] then
			node = node[d]
		else
			node[d] = {}
			node = node[d]
		end
	end
	node["_"] = newfunc
end

-- example usage
--[[
test = OVERLOAD{
    ["number"] = {
        ["table"] = {
            _ = function(n, t, ...)
                print("n, t", n, t, ...)
            end,
        },
        ["string"] = {
            _ = function(n, s, ...)
                print("n, s", n, s, ...)
            end,
            ["number"] = {
                _ = function(n, s, n2, ...)
                    print("n, s, n", n, s, n2, ...)
                end,
            },
            ["string"] = {
                ["number"] = {
                    _ = function(n, s, s2, n2, ...)
                        print("n, s, s, n", n, s, s2, n2, ...)
                    end
                }
            }
        },
    },
    ["string"] = function(s, ...)
        print("s", s, ...)
    end,
    ["boolean"] = function(b, ...)
        print("b", b, ...)
    end,
} ]]

-- ---------------------------------------- --
-- Per-Player Ops Counters                  --
-- ---------------------------------------- --
SFLib.ops = {}

hook.Add("PlayerInitialSpawn", "sf_perplayer_ops", function(ply)
	SFLib.ops[ply] = 0
end)
hook.Add("PlayerDisconnected", "sf_perplayer_ops_dc",function(ply)
	SFLib.ops[ply] = nil
end)

