-- Globals unneeded for now

--- SurfaceInfo type
-- @name SurfaceInfo
-- @class type
-- @libtbl surfaceinfo_methods
-- @libtbl surfaceinfo_meta

SF.RegisterType("SurfaceInfo",false,true,debug.getregistry().SurfaceInfo)

return function(instance) 

local surfaceinfo_methods, surfaceinfo_meta, swrap, sunwrap = instance.Types.SurfaceInfo.Methods, instance.Types.SurfaceInfo, instance.Types.SurfaceInfo.Wrap, instance.Types.SurfaceInfo.Unwrap

function surfaceinfo_meta:__tostring()
	local surfinf = sunwrap(self)
	if not surfinf then return "(null SurfaceInfo)"
	else return tostring(surfinf) end
end


----------- Methods -----------

local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local lwrap, lunwrap = instance.Types.LockedMaterial.Wrap, instance.Types.LockedMaterial.Unwrap

--- Returns the brush surface's material.
-- @client
-- @return Material of one portion of a brush model.
function surfaceinfo_methods:getMaterial()
    local surface = sunwrap(self)
    return lwrap(surface:GetMaterial())
end

--- Returns a list of vertices the brush surface is built from.
-- @shared
-- @return A list of Vector points. This will usually be 4 corners of a quadrilateral in counter-clockwise order.
function surfaceinfo_methods:getVertices()
    local surface = sunwrap(self)
    local t = surface:GetVertices()
    local out = {}
    if not t then return out end
    for K,Vec in ipairs(t) do
        out[K] = vwrap(Vec)
    end
    return out
end

--- Checks if the brush surface is a nodraw surface, meaning it will not be drawn by the engine.
-- This internally checks the SURFDRAW_NODRAW flag.
-- @shared
-- @return Returns true if this surface won't be drawn.
function surfaceinfo_methods:isNoDraw()
    local surface = sunwrap(self)
    return surface:IsNoDraw()
end

--- Checks if the brush surface is displaying the skybox.
-- This internally checks the SURFDRAW_SKY flag.
-- @shared
-- @return Returns true if the surface is the sky.
function surfaceinfo_methods:isSky()
    local surface = sunwrap(self)
    return surface:IsSky()
end

--- Checks if the brush surface is water.
-- This internally checks the SURFDRAW_WATER flag.
-- @shared
-- @return Returns true if the surface is water.
function surfaceinfo_methods:isWater()
    local surface = sunwrap(self)
    return surface:IsWater()
end

end
