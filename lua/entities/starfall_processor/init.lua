
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

include( "starfall/SFLib.lua" )
assert( SF, "Starfall didn't load correctly!" )

local context = SF.CreateContext()

function ENT:UpdateState ( state )
	self:SetOverlayText( "- Starfall Processor -\n[ " .. ( self.name or "Generic ( No-Name )" ) .. " ]\n" .. state )
end

function ENT:Initialize ()
	self.BaseClass.Initialize( self )
	
	self:UpdateState( "Inactive ( No code )" )
	self:SetColor( Color( 255, 0, 0, self:GetColor().a ) )
end

function ENT:Compile ( codetbl, mainfile )
	if self.instance then self.instance:deinitialize() end
	
	local ok, instance = SF.Compiler.Compile( codetbl, context, mainfile, self.owner, { entity = self } )
	if not ok then self:Error( instance ) return end
	
	instance.runOnError = function ( inst, ... ) self:Error( ... ) end
	
	self.instance = instance
	
	local ok, msg, traceback = instance:initialize ()
	if not ok then
		self:Error( msg, traceback )
		return
	end
	
	if not self.instance then return end

	self.name = nil

	if self.instance.ppdata.scriptnames and self.instance.mainfile and self.instance.ppdata.scriptnames[ self.instance.mainfile ] then
		self.name = tostring( self.instance.ppdata.scriptnames[ self.instance.mainfile ] )
	end

	self:UpdateState( "( None )" )
	local clr = self:GetColor()
	self:SetColor( Color( 255, 255, 255, clr.a ) )
end

function ENT:Error ( msg, traceback )
	self.BaseClass.Error( self, msg, traceback )

	self:UpdateState( "Inactive (Error)" )
	self:SetColor( Color( 255, 0, 0, 255 ) )
end

function ENT:Think ()
	self.BaseClass.Think( self )
	
	if self.instance and not self.instance.error then

		local bufferAvg = self.instance.cpuTime:getBufferAverage()

		self:UpdateState( tostring( math.Round( bufferAvg * 1000000 ) ) .. " us.\n" .. tostring( math.floor( bufferAvg / self.instance.context.cpuTime.getMax() * 100 ) ) .. "%" )

		self.instance:updateCPUBuffer()
		self:runScriptHook( "think" )
	end

	self:NextThink( CurTime() )
	return true
end

function ENT:OnRemove ()
	self.BaseClass.OnRemove( self )
end

function ENT:runScriptHook ( hook, ... )
	if self.instance and not self.instance.error and self.instance.hooks[ hook:lower() ] then
		local ok, rt = self.instance:runScriptHook( hook, ... )
		if not ok then self:Error( rt ) end
	end
end

function ENT:runScriptHookForResult ( hook,... )
	if self.instance and not self.instance.error and self.instance.hooks[ hook:lower() ] then
		local ok, rt = self.instance:runScriptHookForResult( hook, ... )
		if not ok then self:Error( rt )
		else return rt end
	end
end

function ENT:BuildDupeInfo ()
	local info = self.BaseClass.BuildDupeInfo( self ) or {}

	if self.instance then
		info.starfall = SF.SerializeCode( self.instance.source, self.instance.mainfile )
	end

	return info
end

function ENT:ApplyDupeInfo ( ply, ent, info, GetEntByID )
	self.BaseClass.ApplyDupeInfo( self, ply, ent, info, GetEntByID )
	self.owner = ply
	
	if info.starfall then
		local code, main = SF.DeserializeCode( info.starfall )
		self:Compile( code, main )
	end
end
