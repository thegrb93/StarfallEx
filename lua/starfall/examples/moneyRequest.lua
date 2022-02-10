--@name Semi-auto gunshop example
--@shared
-- Connect this chip to a screen and customers will be able to choose an item from the following list.
-- Once a customer makes a choice, they'll be asked if they want to send you money via a pop-up.
-- If they click "accept", the money for the product will be transferred to you, and you'll see
-- the product name and quantity appear in chat.
local products = {
    {name="Desert eagle", price=215},
    {name="Fiveseven", price=205},
    {name="Glock", price=160},
    {name="P228", price=185},
    {name="AK47", price=2450, count=10},
    {name="M4", price=2450, count=10},
    {name="MP5", price=2200, count=10},
    {name="Sniper rifle", price=3750, count=10},
    {name="Pump shotgun", price=1750, count=10},
    {name="Mac 10", price=2150, count=10},
}
if SERVER then
    local customers = {}
    local queue = {}
    net.receive('buy', function(_, ply)
        if customers[ply] then return end
        local index = net.readUInt(32)
        local productInfo = products[index]
        if not productInfo then return end
        table.insert(queue, {
            customer = ply,
            productInfo = productInfo
        })
        customers[ply] = true
    end)
    hook.add('think', 'queue', function()
        if not darkrp.canMakeMoneyRequest() then return end
        local queued = queue[1]
        if not queued then return end
        if not isValid(queued.customer) then
            table.remove(queue, 1)
            customers[queued.customer] = nil
            return
        end
        queued.customer:requestMoney(queued.productInfo.name, queued.productInfo.price, function()
            if isValid(queued.customer) then
                print(string.format("%q just bought %q (quantity: %d)!", queued.customer:getName(), queued.productInfo.name, queued.productInfo.count or 1))
            end
            customers[queued.customer] = nil
        end, function(reason)
            if isValid(queued.customer) then
                print(string.format("Money request for %q failed! Reason: %q", queued.customer:getName(), reason or "nil"))
            end
            customers[queued.customer] = nil
        end)
        table.remove(queue, 1)
    end)
    return
end
local y
local wasPressed = {}
local function button(str)
    local retval, isPressed = false, false
    local cx, cy = render.cursorPos()
    if not cx or not cy or cx < 20 or cx >= 320 or cy < y or cy >= y+20 then
        wasPressed[str] = nil
    else
        isPressed = player():keyDown(IN_KEY.USE)
        if isPressed then
            wasPressed[str] = true
        elseif wasPressed[str] then
            -- The key was pressed last frame, but not this frame
            wasPressed[str] = nil
            retval = true
        end
    end
    render.setRGBA(127, 127, 127, 255)
    render.drawRect(20, y+20, 300, 2)
    if not isPressed then
        render.setRGBA(255, 255, 255, 255)
    end
    render.drawRect(20, y, 300, 20)
    render.setRGBA(0, 0, 0, 255)
    render.setFont("DermaDefault")
    render.drawText(30, y+(isPressed and 4 or 3), str)
    y = y+30
    return retval
end
hook.add('render', 'list', function()
    y = 20
    for index, productInfo in ipairs(products) do
        if button(string.format(
            "Buy %s for %s (quantity: %d)",
            productInfo.name,
            darkrp.formatMoney(productInfo.price),
            productInfo.count or 1
        )) then
            net.start("buy")
                net.writeUInt(index, 32)
            net.send()
        end
    end
end)
