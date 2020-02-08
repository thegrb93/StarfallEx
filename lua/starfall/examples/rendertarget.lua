--@name RenderTarget Example
--@author Sparky
--@client

-- This example draws pixels to a rendertarget and then displays the result

render.createRenderTarget("myrendertarget")

local function done()
    hook.add("render","",function()
        render.setRenderTargetTexture("myrendertarget")
        render.drawTexturedRectFast(0,0,512,512)
    end)
end

local paint = coroutine.wrap(function()
    for y=0, 1023 do
        for x=0, 1023 do
            render.setColor(Color(x*y % 360,1,1):hsvToRGB())
            render.drawRectFast(x,y,1,1)
        end
        coroutine.yield(false)
    end
    return true
end)

hook.add("renderoffscreen","",function()
    render.selectRenderTarget("myrendertarget")
    while quotaAverage()<quotaMax()*0.5 do
        if paint() then
            done()
            hook.remove("renderoffscreen","")
            return
        end
    end
end)

