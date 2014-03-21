include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_OPAQUE

local function getRenderBounds ( ent )
    if not ent:IsValid() then return end
    return ent:OBBMins(), ent:OBBMaxs()
end

function ENT:Initialize ()
    self:SetRenderBounds( getRenderBounds( self ) )
end
