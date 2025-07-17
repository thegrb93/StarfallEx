-- Global to all starfalls
local checkluatype = SF.CheckLuaType

local renderQueue = {}
local catchupQueue = {}

SF.Permissions.registerPrivilege( "debugoverlay", "Display debugoverlays", "Allows starfall to render objects and text on your screen.", CLIENT and { client = { default = 1 } } or nil )

if SERVER then
    util.AddNetworkString( "debugoverlay_replicate_instruction" )
end

--- An implementation of the Gmod debugoverlay library. https://gmodwiki.com/debugoverlay
-- @name debugoverlay
-- @class library
-- @libtbl debugoverlay_library
SF.RegisterLibrary( "debugoverlay" )

if CLIENT then
    local function getInstanceFromID( instID )
        local ent = Entity( instID )
        if not IsValid( ent ) then return nil end

        return ent.Instance
    end

    local function encodeInstructionPairs( instructions )
        local funcs = {}
        local args = {}

        for i = 1, #instructions do
            if type( instructions[i] ) == "string" then
                table.insert( funcs, instructions[i] )
            elseif type( instructions[i] ) == "table" then
                table.insert( args, instructions[i] )
            end
        end

        assert( #funcs == #args, "Mismatched function and argument count in render instruction encoding." )

        local encoded = {}

        for i = 1, #funcs do
            local func = funcs[i]
            local arg = args[i]

            table.insert( encoded, { ["func"] = func, ["args"] = arg } )
        end

        return encoded
    end

    local checkpermission = LocalPlayer() ~= SF.Superuser and SF.Permissions.check or function() end

    hook.Add( "PostDrawOpaqueRenderables", "debugoverlay_render_queued_instructions", function( enableDepth, isSkybox, isSkybox3D )
        if isSkybox then return end

        render.SetColorMaterial()

        for instID, queue in pairs( catchupQueue ) do
            for i, inst in pairs( queue ) do
                print( "instructions" )
                if type( renderQueue[instID] ) ~= "table" then return end
                if type( inst ) ~= "table" then continue end

                if table.HasValue( renderQueue[instID], inst ) then
                    catchupQueue[instID][i] = nil
                    continue
                end

                print( "ADDING TO RENDER" )
                table.insert( renderQueue[instID], inst )

                catchupQueue[instID][i] = nil
            end

            if table.IsEmpty( catchupQueue[instID] ) then
                catchupQueue[instID] = nil
            end
        end

        for i, instanceQueue in pairs( renderQueue ) do
            if not IsValid( Entity( i ) ) then
                print( "invalid" )
                renderQueue[i] = nil
                catchupQueue[i] = nil
                continue
            end
            if type( instanceQueue ) ~= "table" then continue end


            checkpermission( nil, LocalPlayer(), "debugoverlay" )

            for i, data in ipairs( instanceQueue ) do
                if type( data ) ~= "table" then continue end
                local encoded = encodeInstructionPairs( data["instructions"] )
                local lifespan = data["lifespan"]

                for _, instruction in pairs( encoded ) do


                    if data["birthtime"] ~= nil then
                        if CurTime() - data["birthtime"] >= lifespan then
                            table.remove( instanceQueue, i )
                            return
                        end
                    else
                        data["birthtime"] = CurTime()
                    end

                    render[instruction["func"]]( unpack( instruction["args"] ) )
                end
            end
        end
    end )

    local function receiveInstructions()
        if not CLIENT then return end
        local instID = net.ReadUInt( 16 )

        print( engine.TickCount(), "RECEIVE" )

        local instructions = net.ReadTable( false )
        if type( instructions ) ~= "table" then return end

        if not IsValid( Entity( instID ) ) then
            return
        end

        if type( renderQueue[instID] ) ~= "table" then
            if catchupQueue[instID] == nil then
                catchupQueue[instID] = {}
            end
            print( "netqueuing" )

            if table.HasValue( catchupQueue[instID], instructions ) then return end

            table.insert( catchupQueue[instID], instructions )
            return
        end

        if table.HasValue( renderQueue[instID], instructions ) then return end

        table.insert( renderQueue[instID], instructions )
   end
    net.Receive( "debugoverlay_replicate_instruction", receiveInstructions )
end

return function( instance )
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local debugoverlay_library = instance.Libraries.debugoverlay
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local color_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap

local vunwrap1, aunwrap1, cunwrap1

local instanceID

local function isLifespanValid( lifespan )
    return type( lifespan ) == "number" and lifespan > 0
end

local function getInstanceID( inst )
    return inst.entity:EntIndex()
end

local function getPlayersWithAccess( inst )
    local players = {}

    for _, ply in ipairs( player.GetHumans() ) do
        if SF.Permissions.hasAccess( inst, ply, "debugoverlay" ) then
            table.insert( players, ply )
        end
    end

    return players
end

local function replicateInstruction( instructions )
    if not SERVER then return end

    local instID = getInstanceID( instance )

    net.Start( "debugoverlay_replicate_instruction" )
    net.WriteUInt( instID, 16 )
    net.WriteTable( instructions, false )
    net.Send( getPlayersWithAccess( instance ) )

    print( engine.TickCount(), "SENDING" )
end

local function addInstruction( instructions )
    if CLIENT then
        checkpermission( instance, nil, "debugoverlay" )
        local instanceQueue = renderQueue[ instanceID ]

        if instanceQueue == nil then
            table.insert( catchupQueue[instanceID], instructions )
            return
        end

        table.insert( instanceQueue, instructions )
    else
        replicateInstruction( instructions )
    end
end

instance:AddHook( "initialize", function()
    print( engine.TickCount(), "INITIALIZE" )
    vunwrap1 = vec_meta.QuickUnwrap1
    aunwrap1 = ang_meta.QuickUnwrap1
    cunwrap1 = color_meta.QuickUnwrap1

    if CLIENT then
        instanceID = getInstanceID( instance )

        PrintTable( renderQueue )

        if catchupQueue[instanceID] == nil then catchupQueue[instanceID] = {} end

        if renderQueue[instanceID] == nil then
            renderQueue[instanceID] = {}
        else
            for i, v in pairs( renderQueue[instanceID] ) do
                if v["birthtime"] ~= nil then
                    local lifespan = v["lifespan"]
                    if CurTime() - v["birthtime"] >= lifespan then
                        table.remove( renderQueue[instanceID], i )
                    end
                end
            end
        end
    end
end )

instance:AddHook( "deinitialize", function()
    if SERVER then print( engine.TickCount(), "SV_DEINIT" ) end
    if CLIENT then
        print( engine.TickCount(), "CL_DEINIT" )
        renderQueue[instanceID] = nil
        --catchupQueue[instanceID] = nil
        return
    end
end )

--- Creates a 3D box.
-- @shared
-- @param Vector origin The origin of the box.
-- @param Angle angle The rotation of the box.
-- @param Vector mins The start position of the box relative to the origin.
-- @param Vector maxs The end position of the box relative to the origin.
-- @param Color color The color of the box.
-- @param number lifespan The time, in seconds the object will draw.
function debugoverlay_library.box( pos, angle, mins, maxs, color, lifespan )
    if not isLifespanValid( lifespan ) then
        SF.Throw( "Invalid lifespan. Must be a valid positive number.", 2 )
    end

    local uwPos = vunwrap( SF.clampPos( pos ) )
    local uwAngle = aunwrap( angle )
    local uwMins = vunwrap( mins )
    local uwMaxs = vunwrap( maxs )
    local uwColor = cunwrap( color )

    local instructions = {
        ["instructions"] = {
            "DrawBox",
            "DrawWireframeBox",
            { uwPos, uwAngle, uwMins, uwMaxs, ColorAlpha( uwColor, 150 ) },
            { uwPos, uwAngle, uwMins, uwMaxs, uwColor, true }
        },
        ["lifespan"] = lifespan
    }

    addInstruction( instructions )
end

--- Creates a 3D wireframe box.
-- @shared
-- @param Vector origin The origin of the box.
-- @param Angle angle The rotation of the box.
-- @param Vector mins The start position of the box relative to the origin.
-- @param Vector maxs The end position of the box relative to the origin.
-- @param Color color The color of the box.
-- @param boolean writeZ If false, the box will be drawn without depth.
-- @param number lifespan The time, in seconds the object will draw.
function debugoverlay_library.wireframeBox( pos, angle, mins, maxs, color, writeZ, lifespan )
    if not isLifespanValid( lifespan ) then
        SF.Throw( "Invalid lifespan. Must be a valid positive number.", 2 )
    end

    checkluatype( writeZ, TYPE_BOOL )

    local uwPos = vunwrap( SF.clampPos( pos ) )
    local uwAngle = aunwrap( angle )
    local uwMins = vunwrap( mins )
    local uwMaxs = vunwrap( maxs )
    local uwColor = cunwrap( color )

    local instructions = {
        ["instructions"] = {
            "DrawWireframeBox",
            { uwPos, uwAngle, uwMins, uwMaxs, uwColor, writeZ }
        },
        ["lifespan"] = lifespan
    }

    addInstruction( instructions )
end

--- Creates a 3D line.
-- @shared
-- @param Vector startpos The start position of the line.
-- @param Vector endpos The end position of the line.
-- @param Color color The color of the line.
-- @param boolean writeZ If false, the line will be drawn without depth.
-- @param number lifespan The time, in seconds the object will draw.
function debugoverlay_library.line( startpos, endpos, color, writeZ, lifespan )
    if not isLifespanValid( lifespan ) then
        SF.Throw( "Invalid lifespan. Must be a valid positive number.", 2 )
    end

    checkluatype( writeZ, TYPE_BOOL )

    local uwStartPos = vunwrap( SF.clampPos( startpos ) )
    local uwEndPos = vunwrap( SF.clampPos( endpos ) )
    local uwColor = cunwrap( color )

    local instructions = {
        ["instructions"] = {
            "DrawLine",
            { uwStartPos, uwEndPos, uwColor, writeZ }
        },
        ["lifespan"] = lifespan
    }

    addInstruction( instructions )
end

--- Creates a 3D sphere.
-- @shared
-- @param Vector origin The origin of the sphere.
-- @param number radius The radius of the sphere.
-- @param number longSteps The number of longitudinal steps in the sphere (increases quality).
-- @param number latSteps The number of latitudinal steps in the sphere (increases quality).
-- @param Color color The color of the sphere.
-- @param number lifespan The time, in seconds the object will draw.
function debugoverlay_library.sphere( origin, radius, longSteps, latSteps, color, lifespan )
    if not isLifespanValid( lifespan ) then
        SF.Throw( "Invalid lifespan. Must be a valid positive number.", 2 )
    end

    if type( longSteps ) ~= "number" or longSteps < 1 then
        SF.Throw( "Invalid longSteps. Must be a valid positive number.", 2 )
    end

    if type( latSteps ) ~= "number" or latSteps < 1 then
        SF.Throw( "Invalid latSteps. Must be a valid positive number.", 2 )
    end

    if type( radius ) ~= "number" or radius < 0 then
        SF.Throw( "Invalid radius. Must be a valid positive number.", 2 )
    end

    local uwPos = vunwrap( SF.clampPos( origin ) )
    local uwColor = cunwrap( color )

    local instructions = {
        ["instructions"] = {
            "DrawSphere",
            "DrawWireframeSphere",
            { uwPos, radius, longSteps, latSteps, ColorAlpha( uwColor, 150 ) }, -- When sending instructions lifespan is always the last argument.
            { uwPos, radius, longSteps, latSteps, uwColor, true }
        },
        ["lifespan"] = lifespan
    }

    addInstruction( instructions )
end

--- Creates a 3D wireframe sphere.
-- @shared
-- @param Vector origin The origin of the sphere.
-- @param number radius The radius of the sphere.
-- @param number longSteps The number of longitudinal steps in the sphere (increases quality).
-- @param number latSteps The number of latitudinal steps in the sphere (increases quality).
-- @param Color color The color of the sphere.
-- @param boolean writeZ If false, the sphere will be drawn without depth.
-- @param number lifespan The time, in seconds the object will draw.
function debugoverlay_library.wireframeSphere( origin, radius, longSteps, latSteps, color, writeZ, lifespan )
    if not isLifespanValid( lifespan ) then
        SF.Throw( "Invalid lifespan. Must be a valid positive number.", 2 )
    end

    if type( longSteps ) ~= "number" or longSteps < 1 then
        SF.Throw( "Invalid longSteps. Must be a valid positive number.", 2 )
    end

    if type( latSteps ) ~= "number" or latSteps < 1 then
        SF.Throw( "Invalid latSteps. Must be a valid positive number.", 2 )
    end

    if type( radius ) ~= "number" or radius < 0 then
        SF.Throw( "Invalid radius. Must be a valid positive number.", 2 )
    end

    local uwPos = vunwrap( SF.clampPos( origin ) )
    local uwColor = cunwrap( color )

    checkluatype( writeZ, TYPE_BOOL )

    local instructions = {
        ["instructions"] = {
            "DrawWireframeSphere",
            { uwPos, radius, longSteps, latSteps, uwColor, writeZ }
        },
        ["lifespan"] = lifespan
    }

    addInstruction( instructions )
end


end