--@name Stencil House
--@author Name
--@shared

if SERVER then
    
    local template = {
        affected = {
            { pos = Vector(-23, -23, 23), ang = Angle(0, 45, 0),  mdl = "models/props_interiors/Furniture_Couch02a.mdl" },
            { pos = Vector(-35, 35, 35),  ang = Angle(0, 45, 0),  mdl = "models/props_interiors/Furniture_Lamp01a.mdl" },
            { pos = Vector(35, 0, 30),    ang = Angle(0, 180, 0), mdl = "models/props_combine/combine_intmonitor001.mdl" },
            { pos = Vector(-28, -28, 17), ang = Angle(0, 45, 0),  mdl = "models/maxofs2d/companion_doll.mdl" },
            { pos = Vector(32, 20, 17),   ang = Angle(0, 15, 0),  mdl = "models/props_junk/TrafficCone001a.mdl" },
            { pos = Vector(0, 0, 90),     ang = Angle(0, 0, 0),   mdl = "models/props_wasteland/prison_lamp001c.mdl" },
        },
        unaffected = {
            { pos = Vector(0, 0, 0),      ang = Angle(0, 0, 0),   mdl = "models/hunter/plates/plate2x2.mdl" },
            { pos = Vector(46, 0, 49),    ang = Angle(90, 0, 0),  mdl = "models/hunter/plates/plate2x2.mdl" },
            { pos = Vector(-46, 0, 49),   ang = Angle(90, 0, 0),  mdl = "models/hunter/plates/plate2x2.mdl" },
            { pos = Vector(0, -46, 49),   ang = Angle(0, 0, 90),  mdl = "models/hunter/plates/plate2x2.mdl" },
            { pos = Vector(33, 46, 49),   ang = Angle(0, 0, 90),  mdl = "models/hunter/plates/plate05x2.mdl" },
            { pos = Vector(-33, 46, 49),  ang = Angle(0, 0, 90),  mdl = "models/hunter/plates/plate05x2.mdl" },
            { pos = Vector(0, 46, 90.5),  ang = Angle(90, 90, 0), mdl = "models/hunter/plates/plate025x1.mdl" },
            { pos = Vector(0, 0, 143.5),  ang = Angle(0, 0, 0),   mdl = "models/hunter/misc/squarecap2x2x2.mdl" },
        }
    }
    
    local affected_ents = {}
    local spawnProps = coroutine.wrap(function()
        for category, category_props in pairs(template) do
            for _, data in ipairs(category_props) do
                local pos, ang = localToWorld(data.pos, data.ang, chip():getPos(), chip():getAngles())
                local ent = prop.create(pos, ang, data.mdl, true)
                
                if category == "affected" then
                    table.insert(affected_ents, ent)
                end
                
                coroutine.yield()
            end
        end
        return true
    end)
    
    local ply_queue = {}
    local function sendEnts(target)
        if not target and #ply_queue < 1 then return end
        net.start("")
            net.writeUInt(#affected_ents, 8)
            for _, ent in ipairs(affected_ents) do
                net.writeEntity(ent)
            end
        net.send(target or ply_queue)
    end
    
    hook.add("ClientInitialized", "NetworkEnts", function(ply)
        if #affected_ents == #template.affected then
            sendEnts(ply)
        else
            table.insert(ply_queue, ply)
        end
    end)
    
    hook.add("Tick", "SpawnProps", function()
        while prop.canSpawn() do
            if spawnProps() then
                sendEnts()
                hook.remove("Tick", "SpawnProps")
                return
            end
        end
    end)
    
else
    
    local function resetStencil()
        render.setStencilWriteMask(0xFF)
        render.setStencilTestMask(0xFF)
        render.setStencilReferenceValue(0)
        render.setStencilCompareFunction(STENCIL.ALWAYS)
        render.setStencilPassOperation(STENCIL.KEEP)
        render.setStencilFailOperation(STENCIL.KEEP)
        render.setStencilZFailOperation(STENCIL.KEEP)
        render.clearStencil()
    end
    
    local ents = {}
    local function drawEnts()
        for _, ent in ipairs(ents) do
            ent:draw()
        end
    end
    
    local function noDrawEnts(hide)
        for _, ent in ipairs(ents) do
            ent:setNoDraw(hide)
        end
    end
    
    local modes = {
        {
            name = "Normal",
        },{
            name = "Highlight",
            draw = function(ents)
                resetStencil()
                render.setStencilEnable(true)
                render.setStencilReferenceValue(1)
                render.setStencilCompareFunction(STENCIL.EQUAL)
                render.setStencilFailOperation(STENCIL.REPLACE)
                drawEnts()
                render.clearBuffersObeyStencil(128, 0, 255, 255, false)
                render.setStencilEnable(false)
            end
        },{
            name = "Reverse",
            draw = function()
                resetStencil()
                render.setStencilEnable(true)
                render.setStencilReferenceValue(1)
                render.setStencilCompareFunction(STENCIL.NOTEQUAL)
                render.setStencilPassOperation(STENCIL.REPLACE)
                drawEnts()
                render.clearBuffersObeyStencil(128, 0, 255, 255, false)
                render.setStencilEnable(false)
            end
        },{
            name = "Wallhack",
            draw = function()
                resetStencil()
                render.setStencilEnable(true)
                render.setStencilReferenceValue(1)
                render.setStencilCompareFunction(STENCIL.ALWAYS)
                render.setStencilZFailOperation(STENCIL.REPLACE)
                drawEnts()
                render.setStencilCompareFunction(STENCIL.EQUAL)
                render.clearBuffersObeyStencil(128, 0, 255, 255, false)
            end
        },{
            name = "Window",
            pre  = function() noDrawEnts(true) end,
            draw = function()
                resetStencil()
                render.setStencilEnable(true)
                render.setStencilReferenceValue(1)
                render.setStencilCompareFunction(STENCIL.EQUAL)
                render.clearStencilBufferRectangle(512, 256, 1024, 768, 1)
                drawEnts()
                render.setStencilEnable(false)
            end,
            hud = function()
                render.setColor(Color(255,50,100))
                render.drawRectOutline(512, 256, 512, 512, 5)
            end,
            post = function() noDrawEnts(false) end
        }
    }
    
    local current_mode, mode_data
    local function changeMode(id)
        if mode_data and mode_data.post then
            mode_data.post()
        end
        
        current_mode = id or current_mode % #modes + 1
        mode_data = modes[current_mode]
        
        if mode_data.pre then
            mode_data.pre()
        end
        
        if mode_data.draw then
            hook.add("PostDrawOpaqueRenderables", "DrawProps", mode_data.draw)
        else
            hook.remove("PostDrawOpaqueRenderables", "DrawProps")
        end
    end
    
    hook.add("InputPressed", "ChangeMode", function(key)
        if key == KEY.E then changeMode() end
    end)
    
    if player() == owner() then enableHud(nil, true) end
    hook.add("DrawHUD", "", function()
        if not current_mode then
            render.setColor(Color(255,255,255))
            render.drawText(522, 266, "Waiting for props...")
        else
            if mode_data.hud then
                mode_data.hud()
            end
            render.setColor(Color(255,255,255))
            render.drawText(522, 266, "Mode: "..mode_data.name)
            render.drawText(522, 290, "Press E to change the mode")
        end
    end)
    
    net.receive("", function()
        local count = net.readUInt(8)
        for i = 1, count do
            net.readEntity(function(ent)
                if not ent or not ent:isValid() then return end
                table.insert(ents, ent)
                if #ents == count then
                    changeMode(1)
                end
            end)
        end
    end)
    
end
