--@name render.renderView example
--@author Szymekk
--@client

-- render.renderView allows to render the world into a render target
-- Link the chip to a screen to see how it works

setupPermissionRequest({ "render.renderscene", "render.renderView" }, "See an example of render.renderView.", true)
local permissionSatisfied = hasPermission("render.renderView")

local rtName = "mirror_rt"
render.createRenderTarget(rtName)

local mat = material.create("gmodscreenspace")
mat:setTextureRenderTarget("$basetexture", rtName)

local scrW, scrH
local screenEnt

hook.add("renderscene", "render_view", function(origin, angles)
    if not permissionSatisfied then return end

    if not render.isInRenderView() and screenEnt then
        render.selectRenderTarget(rtName)
        
        render.enableClipping(true)
        
        local clipNormal = screenEnt:getUp()
        render.pushCustomClipPlane(clipNormal, (screenEnt:getPos() + clipNormal):dot(clipNormal))
        
        local localOrigin = screenEnt:worldToLocal(origin)
        local reflectedOrigin = screenEnt:localToWorld(localOrigin * Vector(1, 1, -1))
        
        local localAng = screenEnt:worldToLocalAngles(angles)
        local reflectedAngle = screenEnt:localToWorldAngles(Angle(-localAng.p, localAng.y, -localAng.r + 180))
        
        render.renderView({
            origin = reflectedOrigin,
            angles = reflectedAngle,
            aspectratio = scrW / scrH,
            x = 0,
            y = 0,
            w = 1024,
            h = 1024,
            drawviewmodel = false,
            drawviewer = true,
        })
        
        render.popCustomClipPlane()
        
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
    render.drawTexturedRect(scrW, 0, -scrW, scrH)
    render.popViewMatrix()
end)

hook.add("permissionrequest", "", function()
    permissionSatisfied = hasPermission("render.renderView")
end)
