local hooked_contexts = {}

SF_Compiler.AddFunction("hook", function(name, func)
	if name == nil or type(name) ~= "string" or not (func == nil or type(func) == "function") then error("Illegal arguments to hook()",0) end
	
	local context = SF_Compiler.currentChip
	if not hooked_contexts[context] then hooked_contexts[context] = {} end
	hooked_context[context][name] = func
end)