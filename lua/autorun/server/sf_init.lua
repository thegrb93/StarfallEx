AddCSLuaFile("starfall/sflib.lua")
AddCSLuaFile("starfall/instance.lua")
AddCSLuaFile("starfall/preprocessor.lua")
AddCSLuaFile("starfall/permissions/core.lua")
AddCSLuaFile("starfall/netstream.lua")
AddCSLuaFile("starfall/transfer.lua")
AddCSLuaFile("starfall/editor/editor.lua")

resource.AddFile("materials/models/spacecode/glass.vmt")
resource.AddFile("materials/models/spacecode/sfchip.vmt")
resource.AddFile("materials/models/spacecode/sfpcb.vmt")
resource.AddFile("materials/radon/starfall2.vmt")
resource.AddFile("materials/radon/arrow_left.png")
resource.AddFile("materials/radon/arrow_right.png")
resource.AddFile("models/spacecode/sfchip.mdl")
resource.AddFile("models/spacecode/sfchip_medium.mdl")
resource.AddFile("models/spacecode/sfchip_small.mdl")
resource.AddFile("resource/fonts/DejaVuSansMono.ttf")
resource.AddFile("resource/fonts/RobotoMono.ttf")
resource.AddFile("resource/fonts/FontAwesome.ttf")

SF = {}
SF.Version = "StarfallEx"
local files, directories = file.Find( "addons/*", "GAME" )
local sf_dir = nil
for k,v in pairs(directories) do
	if file.Exists("addons/"..v.."/lua/starfall/sflib.lua", "GAME") then
		sf_dir = "addons/"..v.."/"
		break
	end
end
if sf_dir then
	local head = file.Read(sf_dir..".git/HEAD","GAME") -- Where head points to
	if head then
		head = head:sub(6,-2) -- skipping ref: and new line
		local lastCommit = file.Read( sf_dir..".git/"..head, "GAME")

		if lastCommit then
			SF.Version = SF.Version .. "_" .. lastCommit:sub(1,7) -- We need only first 7 to be safely unique
		end
	end
end
SetGlobalString("SF.Version", SF.Version)


include("starfall/sflib.lua")
