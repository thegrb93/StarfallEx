
--- Library for creating and manipulating physics-less models AKA "Holograms".
-- @shared
local holograms_library, holograms_library_metamethods = SF.Libraries.Register("holograms")

--- Hologram type
local hologram_methods, hologram_metamethods = SF.Typedef("Hologram", SF.Entities.Metatable)

SF.Holograms = {}
SF.Holograms.defaultquota = CreateConVar( "sf_holograms_defaultquota", "7200", {FCVAR_ARCHIVE,FCVAR_REPLICATED},
	"The default number of holograms allowed to spawn via Starfall scripts across all instances" )

SF.Holograms.personalquota = CreateConVar( "sf_holograms_personalquota", "300", {FCVAR_ARCHIVE,FCVAR_REPLICATED},
	"The default number of holograms allowed to spawn via Starfall scripts for a single instance" )

SF.Holograms.burstrate = CreateConVar( "sf_holograms_burstrate", "10", {FCVAR_ARCHIVE,FCVAR_REPLICATED},
    "The default number of holograms allowed to spawn in a short interval of time via Starfall scripts for a single instance ( burst )" )

SF.Holograms.Methods = hologram_methods
SF.Holograms.Metatable = hologram_metamethods

local dsetmeta = debug.setmetatable
local old_ent_wrap = SF.Entities.Wrap
function SF.Entities.Wrap(obj)
	local w = old_ent_wrap(obj)
	if IsValid(obj) and obj:IsValid() and obj:GetClass() == "starfall_hologram" then
		dsetmeta(w, hologram_metamethods)
	end
	return w
end

local insts = {}
local plyCount = {}

SF.Libraries.AddHook("initialize",function(inst)
	inst.data.holograms = {
		holos = {},
		count = 0,
		burst = SF.Holograms.burstrate:GetInt() or 10
	}

	insts[inst] = true
	plyCount[inst.player] = plyCount[inst.player] or inst.data.holograms.count
end)

SF.Libraries.AddHook("deinitialize", function(inst)
	local holos = inst.data.holograms.holos
	local holo = next(holos)
	while holo do
		local holoent = SF.Entities.Unwrap(holo)
		if IsValid(holoent) then
			holoent:Remove()
		end
		holos[holo] = nil
		holo = next(holos)
	end
	plyCount[inst.player] = plyCount[inst.player] - inst.data.holograms.count
	inst.data.holograms.count = 0

	insts[inst]= nil
end)

local function hologramOnDestroy(holoent, holodata)
	if not holodata.holos then return end
	local holo = SF.Entities.Wrap(holoent)
	if holodata.holos[holo] then
		holodata.holos[holo] = nil
		holodata.count = holodata.count - 1
		assert(holodata.count >= 0)
	end
end

-- ------------------------------------------------------------------------- --

--- Sets the hologram position.
-- @param pos New position
function hologram_methods:setPos(pos)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(pos, "Vector")
	local holo = SF.Entities.Unwrap(self)
	if holo then holo:SetPos(pos) end
end

--- Sets the hologram angle
-- @param ang New angles
function hologram_methods:setAng(ang)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(ang, "Angle")
	local holo = SF.Entities.Unwrap(self)
	if holo then holo:SetAngles(ang) end
end

--- Sets the hologram linear velocity
-- @param vel New velocity
function hologram_methods:setVel(vel)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(vel, "Vector")
	local holo = SF.Entities.Unwrap(self)
	if holo then holo:SetLocalVelocity(vel) end
end

--- Sets the hologram's angular velocity.
-- @param angvel *Vector* angular velocity.
function hologram_methods:setAngVel(angvel)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(angvel, "Angle")
	local holo = SF.Entities.Unwrap(self)
	if holo then holo:SetLocalAngularVelocity(angvel) end
end

--- Parents this hologram to the specified hologram
function hologram_methods:setParent(parent, attachment)
	SF.CheckType(self, hologram_metamethods)
	local child = SF.Entities.Unwrap(self)
	if not child then return end
	
	if parent then
		SF.CheckType(parent, SF.Entities.Metatable)
		local parent = SF.Entities.Unwrap(parent)
		if not parent then return end
		
		-- Prevent cyclic parenting ( = crashes )
		local checkparent = parent
		repeat
			if checkparent == child then return end
			checkparent = checkparent:GetParent()
		until not IsValid(checkparent)
		
		child:SetParent(parent)
		
		if attachment then
			SF.CheckType(attachment, "string")
			child:Fire("SetParentAttachmentMaintainOffset", attachment, 0.01)
		end
	else
		child:SetParent(nil)
	end
end

--- Sets the hologram scale
-- @param scale New scale
function hologram_methods:setScale(scale)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(scale, "Vector")
	local holo = SF.Entities.Unwrap(self)
	if holo then
		holo:SetScale(scale)
	end
end

--- Updates a clip plane
function hologram_methods:setClip(index, enabled, origin, normal, islocal)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(index, "number")
	SF.CheckType(enabled, "boolean")
	SF.CheckType(origin, "Vector")
	SF.CheckType(normal, "Vector")
	SF.CheckType(islocal, "boolean")
	
	local holo = SF.Entities.Unwrap(self)
	if holo then
		holo:UpdateClip(index, enabled, origin, normal, islocal)
	end
end

--- Returns a table of flexname -> flexid pairs for use in flex functions.
-- These IDs become invalid when the hologram's model changes.
function hologram_methods:getFlexes()
	SF.CheckType(self, hologram_metamethods)
	local holoent = SF.Entities.Unwrap(self)
	local flexes = {}
	for i=0,holoent:GetFlexNum()-1 do
		flexes[holoent:GetFlexName(i)] = i
	end
	return flexes
end

--- Sets the weight (value) of a flex.
function hologram_methods:setFlexWeight(flexid, weight)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(flexid, "number")
	SF.CheckType(weight, "number")
	flexid = math.floor(flexid)
	if flexid < 0 or flexid >= holoent:GetFlexNum() then
		SF.throw( "Invalid flex: "..flexid, 2 )
	end
	local holoent = SF.Entities.Unwrap(self)
	if IsValid(holoent) then
		holoent:SetFlexWeight(self, weight)
	end
end

--- Sets the scale of all flexes of a hologram
function hologram_methods:setFlexScale(scale)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(scale, "number")
	local holoent = SF.Entities.Unwrap(self)
	if IsValid(holoent) then
		holoent:SetFlexScale(scale)
	end
end


--- Deletes the hologram
-- @server
function hologram_methods:remove()
    SF.CheckType(self, hologram_metamethods)
    local holoent = SF.Entities.Unwrap(self)
    if IsValid(holoent) then
        holoent:Remove()
    end
end

--- Sets the color ( and alpha ) of a hologram
-- @server
-- @class function
-- @param color Color object to set the hologram to
function hologram_methods:setColor( color )
    SF.CheckType( color, SF.Types[ "Color" ] )

    local this = SF.Entities.Unwrap( self )
    if IsValid( this ) then
        this:SetColor( color )
        this:SetRenderMode( this:GetColor().a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA )
    end
end

--- Suppress Engine Lighting of a hologram. Disabled by default.
-- @server
-- @class function
-- @param enable Boolean to represent if shading should be set or not.
function hologram_methods:suppressEngineLighting ( suppress )
    SF.CheckType( suppress, "boolean" )

    local this = SF.Entities.Unwrap( self )
    if IsValid( this ) then
        this:SetNetworkedBool( "suppressEngineLighting", suppress )
    end
end


--- Updates/Checks burst constraints
-- @class function
-- @param instance Instance table for the burst values related to current SF Instance / Player
-- @param noupdate False if updating the burst should be done.
local function can_spawn(instance, noupdate)
    if instance.data.holograms.burst > 0 then
        if not noupdate then instance.data.holograms.burst = instance.data.holograms.burst - 1 end
        return true
    else
        return false
    end
end

--- Checks if the total number of holograms across all instances has reached the max limit.
-- @class function
-- @return True/False depending on if limit has been reached for SF Holograms
local function max_reached()
    local c = 0
    for _, v in pairs( plyCount ) do
        c = c + v
    end
    if c >= SF.Holograms.defaultquota:GetInt() then return true else return false end
end

--- Checks if the users personal limit of holograms has been exhausted
-- @class function
-- @param i Instance to use, this will relate to the player in question
-- @return True/False depending on if the personal limit has been reached for SF Holograms
local function personal_max_reached( i )
    return plyCount[i.player] >= SF.Holograms.personalquota:GetInt()
end

timer.Create( "SF_Hologram_BurstCounter", 1/4, 0, function()
    for i, _ in pairs( insts ) do
        if i.data.holograms.burst < SF.Holograms.burstrate:GetInt() or 10 then -- Should allow for dynamic changing of burst rate from the server.
            i.data.holograms.burst = i.data.holograms.burst + 1
        end
    end
end )

--- Creates a hologram.
-- @server
-- @return The hologram object
function holograms_library.create( pos, ang, model, scale )
    SF.CheckType( pos, "Vector" )
    SF.CheckType( ang, "Angle" )
    SF.CheckType( model, "string" )
    if scale then SF.CheckType( scale, "Vector" ) end

    local instance = SF.instance
    if not can_spawn( instance ) then return SF.throw( "Can't spawn holograms that often", 2 )
    elseif personal_max_reached( instance ) then return SF.throw( "Can't spawn holograms, maximum personal limit of " .. SF.Holograms.personalquota:GetInt() .. " has been reached", 2 )
    elseif max_reached() then return SF.throw( "Can't spawn holograms, maximum limit of " .. SF.Holograms.defaultquota:GetInt() .. " has been reached", 2 ) end

    local holodata = instance.data.holograms
    local holoent = ents.Create( "starfall_hologram" )
    if holoent and holoent:IsValid() then
        holoent:SetPos( pos )
        holoent:SetAngles( ang )
        holoent:SetModel( model )
        holoent:CallOnRemove( "starfall_hologram_delete", hologramOnDestroy, holodata )
        holoent:Spawn()

        if scale then
            holoent:SetScale( scale )
        end

        local holo = SF.Entities.Wrap( holoent )

        holodata.holos[ holo ] = holo
        holodata.count = holodata.count + 1

        plyCount[ instance.player ] = plyCount[ instance.player ] + 1
        return holo
        -- TODO: Need to fire a umsg here to assign clientside ownership(?)
    end
end

--- Checks if a user can spawn anymore holograms.
-- @server
-- @return True if user can spawn holograms, False if not.
function holograms_library.canSpawn()
    local instance = SF.instance
    return not personal_max_reached( instance ) and not max_reached() and can_spawn( instance, true )
end
