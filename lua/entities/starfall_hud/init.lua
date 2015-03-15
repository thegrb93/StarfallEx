AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString( "starfall_hud_set_enabled" )

local vehiclelinks = setmetatable({}, {__mode="k"})

function ENT:Initialize ()
	self.BaseClass.Initialize( self )
	self:SetUseType( SIMPLE_USE )
end

function ENT:Use( activator )
	net.Start( "starfall_hud_set_enabled" )
		net.WriteEntity( self )
		net.WriteInt(-1, 8)
	net.Send( activator )
end

function ENT:LinkEnt ( ent, ply )
	self.link = ent
	net.Start("starfall_processor_link")
		net.WriteEntity(self)
		net.WriteEntity(ent)
	if ply then net.Send(ply) else net.Broadcast() end
end

function ENT:LinkVehicle( ent )
	vehiclelinks[ent] = self
end

function ENT:BuildDupeInfo ()
	local info = self.BaseClass.BuildDupeInfo( self ) or {}

	if IsValid(self.link) then
		info.link = self.link:EntIndex()
	end
	info.linkedvehicles = {}
	for k, v in pairs( vehiclelinks ) do
		if v == self and k:IsValid() then
			info.linkedvehicles[#info.linkedvehicles + 1] = k:EntIndex()
		end
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
	for k, v in pairs(info.linkedvehicles) do
		local e = GetEntByID( v )
		if IsValid( e ) then
			self:LinkVehicle( e )
		end
	end
end

hook.Add("PlayerEnteredVehicle","Starfall_HUD_PlayerEnteredVehicle",function( ply, vehicle )
	for k,v in pairs( vehiclelinks ) do
		if vehicle == k and v:IsValid() then
			vehicle:CallOnRemove("remove_sf_hud", function()
				if not IsValid( v ) then return end
				net.Start( "starfall_hud_set_enabled" )
					net.WriteEntity( v )
					net.WriteInt(0, 8)
				net.Send( ply )
			end)
			
			net.Start( "starfall_hud_set_enabled" )
				net.WriteEntity( v )
				net.WriteInt(1, 8)
			net.Send( ply )
		end
	end
end)

hook.Add("PlayerLeaveVehicle","Starfall_HUD_PlayerLeaveVehicle",function( ply, vehicle )
	for k,v in pairs( vehiclelinks ) do
		if vehicle == k and v:IsValid() then
			net.Start( "starfall_hud_set_enabled" )
				net.WriteEntity( v )
				net.WriteInt(0, 8)
			net.Send( ply )
		end
	end
end)
