if not SF.Require("gthread") then return function() end end

local STL = function()
	local bInThread = false
	if not FindMetaTable then
		bInThread = true
		FindMetaTable = function( sName ) return debug.getregistry()[sName] end
	end
	
	local FUNCS = {}
	
	do
		local TYPE_NIL = 0
		local TYPE_BOOL = 1
		local TYPE_NUMBER = 3
		local TYPE_STRING = 4
		local TYPE_TABLE = 5
		local TYPE_FUNCTION = 6
		
		local tFunc = {
			[TYPE_NIL     ] = { "WriteNil"     , "ReadNil"      },
			[TYPE_BOOL    ] = { "WriteBool"    , "ReadBool"     },
			[TYPE_NUMBER  ] = { "WriteDouble"  , "ReadDouble"   },
			[TYPE_STRING  ] = { "WriteString"  , "ReadString"   },
			[TYPE_TABLE   ] = { "WriteTable"   , "ReadTable"    },
			[TYPE_FUNCTION] = { "WriteFunction", "ReadFunction" }
		}
		
		local tTypes = {
			["nil"     ] = TYPE_NIL,
			["boolean" ] = TYPE_BOOL,
			["number"  ] = TYPE_NUMBER,
			["string"  ] = TYPE_STRING,
			["table"   ] = TYPE_TABLE,
			["function"] = TYPE_FUNCTION,
		}
		
		function FUNCS:WriteType( any )
			local t = tTypes[type(any)]
			if not t then return 0 end
			return self:WriteUByte(t) + self[tFunc[t][1]]( self, any )
		end
		
		function FUNCS:ReadType()
			local f = tFunc[self:ReadUByte()]
			if not f then return end
			return self[f[2]]( self )
		end
		
		function FUNCS:WriteTable( tTbl )
			local nTotal = 0
			for k, v in pairs( tTbl ) do
				nTotal = nTotal + self:WriteType( k ) + self:WriteType( v )
			end
			return nTotal + self:WriteType( nil )
		end
		
		function FUNCS:ReadTable()
			local tTbl = {}
			local k = self:ReadType()
			while k do
				local v = self:ReadType()
				tTbl[k] = v
				k = self:ReadType()
			end
			return tTbl
		end
		
		function FUNCS:WriteNil() return 0 end
		function FUNCS:ReadNil() return end
		
		function FUNCS:WriteBool( v ) return self:WriteUByte( v and 1 or 0 ) end
		function FUNCS:ReadBool() return self:ReadUByte() ~= 0 end
	end
	
	do
		local function writevarargs( self, n, v, ... )
			if not v then return 0 end
			return writevarargs( self, n + self:WriteType( v ), ... ) 
		end
		
		function FUNCS:WriteVarargs( ... )
			return writevarargs( self, self:WriteUShort( select( "#", ... ) ), ... )
		end
		
		local function readvarags( self, n )
			if n <= 0 then return end
			return self:ReadType(), readvarags( self, n - 1 )
		end
		
		function FUNCS:ReadVarargs()
			return readvarags( self, self:ReadUShort() )
		end
	end

	local CHANNL = FindMetaTable( "GThreadChannel" )
	local PACKET = FindMetaTable( "GThreadPacket" )
	
	for name, func in pairs( FUNCS ) do
		CHANNL[name] = func
		PACKET[name] = func
	end
	
	if timer then 
		local channels = setmetatable( {}, { __mode = "k" } )

		function CHANNL:Receive( func )
			channels[self] = func
		end

		timer.Create("threading_channels", 0, 0, function()
			for chan, func in pairs( channels ) do
				local bytes, tag = chan:PullPacket()
				if bytes then
					func( bytes, tag )
				end
			end
		end)
	else
		local ENGINE = FindMetaTable( "engine" )
		function CHANNL:Wait( ... )
			self:SetFilter( ... )
			local hnd, bytes, tag = self:GetHandle(), 0, 0
			if coroutine.running() then
				hnd, bytes, tag = coroutine.yield( hnd )
			else
				hnd, bytes, tag = engine:Block( hnd )
			end
			return bytes, tag
		end
		
		function ENGINE:Sleep( ms )
			local hnd = self:CreateTimer( ms )
			if coroutine.running() then
				coroutine.yield( hnd )
			else
				engine:Block( hnd )
			end
		end
	end
end

STL()

--- GThread library.
-- @name gthread
-- @class library
-- @libtbl gthread_library
SF.RegisterLibrary("gthread")

return function(instance)
if not instance.player:IsSuperAdmin() then return end

local gthread_library = instance.Libraries.gthread

function gthread_library.newThread()
	local th = gthread.newThread( gthread.CONTEXTTYPE_ISOLATED )
	th:Run(STL)
	return th
end

gthread_library.newChannel  = gthread.newChannel
gthread_library.newPacket   = gthread.newPacket
gthread_library.getDetached = gthread.getDetached
gthread_library.Version     = gthread.Version

gthread_library.HEAD_W = gthread.HEAD_W
gthread_library.HEAD_R = gthread.HEAD_R

gthread_library.LOC_START = gthread.LOC_START
gthread_library.LOC_CUR   = gthread.LOC_CUR
gthread_library.LOC_END   = gthread.LOC_END

end
