--@name Bumpmap Sphere
--@author Sparky
--@shared

local holo
if SERVER then

	holo = holograms.create(chip():getPos()+Vector(0,0,50), chip():getAngles(), "models/Combine_Helicopter/helicopter_bomb01.mdl")
	holo:setScale(Vector(0.1, 0.1, 0.1))
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
	mat:setTexture("$basetexture", "hunter/myplastic")
	mat:setTexture("$bumpmap", "hunter/myplastic_normal")
	mat:setTexture("$envmap", "env_cubemap")

	mat:setFloat("$envmapcontrast", 1)
	mat:setFloat("$envmapsaturation", 0.20000000298023)
	mat:setVector("$envmaptint", Vector(0.006585, 0.006585, 0.006585))

	mat:setInt("$phong", 1)
	mat:setFloat("$phongalbedotint", 0)
	mat:setFloat("$phongboost", 2)
	mat:setFloat("$phongexponent", 60)
	mat:setVector("$phongfresnelranges", Vector(0.219520, 0.612066, 1.000000))

	net.start("")
	net.send()

	local function init()
		if holo and sphere then
			holo:setMesh(sphere)
			holo:setMeshMaterial(mat)
			holo:setRenderBounds(Vector(-200),Vector(200))
		end
	end

	hook.add("net","",function(name, len, pl)
		holo = net.readEntity():toHologram()
		init()
	end)

	http.get("http://thegrb93.github.io/StarfallEx/example_files/sphere.obj",function(data)
		sphere = mesh.createFromObj(data).Sphere
		init()
	end)
end
