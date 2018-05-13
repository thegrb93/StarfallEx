--@name eyebox
--@author thegrb93 aka Sparky
--@shared

-- Place this chip on a box to give it eyes

if SERVER then
	hook.add("net","",function(name,len,ply)
		local e = chip():isWeldedTo()
		e:setMaterial(net.readString(), ply)
		
		net.start("")
		net.writeEntity(e)
		net.send(ply)
	end)
else
	local ent
	render.createRenderTarget("rt")
	render.createRenderTarget("circle")
	
	local box = material.create("UnlitGeneric")
	box:setTexture("$basetexture","models/props_junk/woodcrates01a")
	
	local m = material.create("VertexLitGeneric")
	m:setInt("$model",1)
	m:setTextureRenderTarget("$basetexture", "rt")
	
	net.start("")
	net.writeString("!"..m:getName())
	net.send()

	local function getEyes()
		local playerpos = ent:worldToLocal(player():getShootPos())
		local rightdiff = Vector(-7.373, -7.957, 19.722) - playerpos
		local leftdiff = Vector(-7.373, 6.908, 19.722) - playerpos
		local ratio = -15/leftdiff.z
		local x1, y1, x2, y2 = leftdiff.y*ratio, leftdiff.x*ratio, rightdiff.y*ratio, rightdiff.x*ratio
		local len1 = math.sqrt(x1^2 + y1^2)
		local len2 = math.sqrt(x2^2 + y2^2)
		if len1>20 then x1 = x1*20/len1 y1 = y1*20/len1 end
		if len2>20 then x2 = x2*20/len2 y2 = y2*20/len2 end
		return x1, y1, x2, y2
	end

	local function makeQuad(x,y,w,h) return Vector(x,y,0), Vector(x+w,y,0), Vector(x+w,y+h,0), Vector(x,y+h,0) end
	local boxquad = {makeQuad(0,0,1024,1024)}
	local function doRender()
		render.selectRenderTarget("rt")
		render.setFilterMin(0)
		render.setFilterMag(0)
		render.setTexture(box)
		render.draw3DQuad(unpack(boxquad))

		render.setRenderTargetTexture("circle")
		render.setColor(Color(0,0,0))
		render.drawTexturedRect(705,595,110,110)
		render.drawTexturedRect(855,595,110,110)

		render.setColor(Color(255,255,255))
		render.drawTexturedRect(710,600,100,100)
		render.drawTexturedRect(860,600,100,100)

		local x1, y1, x2, y2 = getEyes()
		render.setColor(Color(0,0,0))
		render.drawTexturedRect(730+x1,620+y1,60,60)
		render.drawTexturedRect(880+x2,620+y2,60,60)
		render.selectRenderTarget()
	end

	local function initRender()
		render.selectRenderTarget("circle")
		local poly = {}
		for i=1, 360 do
			local theta = i*math.pi/180
			poly[i] = {x=math.cos(theta)*512+512, y=math.sin(theta)*512+512}
		end
		render.clear(Color(0,0,0,0))
		render.drawPoly(poly)
		render.selectRenderTarget()

		hook.remove("renderoffscreen","init")
		hook.add("renderoffscreen","go",doRender)
	end
	hook.add("net","",function()
		ent = net.readEntity()
		hook.add("renderoffscreen","init",initRender)
	end)
end
