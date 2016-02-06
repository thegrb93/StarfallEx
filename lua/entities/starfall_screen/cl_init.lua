include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_OPAQUE

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
	
	if screen.link then
		local instance = screen.link.instance
		if instance and instance.hooks[ "starfallUsed" ] then
			local ok, rt, tb = instance:runScriptHook( "starfallUsed", SF.Entities.Wrap( activator ) )
			if not ok then 
				screen.link:Error( rt, tb )
				screen:Error( rt, tb ) 
			end
		end
	end
	
	-- Error message copying
	if activator == LocalPlayer() then
		if screen.error then
			SetClipboardText( string.format( "%q", screen.error.orig ) )
		elseif screen:GetDTString( 0 ) then
			SetClipboardText( screen:GetDTString( 0 ) )
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
	end
end

function ENT:Error ( msg, traceback )
	
	-- Process error message
	self.error = {}
	self.error.orig = msg
	self.error.source, self.error.line, self.error.msg = string.match( msg, "%[@?SF:(%a+):(%d+)](.+)$" )

	if not self.error.source or not self.error.line or not self.error.msg then
		self.error.source, self.error.line, self.error.msg = nil, nil, msg
	else
		self.error.msg = string.TrimLeft( self.error.msg )
	end
	
end

function ENT:LinkEnt ( ent )
	self.link = ent
end

function ENT:RenderScreen()
	if self.link and self.link.instance then
		local instance = self.link.instance
		local data = instance.data
		
		data.render.matricies = 0
		data.render.renderEnt = self
		data.render.isRendering = true
		draw.NoTexture()
		surface.SetDrawColor( 255, 255, 255, 255 )

		if instance.hooks[ "render" ] then
			local ok, rt, tb = instance:runScriptHook( "render" )
			if not ok then
				self.link:Error( rt, tb )
				self:Error( rt, tb ) 
			end
		end

		if data.render.usingRT then
			render.PopRenderTarget()
			data.render.usingRT = false
		end
		data.render.isRendering = nil
		
	elseif self.error then
		surface.SetTexture( 0 )
		surface.SetDrawColor( 0, 0, 0, 120 )
		surface.DrawRect( 0, 0, 512, 512 )
		
		draw.DrawText( "Error occurred in Starfall:", "Starfall_ErrorFont", 32, 16, Color( 0, 255, 255, 255 ) ) -- Cyan
		draw.DrawText( tostring( self.error.msg ), "Starfall_ErrorFont", 16, 80, Color( 255, 0, 0, 255 ) )
		if self.error.source and self.error.line then
			draw.DrawText( "Line: " .. tostring( self.error.line), "Starfall_ErrorFont", 16, 512 - 16 * 7, Color( 255, 255, 255, 255 ) )
			draw.DrawText( "Source: " .. self.error.source, "Starfall_ErrorFont", 16, 512 - 16 * 5, Color( 255, 255, 255, 255 ) )
		end
	end
end

function ENT:Draw ()
	self:DrawModel()
	Wire_Render( self )
	
	if halo.RenderedEntity() == self or not self.ScreenInfo then return end
	-- Draw screen here
	cam.PushModelMatrix( self:GetBoneMatrix(0) * self.ScreenMatrix )
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

		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		render.SetStencilTestMask( 1 )
		render.OverrideDepthEnable( false )
		
		render.PushFilterMag( TEXFILTER.ANISOTROPIC )
		render.PushFilterMin( TEXFILTER.ANISOTROPIC )
		
		self:RenderScreen()
		
		render.PopFilterMag()
		render.PopFilterMin()
		
		render.SetStencilEnable( false )
	cam.PopModelMatrix( )
end

function ENT:GetResolution()
	return 512/self.Aspect, 512
end

ENT.Monitor_Offsets = {
	["models//cheeze/pcb/pcb4.mdl"] = {
		Name	=	"pcb4.mdl",
		RS	=	0.0625,
		RatioX	=	1.0000000596046,
		offset	=	Vector(-0.000000, 0.000000, 0.500003),
		rot	=	Angle(0.000, 0.000, 180.000),
		x1	=	-15.999999046326,
		x2	=	15.999999046326,
		y1	=	-16,
		y2	=	16,
		z	=	0.5000028014183,
	},
	["models//cheeze/pcb/pcb5.mdl"] = {
		Name	=	"pcb5.mdl",
		RS	=	0.062500014901161,
		RatioX	=	0.50793662903801,
		offset	=	Vector(0.000000, -0.500000, 0.500005),
		rot	=	Angle(0.000, 0.000, 180.000),
		x1	=	-31.5,
		x2	=	31.5,
		y1	=	-16.000003814697,
		y2	=	16.000003814697,
		z	=	0.50000548362732,
	},
	["models//cheeze/pcb/pcb6.mdl"] = {
		Name	=	"pcb6.mdl",
		RS	=	0.093750007450581,
		RatioX	=	0.76190482245551,
		offset	=	Vector(-0.5, -7.999998, 0.500005),
		rot	=	Angle(0.000, 0.000, 180.000),
		x1	=	-31.5,
		x2	=	31.5,
		y1	=	-24.000001907349,
		y2	=	24.000001907349,
		z	=	0.50000548362732,
	},
	["models//cheeze/pcb/pcb7.mdl"] = {
		Name	=	"pcb7.mdl",
		RS	=	0.125,
		RatioX	=	1.0000000596046,
		offset	=	Vector(-0.000000, 0.000000, 0.500006),
		rot	=	Angle(0.000, 0.000, 180.000),
		x1	=	-31.999998092651,
		x2	=	31.999998092651,
		y1	=	-32,
		y2	=	32,
		z	=	0.50000560283661,
	},
	["models//cheeze/pcb/pcb8.mdl"] = {
		Name	=	"pcb8.mdl",
		RS	=	0.12500001490116,
		RatioX	=	0.66826218480219,
		offset	=	Vector(15.885404, 0.000, 0.500008),
		rot	=	Angle(0.000, 0.000, 180.000),
		x1	=	-47.885402679443,
		x2	=	47.885402679443,
		y1	=	-32.000003814697,
		y2	=	32.000003814697,
		z	=	0.50000834465027,
	},
	["models/cheeze/pcb2/pcb8.mdl"] = {
		Name	=	"pcb8.mdl",
		RS	=	0.24750001728535,
		RatioX	=	0.99000006914139,
		offset	=	Vector(0.000000, 0.000000, 0.300011),
		rot	=	Angle(0.000, 0.000, 180.000),
		x1	=	-64,
		x2	=	64,
		y1	=	-63.360004425049,
		y2	=	63.360004425049,
		z	=	0.30001118779182,
	},
	["models/blacknecro/tv_plasma_4_3.mdl"] = {
		Name	=	"Plasma TV (4:3)",
		RS	=	0.082,
		RatioX	=	0.75098672407607,
		offset	=	Vector(0.0500, -0.50000, 0.10000),
		rot	=	Angle(0.000, 0.000, -90.000),
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
		offset	=	Vector(24.000000, -0.000000, 0.000000),
		rot	=	Angle(0.000, 90.000, -90.000),
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
		offset	=	Vector(0.000000, -0.000000, 1.700000),
		rot	=	Angle(0.000, 90.000, 180.000),
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
		offset	=	Vector(0.000000, -0.000000, 1.700000),
		rot	=	Angle(0.000, 90.000, 180.000),
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
		offset	=	Vector(0.000000, -0.000000, 1.700000),
		rot	=	Angle(0.000, 90.000, 180.000),
		x1	=	-48,
		x2	=	48,
		y1	=	-48,
		y2	=	48,
		z	=	0,
	},
	["models/hunter/plates/plate4x4.mdl"] = {
		Name	=	"plate4x4.mdl",
		RS	=	0.37070319056511,
		RatioX	=	1.0000002411821,
		offset	=	Vector(-0.000000, 0.000000, 1.700017),
		rot	=	Angle(0.000, 90.000, 180.000),
		x1	=	-94.899993896484,
		x2	=	94.899993896484,
		y1	=	-94.900016784668,
		y2	=	94.900016784668,
		z	=	1.700016617775,
	},
	["models/hunter/plates/plate8x8.mdl"] = {
		Name	=	"plate8x8.mdl",
		RS	=	0.74140638113022,
		RatioX	=	1.0000002411821,
		offset	=	Vector(-0.000000, 0.000000, 1.700033),
		rot	=	Angle(0.000, 90.000, 180.000),
		x1	=	-189.79998779297,
		x2	=	189.79998779297,
		y1	=	-189.80003356934,
		y2	=	189.80003356934,
		z	=	1.7000331878662,
	},
	["models/kobilica/wiremonitorbig.mdl"] = {
		Name	=	"Monitor Big",
		RS	=	0.045,
		RatioX	=	0.99134199134199,
		offset	=	Vector(0.200000, -0.400000, 13.000000),
		rot	=	Angle(0.000, 0.000, -90.000),
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
		offset	=	Vector(0.000000, -0.400000, 5.000000),
		rot	=	Angle(0.000, 0.000, -90.000),
		x1	=	-4.4,
		x2	=	4.5,
		y1	=	0.6,
		y2	=	9.5,
		z	=	0.3,
	},
	["models/props/cs_assault/billboard.mdl"] = {
		Name	=	"Billboard",
		RS	=	0.23,
		RatioX	=	0.52163565947589,
		offset	=	Vector(1.000000, -0.000000, 0.000000),
		rot	=	Angle(0.000, 90.000, -90.000),
		x1	=	-110.512,
		x2	=	110.512,
		y1	=	-57.647,
		y2	=	57.647,
		z	=	1,
	},
	["models/props/cs_militia/reload_bullet_tray.mdl"] = {
		Name	=	"Tray",
		RS	=	0.009,
		RatioX	=	0.6,
		offset	=	Vector(0.000000, -0.000000, 0.800000),
		rot	=	Angle(0.000, 90.000, 180.000),
		x1	=	0,
		x2	=	100,
		y1	=	0,
		y2	=	60,
		z	=	0,
	},
	["models/props/cs_office/computer_monitor.mdl"] = {
		Name	=	"LCD Monitor (4:3)",
		RS	=	0.031,
		RatioX	=	0.76666666666667,
		offset	=	Vector(3.300000, -0.000000, 16.700001),
		rot	=	Angle(0.000, 90.000, -90.000),
		x1	=	-10.5,
		x2	=	10.5,
		y1	=	8.6,
		y2	=	24.7,
		z	=	3.3,
	},
	["models/props/cs_office/tv_plasma.mdl"] = {
		Name	=	"Plasma TV (16:10)",
		RS	=	0.065,
		RatioX	=	0.59649122807018,
		offset	=	Vector(6.100000, -0.000000, 18.930000),
		rot	=	Angle(0.000, 90.000, -90.000),
		x1	=	-28.5,
		x2	=	28.5,
		y1	=	2,
		y2	=	36,
		z	=	6.1,
	},
	["models/props_lab/monitor01b.mdl"] = {
		Name	=	"Small TV",
		RS	=	0.0185,
		RatioX	=	1.0172661870504,
		offset	=	Vector(6.530000, -1.000000, 0.450000),
		rot	=	Angle(0.000, 90.000, -90.000),
		x1	=	-5.535,
		x2	=	3.5,
		y1	=	-4.1,
		y2	=	5.091,
		z	=	6.53,
	},
	["models/props_lab/workspace002.mdl"] = {
		Name	=	"Workspace 002",
		RS	=	0.068359375,
		RatioX	=	0.96685080835225,
		offset	=	Vector(-42.133224, -42.372322, 42.110897),
		rot	=	Angle(0.000, 133.340, -120.317),
		x1	=	-18.10000038147,
		x2	=	18.10000038147,
		y1	=	-17.5,
		y2	=	17.5,
		z	=	42.110897064209,
	},
	["models/props_mining/billboard001.mdl"] = {
		Name	=	"TF2 Red billboard",
		RS	=	0.37500004470348,
		RatioX	=	0.57142863954817,
		offset	=	Vector(3.200003, -0.000002, 96.000000),
		rot	=	Angle(0.000, 90.000, -90.000),
		x1	=	-168,
		x2	=	168,
		y1	=	-96.000007629395,
		y2	=	96.000015258789,
		z	=	96,
	},
	["models/props_mining/billboard002.mdl"] = {
		Name	=	"TF2 Red vs Blue billboard",
		RS	=	0.37500008940697,
		RatioX	=	0.31372556499406,
		offset	=	Vector(3.200009, -0.000004, 192.000000),
		rot	=	Angle(0.000, 90.000, -90.000),
		x1	=	-306,
		x2	=	306,
		y1	=	-96.000015258789,
		y2	=	96.000030517578,
		z	=	192,
	}
}