--@name Hello World
--@author INP
--@client

local font = render.createFont("Default", 30)

hook.add("render", "helloworld_render", function ()
    render.setColor(Color(255, 0, 0, 255)) -- Set colour to red, the alpha argument is optional and will default to 255
    render.setFont(font) -- "Activate" font
    render.drawText(20, 20, "Hello World!") -- Draw text at 20, 20
end)
