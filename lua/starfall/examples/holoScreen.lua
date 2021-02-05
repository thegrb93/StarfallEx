--@name holoScreen Example
--@author LightRobin
--@client

-- This will create a render screen using holograms.
-- Making a screen this way means that you do not need to run a render hook 24/7, thus using less clientside cpu time
-- This is especially useful in applications where the screen does not need to be updated very often

local scrSize = 69 -- size of the screen in source units
local FPS = 30 -- how many frames to draw every second

-- Create a render target to draw onto
render.createRenderTarget("screenRT")
-- Create a new material, we will set the hologram's material to this later
local screenMat = material.create("UnlitGeneric") 
-- Set the material's texture to the render target that we've just created
screenMat:setTextureRenderTarget("$basetexture", "screenRT") 
-- Clear the material's flags
screenMat:setInt("$flags", 0)

-- Create the screen hologram
local screen = holograms.create(chip():localToWorld(Vector(0, 0, scrSize/2)), Angle(90,-90,0), "models/holograms/plane.mdl")
screen:setSize(Vector(scrSize, scrSize, scrSize))    
screen:setParent(chip())

-- Set the screen hologram's material to the material that we created earlier
screen:setMaterial("!" .. screenMat:getName())

-- create a function to update the screen, in future we will call this whenever the screen needs to be updated
local function updateScreen()
    -- create a renderoffscreen hook, no need for a render hook as we are not drawing to a hud/screen
    hook.add("renderoffscreen","",function()
        hook.remove("renderoffscreen","") -- remove the hook since we only want it to draw a single frame per call of this function
        render.selectRenderTarget("screenRT") -- select our render target
        render.clear() -- clear the screen, if we don't do this then whatever we draw will be drawn on top of our last frame
        
        -- do all your drawing from here on as you would normally with a regular screen
        -- keep in mind that we are using a render target which is 1024x1024 pixels, whereas a screen would be 512x512 pixels
        -- draw a funky box that oscillates back and forth in the middle of the screen.
        render.setColor(Color(math.random(100, 255), math.random(100, 255), math.random(100, 255)))
        render.drawRect(math.sin(timer.curtime() * 2) * 380 + (512 - 100), 512 / 2, 200, 400)
    end)
end

-- create a timer to update the screen FPS times a second
timer.create("updateScreen", 1/FPS, 0, updateScreen)
