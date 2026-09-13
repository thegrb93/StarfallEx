--@name Holodraw Example
--@author Name
--@shared

-- Certain hologram models may interfere with depth / alpha channel when drawn to a RenderTarget, rendering them transparent
-- Holograms drawn directly to HUD or a screen do not show these symptomps and the workaround is not necessary
-- One way of fixing this is to set the lighting mode, or if that doesn't work, exposing the hologram to env_projectedtexture

if CLIENT then
    local holo1 = holograms.create(chip():getPos() + Vector(0,8,40), Angle(), "models/spacecode/sfchip.mdl", Vector(1.4))
    local holo2 = holograms.create(chip():getPos() + Vector(0,-8,37), Angle(), "models/Lamarr.mdl", Vector(0.45))
    -- The first hologram can be completely hidden, but for the second method to work, the other hologram needs to render
    --holo1:setNoDraw(true)
    --holo2:setColor(Color(0,0,0,1))
    
    render.createRenderTarget("canvas")
    hook.add("drawhud", "drawstuff", function()
        holo1:setAngles(Angle(45, timer.curtime() * 100, 0))
        holo2:setAngles(Angle(0, -timer.curtime() * 100, 0))
        
        render.selectRenderTarget("canvas")
            render.clear(Color(0,0,0,0), true)
            render.setColor(Color(0,255,255))
            render.drawRectOutline(0, 0, 1024, 1024, 8)
            
            render.pushViewMatrix({
                type   = "3D",
                origin = chip():getPos() + Vector(-30, 0, 40),
                angles = Angle(),
                fov    = 60,
                aspect = 1,
            })
            
            -- FIRST METHOD: Render in fullbright or increased fullbright. May not work with all models, ragdolls in particular
            render.setLightingMode(1)
                holo1:draw()
            render.setLightingMode(0)
            
            holo2:draw()
            
            render.popViewMatrix()
        render.selectRenderTarget()
        
        render.setColor(Color(255,255,255))
        render.setRenderTargetTexture("canvas")
        render.drawTexturedRect(256, 256, 512, 512)
    end)
    
    if player() == owner() then
        enableHud(nil, true)
    end
else
    -- SECOND METHOD: Expose the hologram to env_projectedtexture, eg. player's flashlight or gmod_lamp
    local lamp = prop.createSent(chip():getPos() + Vector(0,-8,75), Angle(90,0,0), "gmod_lamp", true, {
        on = true,
        fov = 10,
        brightness = 0,
        Model = "models/maxofs2d/lamp_flashlight.mdl",
    })
    -- Lamp can be entirely consealed, including disabling the collisions
    --lamp:setColor(Color(0,0,0,0))
    --lamp:setCollisionGroup(COLLISION_GROUP.IN_VEHICLE)
end
