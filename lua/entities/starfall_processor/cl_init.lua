include( "shared.lua" )

DEFINE_BASECLASS( "base_gmodentity" )

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()	
	self.CPUpercent = 0
	self.CPUus = 0
	self.name = "Generic ( No-Name )"
end

hook.Add("NetworkEntityCreated","starfall_chip_reset",function(ent)
	if ent:GetClass()=="starfall_processor" then
		net.Start( "starfall_processor_download" )
		net.WriteEntity( ent )
		net.SendToServer()
	end
end)

function ENT:GetOverlayText()
	local state = self:GetNWInt( "State", 1 )
	local clientstr, serverstr
	if self.instance then
		local bufferAvg = self.instance.cpu_average
		clientstr = tostring( math.Round( bufferAvg * 1000000 ) ) .. "us. (" .. tostring( math.floor( bufferAvg / SF.cpuQuota:GetFloat() * 100 ) ) .. "%)"
	else
		clientstr = "Errored"
	end
	if state == 1 then
		serverstr = tostring( self:GetNWInt( "CPUus", 0 ) ) .. "us. (" .. tostring( self:GetNWFloat( "CPUpercent", 0 ) ) .. "%)"
	elseif state == 2 then
		serverstr = "Errored"
	end
	if serverstr then
		return "- Starfall Processor -\n[ " .. self.name .. " ]\nServer CPU: " .. serverstr .. "\nClient CPU: " .. clientstr
	else
		return "(None)"
	end
end

if WireLib then
	function ENT:DrawTranslucent()
		self:DrawModel()
		Wire_Render( self )
	end
else
	function ENT:DrawTranslucent()
		self:DrawModel()
	end
end

function ENT:CodeSent ( files, main, owner )
	if not files or not main or not owner then return end
	if self.instance then
		self.instance:runScriptHook( "removed" )
		self.instance:deinitialize()
		self.instance = nil
	end
	
	self.error = nil
	self.owner = owner
	self.files = files
	self.mainfile = main
	local ok, instance = SF.Instance.Compile( files, main, owner, { entity = self, render = {} } )
	if not ok then self:Error( instance ) return end
	
	if instance.ppdata.scriptnames and instance.mainfile then
		local name = instance.ppdata.scriptnames[ instance.mainfile ]
		if name and name!="" then
			self.name = name
		end
	end
	
	instance.runOnError = function ( inst, ... ) self:Error( ... ) end
	
	self.instance = instance
	local ok, msg, traceback = instance:initialize()
	if not ok then self:Error( msg, traceback ) end
end

net.Receive( "starfall_processor_download", function ( len )

	local dlFiles = {}
	local dlNumFiles = {}
	local dlProc = net.ReadEntity()
	local dlOwner = net.ReadEntity()
	local dlMain = net.ReadString()
	
	if not dlProc:IsValid() or not dlOwner:IsValid() then return end
	
	local I = 0
	while I < 256 do
		if net.ReadBit() != 0 then break end
		
		local filename = net.ReadString()

		net.ReadStream( nil, function( data )
			dlNumFiles.Completed = dlNumFiles.Completed + 1
			dlFiles[ filename ] = data or ""
			if dlProc:IsValid() and dlProc.CodeSent and dlNumFiles.Completed == dlNumFiles.NumFiles then
				dlProc:CodeSent( dlFiles, dlMain, dlOwner )
			end
		end )
		
		I = I + 1
	end

	dlNumFiles.Completed = 0
	dlNumFiles.NumFiles = I
end )

net.Receive( "starfall_processor_link", function()
	local component = net.ReadEntity()
	local proc = net.ReadEntity()
	if IsValid(component) and component.LinkEnt then
		component:LinkEnt(proc)
	end
end )
