--[[
	Websocket Library
]]

local WebSocket = {}
WebSocket.__index = WebSocket

local function make_js(address)
	address = string.JavascriptSafe(address)
	return [[
		var sf_websocket = new WebSocket("]] .. address .. [[");

		sf_websocket.onmessage = function(event) { sf.on_message(event.data);             };
		sf_websocket.onopen = function()         { sf.on_open();                          };
		sf_websocket.onclose = function()        { sf.on_close(false);                    };
		sf_websocket.onerror = function()        { sf.on_close(true);                     };

		// Exposed functions to lua
		sf.send = function(data) { sf_websocket.send(data); };

		console.log("SF: Opened websocket to ]] .. address .. [[");
	]]
end

local READYSTATE = {
	CONNECTING = 0,
	OPEN = 1,
	CLOSING = 2,
	CLOSED = 3
}

function WebSocket.new(domain, port, path, secure)
	return setmetatable({
		address = (secure and "wss" or "ws") .. "://" .. domain .. ":" .. (port or "443") .. (path and ("/" .. path) or ""),
		state = READYSTATE.CONNECTING
	}, WebSocket)
end

function WebSocket:connect()
	assert( self.state == READYSTATE.CONNECTING and self.html == nil, "WebSocket is already connected" )

	local html = vgui.Create("DHTML")
	html:AddFunction("sf", "on_message", function(msg)
		if self.onMessage then self.onMessage(self, msg) end
	end)

	html:AddFunction("sf", "on_open", function()
		self.state = READYSTATE.OPEN
		if self.onConnected then self.onConnected(self) end
	end)

	html:AddFunction("sf", "on_close", function(errored)
		self.state = READYSTATE.CLOSED
		if self.onDisconnected then self.onDisconnected(self, errored) end
	end)

	html.OnDocumentReady = function()
		html:RunJavascript(make_js(self.address))
	end

	-- Need this :p
	html:SetHTML("")

	self.html = html
end

function WebSocket:close()
	local html = assert( self.state <= READYSTATE.OPEN and self.html, "WebSocket not connected" )

	self.state = READYSTATE.CLOSING

	html:RunJavascript("sf_websocket.close();")
	self.html:Remove()

	-- Calling this manually so we wouldn't need to make a timer to wait for the callback to run on the JS side.
	-- Also removing the panel halts all js immediately
	if self["onDisconnected"] then
		self["onDisconnected"](self, false)
	end
end

function WebSocket:write(msg)
	local html = assert( self.state == READYSTATE.OPEN and self.html, "WebSocket not connected" )
	html:RunJavascript([[
		if (sf_websocket.readyState == 1) {
			sf_websocket.send("]] .. string.JavascriptSafe(msg) .. [[");
		}
	]])
end

--[[
	End of Websocket library
]]

local checkluatype = SF.CheckLuaType

--- Websocket Type. Create a websocket with WebSocket(...)
-- @name WebSocket
-- @class type
-- @libtbl websocket_methods
-- @libtbl websocket_meta
SF.RegisterType("WebSocket", true, false, WebSocket)

return function(instance)

if LocalPlayer() ~= instance.player then return end

local websocket_methods, websocket_meta, wrap, unwrap = instance.Types.WebSocket.Methods, instance.Types.WebSocket, instance.Types.WebSocket.Wrap, instance.Types.WebSocket.Unwrap

local websocket_list = {}

--- Creates a new websocket object.
--- Add onMessage, onConnected, onDisconnected functions for callbacks.
--- Also see the websocket example.
-- @name builtins_library.WebSocket
-- @param string domain Domain of the websocket server.
-- @param number? port Port of the websocket server. (Default 443)
-- @param boolean? secure Whether to use secure connection (wss). (Default false)
-- @param string? path Optional path of the websocket.
-- @return WebSocket The websocket object. Use WebSocket:connect() to connect.
function instance.env.WebSocket(domain, port, secure, path)
	checkluatype(domain, TYPE_STRING)
	if port ~= nil then checkluatype(port, TYPE_NUMBER) end
	if secure ~= nil then checkluatype(secure, TYPE_BOOL) end
	if path ~= nil then checkluatype(path, TYPE_STRING) end

	local websocket =  WebSocket.new(domain, port, path, secure)
	websocket_list[websocket] = true
	return wrap(websocket)
end

--- Closes the websocket connection. Does nothing if already closed
function websocket_methods:close()
	unwrap(self):close()
end

--- Sends a message to the connected websocket stream.
-- @param string msg What to send
function websocket_methods:write(msg)
	unwrap(self):write(msg)
end

--- Connects to the websocket server.
function websocket_methods:connect()
	unwrap(self):connect()
end

--- Returns the current state of the websocket.
-- https://developer.mozilla.org/en-US/docs/Web/API/WebSocket/readyState
-- * 0 - CONNECTING
-- * 1 - OPEN
-- * 2 - CLOSING
-- * 3 - CLOSED
-- @return number The current state of the websocket.
function websocket_methods:getState()
	return unwrap(self).state
end

--- Sets a callback for the websocket.
-- Can be used with the following callbacks:
-- * onMessage - Called when a message is received.
-- * onConnected - Called when the websocket initially connects.
-- * onDisconnected - Called when the websocket is disconnected, with the only param being if it was caused by an 'error' event.
-- @param string k onMessage, onConnected, onDisconnected
-- @param function v The callback function, which will be called with the websocket as the first argument.
function websocket_meta:__newindex(k, v)
	if k == "onMessage" or k == "onConnected" or k == "onDisconnected" then
		if type(v) == "function" then
			unwrap(self)[k] = function(_, arg) instance:runFunction(v, self, arg) end
		elseif v == nil then
			unwrap(self)[k] = nil
		else
			SF.ThrowTypeError("function", SF.GetType(v), 2)
		end
	else
		rawset(self, k, v)
	end
end

--- Returns "WebSocket: " alongside the address of the websocket.
function websocket_meta:__tostring()
	return "WebSocket: " .. unwrap(self).address
end

instance:AddHook("deinitialize", function()
	for socket in pairs(websocket_list) do
		if socket.state <= READYSTATE.OPEN and socket.html then
			socket:close()
		end
	end
end)

end
