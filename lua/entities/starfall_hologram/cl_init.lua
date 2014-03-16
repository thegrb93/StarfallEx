include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_BOTH

-- Umsgs may be recieved before the entity is initialized, place
-- them in here until initialization.
local msgQueueNames = {}
local msgQueueData = {}

local function msgQueueAdd ( umname, ent, udata )
	local names, data = msgQueueNames[ ent ], msgQueueData[ ent ]
	if not names then
		names, data = {}, {}
		msgQueueNames[ ent ] = names
		msgQueueData[ ent ] = data
	end
	
	local i = #names + 1
	names[ i ] = umname
	data[ i ] = udata
end

local function msgQueueProcess ( ent )
	local entid = ent:EntIndex()
	local names, data = msgQueueNames[ entid ], msgQueueData[ entid ]
	if names then
		for i = 1 , #names do
			local name = names[ i ]
			if name == "scale" then
				ent:SetScale( data[ i ] )
			elseif name == "clip" then
				ent:UpdateClip( unpack( data[ i ] ) )
			end
		end
		
		msgQueueNames[ entid ] = nil
		msgQueueData[ entid ] = nil
	end
end

-- ------------------------ MAIN FUNCTIONS ------------------------ --

function ENT:Initialize()
	self.clips = {}
	self.scale = Vector(1,1,1)
	self.initialised = true
	msgQueueProcess(self)
end

function ENT:setupClip ()
    -- Setup Clipping
    local l = #self.clips
    if l > 0 then
        render.EnableClipping( true )
        for i = 1, l do
            local clip = self.clips[ i ]
            if clip.enabled then
                local norm = clip.normal
                local origin = clip.origin

                if clip.islocal then
                    norm = self:LocalToWorld( norm ) - self:GetPos()
                    origin = self:LocalToWorld( origin )
                end
                render.PushCustomClipPlane( norm, norm:Dot( origin ) )
            end
        end
    end
end

function ENT:finishClip ()
    for i = 1, #self.clips do
        render.PopCustomClipPlane()
    end
    render.EnableClipping( false )
end

function ENT:setupRenderGroup ()
    local alpha = self:GetColor().a

    if alpha == 0 then return end

    if alpha ~= 255 then
        self.RenderGroup = RENDERGROUP_BOTH
    else
        self.RenderGroup = RENDERGROUP_OPAQUE
    end
end

function ENT:Draw()
    self:setupRenderGroup()
    self:setupClip()

	render.SuppressEngineLighting( self:GetNWBool( "suppressEngineLighting" ) )
	self:DrawModel()
	render.SuppressEngineLighting( false )

    self:finishClip()
end

-- ------------------------ CLIPPING ------------------------ --

--- Updates a clip plane definition.
function ENT:UpdateClip(index, enabled, origin, normal, islocal)
	local clip = self.clips[index]
	if not clip then
		clip = {}
		self.clips[index] = clip
	end
	
	clip.enabled = enabled
	clip.normal = normal
	clip.origin = origin
	clip.islocal = islocal
end

net.Receive("starfall_hologram_clip", function ()
	local entid = net.ReadUInt( 32 )
	local holoent = Entity( entid )
	if ( not IsValid( holoent ) ) or ( not holoent.initialised ) then
		-- Uninitialized
		msgQueueAdd( "clip", entid, {
			net.ReadUInt( 16 ),
			net.ReadBit() ~= 0,
			Vector( net.ReadDouble(), net.ReadDouble(), net.ReadDouble() ),
			Vector( net.ReadDouble(), net.ReadDouble(), net.ReadDouble() ),
			net.ReadBit() ~= 0
		} )
	else
		holoent:UpdateClip (
			net.ReadUInt( 16 ),
			net.ReadBit() ~= 0,
			Vector( net.ReadDouble(), net.ReadDouble(), net.ReadDouble() ),
			Vector( net.ReadDouble(), net.ReadDouble(), net.ReadDouble() ),
			net.ReadBit() ~= 0
		)
	end
end )

-- ------------------------ SCALING ------------------------ --

--- Sets the hologram scale
-- @param scale Vector scale
function ENT:SetScale ( scale )
	self.scale = scale
	local m = Matrix()
	m:Scale( scale )
	self:EnableMatrix( "RenderMultiply", m )

	local propmax = self:OBBMaxs()
	local propmin = self:OBBMins()
	
	propmax.x = scale.x * propmax.x
	propmax.y = scale.y * propmax.y
	propmax.z = scale.z * propmax.z
	propmin.x = scale.x * propmin.x
	propmin.y = scale.y * propmin.y
	propmin.z = scale.z * propmin.z
	
	self:SetRenderBounds( propmax, propmin )
end

net.Receive("starfall_hologram_scale", function ()
	local entid = net.ReadUInt( 32 )
	local holoent = Entity( entid )
	if ( not IsValid ( holoent ) ) or ( not holoent.initialised ) then
		-- Uninitialized
		msgQueueAdd( "scale", entid, Vector(net.ReadDouble(), net.ReadDouble(), net.ReadDouble()) )
	else
		holoent:SetScale( Vector( net.ReadDouble(), net.ReadDouble(), net.ReadDouble() ) )
	end
end )
