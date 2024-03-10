--@name Cam3D2D
--@author Name
--@client

local scale = 0.1
local font = render.createFont("Roboto", 256, 400, true)

-- Matrix formula used by GLua's cam.Start3D2D:
-- local m = Matrix()
-- m:setAngles(Angle(0, 0, 0))
-- m:setTranslation(Vector(0, 0, 0))
-- m:setScale(Vector(scale, -scale))

hook.add("PostDrawTranslucentRenderables", "", function()
    local m = chip():getMatrix()
    m:translate(Vector(0, 0, 45))
    m:setAngles((eyePos() - m:getTranslation()):getAngle() + Angle(90, 0, 0))
    m:rotate(Angle(0, 90, 0))
    m:setScale(Vector(scale, -scale))
    
    render.pushMatrix(m)
        render.setColor(Color(255, 191, 20, 155))
        render.drawRect(-512, -128, 1024, 256)

        -- Override depth for text rendering, otherwise it's gonna draw on top of the world
        render.enableDepth(true)
        render.setColor(Color(10, 167, 238))
        render.setFont(font)
        render.drawSimpleText(0, 0, "StarfallEx", 1, 1)
    render.popMatrix()
end)

if player() == owner() then
    enableHud(nil, true)
end
