--@name Filetransfer
--@author Sparky
--@shared

--File transfer library. Allows sending strings much larger than the limit size.
--Example usage
---------------------
----SERVER
---------------------
--local filetransfer = require("filetransfer.txt")
--
--net.start("myfile")
--filetransfer.write("mydata")
--net.send()

---------------------
----CLIENT
---------------------
--hook.add("net","",function(name,len)
--	if name=="myfile" then
--		filetransfer.read(function(data)
--			if data then
--				print(data)
--			end
--		end)
--	end
--end)

local filetransfer = {}
filetransfer.uploadcache = {}
filetransfer.downloadqueue = {}

local packetsize = 1000

local function duelSend(ply)
	if SERVER then
		net.send(ply)
	else
		net.send()
	end
end

local function processQueue()
	local item = filetransfer.downloadqueue[1]
	if not item then return end
	
	net.start("ftreqdata")
	net.writeUInt(item.index, 16)
	net.writeUInt(#item.pieces, 16)
	duelSend(item.ply)
	
	if timer.exists("ftdownloadtimeout"..item.index) then
		timer.adjust("ftdownloadtimeout"..item.index, 10, 1)
	else
		timer.create("ftdownloadtimeout"..item.index, 10, 1, function()
			item.callback(nil)
			table.remove(filetransfer.downloadqueue, 1)
			timer.remove("ftkeepalive"..item.index)
			processQueue()
		end)
	end
end

local function sendData(index, ply)
	local part = net.readUInt(16)
	local function timetosend()
		local data = filetransfer.uploadcache[index]
		if not data then return end
		local senddata = string.sub(data, part*packetsize+1, math.min(part*packetsize+packetsize, #data))
			
		if net.getBytesLeft()<#senddata+100 then
			timer.simple(0.1, timetosend)
			return
		end
		
		net.start("ftrecvdata")
		net.writeUInt(index, 16)
		net.writeData(senddata, #senddata)
		duelSend(ply)
	end
	timetosend()
end

local function gotData(index, ply)
	local item = filetransfer.downloadqueue[1]
	if not item then return end
	
	item.pieces[#item.pieces+1] = net.readData(packetsize)
	
	if #item.pieces == item.numpieces then
		local data = fastlz.decompress(table.concat(item.pieces))
		item.callback(data)
		table.remove(filetransfer.downloadqueue, 1)
		timer.remove("ftdownloadtimeout"..item.index)
		timer.remove("ftkeepalive"..item.index)
	end
	processQueue()
end

function filetransfer.write(data)
	local compressed = fastlz.compress(data)
	local index = 1
	while filetransfer.uploadcache[index] do
		index = index + 1
	end
	filetransfer.uploadcache[index] = compressed
	
	timer.create("ftcachetimeout"..index,10,1,function() filetransfer.uploadcache[index] = nil end)
	
	net.writeUInt(index, 16)
	net.writeUInt(math.ceil(#compressed/packetsize),16)
end

function filetransfer.read(callback, ply)
	local index = net.readUInt(16)
	local numpieces = net.readUInt(16)
	local item = {
		index = index,
		numpieces = numpieces,
		pieces = {},
		ply = ply,
		callback = callback
	}
	
	local queuelen = #filetransfer.downloadqueue
	filetransfer.downloadqueue[queuelen+1] = item
	if queuelen == 0 then
		processQueue()
	end
	timer.create("ftkeepalive"..index, 3, 0, function()
		net.start("ftkeepalive")
		net.writeUInt(index,16)
		duelSend(ply)
	end)
end

hook.add("net","filetransfer",function(name,len,ply)
	
	local index = net.readUInt(16)
	if CLIENT then ply = nil end
	
	if name == "ftrecvdata" then
		gotData(index, ply)
	elseif name == "ftkeepalive" then
		timer.adjust("ftcachetimeout"..index,10,1)
	elseif name == "ftreqdata" then
		timer.adjust("ftcachetimeout"..index,10,1)
		sendData(index, ply)
	end
	
end)

return filetransfer
