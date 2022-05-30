if not SF.Require("socket.core") then return function() end end

-- LuaSocket helper module
-- Author: Diego Nehab

-- Exported auxiliar functions
function socket.connect4(address, port, laddress, lport)
    return socket.connect(address, port, laddress, lport, "inet")
end

function socket.connect6(address, port, laddress, lport)
    return socket.connect(address, port, laddress, lport, "inet6")
end

function socket.bind(host, port, backlog)
    if host == "*" then host = "0.0.0.0" end
    local addrinfo, err = socket.dns.getaddrinfo(host);
    if not addrinfo then return nil, err end
    local sock, res
    err = "no info on address"
    for i, alt in ipairs(addrinfo) do
        if alt.family == "inet" then
            sock, err = socket.tcp4()
        else
            sock, err = socket.tcp6()
        end
        if not sock then return nil, err end
        sock:setoption("reuseaddr", true)
        res, err = sock:bind(alt.addr, port)
        if not res then
            sock:close()
        else
            res, err = sock:listen(backlog)
            if not res then
                sock:close()
            else
                return sock
            end
        end
    end
    return nil, err
end

socket.try = socket.newtry()

function socket.choose(table)
    return function(name, opt1, opt2)
        if type(name) ~= "string" then
            name, opt1, opt2 = "default", name, opt1
        end
        local f = table[name or "nil"]
        if not f then error("unknown key (".. tostring(name) ..")", 3)
        else return f(opt1, opt2) end
    end
end

-- Socket sources and sinks, conforming to LTN12
-- create namespaces inside LuaSocket namespace
local sourcet, sinkt = {}, {}
socket.sourcet = sourcet
socket.sinkt = sinkt

socket.BLOCKSIZE = 2048

sinkt["close-when-done"] = function(sock)
    return setmetatable({
        getfd = function() return sock:getfd() end,
        dirty = function() return sock:dirty() end
    }, {
        __call = function(self, chunk, err)
            if not chunk then
                sock:close()
                return 1
            else return sock:send(chunk) end
        end
    })
end

sinkt["keep-open"] = function(sock)
    return setmetatable({
        getfd = function() return sock:getfd() end,
        dirty = function() return sock:dirty() end
    }, {
        __call = function(self, chunk, err)
            if chunk then return sock:send(chunk)
            else return 1 end
        end
    })
end

sinkt["default"] = sinkt["keep-open"]

socket.sink = socket.choose(sinkt)

sourcet["by-length"] = function(sock, length)
    return setmetatable({
        getfd = function() return sock:getfd() end,
        dirty = function() return sock:dirty() end
    }, {
        __call = function()
            if length <= 0 then return nil end
            local size = math.min(socket.BLOCKSIZE, length)
            local chunk, err = sock:receive(size)
            if err then return nil, err end
            length = length - string.len(chunk)
            return chunk
        end
    })
end

sourcet["until-closed"] = function(sock)
    local done
    return setmetatable({
        getfd = function() return sock:getfd() end,
        dirty = function() return sock:dirty() end
    }, {
        __call = function()
            if done then return nil end
            local chunk, err, partial = sock:receive(socket.BLOCKSIZE)
            if not err then return chunk
            elseif err == "closed" then
                sock:close()
                done = 1
                return partial
            else return nil, err end
        end
    })
end

sourcet["default"] = sourcet["until-closed"]

socket.source = socket.choose(sourcet)

--- Socket library. Only usable by owner of starfall.
-- See the WebSocket type for a version of this that doesn't require a DLL, and supports secure websockets (wss)
-- Beware "Blocking" functions; they will freeze the game. See http://w3.impa.br/~diego/software/luasocket/socket.html
-- Install the gmcl_socket.core_*.dll binary file to lua/bin and create a 'gm_socket_whitelist.txt' file in steamapps/common
-- Each line in the whitelist will allow luasocket to access the specified domain and port. They are formatted as 'domain:port' e.g. 'garrysmod.com:80', '*.com:80' '95.123.12.22:27015'
-- @name socket
-- @class library
-- @libtbl socket_library
SF.RegisterLibrary("socket")

-- Socket lib doc sourced from: https://defold.com/ref/stable/socket

return function(instance)

if LocalPlayer() ~= instance.player then return end

local socket_list = setmetatable({},{__mode="k"})

local function create_proxy_function(original_function)
	return function(...)
		local sock, err = original_function(...)
		if sock ~= nil then
			socket_list[sock] = true
		end
		return sock, err
	end
end

instance:AddHook("deinitialize", function()
	for socket in pairs(socket_list) do
		socket:close()
	end
end)

local socket_proxy = {}
setmetatable(socket_proxy, { __index = socket })

--- Creates and returns an IPv4 TCP master object.
-- A master object can be transformed into a server object with the method listen (after a call to bind) or into a client object with the method connect.
-- The only other method supported by a master object is the close method.
-- @name socket_library.tcp
-- @class function
-- @return table New IPv4 TCP Master Object, or nil if error
-- @return string? The error message, or nil if no error
socket_proxy.tcp = create_proxy_function(socket.tcp)

--- Creates and returns an IPv4 TCP master object.
-- A master object can be transformed into a server object with the method listen (after a call to bind) or into a client object with the method connect.
-- The only other method supported by a master object is the close method.
-- @name socket_library.tcp4
-- @class function
-- @return table New IPv4 TCP Master Object, or nil if error
-- @return string? The error message, or nil if no error
socket_proxy.tcp4 = create_proxy_function(socket.tcp4)

--- Creates and returns an IPv6 TCP master object.
-- A master object can be transformed into a server object with the method listen (after a call to bind) or into a client object with the method connect.
-- The only other method supported by a master object is the close method.
-- Note: The TCP object returned will have the option "ipv6-v6only" set to true.
-- @name socket_library.tcp6
-- @class function
-- @return table New IPv6 TCP Master Object, or nil if error
-- @return string? The error message, or nil if no error
socket_proxy.tcp6 = create_proxy_function(socket.tcp6)

-- Creates and returns an unconnected IPv4 UDP object.
-- Unconnected objects support the sendto, receive, receivefrom, getoption, getsockname, setoption, settimeout, setpeername, setsockname, and close methods.
-- The setpeername method is used to connect the object.
-- @name socket_library.udp
-- @class function
-- @return table New IPv4 TCP master object, or nil in case of error.
-- @return string? The error string if errored, else nil
socket_proxy.udp = create_proxy_function(socket.udp)

-- Creates and returns an unconnected IPv4 UDP object.
-- Unconnected objects support the sendto, receive, receivefrom, getoption, getsockname, setoption, settimeout, setpeername, setsockname, and close methods.
-- The setpeername method is used to connect the object.
-- @name socket_library.udp
-- @class function
-- @return table New IPv4 TCP master object, or nil in case of error.
-- @return string? The error string if errored, else nil
socket_proxy.udp4 = create_proxy_function(socket.udp4)

-- Creates and returns an unconnected IPv4 UDP object.
-- Unconnected objects support the sendto, receive, receivefrom, getoption, getsockname, setoption, settimeout, setpeername, setsockname, and close methods.
-- The setpeername method is used to connect the object.
-- Note: The UDP object returned will have the option "ipv6-v6only" set to true.
-- @name socket_library.udp
-- @class function
-- @return table New IPv4 TCP master object, or nil in case of error.
-- @return string? The error string if errored, else nil
socket_proxy.udp6 = create_proxy_function(socket.udp6)

--- This function is a shortcut that creates and returns a TCP client object connected to a remote address at a given port.
-- Optionally, the user can also specify the local address and port to bind (locaddr and locport), or restrict the socket family to "inet" or "inet6".
-- Without specifying family to connect, whether a tcp or tcp6 connection is created depends on your system configuration.
-- @name socket_library.connect
-- @class function
-- @param number addr Address to connect to
-- @param number port Port to connect to
-- @param number? laddr Local address to bind to
-- @param number? lport Local port to bind to
-- @param string? family Socket family, either "inet" or "inet6".
-- @return table client TCPClient object. Nil if error
-- @return string? error Error string if the previous return was nil, else nil
socket_proxy.connect = create_proxy_function(socket.connect)

--- This function is a shortcut that creates and returns a TCP client object connected to a remote address at a given port.
-- Optionally, the user can also specify the local address and port to bind (locaddr and locport)
-- @name socket_library.connect4
-- @class function
-- @param number addr Address to connect to
-- @param number port Port to connect to
-- @param number? laddr Local address to bind to
-- @param number? lport Local port to bind to
-- @return table client TCPClient object. Nil if error
-- @return string? error Error string if the previous return was nil, else nil
socket_proxy.connect4 = create_proxy_function(socket.connect4)

--- This function is a shortcut that creates and returns a TCP client object connected to a remote address at a given port.
-- Optionally, the user can also specify the local address and port to bind (locaddr and locport)
-- @name socket_library.connect6
-- @class function
-- @param number addr Address to connect to
-- @param number port Port to connect to
-- @param number? laddr Local address to bind to
-- @param number? lport Local port to bind to
-- @return table client TCPClient object. Nil if error
-- @return string? error Error string if the previous return was nil, else nil
socket_proxy.connect6 = create_proxy_function(socket.connect6)

-- TODO: Docs for this. is this supposed to be the raw metamethod?
socket_proxy.bind = create_proxy_function(socket.bind)

instance.env.socket = socket_proxy

end
