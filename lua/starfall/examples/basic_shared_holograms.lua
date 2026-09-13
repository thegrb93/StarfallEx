--@name Shared Holograms
--@author Name
--@shared

local offset = SERVER and Vector(10,0,30) or Vector(-10,0,30)
local color = SERVER and Color(50,100,255) or Color(255,120,0)

-- This will create 2 holograms, one on each of the realms
local realm_holo = holograms.create(chip():getPos() + offset, Angle(), "models/hunter/blocks/cube025x025x025.mdl", Vector(0.5))
realm_holo:setColor(color)

-- Serverside holograms can be transmited to the client if needed
if SERVER then
    
    hook.add("ClientInitialized", "cl_init", function(ply)
        net.start("holo")
            net.writeEntity(realm_holo)
        net.send(ply)
    end)
    
else
    
    -- Clientside holograms are somewhat funky, please use them with care and note that certain functions won't work on them
    -- realm_holo:obbSize() --> Vector(0,0,0)
    -- realm_holo:getScale() --> Vector(0.5,0.5,0.5) - only because it's being internally accounted for when setting hologram's scale
    
    -- If you notice that holograms are disappearing too early, when their origin is off the screen,
    -- you can manually set the render bounds (worth noting, that this method is part of the Entity type and works on clientside holograms)
    realm_holo:setRenderBounds(Vector(-5), Vector(5))
    
    local function receivedHologram(ent)
        if ent==nil then error("Failed to get hologram!") end
        
        -- We need to convert it back to it's original type in order to use the Hologram methods on it
        local server_holo = ent:toHologram()
        
        -- Let's now initialize a continuous hook that will use clientside-only method setRenderMatrix on our serverside hologram
        local m = Matrix()
        hook.add("tick", "scale", function()
            if not server_holo:isValid() then return end
            
            local scale = 0.75 + math.sin(timer.curtime() * 10) / 4
            m:setScale(Vector(scale))
            m:rotate(Angle(0, 1, 0))
            server_holo:setRenderMatrix(m)
        end)
    end
    
    net.receive("holo", function(len)
        -- Since the client may not have created the hologram yet, it's important to use the callback of net.readEntity to wait and be sure it exists first.
        net.readEntity(receivedHologram)
    end)
    
end
