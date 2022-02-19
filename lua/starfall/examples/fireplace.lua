--@name Fireplace
--@author INP - Radon

if SERVER then return end

-- Credits to Natty for original fireplace idea as an example
-- Credits to funkake for working out the kinks

-- We'll call Particle as our constructor
local Particle = class("Particle")

-- Let's add our constructor definition
function Particle:initialize(x, y, scale, xv, yv, clr)
	-- Just standard assignment, we want to make sure we get all the properties.
	-- If one of the params is nil, then the default value, 0, will be assigned.
	self.x = x or 0
	self.y = y or 0
	self.scale = scale or 0
	self.x_vel = xv or 0
	self.y_vel = yv or 0
	self.color = clr or Color(0, 0, 0)
end

-- A think method, we'll use this to change particle states.
function Particle:think()
	-- We draw first, then change state.

	self:draw()

	self.x = self.x + self.x_vel
	self.y = self.y + self.y_vel

	self.y_vel = self.y_vel - math.random(0, 0.04)

	self.color.a = self.color.a - math.random(1.5, 3)

	local c = self.color.g - math.random(0.65, 0.95)
	self.color.g = c > 0 and c or 0

	local c = self.color.r + math.random(0.4, 0.6)
	self.color.r = c < 255 and c or 255

	self.scale = self.scale - math.random(0.20, 0.30)
end

-- draw method so that each pixel can be drawn by itself.
function Particle:draw()
	render.setColor(self.color)
	render.drawRect(self.x + 512, self.y + 780, self.scale, self.scale)
end

-- Little table to store some information about the display.
local game = {}
game.particles = {}

-- Timers, we'll use these to spawn new particles and to draw our current ones.
-- This helps us keep constant time when rendering.
local t = timer.systime()
local t2 = timer.systime()

render.createRenderTarget("fireplace")

hook.add("render", "", function ()
 render.setRenderTargetTexture("fireplace")
 render.drawTexturedRect(0,0,512,512)

 render.selectRenderTarget("fireplace")
	if timer.systime() > t then
		for i = 1, math.random(4, 10) do

			-- Make a new particle using our constructor.
			local nP = Particle:new(math.random(-512, 512),
				math.random(-64, 32),
				math.random(40, 80),
				math.random() * 5 - 2,
				-math.random() * 3,
				Color(math.random(200, 230), math.random(100, 130), 0, math.random(120, 255)))

			-- Add our newly made particle to a table of game particles
			table.insert(game.particles, nP)

		end

		-- Increase our timer for our next spawn time.
		t = timer.systime() + (1 / 20)
	end

	if timer.systime() > t2 then

		game.relVel = chip():worldToLocal(chip():getPos() + chip():getVelocity())

		-- Clear the board before rendering anything new
		render.clear(Color(5, 5, 16))

		for k, v in pairs(game.particles) do
			-- Now iterate over all our particles and check if they should be removed.
			if v.color.a <= 0 then table.remove(game.particles, k) continue end

			-- This is responsible for moving our flames if we shake our screen.
			-- Moves sprites based upon their scale.
			v.x_vel = v.x_vel - (game.relVel.y * (1 / 5000) * (80 / v.scale))
			v.y_vel = v.y_vel - (game.relVel.x * (1 / 2000) * (80 / v.scale))

			-- We only need to think.
			-- Our function draws before thinking, so we're fine.
			v:think()
		end

		-- Increase our timer for our next draw time.
		t2 = timer.systime() + (1 / 120)
	end
 render.selectRenderTarget()
end)
