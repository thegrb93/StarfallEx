--@name vr_example
--@author Neatro
--@client

ply = owner()

hook.add( "VRInput", "test", function( action, bool )
    print( action, bool )
    --returns the controller button you pressed!
end )

M = Matrix()

hook.add( "postdrawopaquerenderables", "runtime", function() 

    render.enableDepth( true )
    
    --draw XYZ cross on right hand
    local pos, ang = vr.getRightHandPos( ply ), vr.getRightHandAng( ply )
    render.setColor( Color( 255, 0, 0, 255 ) )
    render.draw3DWireframeBox( pos, ang, Vector( -0.1, -0.1, -0.1 ), Vector( 12, 0.1, 0.1 ) )
    render.setColor( Color( 0, 255, 0, 255 ) )
    render.draw3DWireframeBox( pos, ang, Vector( -0.1, -0.1, -0.1 ), Vector( 0.1, 12, 0.1 ) )
    render.setColor( Color( 0, 0, 255, 255 ) )
    render.draw3DWireframeBox( pos, ang, Vector( -0.1, -0.1, -0.1 ), Vector( 0.1, 0.1, 12 ) )
    
    --draw XYZ cross on left hand
    local pos, ang = vr.getLeftHandPos( ply ), vr.getLeftHandAng( ply )
    render.setColor( Color( 255, 0, 0, 255 ) )
    render.draw3DWireframeBox( pos, ang, Vector( -0.1, -0.1, -0.1 ), Vector( 12, 0.1, 0.1 ) )
    render.setColor( Color( 0, 255, 0, 255 ) )
    render.draw3DWireframeBox( pos, ang, Vector( -0.1, -0.1, -0.1 ), Vector( 0.1, 12, 0.1 ) )
    render.setColor( Color( 0, 0, 255, 255 ) )
    render.draw3DWireframeBox( pos, ang, Vector( -0.1, -0.1, -0.1 ), Vector( 0.1, 0.1, 12 ) )
    
    --draw circle with left touchpad input (vive)
    local d = vr.getInput( VR.VECTOR2_WALKDIRECTION )
    if d then
        local pos, ang = vr.getLeftHandPos( ply ), vr.getLeftHandAng( ply )
        
        M:setTranslation( pos )
        M:setAngles( ang )
        
        M:translate( Vector( 0, 0, 6 ) )
        M:rotate( Angle( 0, -90, -135 ) )
        
        render.setColor( Color( 0, 255, 255, 255 ) )
        
        render.pushMatrix( M )
        
            render.drawCircle( 0, 0, 6 )
            render.draw3DLine( Vector(), d * Vector( 1, -1, 0 ) * 6 )
            
        render.popMatrix()
        
    end
    --draw circle with right touchpad input (vive)
    local d = vr.getInput( VR.VECTOR2_SMOOTHTURN )
    if d then
        local pos, ang = vr.getRightHandPos( ply ), vr.getRightHandAng( ply )
        
        M:setTranslation( pos )
        M:setAngles( ang )
        
        M:translate( Vector( 0, 0, 6 ) )
        M:rotate( Angle( 0, -90, -135 ) )
        
        render.setColor( Color( 0, 255, 255, 255 ) )
        
        render.pushMatrix( M )
        
            render.drawCircle( 0, 0, 6 )
            render.draw3DLine( Vector(), d * Vector( 1, -1, 0 ) * 6 )
            
        render.popMatrix()
        
    end
    
end )