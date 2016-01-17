include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_OPAQUE


surface.CreateFont( "Starfall_ErrorFont", {
	font = "arial",
	size = 26,
	weight = 200
} )

net.Receive( "starfall_processor_used", function ( len )
	local screen = net.ReadEntity()
	local activator = net.ReadEntity()

	if not IsValid( screen ) or not screen.link then return end
	
	local instance = screen.link.instance
	if instance and instance.hooks[ "starfallUsed" ] then
		local ok, rt = instance:runScriptHook( "starfallUsed", SF.Entities.Wrap( activator ) )
		if not ok then 
			screen.link:Error( rt )
			screen:Error( rt ) 
		end
	end
	
	-- Error message copying
	if screen.error then
		SetClipboardText( string.format( "%q", screen.error.orig ) )
	end
end )

function ENT:Initialize ()
	self.BaseClass.Initialize( self )
	self.GPU = GPULib.WireGPU( self )
	
	net.Start( "starfall_processor_update_links" )
		net.WriteEntity( LocalPlayer() )
		net.WriteEntity( self )
	net.SendToServer()
	
	function self.renderfunc ()
		if self.link and self.link.instance then
			local instance = self.link.instance
			local data = instance.data
			
			data.render.gpu = self.GPU
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
end

function ENT:OnRemove ()
	self.GPU:Finalize()
end

function ENT:Error ( msg, traceback )
	msg = self.BaseClass.Error( self, msg, traceback )
	
	-- Process error message
	self.error = {}
	self.error.orig = msg
	self.error.source, self.error.line, self.error.msg = string.match( msg, "%[@?SF:(%a+):(%d+)](.+)$" )

	if not self.error.source or not self.error.line or not self.error.msg then
		self.error.source, self.error.line, self.error.msg = nil, nil, msg
	else
		self.error.msg = string.TrimLeft( self.error.msg )
	end
	
	--self:SetOverlayText( "Starfall Screen\nInactive ( Error )" )
end

function ENT:LinkEnt ( ent )
	self.link = ent
end

function ENT:Draw ()
	baseclass.Get( self.Base ).Draw( self )
	self:DrawModel()
	Wire_Render( self )
	
	if self.renderfunc then
		self.GPU:RenderToGPU(self.renderfunc)
	end
	
	self.GPU:Render()
end
