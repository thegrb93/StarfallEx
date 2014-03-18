AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

include("starfall/SFLib.lua")
assert(SF, "Starfall didn't load correctly!")

local context = SF.CreateContext()
local screens = {}

util.AddNetworkString("starfall_screen_download")
util.AddNetworkString("starfall_screen_update")

local function sendScreenCode(screen, owner, files, mainfile, recipient)
	--print("Sending SF code for: " .. tostring(recipient))
	net.Start("starfall_screen_download")
	net.WriteEntity(screen)
	net.WriteEntity(owner)
	net.WriteString(mainfile)
	if recipient then net.Send(recipient) else net.Broadcast() end
	--print("\tHeader sent")

	local fname = next(files)
	while fname do
		--print("\tSending data for:", fname)
		local fdata = files[fname]
		local offset = 1
		repeat
			net.Start("starfall_screen_download")
			net.WriteBit(false)
			net.WriteString(fname)
			local data = fdata:sub(offset, offset+60000)
			net.WriteString(data)
			if recipient then net.Send(recipient) else net.Broadcast() end

			--print("\t\tSent data from", offset, "to", offset + #data)
			offset = offset + #data + 1
		until offset > #fdata
		fname = next(files, fname)
	end

	net.Start("starfall_screen_download")
	net.WriteBit(true)
	if recipient then net.Send(recipient) else net.Broadcast() end
	--print("Done sending")
end

local requests = {}

local function sendCodeRequest(ply, screenid)
	local screen = Entity(screenid)

	if not screen.mainfile then
		if not requests[screenid] then requests[screenid] = {} end
		if requests[screenid][player] then return end
		requests[screenid][ply] = true
		return

		--[[if timer.Exists("starfall_send_code_request") then return end
		timer.Create("starfall_send_code_request", .5, 1, retryCodeRequests) ]]
	elseif screen.mainfile then
		if requests[screenid] then
			requests[screenid][ply] = nil
		end
		sendScreenCode(screen, screen.owner, screen.files, screen.mainfile, ply)
	end
end

local function retryCodeRequests()
	for screenid,plys in pairs(requests) do
		for ply,_ in pairs(requests[screenid]) do
			sendCodeRequest(ply, screenid)
		end
	end
end

net.Receive("starfall_screen_download", function(len, ply)
	local screen = net.ReadEntity()
	sendCodeRequest(ply, screen:EntIndex())
end)

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType( 3 )
	
	self.Inputs = WireLib.CreateInputs(self, {})
	self.Outputs = WireLib.CreateOutputs(self, {})
	
	local r,g,b,a = self:GetColor()
end

function ENT:OnRestore()
end

function ENT:UpdateName(state)
	if state ~= "" then state = "\n"..state end
	
	if self.instance and self.instance.ppdata.scriptnames and self.instance.mainfile and self.instance.ppdata.scriptnames[self.instance.mainfile] then
		self:SetOverlayText("Starfall Processor\n"..tostring(self.instance.ppdata.scriptnames[self.instance.mainfile])..state)
	else
		self:SetOverlayText("Starfall Processor"..state)
	end
end

function ENT:Error(msg, override)
	if type( msg ) == "table" then
		if msg.message then
			local line = msg.line
			local file = msg.file

			msg = ( file and ( file .. ":" ) or "" ) .. ( line and ( line .. ": " ) or "" ) .. msg.message
		end
	end
	ErrorNoHalt( "Processor of " .. self.owner:Nick() .. " errored: " .. tostring( msg ) .. "\n" )
	WireLib.ClientError(msg, self.owner)
	
	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end
	
	self:UpdateName("Inactive (Error)")
	local r,g,b,a = self:GetColor()
	self:SetColor(255, 0, 0, a)
end

function ENT:CodeSent(ply, files, mainfile)
	if ply ~= self.owner then return end
	local update = self.mainfile ~= nil

	self.files = files
	self.mainfile = mainfile
	screens[self] = self

	if update then
		net.Start("starfall_screen_update")
			net.WriteEntity(self)
			for k,v in pairs(files) do
				net.WriteBit(false)
				net.WriteString(k)
				net.WriteString(util.CRC(v))
			end
			net.WriteBit(true)
		net.Broadcast()
		--sendScreenCode(self, ply, files, mainfile)
	end

	local ppdata = {}
	SF.Preprocessor.ParseDirectives(mainfile, files[mainfile], {}, ppdata)
	
	if ppdata.sharedscreen then		
		local ok, instance = SF.Compiler.Compile(files,context,mainfile,ply)
		if not ok then self:Error(instance) return end
		
		instance.runOnError = function(inst,...) self:Error(...) end

		if self.instance then
			self.instance:deinitialize()
			self.instance = nil
		end

		self.instance = instance
		instance.data.entity = self
		
		local ok, msg = instance:initialize()
		if not ok then
			self:Error(msg)
			return
		end
		
		if not self.instance then return end
		
		self:UpdateName("")
		local r,g,b,a = self:GetColor()
		self:SetColor(Color(255, 255, 255, a))
		self.sharedscreen = true
	end
end

local i = 0
function ENT:Think()
	self.BaseClass.Think(self)

	i = i + 1

	if i % 22 == 0 then
		retryCodeRequests()
		i = 0
	end

	self:NextThink(CurTime())
	
	if self.instance and not self.instance.error then
		self.instance:resetOps()
		self:runScriptHook("think")
	end
	
	return true
end

-- Sends a umsg to all clients about the use.
function ENT:Use( activator )
	if activator:IsPlayer() then
		umsg.Start( "starfall_screen_used" )
			umsg.Short( self:EntIndex() )
			umsg.Short( activator:EntIndex() )
		umsg.End( )
	end
	if self.sharedscreen then
		self:runScriptHook( "starfall_used", SF.Entities.Wrap( activator ) )
	end
end

function ENT:OnRemove()
	if not self.instance then return end
	screens[self] = nil
	self.instance:deinitialize()
	self.instance = nil
end

function ENT:TriggerInput ( key, value )
	self:runScriptHook( "input", key, value )
end

function ENT:ReadCell ( address )
	return tonumber( self:runScriptHookForResult( "readcell", address ) ) or 0
end

function ENT:WriteCell ( address, data )
	self:runScriptHook( "writecell", address, data )
end

-- A modified copy of garry's table.Copy function
function tableCopy ( t, lookup_table )
	if ( t == nil ) then return nil end

	local copy = {}
	setmetatable( copy, debug.getmetatable( t ) )
	for i, v in pairs( t ) do
		if ( not istable( v ) ) then
			copy[ i ] = v
		else
			lookup_table = lookup_table or {}
			lookup_table[ t ] = copy
			if lookup_table[ v ] then
				copy[ i ] = lookup_table[ v ] -- we already copied this table. reuse the copy.
			else
				copy[ i ] = table.Copy( v, lookup_table ) -- not yet copied. copy it.
			end
		end
	end
	return copy
end

function ENT:BuildDupeInfo ()
	table.Copy = tableCopy --TODO: Remove once table.Copy is fixed
	local info = self.BaseClass.BuildDupeInfo( self ) or {}
	info.starfall = SF.SerializeCode( self.files, self.mainfile )
	return info
end

function ENT:ApplyDupeInfo ( ply, ent, info, GetEntByID  )
	self.BaseClass.ApplyDupeInfo( self, ply, ent, info, GetEntByID )
	self.owner = ply
	local code, main = SF.DeserializeCode( info.starfall )
	self:CodeSent( ply, code, main )
end
