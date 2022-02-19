--@name Cam3D2D
--@author Name
--@client

local iterations = 14
local scale = 0.1
local font = render.createFont("Roboto", 256, 400, true)

-- Matrix formula used by GLua's cam.Start3D2D:
-- local m = Matrix()
-- m:setAngles(Angle(0, 0, 0))
-- m:setTranslation(Vector(0, 0, 0))
-- m:setScale(Vector(scale, -scale))

hook.add("PostDrawOpaqueRenderables", "", function()
    local m = chip():getMatrix()
    m:translate(Vector(0, 0, 45))
    m:setAngles((eyePos() - m:getTranslation()):getAngle() + Angle(90, 0, 0))
    m:rotate(Angle(0, 90, 0))
    m:setScale(Vector(scale, -scale))
    
    for i = 1, iterations do
        render.pushMatrix(m)
            render.setColor(Color(245, 177, 29) / (iterations-i))
            render.setFont(font)
            render.drawSimpleText(0, 0, "FANCY", 1, 1)
        render.popMatrix()
        m:translate(Vector(1, -1))
    end
end)

if player() == owner() then
    enableHud(nil, true)
end
