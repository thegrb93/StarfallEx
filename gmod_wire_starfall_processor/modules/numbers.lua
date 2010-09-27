local type_number = {}

type_number._zero = 0
-- "lua" means to translate the statement to use lua operators in the script.
-- Ex. 1 + 2 translates to 1 + 2 in lua and not SFLib.types.number.ops.add(1, 2)
type_number._op_add = "lua"
type_number._op_sub = "lua"
type_number._op_mul = "lua"
type_number._op_div = "lua"

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
end