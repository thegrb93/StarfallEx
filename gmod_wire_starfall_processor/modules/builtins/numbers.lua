local type_number = {}

type_number._zero = 0

-- List of all types compatible with all arithmetic operators
type_number._op_arit_compatible = {"number"=true}
-- "lua" means to translate the statement to use lua operators in the script.
-- Ex. 1 + 2 translates to 1 + 2 in lua and not SFLib.types.number._op_add(1, 2)
type_number._op_add = "lua"
type_number._op_sub = "lua"
type_number._op_mul = "lua"
type_number._op_div = "lua"

SFLib:AddFunction("abs", nil, "number", "number", function(x)
	return math.abs(x)
end)

SFLib:AddFunction("sum", nil, "...", "number", function(...)
	local x = {...}
	local sum = 0
	for _,i in ipairs(x) do
		if type(x) ~= "number" then continue end
		sum = sum + i
	end
	return sum
end)

--[[
sffunction number abs(number x)
	return math.abs(x)
end

sffunction number sum(number x, ...)
	local sum = 0
	
	for i,val in ipairs(varargs) do
		if vartypes[i] ~= "number" then
			error("Argument is not a number",0)
		end
		sum = sum + val
	end
	
	return sum
end]]