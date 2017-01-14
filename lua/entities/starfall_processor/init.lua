
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
util.AddNetworkString( "starfall_processor_update_links" )
util.AddNetworkString( "starfall_processor_used" )
util.AddNetworkString( "starfall_processor_link" )

local function sendCode ( proc, owner, files, mainfile, recipient )
	net.Start( "starfall_processor_download" )
	net.WriteEntity( proc )
	net.WriteEntity( owner )
	net.WriteString( mainfile )
	
	for name, data in pairs( files ) do
	
		net.WriteBit( false )
		net.WriteString( name )
		net.WriteStream( data )

	end

	net.WriteBit( true )
	
	if recipient then net.Send( recipient ) else net.Broadcast() end
end

-- Request code from the chip. If the chip doesn't have code yet then wait at most 5 sec for code.
net.Receive("starfall_processor_download", function(len, ply)
	local proc = net.ReadEntity()
	if ply:IsValid() and proc:IsValid() then
		local hookname = "SFCodeRQ"..proc:EntIndex().."_"..ply:EntIndex()
		local timeout = CurTime()+5
		hook.Add("Think", hookname, function()
			if ply:IsValid() and proc:IsValid() and CurTime()<timeout then
				if proc.mainfile and proc.files then
					sendCode(proc, proc.owner, proc.files, proc.mainfile, ply)
					hook.Remove("Think", hookname)
				end
			else
				hook.Remove("Think", hookname)
			end
		end)
	end
end)

net.Receive("starfall_processor_update_links", function(len, ply)
	local ply = net.ReadEntity()
	local linked = net.ReadEntity()
	if IsValid( linked.link ) then
		linked:LinkEnt( linked.link, ply )
	end
end)

function ENT:Compile(files, mainfile)
	if self.instance then
		self:runScriptHook( "removed" )
		self.instance:deinitialize()
		self.instance = nil
	end
	
	local update = self.mainfile ~= nil
	self.error = nil
	self.files = files
	self.mainfile = mainfile

	if update then
		sendCode(self, self.owner, self.files, self.mainfile)
	end

	local ppdata = {}
	SF.Preprocessor.ParseDirectives(mainfile, files[mainfile], {}, ppdata)
		
	local ok, instance = SF.Compiler.Compile( files, context, mainfile, self.owner, { entity = self } )
	if not ok then self:Error(instance) return end
	
	if instance.ppdata.scriptnames and instance.mainfile and instance.ppdata.scriptnames[ instance.mainfile ] then
		self.name = tostring( instance.ppdata.scriptnames[ instance.mainfile ] )
	end
	
	instance.runOnError = function(inst,...) self:Error(...) end
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

function ENT:GetGateName()
	return self.name
end

function ENT:Think ()
	self.BaseClass.Think( self )
	
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
		local info = WireLib and WireLib.BuildDupeInfo(self) or {}
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
		
		if WireLib then
			WireLib.ApplyDupeInfo( ply, ent, info, EntityLookup( CreatedEntities ) )
		end
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
