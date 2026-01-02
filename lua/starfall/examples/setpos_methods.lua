--@name Setpos methods
--@author Neatro
--@server

if not hasPermission( "entities.setPos", chip() ) then
    throw( "You need Entities permission to see this example code! Enable permission entities.setpos" )
end

--[[
This example code shows how smooth Setpos is achieved.

You may have tried to directly setPos() an entity and saw how the movement was very choppy.

This is because this method doesn't have any interpolation.
It can be good for other uses unless you want smooth motion with setPos().

To do this, you need to setPos() the physicsObject of an entity. 

This retains the interpolation and makes motion looks smooth.

As an example, The red box has setPos on itself.
The greenbox has setPos on the physicsObject.

]]--

-- Ignore this bit, it's for creating the prop
local function create( c )
    p = prop.create( Vector(0), Angle(0), "models/props_junk/wood_crate001a.mdl", true )
    p:setColor( c ) 
    return p
end

-- Localize our variables, makes code more efficient
local smooth, normal

-- Change prop positions every tick
hook.add( "tick", "runtime", function()
    -- Movement code
    local motion = chip():getPos() + Vector( math.sin( timer.systime() * 4 ) * 64, 0, 48 )
    
    -- Spawns prop when it doesn't exist
    
    -- If the prop exists, setPos to the movement else try and respawn it
    if isValid( normal ) then
        -- This is setpos WITHOUT getting the entities getPhysicsObject()
        -- There is NO interpolation!
        normal:setPos( motion )
    elseif prop.canSpawn() then
        normal = create( Color( 255, 0, 0, 255) )
    end
    
    -- Movement code
    motion = motion + Vector( 0, 0, 48 ) 
    
    -- If the prop exists, set the physobj position to the movement else try and respawn it
    if isValid( smooth ) and smooth:isValidPhys() then
        -- This is setpos With getting the entities getPhysicsObject()
        -- Interpolation will work!
        smooth:getPhysicsObject():setPos( motion )
    elseif prop.canSpawn() then
        smooth = create( Color( 0, 255, 0, 255) )
    end
end)