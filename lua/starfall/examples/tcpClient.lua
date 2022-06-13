--@name Asynchronous tcp client http example
--@author Sparky
--@client

-- Requires setup of the socket library
-- This example performs async GET request from an http server and prints the response.

-- Upon placing the chip, the socket will perform an http request and save the response to sf_filedata/httpdata.txt

local operationTimeout = 5

local tcpclient = class("tcpclient")
local tcptask = class("tcptask")
local tcpconnecttask = class("tcpconnecttask", tcptask)
local tcpsendtask = class("tcpsendtask", tcptask)
local tcprecvtask = class("tcprecvtask", tcptask)

do -- tcptask
	function tcptask:initialize(client, success, fail)
		self.client = client
		self.socket = client.socket
		self.success = success
		self.fail = fail
	end

	function tcptask.success()
	end

	function tcptask.fail()
	end

	function tcptask:isTimedout()
		if self.timeout then
			return timer.curtime()>=self.timeout
		else
			self.timeout = timer.curtime()+operationTimeout
			return false
		end
	end
end

do -- tcpconnecttask
	function tcpconnecttask:initialize(client, addr, port, success, fail)
		tcptask.initialize(self, client, success, fail)
		self.socket:connect(addr, port)
	end

	function tcpconnecttask:process()
		local r, w, e = socket.select(nil, {self.socket}, 0)
		if e==nil then
			self.client.connected = true
			self.success()
		elseif e=="timeout" then
			if self:isTimedout() then
				self.fail("Connect operation timed out!")
			else
				return false
			end
		else
			self.fail(e)
		end
		return true
	end
end

do -- tcpsendtask
	function tcpsendtask:initialize(client, data, success, fail)
		tcptask.initialize(self, client, success, fail)
		self.data = data
		self.bytesSent = 0
	end

	function tcpsendtask:process()
		local r, w, e = socket.select(nil, {self.socket}, 0)
		if e==nil then
			local sent, err, sent2 = self.socket:send(self.data, self.bytesSent+1, math.min(#self.data, self.bytesSent+2048))
			--print(sent, err, sent2)
			if err==nil then
				self.bytesSent = self.bytesSent + sent
				if self.bytesSent == #self.data then
					self.success()
				else
					return false
				end
			elseif err=="closed" then
				self.fail(err, sent2)
				self.client:close()
			elseif err=="timeout" then
				if self:isTimedout() then
					self.fail("Send operation timed out!")
				else
					return false
				end
			else
				self.fail(err)
			end
		elseif e=="timeout" then
			if self:isTimedout() then
				self.fail("Send operation timed out!")
			else
				return false
			end
		else
			self.fail(e)
		end
		return true
	end
end

do -- tcprecvtask
	function tcprecvtask:initialize(client, success, fail)
		tcptask.initialize(self, client, success, fail)
	end

	function tcprecvtask:process()
		local r, w, e = socket.select({self.socket}, nil, 0)
		if e==nil then
			local recv, err, recv2 = self.socket:receive(2048)
			--print(recv, err, recv2)
			if err==nil then
				self.success(recv)
			elseif err=="closed" then
				self.success(recv2, err)
				self.client:close()
			elseif err=="timeout" then
				if self:isTimedout() then
					self.fail("Receive operation timed out!")
				else
					self.success(recv2, err)
					return false
				end
			else
				self.fail(err)
			end
		elseif e=="timeout" then
			if self:isTimedout() then
				self.fail("Receive operation timed out!")
			else
				return false
			end
		else
			self.fail(e)
		end
		return true
	end
end

do -- tcpclient
	function tcpclient:initialize()
		self.connected = false
		self.sendqueue = {}
		self.recvqueue = {}

		self.socket = socket.tcp()
		self.socket:settimeout(0)

		hook.add("think",tostring(self),function()
			self:process()
		end)
	end

	function tcpclient:connect(addr, port, success, fail)
		if self.connected then
			error("This socket is already connected!", 2)
		elseif self.connecting then
			error("This socket is already connecting!", 2)
		else
			self.connecting = tcpconnecttask:new(self, addr, port, success, fail)
		end
	end

	function tcpclient:receive(success, fail)
		if self.connected then
			self.recvqueue[#self.recvqueue + 1] = tcprecvtask:new(self, success, fail)
		else
			error("The socket is not connected!", 2)
		end
	end

	function tcpclient:send(data, success, fail)
		if self.connected then
			self.sendqueue[#self.sendqueue + 1] = tcpsendtask:new(self, data, success, fail)
		else
			error("The socket is not connected!", 2)
		end
	end

	function tcpclient:process()
		if self.connected then
			while (#self.recvqueue>0 or #self.sendqueue>0) and quotaAverage()<quotaMax()*0.1 do
				if #self.recvqueue>0 and self.recvqueue[1]:process() then
					table.remove(self.recvqueue, 1)
				end
				if #self.sendqueue>0 and self.sendqueue[1]:process() then
					table.remove(self.sendqueue, 1)
				end
			end
		elseif self.connecting and self.connecting:process() then
			self.connecting = nil
		end
	end

	function tcpclient:close()
		hook.remove("think",tostring(self))
		self.socket:close()
		self.socket = nil
		self.connected = false
		self.connecting = nil
	end
end

local sock = tcpclient:new()
sock:connect("sparkysandbox.org", 80, function()
	-- Keep reading until it closes or times out.
	local chunks = {}
	local function receiveData()
		sock:receive(function(data, err)
			chunks[#chunks+1] = data
			if err=="closed" then
				file.write("httpdata.txt", table.concat(chunks))
			else
				receiveData()
			end
		end, error)
	end

	sock:send("GET / HTTP/1.0\r\nHost: sparkysandbox.org\r\n\r\n", receiveData, error)
end, error)

