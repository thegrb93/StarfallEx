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

-- Types
SFLib.types = {}
function SFLib:AddType(name, tbl)
	if types[name] == nil then
		self.types[name] = tbl
	else
		error("Starfall: Type "..name.." defined more than once")
	end
end

SFLib.functions = {}

function SFLib:FuncToStr(name, base, args)
	-- Returns a string representation of a function.
	-- Note: the function doesn't have to be defined.
	
	local out = ""
	if base then
		out = base..":"
	end
	out = out .. name
	for _,arg in ipairs(args) do
		out = out .. arg .. ","
	end
	return out:sub(1,out:len()-1)
end

function SFLib:FuncTypToStr(base, args)
	-- Returns the string type of a function
	-- [base]:arg1,arg2,arg3
	-- There is a ":" even if no base type is available
	
	local imploded = string.Implode(args,",")
	return (base or "") .. ":" .. imploded
end

local function get_or_add(tbl, key)
	if tbl[key] then return tbl[key]
	else
		tbl[key] = {}
		return tbl[key]
	end
end

function SFLib:AddFunction(name, base, args, rt, func)
	local node = get_or_add(self.functions, name)
	
	local key = (base or "")..":"..string.Implode(args,",")
	if node[key] then
		error("Starfall: Function " .. self:FuncToStr(name, base, args) .. " defined more than once")
	end
	
	node[key] = func
	node["rt:"..key] = rt
end

function SFLib:GetFunction(name, base, args)
	local node = SFLib.functions[name]
	if not node then return nil end
	
	local imploded = string.Implode(",",args)
	if node[imploded] then
		-- Exact match
		return node[imploded], node["rt:"..imploded]
	end
	
	-- No match, look for ellipsis
	for i=#args,0,-1 do
		local str = ""
		for j=1,i do
			str = str .. args[j] .. ","
		end
		str = str .. "..."
		if node[str] then
			return node[str], node["rt:"..str]
		end
	end
	
	-- No match
	return nil
end

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

