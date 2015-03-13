
--- Library for creating and manipulating physics-less models AKA "Props".
-- @shared
local props_library, props_library_metamethods = SF.Libraries.Register("prop")

local vunwrap = SF.UnwrapObject

SF.Props = {}
SF.Props.defaultquota = CreateConVar( "sf_props_defaultquota", "200", {FCVAR_ARCHIVE,FCVAR_REPLICATED},
	"The default number of props allowed to spawn via Starfall scripts across all instances" )

SF.Props.personalquota = CreateConVar( "sf_props_personalquota", "100", {FCVAR_ARCHIVE,FCVAR_REPLICATED},
	"The default number of props allowed to spawn via Starfall scripts for a single instance" )

SF.Props.burstrate = CreateConVar( "sf_props_burstrate", "4", {FCVAR_ARCHIVE,FCVAR_REPLICATED},
	"The default number of props allowed to spawn in a short interval of time via Starfall scripts for a single instance ( burst )" )

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege( "prop.create", "Create prop", "Allows the user to create props" )
end

local insts = {}
local plyCount = {}

SF.Libraries.AddHook("initialize",function(inst)
	inst.data.props = {
		props = {},
		count = 0,
		burst = SF.Props.burstrate:GetInt() or 10
	}

	insts[inst] = true
	plyCount[inst.player] = plyCount[inst.player] or inst.data.props.count
end)

SF.Libraries.AddHook("deinitialize", function(inst)
	local props = inst.data.props.props
	local prop = next(props)
	while prop do
		local propent = SF.Entities.Unwrap(prop)
		if IsValid(propent) then
			propent:Remove()
		end
		props[prop] = nil
		prop = next(props)
	end
	inst.data.props.count = 0

	insts[inst]= nil
end)

local function propOnDestroy(propent, propdata, ply)
	plyCount[ply] = plyCount[ply] - 1
	if not propdata.props then return end
	local prop = SF.Entities.Wrap(propent)
	if propdata.props[prop] then
		propdata.props[prop] = nil
		propdata.count = propdata.count - 1
		assert(propdata.count >= 0)
	end
end


--- Updates/Checks burst constraints
-- @class function
-- @param instance Instance table for the burst values related to current SF Instance / Player
-- @param noupdate False if updating the burst should be done.
local function can_spawn(instance, noupdate)
	if instance.data.props.burst > 0 then
		if not noupdate then instance.data.props.burst = instance.data.props.burst - 1 end
		return true
	else
		return false
	end
end

--- Checks if the total number of props across all instances has reached the max limit.
-- @class function
-- @return True/False depending on if limit has been reached for SF Props
local function max_reached()
	local c = 0
	for _, v in pairs( plyCount ) do
		c = c + v
	end
	if c >= SF.Props.defaultquota:GetInt() then return true else return false end
end

--- Checks if the users personal limit of props has been exhausted
-- @class function
-- @param i Instance to use, this will relate to the player in question
-- @return True/False depending on if the personal limit has been reached for SF Props
local function personal_max_reached( i )
	return plyCount[i.player] >= SF.Props.personalquota:GetInt()
end

timer.Create( "SF_Prop_BurstCounter", 1/4, 0, function()
	for i, _ in pairs( insts ) do
		if i.data.props.burst < SF.Props.burstrate:GetInt() or 10 then -- Should allow for dynamic changing of burst rate from the server.
			i.data.props.burst = i.data.props.burst + 1
		end
	end
end )

--- Creates a prop.
-- @server
-- @return The prop object
function props_library.create ( pos, ang, model, frozen )
	
	if not SF.Permissions.check( SF.instance.player,  nil, "prop.create" ) then SF.throw( "Insufficient permissions", 2 ) end

	SF.CheckType( pos, SF.Types[ "Vector" ] )
	SF.CheckType( ang, SF.Types[ "Angle" ] )
	SF.CheckType( model, "string" )
	frozen = frozen and true or false

	local pos = vunwrap( pos )
	local ang = SF.Angles.Unwrap( ang )

	local instance = SF.instance
	if not can_spawn( instance ) then return SF.throw( "Can't spawn props that often", 2 )
	elseif personal_max_reached( instance ) then return SF.throw( "Can't spawn props, maximum personal limit of " .. SF.Props.personalquota:GetInt() .. " has been reached", 2 )
	elseif max_reached() then return SF.throw( "Can't spawn props, maximum limit of " .. SF.Props.defaultquota:GetInt() .. " has been reached", 2 ) end
	if not IsValid( instance.player ) then return SF.Entities.Wrap( NULL ) end
	if not gamemode.Call( "PlayerSpawnProp", instance.player, model ) then return SF.Entities.Wrap( NULL ) end

	local propdata = instance.data.props
	local propent = ents.Create( "prop_physics" )
	
	propent:CallOnRemove( "starfall_propgram_delete", propOnDestroy, propdata, instance.player )
	propent:SetPos( pos )
	propent:SetAngles( ang )
	propent:SetModel( model )
	propent:Spawn()
	
	for I = 0,  propent:GetPhysicsObjectCount() - 1 do
		local obj = propent:GetPhysicsObjectNum( I )
		if obj:IsValid() then
			obj:EnableMotion(not frozen)
		end
	end
	
	instance.player:AddCleanup( "props", propent )
	
	gamemode.Call( "PlayerSpawnedProp", instance.player, model, propent )
	FixInvalidPhysicsObject( propent )

	local prop = SF.Entities.Wrap( propent )

	propdata.props[ prop ] = prop
	propdata.count = propdata.count + 1

	plyCount[ instance.player ] = plyCount[ instance.player ] + 1
	return prop
end

--- Checks if a user can spawn anymore props.
-- @server
-- @return True if user can spawn props, False if not.
function props_library.canSpawn ()

	if not SF.Permissions.check( SF.instance.player,  nil, "prop.create" ) then return false end
	
	local instance = SF.instance
	return not personal_max_reached( instance ) and not max_reached() and can_spawn( instance, true )
	
end
