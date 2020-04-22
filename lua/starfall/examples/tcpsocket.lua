--@name Asynchronous tcp http example
--@author Sparky
--@client

-- Requires setup of the socket library
-- This example performs async GET request from an http server and prints the response.

local tcp = class("tcp")

function tcp:initialize()
	self.queue = {}
	self.tries = 0
	self.maxtries = 60

	self.socket = socket.tcp()
	self.socket:settimeout(0)

	hook.add("think",tostring(self),function() self:process() end)
end

function tcp:connect(addr, port, success, fail)
	self.queue[#self.queue + 1] = function(timeout)
		self.socket:connect(addr, port)
		return true
	end
	self.queue[#self.queue + 1] = function(timeout)
		if timeout then if fail then fail("Connect operation timed out!") end return end
		local r, w, e = socket.select(nil, {self.socket}, 0)
		if e==nil then if success then success() end return true end
		if e=="timeout" then return end
		if fail then fail(e) end
		return true
	end
end

function tcp:receive(success, fail)
	self.queue[#self.queue + 1] = function(timeout)
		if timeout then if fail then fail("Receive operation timed out!") end return end
		local r, w, e = socket.select({self.socket}, nil, 0)
		if e=="timeout" then return end
		if r[1] then
			local recv, err, recv2 = self.socket:receive(2048)
			if recv then
				if success then success(recv) end
			elseif err=="closed" then
				if success then success(recv2) end
			elseif err=="timeout" then
				return
			else
				if fail then fail(err) end
			end
		else
			if fail then fail(e) end
		end
		return true
	end
end

function tcp:send(data, success, fail)
	local bytesSent = 0
	self.queue[#self.queue + 1] = function(timeout)
		if timeout then if fail then fail("Send operation timed out!") end return end
		local r, w, e = socket.select(nil, {self.socket}, 0)
		if e=="timeout" then return end
		if w[1] then
			local sent, err, err2 = self.socket:send(data, bytesSent+1, math.min(#data, bytesSent+2048))
			print(sent, err, err2)
			if sent then
				bytesSent = bytesSent + sent
				if bytesSent == #data then
					if success then success() end
					return true
				end
				table.insert(self.queue, 2, self.queue[1])
			else
				if fail then fail(err) end
			end
		else
			if fail then fail(e) end
		end
		return true
	end
end

function tcp:process()
	local func = self.queue[1]
	if func then
		local result = func()
		if result then
			self.tries = 0
			table.remove(self.queue, 1)
		else
			if self.tries == self.maxtries then
				func(true)
				self.tries = 0
				table.remove(self.queue, 1)
			else
				self.tries = self.tries + 1
			end
		end
	end
end

function tcp:close()
	hook.remove("think",tostring(self))
	self.socket:close()
	self.socket = nil
end

local sock = tcp:new()
sock:connect("sparkysandbox.org", 80, nil, error)
sock:send("GET / HTTP/1.0\r\nHost: sparkysandbox.org\r\n\r\n", nil, error)
sock:receive(function(data)
	print(data)
	sock:close()
end, error)
