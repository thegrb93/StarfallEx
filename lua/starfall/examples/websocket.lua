--@name Websocket Example
--@author Vurv
--@client

-- Shows basic usage of a websocket with an echo server.

-- First param is the base url
-- Second is the port (optional),
-- Third is whether to use secure connection (wss) (optional). Some servers require this.
local ws = WebSocket("ws.ifelse.io", 443, true)

function ws:onConnected()
	-- Print a message when connected, and the state.
	-- See the SF Helper for more info on the websocket state
	print("Socket connected", self:getState())

	-- Send a message to the server
	self:write("Test")
end

-- This is usually called twice, once when the socket gets an "error", which will pass true to this callback,
-- and then another time for it finally "disconnecting" (which will pass false).
function ws:onDisconnected(errored)
	print("Socket disconnected", errored, self:getState())
end

-- This is called whenever the socket receives a message.
function ws:onMessage(msg)
	print("Socket got a message: ", msg)

	if msg == "Test" then
		-- Send another message
		self:write("Exit")
	elseif msg == "Exit" then
		-- Close the socket
		self:close()
	end
end

-- Connect to the server
ws:connect()
