--@name Simple Custom Prop
--@author Name
--@server

local fidelity = 16
local x, y, z = 15, 10, 5

local convexes = {
    -- cube
    {
        Vector(0, 0, 0), Vector(x, 0, 0), Vector(x, y, 0), Vector(0, y, 0),
        Vector(0, 0, z), Vector(x, 0, z), Vector(x, y, z), Vector(0, y, z),
    },
    -- cylinder
    {
        -- cone
        Vector(x/2, y/2, z*3)
    },
}

-- cylinder base
for i = 1, fidelity do
    local t = math.pi*2 / fidelity * i
    local cos = x/2 + math.cos(t) * x/4
    local sin = y/2 + math.sin(t) * y/4
    
    table.insert(convexes[2], Vector(cos, sin, z))
    table.insert(convexes[2], Vector(cos, sin, z*2))
end

local ent = prop.createCustom(chip():getPos() + chip():getUp()*45, Angle(), convexes, true)
