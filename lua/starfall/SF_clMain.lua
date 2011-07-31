
--------------------------- Variables ---------------------------

SF_Compiler = {}
SF_Compiler.hooks = {}
SF_Compiler.modules = {}

function SF_Compiler.ReloadLibraries()
	print("SF: Loading clientside libraries...")
	SF_Compiler.modules = {}
	SF_Compiler.hooks = {}
	do
		local l = file.FindInLua("starfall/sflibs/*.lua")
		for _,filename in pairs(l) do
			if string.sub(filename,-7,-1) == "_cl.lua" then
				MsgN("SF: Including sflibs/"..filename)
				include("sflibs/"..filename)
			end
		end
	end
	print("SF: End loading libraries")
end
--concommand.Add("sf_reload_libraries",SF_Compiler.ReloadLibraries,nil,"Reloads starfall libraries")
SF_Compiler.ReloadLibraries()