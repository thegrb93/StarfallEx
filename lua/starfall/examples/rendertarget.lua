--@name RenderTarget Example
--@author Sparky
--@client

-- This example draws pixels to a rendertarget and then displays the result

render.createRenderTarget("myrendertarget")

local paint = coroutine.wrap(function()
    for y=0, 1023 do
        for x=0, 1023 do
            render.setColor(Color(x*y*360/512 % 360,1,1):hsvToRGB())
            render.drawRectFast(x,y,1,1)
        end
        coroutine.yield()
    end
    return true
end)

hook.add("renderoffscreen","",function()
    render.selectRenderTarget("myrendertarget")
    while quotaAverage()<quotaMax()*0.5 do
        if paint() then
            hook.remove("renderoffscreen","")
            return
        end
    end
end)

hook.add("render","",function()
    render.setRenderTargetTexture("myrendertarget")
    render.drawTexturedRect(0,0,512,512)
end)

