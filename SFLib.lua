--[[---------------------------------------]
   [ Starfall Library                      ]
   [ By Colonel Thirty Two                 ]
   [---------------------------------------]]

local SFLib = SFLib or {}

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
		for k,v in pairs(self.types[name]) do
			tbl[k] = v
		end
		self.types[name] = tbl
	end
end

-- Functions without a base type.
-- This is a Tree; the first node is the base type (or "_none_")
-- All other nodes are argument types, or "_ellipsis_"
SFLib.functions = {_none_ = {}}
-- Name = true pairs, used for checking variables
SFLib.global_functions = {}

local function get_or_add(tbl, key)
	if tbl[key] then return tbl[key] end
	else
		tbl[key] = {}
		return tbl[key]
	end
end

function SFLib:AddFunction(func, name, base, args)
	local node
	if base == nil then
		node = self.functions._none_
		self.global_functions[name] = true
	else
		node = self.functions[base]
		if node == nil then
			error("No such type: "..base,0)
		end
	end
	
	for _,arg in ipairs(args) do
		if not self.types[arg] then
			error("No such type: "..arg,0)
		end
		node = get_or_add(node, arg)
	end
	
	node[name] = func
end

function SFLib:GetFunction(name, base, args)
	local node
	if base == nil then node = self.functions._none_
	else node = self.functions[base] end
	
	local closest_ellipsis = nil
	for _,arg in ipairs(args) do
		if node._ellipsis_ and node._ellipsis_.name then
			closest_ellipsis = node._ellipsis_.name
		end
		
		if node[arg] then
			node = node[arg]
		else
			return closest_ellipsis
		end
	end
	
	return node[name] or closest_ellipsis
end

function SFLib:FinalizeFunctions()
	for name, tbl in pairs(SFLib.types) do
		if not tbl._registered then
			Msg("[W] Undeclared type " .. name .. "\n")
		end
	end
end