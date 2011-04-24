TOOL.Category		= "Starfall"
TOOL.Name			= "Starfall"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

if CLIENT then
    language.Add( "Tool_starfall_name", "Starfall Tool (Wire)" )
    language.Add( "Tool_starfall_desc", "Spawns a starfall processor" )
    language.Add( "Tool_starfall_0", "Primary: Spawn, Secondary: Uploads code form sf_code_buffer" )
	language.Add( "sboxlimit_starfall", "You've hit the Starfall processor limit!" )
	language.Add( "undone_Wire Starfall", "Undone Starfall" )
	CreateConVar("sf_code_buffer", "", {FCVAR_USERINFO})
end

if SERVER then
	CreateConVar('sbox_maxstarfall', 10)
end

TOOL.ClientConVar[ "Model" ] = "models/jaanus/wiretool/wiretool_siren.mdl"

cleanup.Register( "wire_starfall" )


function TOOL:LeftClick( trace )
	if !trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	if ValidEntity(trace.Entity) and trace.Entity:GetClass() == "gmod_starfall" then
		local code = self:GetOwner():GetInfo("sf_code_buffer")
		trace.Entity:Compile(code)
		return true
	end
	
	self:SetStage(0)

	local model = self:GetClientInfo( "Model" )
	local ply = self:GetOwner()
	if !self:GetSWEP():CheckLimit( "wire_starfall" ) then return false end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local sf = MakeSF( ply, trace.HitPos, Ang, model)

	local min = sf:OBBMins()
	sf:SetPos( trace.HitPos - trace.HitNormal * min.z )

	local const = WireLib.Weld(sf, trace.Entity, trace.PhysicsBone, true)

	undo.Create("Wire Starfall")
		undo.AddEntity( sf )
		undo.AddEntity( const )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "wire_starfall", sf )

	return true
end

function TOOL:RightClick( trace )
	if !trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	if ValidEntity(trace.Entity) then
		if trace.Entity:GetClass() == "gmod_starfall" then
			local code = self:GetOwner():GetInfo("sf_code_buffer")
			trace.Entity:Compile(code)
			return true
		end
	end
end

function TOOL:Reload(trace)
	return false
end

function TOOL:DrawHUD()
end

if SERVER then
	function MakeSF( pl, Pos, Ang, model)
		if !pl:CheckLimit( "wire_starfall" ) then return false end

		local sf = ents.Create( "gmod_starfall" )
		if !IsValid(sf) then return false end

		sf:SetAngles( Ang )
		sf:SetPos( Pos )
		sf:SetModel( model )
		sf:Spawn()

		sf.player = pl

		pl:AddCount( "wire_starfall", sf )

		return sf
	end
end

function TOOL:Think()
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_starfall_name", Description = "#Tool_starfall_desc" })
end