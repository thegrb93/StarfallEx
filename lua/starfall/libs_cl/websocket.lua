--[[
	Websocket Library
]]

local WebSocket = {}
WebSocket.__index = WebSocket

local function make_html(address)
	address = string.JavascriptSafe(address)
	return [[
	<script>
		var sf_websocket = new WebSocket("]] .. address .. [[");

		sf_websocket.onmessage = function(event) { sf.on_message(event.data);             };
		sf_websocket.onopen = function()         { sf.on_open();                          };
		sf_websocket.onclose = function()        { sf.on_close(false);                    };
		sf_websocket.onerror = function()        { sf.on_close(true);                     };

		// Exposed functions to lua
		sf.send = function(data) { sf_websocket.send(data); };

		console.log("SF: Opened websocket to ]] .. address .. [[");
	</script>
	]]
end

local function hook_call(self, event)
	return function(arg)
		if self["on" .. event] then
			self["on" .. event](self, arg)
		end
	end
end

function WebSocket.new(addr, port, secure)
	return setmetatable({
		callback = {},
		address = (secure and "wss" or "ws") .. "://" .. addr .. ":" .. (port or "443"),
	}, WebSocket)
end

function WebSocket:connect()
	local panel = vgui.Create("DFrame", nil, nil)
	panel:SetSize(0, 0)
	panel:SetTitle("")
	panel:SetDeleteOnClose(true)
	panel.Paint = function() end

	local html = vgui.Create("DHTML", p, nil)
	html:AddFunction("sf", "on_message", hook_call(self, "Message"))
	html:AddFunction("sf", "on_open", hook_call(self, "Connected"))
	html:AddFunction("sf", "on_close", hook_call(self, "Disconnected"))
	html:AddFunction("sf", "on_status", hook_call(self, "Status"))
	html:SetAllowLua(false)
	html:SetHTML(make_html(self.address))

	self.html = html
	self.panel = panel
end

function WebSocket:close()
	local html = assert( self.html, "WebSocket not connected" )
	html:RunJavascript("sf_websocket.close()")

	self.panel:Clear()
	self.panel:Remove()
end

function WebSocket:write(msg)
	local html = assert( self.html, "WebSocket not connected" )
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

--- Websocket Type. Create a websocket with websocket.new
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
-- @name builtins_library.WebSocket
-- @param string addr Address of the websocket server.
-- @param number? port Port of the websocket server.
-- @param boolean? secure Whether to use secure connection (wss).
-- @return WebSocket The websocket object. Use WebSocket:connect() to connect.
function instance.env.WebSocket(addr, port, secure)
	checkluatype(addr, TYPE_STRING)
	if port ~= nil then checkluatype(port, TYPE_NUMBER) end
	if secure ~= nil then checkluatype(secure, TYPE_BOOL) end

	local websocket =  WebSocket.new(addr, port, secure)
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

local Callbacks = {
	["onMessage"] = true,
	["onConnected"] = true,
	["onDisconnected"] = true
}

function websocket_meta:__newindex(k, v)
	local cb = Callbacks[k]
	if cb and type(v) == "function" or v == nil then
		unwrap(self)[k] = v
	end
end

instance:AddHook("deinitialize", function()
	for socket in pairs(websocket_list) do
		if socket.html then
			socket:close()
		end
	end
end)

end
