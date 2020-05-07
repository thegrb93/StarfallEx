--@name Holodraw
--@author Name
--@client

-- This example shows you how to properly use Hologram:draw method on a rendertarget with transparent background
-- To solve the weird lighting issues, use render.setLightingMode with values of 1 (fullbright) or 2 (increased fullbright)
-- Please note, this won't work for all models, ie. models/Gibs/HGIBS.mdl or most, if not all of the Facepunch models
-- To solve that, you need to draw the hologram with at least 1 alpha and light it manually using player's flashlight or gmod_lamp (not gmod_light)

local holo = holograms.create(Vector(), Angle(), "models/spacecode/sfchip.mdl", Vector(1))
holo:setNoDraw(true)

render.createRenderTarget("canvas")

hook.add("drawhud", "drawstuff", function()
    holo:setAngles(Angle(45, timer.curtime() * 100, 0))
    
    render.selectRenderTarget("canvas")
        render.clear(Color(0,0,0,0), true)
        
        -- border
        render.setColor(Color(255,0,0))
        render.drawRectOutline(1, 1, 1022, 1022)
        
        render.pushViewMatrix({
            type = "3D",
            origin = Vector(15, 0, 0),
            angles = Angle(0, 180, 0),
            fov = 60,
            aspect = 1,
        })
        
        render.setLightingMode(2)
            holo:draw()
        render.setLightingMode(0)
        
        render.popViewMatrix()
    render.selectRenderTarget()
    
    render.setColor(Color(255,255,255))
    render.setRenderTargetTexture("canvas")
    render.drawTexturedRect(16, 16, 512, 512)
end)
