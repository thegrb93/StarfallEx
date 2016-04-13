
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

include( "starfall/SFLib.lua" )
assert( SF, "Starfall didn't load correctly!" )

local context = SF.CreateContext()


function ENT:Initialize ()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
	self:SetNWInt( "State", self.States.None )
	self:SetColor( Color( 255, 0, 0, self:GetColor().a ) )
end

-- Sends a net message to all clients about the use.
function ENT:Use( activator )
	if activator:IsPlayer() then
		net.Start( "starfall_processor_used" )
			net.WriteEntity( self )
			net.WriteEntity( activator )
		net.Broadcast()
	end
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
	self.error = nil
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

	local clr = self:GetColor()
	self:SetColor( Color( 255, 255, 255, clr.a ) )
	
	if self.Inputs then
		for k, v in pairs(self.Inputs) do
			self:TriggerInput( k, v.Value )
		end
	end
	
	self:runScriptHook( "initialize" )
	self:SetNWInt( "State", self.States.Normal )
end

local i = 0
function ENT:Think ()	
	i = i + 1

	if i % 22 == 0 then
		retryCodeRequests()
		i = 0
	end
	
	if self.instance and not self.instance.error then		
		local bufferAvg = self.instance:movingCPUAverage()
		self:SetNWInt( "CPUus", math.Round( bufferAvg * 1000000 ) )
		self:SetNWFloat( "CPUpercent", math.floor( bufferAvg / self.instance.context.cpuTime.getMax() * 100 ) )
		self.instance.cpu_total = 0
		self.instance.cpu_average = bufferAvg
		self:runScriptHook( "think" )
	end

	self:NextThink( CurTime() )
	return true
end

function ENT:PreEntityCopy ()
	if self.EntityMods then self.EntityMods.SFDupeInfo = nil end
	
	if self.instance then
		local info = WireLib.BuildDupeInfo(self)
		info.starfall = SF.SerializeCode( self.files, self.mainfile )
		duplicator.StoreEntityModifier( self, "SFDupeInfo", info )
	end
end

local function EntityLookup(CreatedEntities)
	return function(id, default)
		if id == nil then return default end
		if id == 0 then return game.GetWorld() end
		local ent = CreatedEntities[id] or (isnumber(id) and ents.GetByIndex(id))
		if IsValid(ent) then return ent else return default end
	end
end
function ENT:PostEntityPaste ( ply, ent, CreatedEntities )
	if ent.EntityMods and ent.EntityMods.SFDupeInfo then
		local info = ent.EntityMods.SFDupeInfo
		
		WireLib.ApplyDupeInfo( ply, ent, info, EntityLookup( CreatedEntities ) )
		self.owner = ply
	
		if info.starfall then
			local code, main = SF.DeserializeCode( info.starfall )
			self:Compile( code, main )
		end
	end
end

local function dupefinished( TimedPasteData, TimedPasteDataCurrent )
	for k,v in pairs( TimedPasteData[TimedPasteDataCurrent].CreatedEntities ) do
		if IsValid(v) and v:GetClass() == "starfall_processor" then
			v:runScriptHook( "initialize" )
		end
	end
end
hook.Add("AdvDupe_FinishPasting", "SF_dupefinished", dupefinished )
