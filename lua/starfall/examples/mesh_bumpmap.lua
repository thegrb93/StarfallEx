--@name Bumpmap Sphere
--@author Sparky
--@shared

local holo
if SERVER then

	holo = holograms.create(chip():getPos()+Vector(0,0,100), chip():getAngles(), "models/Combine_Helicopter/helicopter_bomb01.mdl")
	holo:setParent(chip())

	hook.add("net","",function(name, len, pl)        
		net.start("")
		net.writeEntity(holo)
		net.send(pl)
	end)

else

	local sphere
	local mat = material.create("VertexLitGeneric")
	mat:setInt("$flags",138414080)
	mat:setTexture("$basetexture", "phoenix_storms/cube")
	mat:setTexture("$bumpmap", "phoenix_storms/cube_bump")
	mat:setTexture("$envmap", "env_cubemap")
	
	mat:setFloat("$envmapcontrast", 1)
	mat:setFloat("$envmapsaturation", 0.20000000298023)
	mat:setVector("$envmaptint", Vector(0.006585, 0.006585, 0.006585))
	
	mat:setInt("$phong", 1)
	mat:setFloat("$phongalbedotint", 0)
	mat:setFloat("$phongboost", 2)
	mat:setFloat("$phongexponent", 20)
	mat:setVector("$phongfresnelranges", Vector(.219520, 0.612066, 1.000000))

	net.start("")
	net.send()
	
	local function init()
		if holo and sphere then
			holo:setMaterial("!"..mat:getName())
			holo:setHologramMesh(sphere)
			holo:setHologramRenderBounds(Vector(-200),Vector(200))
		end
	end
	
	hook.add("net","",function(name, len, pl)
		holo = net.readEntity()
		init()
	end)

	http.get("https://dl.dropboxusercontent.com/s/243l0or1o3xolmu/sphere.obj?dl=0",function(data)
		sphere = mesh.createFromObj(data)
		init()
	end)
end
