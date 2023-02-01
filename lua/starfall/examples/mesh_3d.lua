--@name Renamon
--@author Sparky
--@client

local holo = holograms.create(chip():getPos(), chip():getAngles(), "models/Combine_Helicopter/helicopter_bomb01.mdl")
holo:setParent(chip())

local textureloaded, mymesh
local texture = material.create("VertexLitGeneric")
local screentexture = material.create("UnlitGeneric")
screentexture:setInt("$flags",48)
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
	render.setMaterial(screentexture)
	mymesh:draw()
	render.popMatrix()
	render.popViewMatrix()
	render.selectRenderTarget()

	render.enableDepth(false)
	render.setRenderTargetTexture("mesh")
	render.drawTexturedRect(0,0,512,512)
end

texture:setTextureURL("$basetexture", "http://thegrb93.github.io/StarfallEx/example_files/renamon.png")
screentexture:setTexture("$basetexture", texture:getTexture("$basetexture"))

http.get("http://thegrb93.github.io/StarfallEx/example_files/renamon.obj",function(objdata)
	local triangles = mesh.trianglesLeft()

	local function doneLoadingMesh()
		print("Used "..(triangles - mesh.trianglesLeft()).." triangles.")
		holo:setMesh(mymesh)
		holo:setMeshMaterial(texture)
		holo:setRenderBounds(Vector(-200),Vector(200))
		
		hook.add("postdrawopaquerenderables","mesh",renderHUD)
		hook.add("render","mesh",renderScreen)
	end

	local loadmesh = coroutine.wrap(function() mymesh = mesh.createFromObj(objdata, true).Renamon return true end)
	hook.add("think","loadingMesh",function()
		while quotaAverage()<quotaMax()/2 do
			if loadmesh() then
				doneLoadingMesh()
				hook.remove("think","loadingMesh")
				return
			end
		end
	end)
end)
