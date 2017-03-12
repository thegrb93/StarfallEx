include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_BOTH

local render = render

surface.CreateFont( "Starfall_ErrorFont", {
	font = "arial",
	size = 26,
	weight = 200
} )

net.Receive( "starfall_processor_used", function ( len )
	local screen = net.ReadEntity()
	local activator = net.ReadEntity()
	if not IsValid( screen ) then return end
	
	if IsValid( screen.link ) then
	
		if screen.link.instance then
			screen.link.instance:runScriptHook( "starfallused", SF.Entities.Wrap( activator ) )
		end
		
		-- Error message copying
		if activator == LocalPlayer() then
			if screen.link.error and screen.link.error.message then
				SetClipboardText( string.format( "%q", screen.link.error.message ) )
			elseif screen:GetDTString( 0 ) then
				SetClipboardText( screen:GetDTString( 0 ) )
			end
		end
	end
end )

function ENT:Initialize ()
	self.BaseClass.Initialize( self )
	
	net.Start( "starfall_processor_update_links" )
		net.WriteEntity( LocalPlayer() )
		net.WriteEntity( self )
	net.SendToServer()
	
	local info = self.Monitor_Offsets[ self:GetModel() ]
	if info then
		local rotation, translation, translation2, scale = Matrix(), Matrix(), Matrix(), Matrix()
		rotation:SetAngles(info.rot)
		translation:SetTranslation(info.offset)
		translation2:SetTranslation(Vector(-256/info.RatioX,-256,0))
		scale:SetScale(Vector(info.RS,info.RS,info.RS))
		
		self.ScreenMatrix = translation * rotation * scale * translation2
		self.ScreenInfo = info
		self.Aspect = info.RatioX
		self.Scale = info.RS
		self.Origin = info.offset
	end
end

function ENT:LinkEnt ( ent )
	self.link = ent
end

function ENT:RenderScreen()
	if IsValid( self.link ) then
		local instance = self.link.instance
		if instance then
			if SF.Permissions.hasAccess( instance.player, nil, "render.screen" ) then
				local data = instance.data

				data.render.renderEnt = self
				data.render.isRendering = true
				data.render.useStencil = true
				draw.NoTexture()
				surface.SetDrawColor( 255, 255, 255, 255 )

				instance:runScriptHook( "render" )

				data.render.isRendering = nil
			end
		elseif self.link.error then
			local error = self.link.error
			surface.SetTexture( 0 )
			surface.SetDrawColor( 0, 0, 0, 120 )
			surface.DrawRect( 0, 0, 512, 512 )

			draw.DrawText( "Error occurred in Starfall:", "Starfall_ErrorFont", 32, 16, Color( 0, 255, 255, 255 ) ) -- Cyan
			draw.DrawText( tostring( error.message ), "Starfall_ErrorFont", 16, 80, Color( 255, 0, 0, 255 ) )
			if error.source and error.line then
				draw.DrawText( "Line: " .. tostring( error.line), "Starfall_ErrorFont", 16, 512 - 16 * 7, Color( 255, 255, 255, 255 ) )
				draw.DrawText( "Source: " .. error.source, "Starfall_ErrorFont", 16, 512 - 16 * 5, Color( 255, 255, 255, 255 ) )
			end
		end
	end
end

function ENT:Draw ()
	self:DrawModel()
end

function ENT:DrawTranslucent ()
	self:DrawModel()
	
	if halo.RenderedEntity() == self or not self.ScreenInfo then return end
	-- Draw screen here
	local transform = self:GetBoneMatrix(0) * self.ScreenMatrix
	self.Transform = transform
	cam.Start({type = "3D", znear = 3.001})
	cam.PushModelMatrix( transform )
		render.ClearStencil()
		render.SetStencilEnable( true )
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
		render.SetStencilWriteMask( 1 )
		render.SetStencilReferenceValue( 1 )

		render.OverrideDepthEnable( true, true )
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,512/self.Aspect,512)
		render.OverrideDepthEnable( false )

		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		render.SetStencilTestMask( 1 )
		
		render.PushFilterMag( TEXFILTER.ANISOTROPIC )
		render.PushFilterMin( TEXFILTER.ANISOTROPIC )
		
		self:RenderScreen()
		
		render.PopFilterMag()
		render.PopFilterMin()
		
		render.SetStencilEnable( false )
	cam.PopModelMatrix()
	cam.End()
end

function ENT:GetResolution()
	return 512/self.Aspect, 512
end

ENT.Monitor_Offsets = {
	["models//cheeze/pcb/pcb4.mdl"] = {
		Name	=	"pcb4.mdl",
		RS	=	0.0625,
		RatioX	=	1,
		offset	=	Vector(0, 0, 0.5),
		rot	=	Angle(0, 0, 180),
		x1	=	-16,
		x2	=	16,
		y1	=	-16,
		y2	=	16,
		z	=	0.5,
	},
	["models//cheeze/pcb/pcb5.mdl"] = {
		Name	=	"pcb5.mdl",
		RS	=	0.0625,
		RatioX	=	0.508,
		offset	=	Vector(-0.5, 0, 0.5),
		rot	=	Angle(0, 0, 180),
		x1	=	-31.5,
		x2	=	31.5,
		y1	=	-16,
		y2	=	16,
		z	=	0.5,
	},
	["models//cheeze/pcb/pcb6.mdl"] = {
		Name	=	"pcb6.mdl",
		RS	=	0.09375,
		RatioX	=	0.762,
		offset	=	Vector(-0.5, -8, 0.5),
		rot	=	Angle(0, 0, 180),
		x1	=	-31.5,
		x2	=	31.5,
		y1	=	-24,
		y2	=	24,
		z	=	0.5,
	},
	["models//cheeze/pcb/pcb7.mdl"] = {
		Name	=	"pcb7.mdl",
		RS	=	0.125,
		RatioX	=	1,
		offset	=	Vector(0, 0, 0.5),
		rot	=	Angle(0, 0, 180),
		x1	=	-32,
		x2	=	32,
		y1	=	-32,
		y2	=	32,
		z	=	0.5,
	},
	["models//cheeze/pcb/pcb8.mdl"] = {
		Name	=	"pcb8.mdl",
		RS	=	0.125,
		RatioX	=	0.668,
		offset	=	Vector(15.885, 0, 0.5),
		rot	=	Angle(0, 0, 180),
		x1	=	-47.885,
		x2	=	47.885,
		y1	=	-32,
		y2	=	32,
		z	=	0.5,
	},
	["models/cheeze/pcb2/pcb8.mdl"] = {
		Name	=	"pcb8.mdl",
		RS	=	0.2475,
		RatioX	=	0.99,
		offset	=	Vector(0, 0, 0.3),
		rot	=	Angle(0, 0, 180),
		x1	=	-64,
		x2	=	64,
		y1	=	-63.36,
		y2	=	63.36,
		z	=	0.3,
	},
	["models/blacknecro/tv_plasma_4_3.mdl"] = {
		Name	=	"Plasma TV (4:3)",
		RS	=	0.082,
		RatioX	=	0.751,
		offset	=	Vector(0, -0.1, 0),
		rot	=	Angle(0, 0, -90),
		x1	=	-27.87,
		x2	=	27.87,
		y1	=	-20.93,
		y2	=	20.93,
		z	=	0.1,
	},
	["models/hunter/blocks/cube1x1x1.mdl"] = {
		Name	=	"Cube 1x1x1",
		RS	=	0.09,
		RatioX	=	1,
		offset	=	Vector(24, 0, 0),
		rot	=	Angle(0, 90, -90),
		x1	=	-48,
		x2	=	48,
		y1	=	-48,
		y2	=	48,
		z	=	24,
	},
	["models/hunter/plates/plate05x05.mdl"] = {
		Name	=	"Panel 0.5x0.5",
		RS	=	0.045,
		RatioX	=	1,
		offset	=	Vector(0, 0, 1.7),
		rot	=	Angle(0, 90, 180),
		x1	=	-48,
		x2	=	48,
		y1	=	-48,
		y2	=	48,
		z	=	0,
	},
	["models/hunter/plates/plate1x1.mdl"] = {
		Name	=	"Panel 1x1",
		RS	=	0.09,
		RatioX	=	1,
		offset	=	Vector(0, 0, 2),
		rot	=	Angle(0, 90, 180),
		x1	=	-48,
		x2	=	48,
		y1	=	-48,
		y2	=	48,
		z	=	0,
	},
	["models/hunter/plates/plate2x2.mdl"] = {
		Name	=	"Panel 2x2",
		RS	=	0.182,
		RatioX	=	1,
		offset	=	Vector(0, 0, 2),
		rot	=	Angle(0, 90, 180),
		x1	=	-48,
		x2	=	48,
		y1	=	-48,
		y2	=	48,
		z	=	0,
	},
	["models/hunter/plates/plate4x4.mdl"] = {
		Name	=	"plate4x4.mdl",
		RS	=	0.3707,
		RatioX	=	1,
		offset	=	Vector(0, 0, 2),
		rot	=	Angle(0, 90, 180),
		x1	=	-94.9,
		x2	=	94.9,
		y1	=	-94.9,
		y2	=	94.9,
		z	=	1.7,
	},
	["models/hunter/plates/plate8x8.mdl"] = {
		Name	=	"plate8x8.mdl",
		RS	=	0.741,
		RatioX	=	1,
		offset	=	Vector(0, 0, 2),
		rot	=	Angle(0, 90, 180),
		x1	=	-189.8,
		x2	=	189.8,
		y1	=	-189.8,
		y2	=	189.8,
		z	=	1.7,
	},
	["models/hunter/plates/plate16x16.mdl"] = {
		Name	=	"plate16x16.mdl",
		RS	=	1.482,
		RatioX	=	1,
		offset	=	Vector(0, 0, 2),
		rot	=	Angle(0, 90, 180),
		x1	=	-379.6,
		x2	=	379.6,
		y1	=	-379.6,
		y2	=	379.6,
		z	=	1.7,
	},
	["models/hunter/plates/plate24x24.mdl"] = {
		Name	=	"plate24x24.mdl",
		RS	=	2.223,
		RatioX	=	1,
		offset	=	Vector(0, 0, 2),
		rot	=	Angle(0, 90, 180),
		x1	=	-569.4,
		x2	=	569.4,
		y1	=	-569.4,
		y2	=	569.4,
		z	=	1.7,
	},
	["models/hunter/plates/plate32x32.mdl"] = {
		Name	=	"plate32x32.mdl",
		RS	=	2.964,
		RatioX	=	1,
		offset	=	Vector(0, 0, 2),
		rot	=	Angle(0, 90, 180),
		x1	=	-759.2,
		x2	=	759.2,
		y1	=	-759.2,
		y2	=	759.2,
		z	=	1.7,
	},
	["models/kobilica/wiremonitorbig.mdl"] = {
		Name	=	"Monitor Big",
		RS	=	0.045,
		RatioX	=	0.991,
		offset	=	Vector(0.2, -0.4, 13),
		rot	=	Angle(0, 0, -90),
		x1	=	-11.5,
		x2	=	11.6,
		y1	=	1.6,
		y2	=	24.5,
		z	=	0.2,
	},
	["models/kobilica/wiremonitorsmall.mdl"] = {
		Name	=	"Monitor Small",
		RS	=	0.0175,
		RatioX	=	1,
		offset	=	Vector(0, -0.4, 5),
		rot	=	Angle(0, 0, -90),
		x1	=	-4.4,
		x2	=	4.5,
		y1	=	0.6,
		y2	=	9.5,
		z	=	0.3,
	},
	["models/props/cs_assault/billboard.mdl"] = {
		Name	=	"Billboard",
		RS	=	0.23,
		RatioX	=	0.522,
		offset	=	Vector(2, 0, 0),
		rot	=	Angle(0, 90, -90),
		x1	=	-110.512,
		x2	=	110.512,
		y1	=	-57.647,
		y2	=	57.647,
		z	=	1,
	},
	["models/props/cs_militia/reload_bullet_tray.mdl"] = {
		Name	=	"Tray",
		RS	=	0,
		RatioX	=	0.6,
		offset	=	Vector(0, 0, 0.8),
		rot	=	Angle(0, 90, 180),
		x1	=	0,
		x2	=	100,
		y1	=	0,
		y2	=	60,
		z	=	0,
	},
	["models/props/cs_office/computer_monitor.mdl"] = {
		Name	=	"LCD Monitor (4:3)",
		RS	=	0.031,
		RatioX	=	0.767,
		offset	=	Vector(3.3, 0, 16.7),
		rot	=	Angle(0, 90, -90),
		x1	=	-10.5,
		x2	=	10.5,
		y1	=	8.6,
		y2	=	24.7,
		z	=	3.3,
	},
	["models/props/cs_office/tv_plasma.mdl"] = {
		Name	=	"Plasma TV (16:10)",
		RS	=	0.065,
		RatioX	=	0.5965,
		offset	=	Vector(6.1, 0, 18.93),
		rot	=	Angle(0, 90, -90),
		x1	=	-28.5,
		x2	=	28.5,
		y1	=	2,
		y2	=	36,
		z	=	6.1,
	},
	["models/props_lab/monitor01b.mdl"] = {
		Name	=	"Small TV",
		RS	=	0.0185,
		RatioX	=	1.0173,
		offset	=	Vector(6.53, -1, 0.45),
		rot	=	Angle(0, 90, -90),
		x1	=	-5.535,
		x2	=	3.5,
		y1	=	-4.1,
		y2	=	5.091,
		z	=	6.53,
	},
	["models/props_lab/workspace002.mdl"] = {
		Name	=	"Workspace 002",
		RS	=	0.06836,
		RatioX	=	0.9669,
		offset	=	Vector(-42.133224, -42.372322, 42.110897),
		rot	=	Angle(0, 133.340, -120.317),
		x1	=	-18.1,
		x2	=	18.1,
		y1	=	-17.5,
		y2	=	17.5,
		z	=	42.1109,
	},
	["models/props_mining/billboard001.mdl"] = {
		Name	=	"TF2 Red billboard",
		RS	=	0.375,
		RatioX	=	0.5714,
		offset	=	Vector(3.5, 0, 96),
		rot	=	Angle(0, 90, -90),
		x1	=	-168,
		x2	=	168,
		y1	=	-96,
		y2	=	96,
		z	=	96,
	},
	["models/props_mining/billboard002.mdl"] = {
		Name	=	"TF2 Red vs Blue billboard",
		RS	=	0.375,
		RatioX	=	0.3137,
		offset	=	Vector(3.5, 0, 192),
		rot	=	Angle(0, 90, -90),
		x1	=	-306,
		x2	=	306,
		y1	=	-96,
		y2	=	96,
		z	=	192,
	}
}