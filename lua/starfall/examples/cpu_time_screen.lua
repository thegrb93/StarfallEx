--@name cpuTime Example
--@author INP - Radon + Sparky
--@client

-- This function helps us check if we can run.
-- Use a mixture of quotaUsed() and quotaAverage()
-- quotaUsed() returns the value of the current buffer.
-- quotaAverage() gives the cpuTime average across the whole buffer.
-- Your chip will throw an error if quotaAverage() > quotaMax()
-- n is a parameter between 0 and 1 that represents the percent. 0.8 = 80%.
local function quotaCheck(n)
	return math.max(quotaAverage(), quotaUsed()) < quotaMax() * n
end

render.createRenderTarget("Background")
-- Standard render hook.
hook.add("render", "", function ()
	local maxQuota = 0.1
	render.setColor(Color(255, 255, 255))
	-- Print some stats to the screen
	render.drawText(10, 10, "Quota Used: " .. math.round(quotaUsed() * 1000000) .. "us")
	render.drawText(10, 30, "Quota Avg: " .. math.round(quotaAverage() * 1000000) .. "us")
	render.drawText(10, 50, "Quota Max: " .. math.round(quotaMax() * 1000000) .. "us")

	local quota = quotaAverage() / quotaMax()
	if quota >= maxQuota then render.setColor(Color(255, 0, 0)) end
	render.drawText(10, 70, "Percent: " .. math.round(quota * 100, 2) .. "%")

	-- Set the rendertarget to our background so that we can make a bluring effect
	render.selectRenderTarget("Background")
	render.setColor(Color(0, 0, 0, 50))
	render.drawRect(0, 0, 1024, 1024)

	-- While our quota is less than 10%.
	-- This will result in higher FPS, thus more render calls.
	-- You'd think this would affect the rendering of the cube, it doesn't.
	-- If you increase this check to 99%, FPS will significantly drop, and the movement would be slower.
	-- Play with this value and see the effects on percentage and your FPS.
	while quotaCheck(maxQuota) do
		-- Now we can draw a funky box that oscillates back and forth in the middle of the screen.
		render.setColor(Color(math.random(100, 255), math.random(100, 255), math.random(100, 255)))
		render.drawRect(math.sin(timer.curtime() * 2) * 380 + (512 - 100), 512 / 2, 200, 400)
	end

	render.selectRenderTarget(nil)

	-- Draw the resulting rendertarget
	render.setRenderTargetTexture("Background")
	render.setColor(Color(255, 255, 255))
	render.drawTexturedRect(0, 128, 512, 384)
end)
