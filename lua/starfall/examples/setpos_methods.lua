--@name Setpos methods
--@author Neatro
--@server

if not hasPermission( "entities.setPos", owner() ) then
    throw( "You need Entities permission to see this example code! Enable permission entities.setpos" )
end

--[[
This example code shows how smooth Setpos is achieved.

You may have tried to directly setPos() an entity, right?
You probably saw how the movement is very choppy.

This is because this method doesn't utilize any interpolation.
It can be good for other uses unless you want smooth motion with setPos().

To do this, you need to setPos() the physicsObject of an entity. 

This retains the interpolation and makes motion looks smooth.

]]--

--ignore this bit, it's for creating the prop
function create( c )
    p = prop.create( Vector( 0), Angle( 0 ), "models/props_junk/wood_crate001a.mdl", 1 )
    p:setColor( c ) 
    return p
end

--hook
hook.add( "tick", "runtime", function() 
    --movement code
    Motion = chip():getPos() + Vector( math.sin( timer.systime() * 4 ) * 64, 0, 48 )
    --spawns prop when it doesn't exist
    normal = ( ( not normal or not normal:isValid() ) and prop.canSpawn() ) and create( Color( 255, 0, 0, 255 ) ) or normal        
    --check
    if normal and normal:isValid() and normal:isValidPhys() then
        
        --This is setpos WITHOUT getting the entities getPhysicsObject()
        --There is NO interpolation!
        normal:setPos( Motion )
    end
    --movement code
    Motion = Motion + Vector( 0, 0, 48 ) 
    --spawns prop when it doesn't exist
    normalandphys = ( ( not normalandphys or not normalandphys:isValid() ) and prop.canSpawn() ) and create( Color( 0, 255, 0, 255 ) ) or normalandphys        
    --check
    if normalandphys and normalandphys:isValid() and normalandphys:isValidPhys() then
        
        --This is setpos With getting the entities getPhysicsObject()
        --Interpolation will work!
        normalandphys:getPhysicsObject():setPos( Motion )
        --            __________________
    end
    
end )