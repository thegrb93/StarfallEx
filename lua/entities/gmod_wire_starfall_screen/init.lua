
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

include("starfall2/SFLib.lua")
include("libtransfer/libtransfer.lua")

local context = SF.CreateContext()
local screens = {}

hook.Add("PlayerInitialSpawn","sf_screen_download",function(ply)
	local tbl = {}
	for _,s in pairs(screens) do
		tbl[#tbl+1] = {
			ent = s,
			owner = s.owner,
			files = s.task.files,
			main = s.task.mainfile,
		}
	end
	if #tbl > 0 then
		datastream.StreamToClients(ply,"sf_screen_download",tbl)
	end
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

function ENT:CodeSent(ply, task)
	if ply ~= self.owner then return end
	self.task = task
	datastream.StreamToClients(player.GetHumans(), "sf_screen_download",
		{{
			ent = self,
			owner = ply,
			files = task.files,
			main = task.mainfile,
		}})
	screens[self] = self
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:NextThink(CurTime())
	
	if self.instance and not self.instance.error then
		self.instance:resetOps()
		self:RunScriptHook("think")
	end
	
	return true
end

-- Copied from GPULib
local function ScaleCursor( this, x, y )
	if (this.Scaling) then			
		local xMin = this.xScale[1]
		local xMax = this.xScale[2]
		local yMin = this.yScale[1]
		local yMax = this.yScale[2]
		
		x = (x * (xMax-xMin)) / 512 + xMin
		y = (y * (yMax-yMin)) / 512 + yMin
	end
	
	return x, y
end

-- Copied from GPULib
local function ReturnFailure( this )
	if (this.Scaling) then
		return {this.xScale[1]-1,this.yScale[1]-1}
	end
	return {-1,-1}
end

-- Copied from GPULib
function ENT:getCursor( ply )
	local Normal, Pos, monitor, Ang
		
	-- Get monitor screen pos & size
	monitor = WireGPU_Monitors[ self:GetModel() ]
		
	-- Monitor does not have a valid screen point
	if (!monitor) then return {-1,-1} end
		
	Ang = self:LocalToWorldAngles( monitor.rot )
	Pos = self:LocalToWorld( monitor.offset )
		
	Normal = Ang:Up()
	
	local Start = ply:GetShootPos()
	local Dir = ply:GetAimVector()
	
	local A = Normal:Dot(Dir)
	
	-- If ray is parallel or behind the screen
	if (A == 0 or A > 0) then return ReturnFailure( self ) end
	
	local B = Normal:Dot(Pos-Start) / A
		if (B >= 0) then
		local HitPos = WorldToLocal( Start + Dir * B, Angle(), Pos, Ang )
		local x = (0.5+HitPos.x/(monitor.RS*512/monitor.RatioX)) * 512
		local y = (0.5-HitPos.y/(monitor.RS*512)) * 512	
		if (x < 0 or x > 512 or y < 0 or y > 512) then return ReturnFailure( self ) end -- Aiming off the screen 
		x, y = ScaleCursor( self, x, y )
		return {x,y}
	end
	
	return ReturnFailure( self )
end

-- Sends a umsgs to all clients about the use.
function ENT:Use( activator )
	if activator:IsPlayer() then
		local pos = self:getCursor( activator )
		
		umsg.Start( "starfall_screen_used" )
			umsg.Short( self:EntIndex() )
			umsg.Short( activator:EntIndex() )
			umsg.Float( pos[1] )
			umsg.Float( pos[2] )
		umsg.End( )
		
		if self.sharedscreen then
			self:RunScriptHook( "screen_use", SF.Entities.Wrap( activator ), pos[1], pos[2] )
		end
		
	end
end

function ENT:OnRemove()
	if not self.instance then return end
	screens[self] = nil
	self.instance:deinitialize()
	self.instance = nil
end

function ENT:TriggerInput(key, value)
	if self.instance and not self.instance.error then
		self.instance:runScriptHook("input",key,value)
	end
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID, GetConstByID)
	self.BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID, GetConstByID)
end
