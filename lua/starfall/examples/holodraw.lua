--@name Holodraw
--@author Name
--@shared

-- This code explains how to correctly use Hologram.draw method on a randertarget with transparent background
-- Steps shown in here are not required if you're drawing it directly to a screen or a HUD
-- Two methods are shown here, but they cannot be combined, therefore the appropriate one has to be chosen depending on the model

local origin = chip():getPos()

if CLIENT then
    
    local holo1 = holograms.create(origin + Vector(0,8,40), Angle(), "models/spacecode/sfchip.mdl", Vector(1.4))
    local holo2 = holograms.create(origin + Vector(0,-8,37), Angle(), "models/Lamarr.mdl", Vector(0.45))
    -- We can hide the holograms, but 'holo2' needs to render in order to work with the second method
    --holo1:setNoDraw(true)
    --holo2:setColor(Color(0,0,0,1))
    
    render.createRenderTarget("canvas")
    
    hook.add("drawhud", "drawstuff", function()
        holo1:setAngles(Angle(45, timer.curtime() * 100, 0))
        holo2:setAngles(Angle(0, -timer.curtime() * 100, 0))
        
        render.selectRenderTarget("canvas")
            render.clear(Color(0,0,0,0), true)
            
            render.setColor(Color(0,255,255))
            render.drawRectOutline(1, 1, 1022, 1022)
            
            render.pushViewMatrix({
                type = "3D",
                origin = origin + Vector(-30, 0, 40),
                angles = Angle(),
                fov = 60,
                aspect = 1,
            })
            
            -- This is the simplest way of combating weird lighting issues
            -- It doesn't work for all models though, ragdolls in particular
            -- Value for this function can be 1 (total fullbright) or 2 (increased fullbright), depending on the needs
            render.setLightingMode(1)
                holo1:draw()
            render.setLightingMode(0)
            
            holo2:draw()
            
            render.popViewMatrix()
        render.selectRenderTarget()
        
        render.setColor(Color(255,255,255))
        render.setRenderTargetTexture("canvas")
        render.drawTexturedRect(16, 256, 512, 512)
    end)
    
    if player() == owner() then
        enableHud(nil, true)
    end
else
    
    -- To combat the lighting on this hologram, we have to expose it to env_projectedtexture
    -- This special entity can be created by gmod_lamp (player's flashlight works too!)
    -- The lamp itself can have a brightness of 0 and can be made non-intrusive by making it invisible and disabling the collisions
    local lamp = prop.createSent(origin + Vector(0,-8,75), Angle(90,0,0), "gmod_lamp", true, {
        starton = true,
        brightness = 0,
        fov = 10,
        model = "models/maxofs2d/lamp_flashlight.mdl",
    })
    --lamp:setColor(Color(0,0,0,0))
    --lamp:setCollisionGroup(10) -- COLLISION_GROUP_IN_VEHICLE
end
