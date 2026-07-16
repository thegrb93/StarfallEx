--@name WigglyCylinder
--@author Chirp
--@shared

-- Creates a jiggly rainbow cylinder mesh

local function makeWorker(func)
	local worker = coroutine.wrap(func)
	return function()
		while quotaAverage()<quotaMax()*0.4 do
			local status = worker()
			if status~=nil then return status end
		end
	end
end

if CLIENT then

local jiggleprop_cl = class("jiggleprop_cl")
jiggleprop_cl.static.propstore = {}
function jiggleprop_cl:initialize()
	jiggleprop_cl.static.propstore[self] = true
	self.draw = self.drawPreInit
	self.worker = makeWorker(function() return self:generate() end)
end

function jiggleprop_cl:recv()
	self.bonelength = net.readFloat()
	self.r = net.readFloat()
	self.nx = net.readUInt(32)
	self.bones = {}
	self.nbones = net.readUInt(32)
	for i=1, self.nbones do
		net.readEntity(function(e) self.bones[i] = e end)
	end
end

function jiggleprop_cl:generate()
	-- Generate vertex map
	local vertices = {}
	local normals = {}
	local weights = {}
	local nx, r = self.nx, self.r
	local thetainc = 2*math.pi/nx
	local zinc = 2*r*math.sin(thetainc*0.5)
	local ny = math.floor(self.bonelength*self.nbones / zinc)
	for y=1, ny+1 do
		for x=1, nx do
			local theta = (x-1)*thetainc
			vertices[nx*(y-1) + x] = Vector(math.cos(theta)*r, math.sin(theta)*r, (y-1)*zinc)
		end
		coroutine.yield()
	end
	for x=1, nx do
		local theta = (x-1)*thetainc
		normals[x] = Vector(math.cos(theta), math.sin(theta), 0)
		coroutine.yield()
	end
	for y=1, ny+1 do
		local b1, b2
		local b1d, b2d = math.huge, math.huge
		for b=1, self.nbones do
			local dist = math.sqrt(((y-1)*zinc - (b-1)*self.bonelength)^2 + r^2)
			if dist < b1d then b2 = b1 b2d = b1d b1 = b b1d = dist
			elseif dist < b2d then b2 = b b2d = dist
			end
		end
		weights[y] = {b1, b1d/(b1d+b2d), b2, b2d/(b1d+b2d)}
		coroutine.yield()
	end
	self.mesh = mesh.createEmptySkinned()
	self.matrices = self.mesh:setupBoneMatrices(self.nbones)

	-- Wait for average to decrease enough to generate the mesh
	while quotaAverage()>quotaMax()*0.1 do coroutine.yield("wait") end

	mesh.generate(self.mesh, MATERIAL.QUADS, nx*ny, function()
		-- Generate a quad for every face
		for y=1, ny do
			local hsv1 = Color((y-1)*10, 1, 1):hsvToRGB()
			local hsv2 = Color(y*10, 1, 1):hsvToRGB()
			for x=1, nx do
				local x2 = x%nx + 1
				local u1, u2, v1, v2 = (x-1)/nx, x/nx, (y-1)/ny, y/ny
				local w1, w2 = weights[y], weights[y+1]
				mesh.writePosition(vertices[nx*(y-1) + x])
				mesh.writeBoneData(0, w1[1], w1[2])
				mesh.writeBoneData(1, w1[3], w1[4])
				mesh.writeNormal(normals[x])
				mesh.writeColor( unpack(hsv1) )
				mesh.writeUV(0, u1, v1)
				mesh.advanceVertex()
				mesh.writePosition(vertices[nx*y + x])
				mesh.writeBoneData(0, w2[1], w2[2])
				mesh.writeBoneData(1, w2[3], w2[4])
				mesh.writeNormal(normals[x])
				mesh.writeColor( unpack(hsv2) )
				mesh.writeUV(0, u1, v2)
				mesh.advanceVertex()
				mesh.writePosition(vertices[nx*y + x2])
				mesh.writeBoneData(0, w2[1], w2[2])
				mesh.writeBoneData(1, w2[3], w2[4])
				mesh.writeNormal(normals[x2])
				mesh.writeColor( unpack(hsv2) )
				mesh.writeUV(0, u2, v2)
				mesh.advanceVertex()
				mesh.writePosition(vertices[nx*(y-1) + x2])
				mesh.writeBoneData(0, w1[1], w1[2])
				mesh.writeBoneData(1, w1[3], w1[4])
				mesh.writeNormal(normals[x2])
				mesh.writeColor( unpack(hsv1) )
				mesh.writeUV(0, u2, v1)
				mesh.advanceVertex()
			end
		end
	end)
	coroutine.yield()

	-- Wait for bone entities
	while true do
		local ready = true
		for i=1, self.nbones do
			if not isValid(self.bones[i]) then ready = false break end
		end
		if ready then break end
		coroutine.yield("wait")
	end

	return "done"
end

function jiggleprop_cl:drawPreInit()
	if self.worker() == "done" then
		self.worker = nil
		self.draw = self.drawPostInit
	end
end

function jiggleprop_cl:drawPostInit()
	local t = Matrix()
	t:translate(Vector(0,0,self.bonelength*1.5))
	for i=1, self.nbones do
		t:translate(Vector(0,0,-self.bonelength))
		self.matrices[i]:set(self.bones[i]:getBoneMatrix(0)*t)
	end
	render.enableDepth(true)
	self.mesh:draw()
end

net.receive("jiggleprop", function() jiggleprop_cl:new():recv() end)

hook.add("postdrawopaquerenderables","jiggleprop",function(_,sky,sky2)
	if sky or sky2 then return end
	for prop in pairs(jiggleprop_cl.static.propstore) do
		local ok, err = xpcall(prop.draw, debug.traceback, prop)
		if not ok then
			print(err)
			jiggleprop_cl.static.propstore[prop] = nil
		end
	end
end)

return
end

enableHud(owner(), true)

local jiggleprop = class("jiggleprop")
jiggleprop.static.propstore = {}
jiggleprop.static.propinitializing = {}
function jiggleprop:initialize(pos, ang, nbones, bonelength, radius, nradial)
	jiggleprop.static.propstore[self] = true
	jiggleprop.static.propinitializing[self] = true
	self.nbones = nbones
	self.bonelength = bonelength
	self.radius = radius
	self.nradial = nradial
	self.isInitialized = false
	self.plysToSend = {}
	self.worker = makeWorker(function() return self:generate(pos, ang) end)
end

function jiggleprop:generate(pos, ang)
	self.bones = {}
	for i=1, self.nbones do
		local bpos, bang = localToWorld(Vector(0,0,(i-1)*self.bonelength), Angle(), pos, ang)
		while not prop.canSpawn() do coroutine.yield("wait") end
		self.bones[i] = prop.create(bpos, bang, "models/props_junk/plasticbucket001a.mdl", true)
		--self.bones[i]:setNoDraw(true)
	end
	for i=2, self.nbones do
		constraint.weld(self.bones[i-1], self.bones[i], 0, 0, 0, true)
	end
	self.isInitialized = true
	if self.plysToSend[1] then self:send(self.plysToSend) end
	return "done"
end

function jiggleprop:send(ply)
	net.start("jiggleprop")
	net.writeFloat(self.bonelength)
	net.writeFloat(self.radius)
	net.writeUInt(self.nradial, 32)
	net.writeUInt(self.nbones, 32)
	for i=1, self.nbones do
		net.writeEntity(self.bones[i])
	end
	net.send(ply)
end

hook.add("think", "jiggleprop", function()
	for prop in pairs(jiggleprop.static.propinitializing) do
		if prop.worker() == "done" then
			jiggleprop.static.propinitializing[prop] = nil
		end
	end
end)

hook.add("clientinitialized", "jiggleprop", function(ply)
	for prop in pairs(jiggleprop.static.propstore) do
		if prop.isInitialized then
			prop:send(ply)
		else
			table.insert(prop.plysToSend, ply)
		end
	end
end)

jiggleprop:new(chip():getPos(), chip():getAngles(), 10, 15, 20, 30)
