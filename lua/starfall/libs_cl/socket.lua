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
-- Beware "Blocking" functions; they will freeze the game. See http://w3.impa.br/~diego/software/luasocket/socket.html
-- Install the gmcl_socket.core_*.dll binary file to lua/bin and create a 'gm_socket_whitelist.txt' file in steamapps/common
-- Each line in the whitelist will allow luasocket to access the specified domain and port. They are formatted as 'domain:port' e.g. 'garrysmod.com:80', '*.com:80' '95.123.12.22:27015'
-- @name socket
-- @class library
-- @libtbl socket_library
SF.RegisterLibrary("socket")


return function(instance)

if LocalPlayer() ~= instance.player then return end

local socket_data = {}
-- maps userdata sockets to proxy sockets
socket_data.sockets = {}
instance.data.socket = socket_data

local function sock_proxy_get_underlying(prx)
	return getmetatable(prx).sock
end

local function sock_proxy_get_underlying_value(prx, key)
	local underlying_socket = getmetatable(prx).sock
	return underlying_socket[key]
end

local function sock_proxy_create(sock)
	local sock_proxy = {
		close = function(prx, ...)
			local underlying_socket = sock_proxy_get_underlying(prx)
			socket_data.sockets[underlying_socket] = nil
			return underlying_socket:close(...)
		end,
		accept = function(prx, ...)
			local underlying_socket = sock_proxy_get_underlying(prx)
			local client, err = underlying_socket:accept(...)
			if client ~= nil then
				local client_proxy = sock_proxy_create(client)
				socket_data.sockets[client] = client_proxy

				client = client_proxy
			end
			return client, err
		end,
	}
	setmetatable(sock_proxy, {
		sock = sock,
		__index = function(prx, key)
			local underlying_value = sock_proxy_get_underlying_value(prx, key)
			if type(underlying_value) == "function" then
				return function(s, ...)
					local meta = getmetatable(prx)
					if meta ~= nil then s = meta.sock or s end
					return underlying_value(s, ...)
				end
			else
				return underlying_value
			end
		end
	})

	return sock_proxy
end

local function create_proxy_function(original_function)
	return function(...)
		local sock, err = original_function(...)
		if sock ~= nil then
			local prx = sock_proxy_create(sock)
			socket_data.sockets[sock] = prx

			sock = prx
		end
		return sock, err
	end
end

instance:AddHook("deinitialize", function()
	local originals = instance.data.socket.originals
	local socket_list = instance.data.socket.sockets
	for sock, _ in pairs(socket_list) do
		sock:close()
	end
end)

local socket_proxy = {}
setmetatable(socket_proxy, { __index = socket })

socket_proxy.tcp = create_proxy_function(socket.tcp)
socket_proxy.tcp4 = create_proxy_function(socket.tcp4)
socket_proxy.tcp6 = create_proxy_function(socket.tcp6)
socket_proxy.udp = create_proxy_function(socket.udp)
socket_proxy.udp4 = create_proxy_function(socket.udp4)
socket_proxy.udp6 = create_proxy_function(socket.udp6)
socket_proxy.connect = create_proxy_function(socket.connect)
socket_proxy.connect4 = create_proxy_function(socket.connect4)
socket_proxy.connect6 = create_proxy_function(socket.connect6)
socket_proxy.bind = create_proxy_function(socket.bind)
socket_proxy.select = function(rcv, snd, ...)
	local rcv_underlying = nil
	local snd_underlying = nil
	if rcv ~= nil then
		rcv_underlying = {}
		for i = 1, #rcv do
			rcv_underlying[i] = sock_proxy_get_underlying(rcv[i])
		end
	end
	if snd ~= nil then
		snd_underlying = {}
		for i = 1, #snd do
			snd_underlying[i] = sock_proxy_get_underlying(snd[i])
		end
	end

	rcv_underlying, snd_underlying, err = socket.select(rcv_underlying, snd_underlying, ...)

	rcv = {}
	snd = {}

	for i = 1, #rcv_underlying do
		local prx = socket_data.sockets[rcv_underlying[i]]
		rcv[i] = prx
		rcv[prx] = i
	end
	for i = 1, #snd_underlying do
		local prx = socket_data.sockets[snd_underlying[i]]
		snd[i] = prx
		snd[prx] = i
	end
	return rcv, snd, err
end
socket_proxy.sink = function(mode, prx)
	return socket.sink(mode, sock_proxy_get_underlying(prx))
end
socket_proxy.source = function(mode, prx, ...)
	return socket.source(mode, sock_proxy_get_underlying(prx), ...)
end

instance.env.socket = socket_proxy

end
