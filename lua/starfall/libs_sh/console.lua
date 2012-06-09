
--- Console functions. Allows execution of console commands and accessing convars
-- Changing of convars and execution of concommands requires a clientside
-- convar to be set. That convar is 'starfall_console_enable_sv' if the
-- SF instance is serverside and 'starfall_console_enable_cl' if the instance
-- is clientside.
-- @shared
local console_library, _ = SF.Libraries.Register("console")

if CLIENT then
	CreateClientConVar("starfall_console_enable_sv", "0", true, true)
	CreateClientConVar("starfall_console_enable_cl", "0", true, true)
end

local consoleEnableVar = CLIENT and "starfall_console_enable_cl" or "starfall_console_enable_sv"
local function canExecCmd(ply, cmd)
	if not ply:IsValid() then return false end
	if ply:GetInfoNum(consoleEnableVar) == 0 then return false end
	return true
end

--- Executes a console command on 
function console_library.exec(command)
	SF.CheckType(command, "string")
	if not canExecCmd(SF.instance.player, command) then return false end
	SF.instance.player:ConCommand(command:gsub("%%", "%%%%"))
	return true
end
