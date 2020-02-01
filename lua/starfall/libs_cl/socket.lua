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

--- Socket library. Only usable by owner of starfall.<br>
-- Beware "Blocking" functions; they will freeze the game. See http://w3.impa.br/~diego/software/luasocket/socket.html<br>
-- Install the gmcl_socket.core_*.dll binary file to lua/bin and create a 'gm_socket_whitelist.txt' file in steamapps/common<br>
-- Each line in the whitelist will allow luasocket to access the specified domain and port. They are formatted as 'domain:port' e.g. 'garrysmod.com:80', '*.com:80' '95.123.12.22:27015'
-- @name socket
-- @class library
-- @libtbl socket_library
SF.RegisterLibrary("socket")


return function(instance)


if LocalPlayer() == instance.player then
	instance.env.socket = socket
end

end
