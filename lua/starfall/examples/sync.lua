--@name Sync
--@author INP

if SERVER then
	-- Code only executed on the server
	local randomNumber = math.random(0, 100)

	net.receive("request", function (len, ply)
		-- ply being the client that sent the net message

		-- A client is asking for the number
		-- Send it to the client
		net.start("number")
			-- UInt means that the number is an unsigned integer
			-- 7 is the amount of bits to use for the transmission
			net.writeUInt(randomNumber, 7)
		net.send(ply)
	end)
else
	-- Code only executed on the client
	local randomNumber

	local font = render.createFont("Default", 62)

	-- Send a request for the number to the server
	net.start("request")
	net.send()

	net.receive("number", function (len)
		-- No client argument, since it can only come from the server
		-- The server is sending us the number
		randomNumber = net.readUInt(7)
	end)

	-- The render hook is called every frame the client requires the screen to be rendered
	-- If the client has 120 FPS then this hook will be called 120 in a second.
	hook.add("render", "renderHook", function ()
		if randomNumber then
			render.setColor(Color(0, 255, 255, 255))
			render.setFont(font)
			render.drawText(20, 20, tostring(randomNumber))
		end
	end)
end
