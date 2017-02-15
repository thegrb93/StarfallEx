include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_BOTH


function ENT:Initialize ()
	self.BaseClass.Initialize( self )
	
	net.Start( "starfall_processor_update_links" )
		net.WriteEntity( LocalPlayer() )
		net.WriteEntity( self )
	net.SendToServer()
end

function ENT:LinkEnt ( ent )
	self.link = ent
end

function ENT:Draw ()
	self:DrawModel()
end

function ENT:DrawHUD( hookname, ... )
	if not self.link or not self.link.instance then return end
	
	local instance = self.link.instance
	local data = instance.data
	
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )
	
	data.render.renderEnt = self
	data.render.isRendering = true
	draw.NoTexture()
	surface.SetDrawColor( 255, 255, 255, 255 )
	
	instance:runScriptHook( hookname, ... )
	
	render.PopFilterMag()
	render.PopFilterMin()
	data.render.isRendering = nil
end


function ENT:DoCalcView(ply, pos, ang, fov, znear, zfar)
	if IsValid( self.link ) then
		local tbl = self.link:runScriptHookForResult( "calcview", SF.WrapObject( pos ),  SF.WrapObject( ang ), fov, znear, zfar )
		local ok, rt = tbl[1], tbl[2] 
		if ok and type(rt) == "table" then
			return {origin = SF.UnwrapObject( rt.origin ), angles = SF.UnwrapObject( rt.angles ), fov = rt.fov, znear = rt.znear, zfar = rt.zfar, drawviewer = rt.drawviewer}
		end
	end
end

function ENT:GetResolution()
	return ScrW(), ScrH()
end

SF.ConnectedHuds = {}
local hook_pref = "starfall_hud_hook_"
local ConnectHUD, DisconnectHUD

local Hint_FirstPrint = true
function ConnectHUD( ent )
	local hookname = hook_pref..ent:EntIndex()
	ent:CallOnRemove( "sf_hud_unlink_on_remove", DisconnectHUD ) 
	hook.Add("HUDPaint", hookname, function() ent:DrawHUD("render") end)
	hook.Add("PreDrawOpaqueRenderables", hookname, function(...) ent:DrawHUD("predrawopaquerenderables", ...) end)
	hook.Add("PostDrawOpaqueRenderables", hookname, function(...) ent:DrawHUD("postdrawopaquerenderables", ...) end)
	hook.Add("CalcView", hookname, function(...) return ent:DoCalcView(...) end)
	if (Hint_FirstPrint) then
		LocalPlayer():ChatPrint("Starfall HUD Connected. NOTE: Type 'sf_hud_unlink' in the console to disconnect yourself from all HUDs.")
		Hint_FirstPrint = nil
	else
		LocalPlayer():ChatPrint("Starfall HUD Connected.")
	end
	SF.ConnectedHuds[ent] = true
	hook.Run( "starfall_hud_connect", ent )
end

function DisconnectHUD( ent )
	local hookname = hook_pref..ent:EntIndex()
	hook.Remove("HUDPaint", hookname)
	hook.Remove("PreDrawOpaqueRenderables", hookname)
	hook.Remove("PostDrawOpaqueRenderables", hookname)
	hook.Remove("CalcView", hookname)
	LocalPlayer():ChatPrint("Starfall HUD Disconnected.")
	SF.ConnectedHuds[ent] = nil
	hook.Run( "starfall_hud_disconnect", ent )
end

net.Receive( "starfall_hud_set_enabled" , function()
	local ent = net.ReadEntity()
	local enable = net.ReadInt(8)
	if IsValid(ent) then		
		if SF.ConnectedHuds[ent] then
			if ( enable == -1 or enable == 0 ) then
				DisconnectHUD(ent)
			end
		else
			if ( enable == -1 or enable == 1 ) then
				ConnectHUD(ent)
			end
		end
	end
end)

concommand.Add("sf_hud_unlink",function()
	for ent, _ in pairs(SF.ConnectedHuds) do
		DisconnectHUD(ent) --Should be valid or something horrible has happened.
	end
	LocalPlayer():ChatPrint("Disconnected from all Starfall HUDs.")
end)
