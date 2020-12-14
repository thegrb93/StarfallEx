include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH


function ENT:Initialize()
	self.BaseClass.Initialize(self)

	net.Start("starfall_processor_link")
		net.WriteUInt(self:EntIndex(), 16)
	net.SendToServer()
end

function ENT:Draw()
	self:DrawModel()
end

local ConnectHUD, DisconnectHUD

local Hint_FirstPrint = true
function ConnectHUD(ent)
	ent:CallOnRemove("sf_hud_unlink_on_remove", DisconnectHUD)
	if (Hint_FirstPrint) then
		LocalPlayer():ChatPrint("Starfall HUD Connected. NOTE: Type 'sf_hud_unlink' in the console to disconnect yourself from all HUDs.")
		Hint_FirstPrint = nil
	else
		LocalPlayer():ChatPrint("Starfall HUD Connected.")
	end
	SF.ActiveHuds[ent] = true

	if not (ent.link and ent.link:IsValid()) then return end
	local instance = ent.link.instance
	if not instance then return end
	instance:runScriptHook("hudconnected", instance.WrapObject(ent))
	instance:RunHook("starfall_hud_connected", ent)
end

function DisconnectHUD(ent)
	ent:RemoveCallOnRemove("sf_hud_unlink_on_remove")
	LocalPlayer():ChatPrint("Starfall HUD Disconnected.")
	SF.ActiveHuds[ent] = nil

	if not (ent.link and ent.link:IsValid()) then return end
	local instance = ent.link.instance
	if not instance then return end
	instance:runScriptHook("huddisconnected", instance.WrapObject(ent))
	instance:RunHook("starfall_hud_disconnected", ent)
end

net.Receive("starfall_hud_set_enabled" , function()
	local ent = net.ReadEntity()
	local enable = net.ReadInt(8)
	if ent:IsValid() then
		if SF.ActiveHuds[ent] then
			if (enable == -1 or enable == 0) then
				DisconnectHUD(ent)
			end
		else
			if (enable == -1 or enable == 1) then
				ConnectHUD(ent)
			end
		end
	end
end)

concommand.Add("sf_hud_unlink", function()
	for ent, _ in pairs(SF.ActiveHuds) do
		DisconnectHUD(ent) --Should be valid or something horrible has happened.
	end
	LocalPlayer():ChatPrint("Disconnected from all Starfall HUDs.")
end)
