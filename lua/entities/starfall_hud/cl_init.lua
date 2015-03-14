include( "shared.lua" )

--ENT.RenderGroup = RENDERGROUP_OPAQUE


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
	baseclass.Get( self.Base ).Draw( self )
	self:DrawModel()
	Wire_Render( self )
end

function ENT:DrawHUD()
	if not self.link or not self.link.instance then return end
	
	local instance = self.link.instance
	local data = instance.data
	
	data.render.isRendering = true
	draw.NoTexture()
	surface.SetDrawColor( 255, 255, 255, 255 )

	if instance.hooks[ "render" ] then
		local ok, rt = instance:runScriptHook( "render" )
		if not ok then self:Error( rt ) end
	end

	if data.render.usingRT then
		render.PopRenderTarget()
		data.render.usingRT = false
	end
	data.render.isRendering = nil
end


function ENT:DoCalcView(ply, pos, ang, fov, znear, zfar)
	if not self.link or not self.link.instance then return end
	
	local instance = self.link.instance
	if instance.hooks[ "calcview" ] then
		local ok, rt = instance:runScriptHookForResult( "calcview", SF.WrapObject( pos ),  SF.WrapObject( ang ), fov, znear, zfar)
		if ok then
			if rt and type(rt) == "table" then
				return {origin = SF.UnwrapObject( rt.origin ), angles = SF.UnwrapObject( rt.angles ), fov = rt.fov, znear = rt.znear, zfar = rt.zfar, drawviewer = rt.drawviewer}
			end
		else
			self:Error( rt )
		end
	end
end


local hook_pref = "starfall_hud_hook_"

net.Receive( "starfall_hud_set_enabled" , function()
	local ent = net.ReadEntity()
	local enable = net.ReadInt(8)
	if IsValid(ent) then
		local hook_table = hook.GetTable().HUDPaint
		local hook_name = hook_pref .. ent:EntIndex()
		if hook_table[ hook_name ] and ( enable == -1 or enable == 0 ) then
			hook.Remove("HUDPaint", hook_name)
			hook.Remove("CalcView", hook_name) 
			LocalPlayer():ChatPrint("Starfall HUD Disconnected.")
		else
			ent:CallOnRemove( "sf_hud_unlink_on_remove", function() 
				hook.Remove("HUDPaint", hook_name) 
				hook.Remove("CalcView", hook_name) 
			end ) 
			hook.Add("HUDPaint", hook_name, function() ent:DrawHUD() end)
			hook.Add("CalcView", hook_name, function() return ent:DoCalcView() end)
			if (Hint_FirstPrint) then
				LocalPlayer():ChatPrint("Starfall HUD Connected. NOTE: Type 'sf_hud_unlink' in the console to disconnect yourself from all HUDs.")
				Hint_FirstPrint = nil
			else
				LocalPlayer():ChatPrint("Starfall HUD Connected.")
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


