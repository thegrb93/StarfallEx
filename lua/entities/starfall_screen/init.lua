AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')


function ENT:Initialize ()
	self.BaseClass.Initialize( self )
	self:SetUseType( SIMPLE_USE )
end

-- Sends a net message to all clients about the use.
function ENT:Use( activator )
	if not self.link then return end
	
	if activator:IsPlayer() then
		net.Start( "starfall_processor_used" )
			net.WriteEntity( self )
			net.WriteEntity( activator )
		net.Broadcast()
	end
	
	local instance = self.link.instance
	if instance and instance.hooks[ "starfallUsed" ] then
		local ok, rt = instance:runScriptHook( "starfallUsed", SF.Entities.Wrap( activator ) )
		if not ok then self:Error( rt ) end
	end
end

function ENT:LinkEnt ( ent, ply )
	self.link = ent
	net.Start("starfall_processor_link")
		net.WriteEntity(self)
		net.WriteEntity(ent)
	if ply then net.Send(ply) else net.Broadcast() end
end

function ENT:BuildDupeInfo ()
	local info = self.BaseClass.BuildDupeInfo( self ) or {}

	if IsValid(self.link) then
		info.link = self.link:EntIndex()
	end

	return info
end

function ENT:ApplyDupeInfo ( ply, ent, info, GetEntByID )
	self.BaseClass.ApplyDupeInfo( self, ply, ent, info, GetEntByID )
	
	if info.link then
		local e = GetEntByID( info.link )
		if IsValid( e ) then
			self:LinkEnt( e )
		end
	end
end