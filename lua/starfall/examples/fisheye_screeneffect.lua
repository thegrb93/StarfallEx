--@name Fish-eye effect
--@client
--@owneronly

-- Enabling our HUD
enableHud(owner(), true)

-- Get screenspace texture
local screenspace = render.getScreenEffectTexture()

-- We should create the material first
local fisheye = material.create("Refract_DX90")
-- There we set the screen effect texture to refract it
fisheye:setTexture("$basetexture", screenspace)
-- Fish-eye $dudvmap and $normalmap
fisheye:setTexture("$dudvmap", "models/effects/fisheyelens_dudv")
fisheye:setTexture("$normalmap", "models/effects/fisheyelens_normal")
-- Refract amount. Negative values will give a fish-eye effect like a GoPro
fisheye:setFloat("$refractamount", -0.07)

-- To render the effect, we will use DrawHUD
hook.add("DrawHUD", "FisheyeEffect", function()
    -- Update the screenspace texture (to render it again with new information)
    render.updateScreenEffectTexture()
    -- And draw refracted texture (fish-eye)
    render.setMaterial(fisheye)
    render.drawTexturedRect(0, 0, render.getGameResolution())
end)
