include( "shared.lua" )

DEFINE_BASECLASS( "base_gmodentity" )

ENT.RenderGroup = RENDERGROUP_OPAQUE

local context = SF.CreateContext( nil, nil, nil, SF.Libraries.CreateLocalTbl{"render"} )

function ENT:Initialize()
    self:SetRenderBounds( self:OBBMins(), self:OBBMaxs() )

	net.Start( "starfall_processor_download" )
		net.WriteEntity( self )
	net.SendToServer()
end

function ENT:GetOverlayText ()
    local message = BaseClass.GetOverlayText( self )
    return message or ""
end

function ENT:Draw ()
    BaseClass.Draw( self )
    self:DrawModel()
    if self:BeingLookedAtByLocalPlayer() then
        AddWorldTip( self:EntIndex(), self:GetOverlayText(), 0.5, self:GetPos(), self )
    end
end

function ENT:Think ()
	BaseClass.Think( self )
	
	if self.instance and not self.instance.error then
		local bufferAvg = self.instance:movingCPUAverage()
		self.instance.cpu_total = 0
		self.instance.cpu_average = bufferAvg
		self:runScriptHook( "think" )
	end

	self:NextThink( CurTime() )
	return true
end

function ENT:CodeSent ( files, main, owner )
	if not files or not main or not owner then return end
	if self.instance then self.instance:deinitialize() end
	self.owner = owner
	local ok, instance = SF.Compiler.Compile( files, context, main, owner, { entity = self, render = {} } )
	if not ok then self:Error( instance ) return end
	
	instance.runOnError = function ( inst, ... ) self:Error( ... ) end
	
	self.instance = instance
	local ok, msg, traceback = instance:initialize()
	if not ok then self:Error( msg, traceback ) end
end


local dlProc = nil
local dlOwner = nil
local dlMain = nil
local dlFiles = nil
local hashes = {}

net.Receive( "starfall_processor_download", function ( len )
	if not dlProc then
		dlProc = net.ReadEntity()
		dlOwner = net.ReadEntity()
		dlMain = net.ReadString()
		dlFiles = {}
	else
		if net.ReadBit() ~= 0 then
			if dlProc:IsValid() then
				dlProc:CodeSent( dlFiles, dlMain, dlOwner )
				dlProc.files = dlFiles
				dlProc.mainfile = dlMain
			end
			dlProc, dlFiles, dlMain, dlOwner = nil, nil, nil, nil
			return
		end
		local filename = net.ReadString()
		local filedata = net.ReadString()
		dlFiles[ filename ] = dlFiles[ filename ] and dlFiles[ filename ] .. filedata or filedata
	end
end )

net.Receive( "starfall_processor_update", function ( len )
	local proc = net.ReadEntity()
	if not IsValid( proc ) then return end

	local dirty = false
	local finish = net.ReadBit()

	while finish == 0 do
		local file = net.ReadString()
		local hash = net.ReadString()

		if hash ~= hashes[ file ] then
			dirty = true
			hashes[ file ] = hash
		end
		finish = net.ReadBit()
	end
	if dirty then
		net.Start( "starfall_processor_download" )
			net.WriteEntity( proc )
		net.SendToServer()
	else
		proc:CodeSent( proc.files, proc.mainfile, proc.owner )
	end
end )


net.Receive( "starfall_processor_link", function()
	local component = net.ReadEntity()
	local proc = net.ReadEntity()
	if IsValid(proc) and IsValid(component) and component.LinkEnt then
		component:LinkEnt(proc)
	end
end )
