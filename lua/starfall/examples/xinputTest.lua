--@name XInput Test
--@author mitterdoo
--@client

-- Renders a rectangle and colors it based on the bool value of b
local function button(b, x, y, w, h)
    if b then
        render.setRGBA(0,255,0,255)
    else
        render.setRGBA(255,0,0,255)
    end
    render.drawRect(x, y, w, h)
end

local controllerIdx = 0 -- This is the index for the controller to show the input of. It begins at 0

local softRumble = 0
local hardRumble = 0

hook.add("render", "", function()

    if xinput.getState(controllerIdx) then-- This shows we're connected
    
        render.setRGBA(255,255,255,255)
        render.drawText(0, 0, "CONTROLLER " .. controllerIdx .. " CONNECTED", 0)
    
    end
    local cx, cy = 100, 200 -- Center of the left dpad
    local dist = 10 -- Distance between center, and the inside endpoints of the button line
    local size = 40 -- Length of a dpad button
    local wide = 10 -- Width of a dpad button
    local tsize = 100 -- Height of trigger
    
    button(xinput.getButton(controllerIdx, 0x1), cx - wide/2, cy - dist - size, wide, size) -- Up
    button(xinput.getButton(controllerIdx, 0x2), cx - wide/2, cy + dist, wide, size) -- Down
    button(xinput.getButton(controllerIdx, 0x4), cx - dist - size, cy - wide/2, size, wide) -- Left
    button(xinput.getButton(controllerIdx, 0x8), cx + dist, cy - wide/2, size, wide) -- Right
    button(xinput.getButton(controllerIdx, 0x100), cx - dist - size, cy - dist - size - wide, size*2 + dist*2, wide) -- Left shoulder
    render.setRGBA(255,0,0,255)
    render.drawRect(cx - dist - size, cy - dist - size - wide*2 - tsize, size*2 + dist*2, tsize) -- Trigger BG
    
    render.setRGBA(0,255,0,255)
    local perc = xinput.getTrigger(controllerIdx, 0) / 255
    render.drawRect(cx - dist - size, cy - dist - size - wide*2 - tsize*perc, size*2 + dist*2, tsize*perc) -- Left Trigger
    
    cx, cy = 300, 200 -- Move centerpoint to right
    button(xinput.getButton(controllerIdx, 0x8000), cx - wide/2, cy - dist - size, wide, size) -- Y
    button(xinput.getButton(controllerIdx, 0x1000), cx - wide/2, cy + dist, wide, size) -- A
    button(xinput.getButton(controllerIdx, 0x4000), cx - dist - size, cy - wide/2, size, wide) -- X
    button(xinput.getButton(controllerIdx, 0x2000), cx + dist, cy - wide/2, size, wide) -- B
    button(xinput.getButton(controllerIdx, 0x200), cx - dist - size, cy - dist - size - wide, size*2 + dist*2, wide) -- Right shoulder
    
    button(xinput.getButton(controllerIdx, 0x20), 50 + 110, 150, 5, 20) -- Back
    button(xinput.getButton(controllerIdx, 0x10), 250 - 15, 150, 5, 20) -- Start
    
    button(xinput.getButton(controllerIdx, 0x40), 50, 300, 100, 100) -- Left thumb button
    button(xinput.getButton(controllerIdx, 0x80), 250, 300, 100, 100) -- Right thumb button
    render.setRGBA(255,0,0,255)
    render.drawRect(cx - dist - size, cy - dist - size - wide*2 - tsize, size*2 + dist*2, tsize) -- Trigger BG
    
    render.setRGBA(0,255,0,255)
    local perc = xinput.getTrigger(controllerIdx, 1) / 255
    render.drawRect(cx - dist - size, cy - dist - size - wide*2 - tsize*perc, size*2 + dist*2, tsize*perc) -- Right Trigger
    
    render.setRGBA(0,0,0,255)
    cx, cy = 50+50, 300+50 -- Move centerpoint to below trigger for stick
    size = 100 -- Width of the stick region
    local blip = 4 -- Size of the "blip" that marks where the stick is located
    
    local x, y = xinput.getStick(controllerIdx, 0)
    render.drawRect(cx + x/65535*size-blip/2, cy + -y/65535*size-blip/2, blip, blip) -- Left stick position
    
    cx, cy = 250+50, 300+50 -- Move centerpoint to the right
    local x, y = xinput.getStick(controllerIdx, 1)
    render.drawRect(cx + x/65535*size-blip/2, cy + -y/65535*size-blip/2, blip, blip) -- Right stick position
    
    
    local cursor_x, cursor_y = render.cursorPos()
    local useKey = input.lookupBinding("+use")
    local held = cursor_x and input.isKeyDown(useKey) -- If cursor_x is nil (player isn't looking at screen), don't bother with slider maths)
    
    local bx1, by1, bw, bh = 400, 100, 40, 200
    local bx2, by2 = bx1 + bw, by1 + bh -- Get the boundary of the slider
    
    render.setRGBA(255,0,0,255)
    render.drawRect(bx1, by1, bw, bh)
    
    if held and bx1 <= cursor_x and cursor_x <= bx2 and by1 <= cursor_y and cursor_y <= by2 then -- Checks if the cursor is inside the slider
        local percent = 1 - (cursor_y - by1) / bh
        softRumble = percent
        
    end
    
    render.setRGBA(0,255,0,255)
    render.drawRect(bx1, by2 - bh*softRumble, bw, bh*softRumble) -- Draws a variable-height rectangle, locked to the bottom
    
    bx1, by1, bw, bh = 450, 100, 40, 200
    bx2, by2 = bx1 + bw, by1 + bh -- Get the boundary of the slider
    render.setRGBA(255,0,0,255)
    render.drawRect(bx1, by1, bw, bh)
    
    if held and bx1 <= cursor_x and cursor_x <= bx2 and by1 <= cursor_y and cursor_y <= by2 then -- Checks if the cursor is inside the slider
        local percent = 1 - (cursor_y - by1) / bh
        hardRumble = percent
    end
    
    render.setRGBA(0,255,0,255)
    render.drawRect(bx1, by2 - bh*hardRumble, bw, bh*hardRumble) -- Draws a variable-height rectangle, locked to the bottom
    
    render.setRGBA(255,255,255,255)
    render.drawText(420, 110, "SOFT", 1)
    render.drawText(470, 110, "HARD", 1)
    render.drawText(445, 310, "RUMBLE (PRESS USE)", 1)
    
    xinput.setRumble(controllerIdx, softRumble, hardRumble)
    
    
end)
