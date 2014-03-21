include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:GetOverlayText ()
    local message = baseclass.Get( "base_gmodentity" ).GetOverlayText( self )
    return message or ""
end

function ENT:Draw ()
    self.BaseClass.Draw( self )
    self:DrawModel()
    if self:BeingLookedAtByLocalPlayer() then
        AddWorldTip( self:EntIndex(), self:GetOverlayText(), 0.5, self:GetPos(), self )
    end
end
