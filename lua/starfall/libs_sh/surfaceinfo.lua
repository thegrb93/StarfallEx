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
	return "SurfaceInfo"
end


----------- Methods -----------

local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local lwrap, lunwrap = instance.Types.LockedMaterial.Wrap, instance.Types.LockedMaterial.Unwrap

--- Returns the brush surface's material.
-- @client
-- @return Material of one portion of a brush model.
function surfaceinfo_methods:getMaterial()
    return lwrap(sunwrap(self):GetMaterial())
end

--- Returns a list of vertices the brush surface is built from.
-- @shared
-- @return A list of Vector points. This will usually be 4 corners of a quadrilateral in counter-clockwise order.
function surfaceinfo_methods:getVertices()
    local t = sunwrap(self):GetVertices()
    local out = {}
    if not t then return out end
    for k,vec in ipairs(t) do
        out[k] = vwrap(vec)
    end
    return out
end

--- Checks if the brush surface is a nodraw surface, meaning it will not be drawn by the engine.
-- This internally checks the SURFDRAW_NODRAW flag.
-- @shared
-- @return Returns true if this surface won't be drawn.
function surfaceinfo_methods:isNoDraw()
    return sunwrap(self):IsNoDraw()
end

--- Checks if the brush surface is displaying the skybox.
-- This internally checks the SURFDRAW_SKY flag.
-- @shared
-- @return Returns true if the surface is the sky.
function surfaceinfo_methods:isSky()
    return sunwrap(self):IsSky()
end

--- Checks if the brush surface is water.
-- This internally checks the SURFDRAW_WATER flag.
-- @shared
-- @return Returns true if the surface is water.
function surfaceinfo_methods:isWater()
    return sunwrap(self):IsWater()
end

end
