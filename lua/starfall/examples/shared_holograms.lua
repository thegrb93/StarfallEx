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
            -- Most of the time you can treat them like normal entities, so using net.writeEntity will work just fine
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
    
    net.receive("holo", function(len)
        -- When reading it from network, it will be just like any other entity,
        -- so to use Hologram specific methods, we need to convert it back to the appropriate type
        local server_holo = net.readEntity():toHologram()
        
        -- On a side note, please notice that script will error when reuploaded due to invalid entity later on,
        -- it's always a good idea to implement some sort of buffer and send entity index, converting and validating it manually
        
        -- Let's now initialize a continuous hook that will use clientside-only method setRenderMatrix on our serverside hologram
        local m = Matrix()
        hook.add("tick", "scale", function()
            local scale = 0.75 + math.sin(timer.curtime() * 10) / 4
            m:setScale(Vector(scale))
            m:rotate(Angle(0, 1, 0))
            server_holo:setRenderMatrix(m)
        end)
    end)
    
end
