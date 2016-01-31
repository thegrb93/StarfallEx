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
			local ok, rt = instance:runScriptHook( "starfallUsed", SF.Entities.Wrap( activator ) )
			if not ok then 
				screen.link:Error( rt )
				screen:Error( rt ) 
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
	
	local info = WireGPU_Monitors[ self:GetModel() ]
	
	local rotation, translation, translation2, scale = Matrix(), Matrix(), Matrix(), Matrix()
	rotation:SetAngles(info.rot)
	rotation:Rotate(Angle(0,0,180))
	translation:SetTranslation(info.offset)
	translation2:SetTranslation(Vector(-256/info.RatioX,-256,0))
	scale:SetScale(Vector(info.RS,info.RS,info.RS))
	
	self.ScreenMatrix = translation * rotation * scale * translation2
	self.Aspect = info.RatioX
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
			local ok, rt = instance:runScriptHook( "render" )
			if not ok then
				self.link:Error( rt )
				self:Error( rt ) 
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

