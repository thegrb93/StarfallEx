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
    -- Because there's a limit on how often we can make money requests,
    -- we need a queue to deal with multiple players buying items in a short time span.
    local queue = {}
    hook.add("think", "queue", function()
        local i = 1
        while darkrp.canMakeMoneyRequest() do
            local firstInQueue = queue[i]
            if not firstInQueue then return end
            if firstInQueue.shop:processTransaction(firstInQueue.ply, firstInQueue.item) then
                i = i+1
            else
                table.remove(queue, 1)
            end
        end
    end)

    local gunShop = class("GunShop")
    function gunShop:initialize(products)
        self.customers = {}
        self.products = products
    end
    function gunShop:processTransaction(ply, item)
        if not ply:isValid() then
            self.customers[ply] = nil
            return
        end
        if not darkrp.canMakeMoneyRequest(ply) then
            return true
        end
        ply:requestMoney(item.name, item.price, function()
            if ply:isValid() then
                print(string.format("%q just bought %q (quantity: %d)!", ply:getName(), item.name, item.count or 1))
            end
            self.customers[ply] = nil
        end, function(reason)
            if ply:isValid() then
                print(string.format("Money request for %q failed! Reason: %q", ply:getName(), reason or "nil"))
            end
            self.customers[ply] = nil
        end)
    end
    function gunShop:buy(ply, item)
        if self.customers[ply] then return end
        item = self.products[item]
        if not item then return end
        self.customers[ply] = true
        table.insert(queue, {
            ply = ply,
            item = item,
            shop = self
        })
    end

    local myGunShop = gunShop:new(products)
    net.receive("buy", function(_, ply)
        myGunShop:buy(ply, net.readUInt(32))
    end)
elseif CLIENT then
    local button = class("Button")
    function button:initialize(x, y, text, w, h)
        self.x = x
        self.y = y
        self.w = w or 300
        self.h = h or 20
        self.text = text
        self.pressed = false
    end
    function button:isHovered(cx, cy)
        return cx and cx > self.x and cx < self.x+self.w and cy > self.y and cy < self.y+self.h
    end
    function button:draw()
        render.setRGBA(127, 127, 127, 255)
        render.drawRect(20, self.y+20, 300, 2)
        if not self.pressed then
            render.setRGBA(255, 255, 255, 255)
        end
        render.drawRect(self.x, self.y, self.w, self.h)
        render.setRGBA(0, 0, 0, 255)
        render.setFont("DermaDefault")
        local offset = self.pressed and 4 or 3
        render.drawText(self.x+offset, self.y+offset, self.text)
    end
    
    local menu = class("Menu")
    function menu:initialize(products)
        self.buttons = {}
        self.pressed = false
        for i, item in ipairs(products) do
            self.buttons[i] = button:new(20, (i-1)*30+20, string.format(
                "Buy %s for %s (quantity: %d)",
                item.name,
                darkrp.formatMoney(item.price),
                item.count or 1
            ))
        end
    end
    function menu:drawButtons()
        for i, button in ipairs(self.buttons) do
            button:draw()
        end
    end
    function menu:handleInput()
        -- Only trigger when the use key is pushed down
        if player():keyDown(IN_KEY.USE) then
            if not self.pressed then -- If use was pressed this frame but not last frame
                self.pressed = true

                local cx, cy = render.cursorPos()
                if not cx or not cy then return end

                for i, button in ipairs(self.buttons) do
                    if button:isHovered(cx, cy) then
                        self:buy(i)
                        button.pressed = true
                        break
                    end
                end
            end
        elseif self.pressed then -- Otherwise, if use was not pressed this frame, but was pressed last frame
            self.pressed = false

            for i, button in ipairs(self.buttons) do
                button.pressed = false
            end
        end
    end
    function menu:buy(index)
        net.start("buy")
            net.writeUInt(index, 32)
        net.send()
    end

    local myMenu = menu:new(products)
    hook.add("render", "list", function()
        myMenu:handleInput()
        myMenu:drawButtons()
    end)
end
