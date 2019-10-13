--@name Textured mesh
--@author Sparky
--@shared

--Link a screen or hud to the chip to see all the different ways to render a mesh

local holo
if SERVER then

	holo = holograms.create(chip():getPos(), chip():getAngles(), "models/Combine_Helicopter/helicopter_bomb01.mdl")
	holo:setParent(chip())
	hook.add("net","",function(name, len, pl)
		net.start("")
		net.writeEntity(holo)
		net.send(pl)
	end)

else

	local textureloaded, mymesh
	local texture = material.create("VertexLitGeneric")
	local screenmaterial = material.create("UnlitGeneric")
	screenmaterial:setInt("$flags",48)
	render.createRenderTarget("mesh")

	-- Renders the mesh using a HUD
	local function renderHUD()
		render.pushMatrix(chip():getMatrix(),true)
		render.enableDepth(true)
		render.setMaterial(texture)
		mymesh:draw()
		render.popMatrix()
	end

	-- Render the mesh using a screen
	local function renderScreen()
		render.selectRenderTarget("mesh")
		render.pushViewMatrix({type="3D", x=0, y=0, w=1024, h=1024, origin=Vector(-50,50,0), angles = Angle(0,0,0), aspect=1})
		local rotation = Matrix()
		rotation:rotate(Angle(timer.curtime()*10,0,0))
		render.pushMatrix(rotation, true)
		render.clear(Color(0,0,0,0),true)
		render.enableDepth(true)
		render.setMaterial(screenmaterial)
		mymesh:draw()
		render.popMatrix()
		render.popViewMatrix()
		render.selectRenderTarget()

		render.enableDepth(false)
		render.setRenderTargetTexture("mesh")
		render.drawTexturedRect(0,0,512,512)
	end

	local function init()
		if not (mymesh and holo) then return end

		holo:setMesh(mymesh)
		holo:setMeshMaterial(texture)
		holo:setRenderBounds(Vector(-200),Vector(200))

		hook.add("postdrawopaquerenderables","mesh",renderHUD)
		hook.add("render","mesh",renderScreen)
	end

	-- Used for setting up the hologram
	hook.add("net","",function(name, len, pl)
		holo = net.readEntity():toHologram()
		init()
	end)
	net.start("") net.send()

	texture:setTextureURL("$basetexture", "https://dl.dropboxusercontent.com/s/79nhlngkvydv85f/renamon.png")
	screenmaterial:setTexture("$basetexture", texture:getTexture("$basetexture"))

	http.get("https://dl.dropboxusercontent.com/s/cwob1j0nka0ko2e/renamon.obj",function(objdata)
		local start = mesh.trianglesLeft()
		mymesh = mesh.createFromObj(objdata)
		print("Used "..(start-mesh.trianglesLeft()).." triangles.")
		init()
	end)
end

