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
		tbl._registered = true
	end
end

local function add_placeholder_type(name)
	if SFLib.types[name] then return end
	SFLib.types[name] = {_registered = false}
end

-- Functions without a base type
SFLib.functions = {}

function SFLib:AddFunction(name, base, args)
	local basetable
	if base == nil then
		basetable = self.functions
	else
		if not self.types[base] 
		basetable = SFLib.types
	end
end

function SFLib:FinalizeFunctions()
	for name, tbl in pairs(SFLib.types) do
		if not tbl._registered then
			Msg("[W] Undeclared type " .. name .. "\n")
		end
	end
end