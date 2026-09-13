--@name holoScreen Example
--@author LightRobin
--@client

-- This will create a render screen using a hologram.
-- Also has FPS limiting, which is especially useful in applications where the screen does not need to be updated very often

local scrSize = 69 -- Size of the screen in source units
local FPS = 60 -- How many frames to draw every second

local next_frame = 0 -- Save when the next frame should happen so we can calculate whether enough time has passed to render another frame
local fps_delta = 1/FPS -- Calculate how many ms in between frames to be used with fps limiting. (Don't want to constantly recalculate it)

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

-- Create a renderoffscreen hook, no need for a render hook as we are not drawing to a hud/screen
-- This hook always runs since we can't tell the game when the holo screen needs to render.
hook.add("renderoffscreen", "", function()
    -- Limit the FPS by calculating the time in between frames to see if we should render another frame
    local now = timer.systime()
    if next_frame > now then return end
    next_frame = now + fps_delta
    -- You can also get difference in these frames by subtracting now from last_frame,
    -- Or if you only need that, just use timer.frametime rather than storing the frames.

    render.selectRenderTarget("screenRT") -- select our render target
    render.clear() -- clear the screen, if we don't do this then whatever we draw will be drawn on top of our last frame
    
    -- Do all your drawing from here on as you would normally with a regular screen
    -- Keep in mind that we are using a render target which is 1024x1024 pixels, whereas a screen would be 512x512 pixels
    -- Draw a funky box that oscillates back and forth in the middle of the screen.
    render.setColor(Color(math.random(100, 255), math.random(100, 255), math.random(100, 255)))
    render.drawRect(math.sin(now * 2) * 380 + (512 - 100), 512 / 2, 200, 400)
end)
