if SERVER then
	AddCSLuaFile("SF_Load.lua")
	AddCSLuaFile("starfall/SF_clMain.lua")
	AddCSLuaFile("starfall/SF_Preprocessor.lua")
	
	include("starfall/SF_Permissions.lua")
	include("starfall/SF_Main.lua")
else
	include("starfall/SF_clMain.lua")
	include("starfall/SF_Preprocessor.lua")
end