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
	if not IsValid(self.link) then return end
	local instance = self.link.instance
	if not instance then return end
	
	local data = instance.data
	
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )
	
	data.render.renderEnt = self
	data.render.isRendering = true
	data.render.useStencil = false
	draw.NoTexture()
	surface.SetDrawColor( 255, 255, 255, 255 )
	
	instance:runScriptHook( hookname, ... )
	
	render.PopFilterMag()
	render.PopFilterMin()
	data.render.isRendering = nil
end


function ENT:DoCalcView(ply, pos, ang, fov, znear, zfar)
	if not IsValid(self.link) then return end
	local instance = self.link.instance
	if not instance then return end

	local tbl = instance:runScriptHookForResult( "calcview", SF.WrapObject( pos ),  SF.WrapObject( ang ), fov, znear, zfar )
	local ok, rt = tbl[1], tbl[2] 
	if ok and type(rt) == "table" then
		return {origin = SF.UnwrapObject( rt.origin ), angles = SF.UnwrapObject( rt.angles ), fov = rt.fov, znear = rt.znear, zfar = rt.zfar, drawviewer = rt.drawviewer}
	end
end

function ENT:GetResolution()
	return ScrW(), ScrH()
end

SF.ActiveHuds = {}
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
	SF.ActiveHuds[ent] = true
	
	if not IsValid(ent.link) then return end
	local instance = ent.link.instance
	if not instance then return end
	instance:runScriptHook( "hudconnected", SF.Entities.Wrap( ent ) )
	SF.Libraries.CallHook( "starfall_hud_connected", instance, ent )
end

function DisconnectHUD( ent )
	local hookname = hook_pref..ent:EntIndex()
	hook.Remove("HUDPaint", hookname)
	hook.Remove("PreDrawOpaqueRenderables", hookname)
	hook.Remove("PostDrawOpaqueRenderables", hookname)
	hook.Remove("CalcView", hookname)
	LocalPlayer():ChatPrint("Starfall HUD Disconnected.")
	SF.ActiveHuds[ent] = nil
	
	if not IsValid(ent.link) then return end
	local instance = ent.link.instance
	if not instance then return end
	instance:runScriptHook( "huddisconnected", SF.Entities.Wrap( ent ) )
	SF.Libraries.CallHook( "starfall_hud_disconnected", instance, ent )
end

net.Receive( "starfall_hud_set_enabled" , function()
	local ent = net.ReadEntity()
	local enable = net.ReadInt(8)
	if IsValid(ent) then		
		if SF.ActiveHuds[ent] then
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
	for ent, _ in pairs(SF.ActiveHuds) do
		DisconnectHUD(ent) --Should be valid or something horrible has happened.
	end
	LocalPlayer():ChatPrint("Disconnected from all Starfall HUDs.")
end)
