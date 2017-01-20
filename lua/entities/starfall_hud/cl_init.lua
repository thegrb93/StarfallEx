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


local hook_pref = "starfall_hud_hook_"
local Hint_FirstPrint = true
net.Receive( "starfall_hud_set_enabled" , function()
	local ent = net.ReadEntity()
	local enable = net.ReadInt(8)
	if IsValid(ent) then
		local hook_table = hook.GetTable().HUDPaint
		local hook_name = hook_pref .. ent:EntIndex()
		if hook_table[ hook_name ] then
			if ( enable == -1 or enable == 0 ) then
				hook.Remove("HUDPaint", hook_name)
				hook.Remove("PreDrawOpaqueRenderables", hook_name)
				hook.Remove("PostDrawOpaqueRenderables", hook_name)
				hook.Remove("CalcView", hook_name) 
				LocalPlayer():ChatPrint("Starfall HUD Disconnected.")
			end
		else
			if ( enable == -1 or enable == 1 ) then
				ent:CallOnRemove( "sf_hud_unlink_on_remove", function() 
					hook.Remove("HUDPaint", hook_name)
					hook.Remove("PreDrawOpaqueRenderables", hook_name)
					hook.Remove("PostDrawOpaqueRenderables", hook_name)
					hook.Remove("CalcView", hook_name) 
				end ) 
				hook.Add("HUDPaint", hook_name, function() ent:DrawHUD("render") end)
				hook.Add("PreDrawOpaqueRenderables", hook_name, function(...) ent:DrawHUD("predrawopaquerenderables", ...) end)
				hook.Add("PostDrawOpaqueRenderables", hook_name, function(...) ent:DrawHUD("postdrawopaquerenderables", ...) end)
				hook.Add("CalcView", hook_name, function(...) return ent:DoCalcView(...) end)
				if (Hint_FirstPrint) then
					LocalPlayer():ChatPrint("Starfall HUD Connected. NOTE: Type 'sf_hud_unlink' in the console to disconnect yourself from all HUDs.")
					Hint_FirstPrint = nil
				else
					LocalPlayer():ChatPrint("Starfall HUD Connected.")
				end
			end
		end
	end
end)

concommand.Add("sf_hud_unlink",function()
	local hook_table = hook.GetTable().HUDPaint
	for k, v in pairs(hook_table) do
		if k:sub(1, #hook_pref) == hook_pref then
			hook.Remove("HUDPaint", k)
		end
	end
	LocalPlayer():ChatPrint("Disconnected from all Starfall HUDs.")
end)


