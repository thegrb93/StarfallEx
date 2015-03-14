
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


util.AddNetworkString( "starfall_processor_download" )
util.AddNetworkString( "starfall_processor_update" )
util.AddNetworkString( "starfall_processor_update_links" )
util.AddNetworkString( "starfall_processor_used" )
util.AddNetworkString( "starfall_processor_link" )

local function sendCode ( proc, owner, files, mainfile, recipient )
	net.Start( "starfall_processor_download" )
	net.WriteEntity( proc )
	net.WriteEntity( owner )
	net.WriteString( mainfile )
	if recipient then net.Send( recipient ) else net.Broadcast() end

	local fname = next( files )
	while fname do
		local fdata = files[ fname ]
		local offset = 1
		repeat
			net.Start( "starfall_processor_download" )
			net.WriteBit( false )
			net.WriteString( fname )
			local data = fdata:sub( offset, offset + 60000 )
			net.WriteString( data )
			if recipient then net.Send( recipient ) else net.Broadcast() end

			offset = offset + #data + 1
		until offset > #fdata
		fname = next( files, fname )
	end

	net.Start( "starfall_processor_download" )
	net.WriteBit( true )
	if recipient then net.Send( recipient ) else net.Broadcast() end
end

local requests = {}

local function sendCodeRequest(ply, procid)
	local proc = Entity(procid)

	if not proc.mainfile then
		if not requests[procid] then requests[procid] = {} end
		if requests[procid][player] then return end
		requests[procid][ply] = true
		return

	elseif proc.mainfile then
		if requests[procid] then
			requests[procid][ply] = nil
		end
		sendCode(proc, proc.owner, proc.files, proc.mainfile, ply)
	end
end

local function retryCodeRequests()
	for procid,plys in pairs(requests) do
		for ply,_ in pairs(requests[procid]) do
			sendCodeRequest(ply, procid)
		end
	end
end

net.Receive("starfall_processor_download", function(len, ply)
	local proc = net.ReadEntity()
	sendCodeRequest(ply, proc:EntIndex())
end)

net.Receive("starfall_processor_update_links", function(len, ply)
	local ply = net.ReadEntity()
	local linked = net.ReadEntity()
	if IsValid( linked.link ) then
		linked:LinkEnt( linked.link, ply )
	end
end)

function ENT:Compile(files, mainfile)
	local update = self.mainfile ~= nil

	self.files = files
	self.mainfile = mainfile

	if update then
		net.Start("starfall_processor_update")
			net.WriteEntity(self)
			for k,v in pairs(files) do
				net.WriteBit(false)
				net.WriteString(k)
				net.WriteString(util.CRC(v))
			end
			net.WriteBit(true)
		net.Broadcast()
	end

	local ppdata = {}
	SF.Preprocessor.ParseDirectives(mainfile, files[mainfile], {}, ppdata)
		
	local ok, instance = SF.Compiler.Compile( files, context, mainfile, self.owner, { entity = self } )
	if not ok then self:Error(instance) return end
	
	instance.runOnError = function(inst,...) self:Error(...) end

	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end

	self.instance = instance
	
	local ok, msg, traceback = instance:initialize()
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
	
	for k, v in pairs(ents.GetAll()) do
		if v.link == self then
			v:LinkEnt( self )
		end
	end
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
