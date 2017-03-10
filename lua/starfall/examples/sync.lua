--@name Sync
--@author INP

if SERVER then
	-- Code only executed on the server
	local randomNumber = math.floor( math.random() * 100 )

	hook.add( "net", "uniqueHookNameHere", function ( name, len, ply )
		-- ply being the client that sent the net message
		-- A client is asking for the number
		if name == "request" then
			-- Send it to the client
			net.start( "number" )
				-- 8 is the amount of bits to use for the transmission
				net.writeInt( randomNumber, 8 )
			net.send( ply )
		end
	end )
else
	-- Code only executed on the client
	local randomNumber

	local font = render.createFont( "Default", 62 )

	-- Send a request for the number to the server
	net.start( "request" )
	net.send()

	hook.add( "net", "uniqueHookNameHerev2", function ( name, len )
		-- No client argument, since it can only come from the server
		-- The server is sending us the number
		if name == "number" then
			randomNumber = net.readInt( 8 )
		end
	end )

	-- The render hook is called every frame the client requires the screen to be rendered
	-- If the client has 120 FPS then this hook will be called 120 in a second.
	hook.add( "render", "renderHook", function ()
		render.clear()
		if randomNumber then
			render.setColor( Color( 0,255,255,255 ) )
			render.setFont( font )
			render.drawText( 20, 20, tostring( randomNumber ) )
		end
	end )
end
