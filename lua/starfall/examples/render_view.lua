--@name render.renderView example
--@author Szymekk
--@client

-- render.renderView allows to render the world into a render target
-- Link the chip to a screen to see how it works

setupPermissionRequest({ "render.offscreen", "render.renderView" }, "See an example of render.renderView.", true)
local permissionSatisfied = hasPermission("render.renderView")

local rtName = "rendertarget"
render.createRenderTarget(rtName)

local mat = material.create("gmodscreenspace")
mat:setTextureRenderTarget("$basetexture", rtName)

local scrW, scrH
local screenEnt

hook.add("renderoffscreen", "render_view", function()
    if not permissionSatisfied then return end

    if not render.isInRenderView() and screenEnt then
        render.selectRenderTarget(rtName)

        local origin = screenEnt:getPos()
        local relativePos = (origin - eyePos())
        
        local m1 = Matrix()
        m1:setAngles(screenEnt:getAngles())
        
        local m2 = Matrix()
        m2:setAngles(eyeAngles())
        
        local m3 = Matrix()
        m3:setTranslation(relativePos)
        
        local mRotation = m1:getInverseTR() * m2
        local mTransform = m1:getInverseTR() * m3
        
        render.renderView({
            origin = screenEnt:getPos() - mTransform:getTranslation() + Vector(0, 0, 200),
            angles = mRotation:getAngles(),
            aspectratio = scrW / scrH,
            x = 0,
            y = 0,
            w = 1024,
            h = 1024,
            drawviewmodel = false,
        })
        
        render.selectRenderTarget()
    end
end)

hook.add("render", "render_screen", function()
    if not permissionSatisfied then
        render.setColor(Color(255, 255, 255))
        render.setFont("DermaLarge")
        render.drawText(256, 256 - 32, "Use me", 1)
        return
    end

    if render.isInRenderView() then
        render.setColor(Color(0, 0, 0))
        render.drawRect(0, 0, 512, 512)
        render.setColor(Color(255, 255, 0))
        render.setFont("DermaLarge")
        render.drawText(256, 256 - 32, "RenderView", 1)
        return
    end

    scrW, scrH = render.getGameResolution()
    screenEnt = screenEnt or render.getScreenEntity()

    render.pushViewMatrix({ type = "2D" })
    render.setMaterial(mat)
    render.setColor(Color(255, 255, 255))
    render.drawTexturedRect(0, 0, scrW, scrH)
    render.popViewMatrix()
end)

hook.add("permissionrequest", "", function()
    permissionSatisfied = hasPermission("render.renderView")
end)