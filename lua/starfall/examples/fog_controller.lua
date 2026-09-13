--@name Fog Controller
--@author Name
--@client

local distance = 0
local density = 0

local function setupFog(scale)
    -- distances have to be corrected according to skybox's scale
    local skybox_mul = scale or 1
    
    -- only calculate fog properties once, in SetupWorldFog hook
    if not scale then
        local chipPos = chip():getPos()
        local ownerPos = owner():getPos()
        
        distance = chipPos:getDistance(ownerPos)
        density = 1 - math.clamp(distance / 500, 0, 1)
    end
    
    render.setFogMode(1)
    render.setFogColor(Color(230,245,255))
    
    -- thickens the fog when you get closer to the chip
    render.setFogDensity(density)
    render.setFogStart(distance / 500 * skybox_mul)
    render.setFogEnd((distance + 1000) * skybox_mul)
end

hook.add("SetupWorldFog", "", setupFog)
hook.add("SetupSkyboxFog", "", setupFog)

if player() == owner() then
    enableHud(nil, true)
end
