-------------------------------------------------------------------------------
-- Find functions
-------------------------------------------------------------------------------

--- Find library. Finds entities in various shapes.
-- @shared
local find_library, _ = SF.Libraries.Register( "find" )

local vunwrap = SF.UnwrapObject

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege( "find", "Find", "Allows the user to access the find library" )
end

local find_cooldown
if SERVER then
	find_cooldown = CreateConVar( "sf_find_cooldown_sv", "0.01", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_DONTRECORD } )
else
	find_cooldown = CreateConVar( "sf_find_cooldown_cl", "0.01", { FCVAR_ARCHIVE, FCVAR_DONTRECORD } )
end

local function updateCooldown ( instance )
	if not instance.data.findcooldown then instance.data.findcooldown = 0 end
	local time = CurTime()
	
	if instance.data.findcooldown > time then return false end
	instance.data.findcooldown = time + find_cooldown:GetFloat()
	return true
end

local function convert ( results, func )
	if func then SF.CheckType( func, "function" ) end
	local wrap = SF.WrapObject
	
	local t = {}
	local count = 1
	for i = 1, #results do
		local e = wrap( results[ i ] )
		if not func or func( e ) then
			t[ count ] = e
			count = count + 1
		end
	end
	return t
end

--- Checks if a find function can be performed
-- @return True if find functions can be used
function find_library.canFind ()
	if not SF.Permissions.check( SF.instance.player, nil, "find" ) then return false end
	local data = SF.instance.data
	if not data.findcooldown then data.findcooldown = 0 end
	return data.findcooldown <= CurTime()
end

--- Finds entities in a box
-- @param min Bottom corner
-- @param max Top corner
-- @param filter Optional function to filter results, arguments: entity
-- @return An array of found entities
function find_library.inBox ( min, max, filter )
	if not SF.Permissions.check( SF.instance.player, nil, "find" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( min, SF.Types[ "Vector" ] )
	SF.CheckType( max, SF.Types[ "Vector" ] )

	local min, max = vunwrap( min ), vunwrap( max )
	
	local instance = SF.instance
	if not updateCooldown( instance ) then SF.throw( "You cannot run a find right now; use 'find_library.canFind()'", 2 ) return end
	
	return convert( ents.FindInBox( min, max ), filter )
end

--- Finds entities in a sphere
-- @param center Center of the sphere
-- @param radius Sphere radius
-- @param filter Optional function to filter results, arguments: entity
-- @return An array of found entities
function find_library.inSphere ( center, radius, filter )
	if not SF.Permissions.check( SF.instance.player, nil, "find" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( center, SF.Types[ "Vector" ] )
	SF.CheckType( radius, "number" )

	local center = vunwrap( center )
	
	local instance = SF.instance
	if not updateCooldown( instance ) then SF.throw( "You cannot run a find right now; use 'find_library.canFind()'", 2 ) end
	
	return convert( ents.FindInSphere( center, radius ), filter )
end

--- Finds entities in a cone
-- @param pos The cone vertex position
-- @param dir The direction to project the cone
-- @param distance The length to project the cone
-- @param radius The angle of the cone
-- @param filter Optional function to filter results, arguments: entity
-- @return An array of found entities
function find_library.inCone ( pos, dir, distance, radius, filter )
	if not SF.Permissions.check( SF.instance.player, nil, "find" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( pos, SF.Types[ "Vector" ] )
	SF.CheckType( dir, SF.Types[ "Vector" ] )
	SF.CheckType( distance, "number" )
	SF.CheckType( radius, "number" )

	local pos, dir = vunwrap( pos ), vunwrap( dir )
	
	local instance = SF.instance
	if not updateCooldown( instance ) then SF.throw( "You cannot run a find right now; use 'find_library.canFind()'", 2 ) end
	
	return convert( ents.FindInCone( pos, dir, distance, radius ), filter )
end

--- Finds entities by class name
-- @param class The class name
-- @param filter Optional function to filter results, arguments: entity
-- @return An array of found entities
function find_library.byClass ( class, filter )
	if not SF.Permissions.check( SF.instance.player, nil, "find" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( class, "string" )
	
	local instance = SF.instance
	if not updateCooldown( instance ) then SF.throw( "You cannot run a find right now; use 'find_library.canFind()'", 2 ) end
	
	return convert( ents.FindByClass( class ), filter )
end

--- Finds entities by model
-- @param model The model file
-- @param filter Optional function to filter results, arguments: entity
-- @return An array of found entities
function find_library.byModel ( model, filter )
	if not SF.Permissions.check( SF.instance.player, nil, "find" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( model, "string" )
	
	local instance = SF.instance
	if not updateCooldown( instance ) then SF.throw( "You cannot run a find right now; use 'find_library.canFind()'", 2 ) end
	
	return convert( ents.FindByModel( model ), filter )
end

--- Finds all players (including bots)
-- @param filter Optional function to filter results, arguments: entity
-- @return An array of found entities
function find_library.allPlayers ( filter )
	if not SF.Permissions.check( SF.instance.player, nil, "find" ) then SF.throw( "Insufficient permissions", 2 ) end
	local instance = SF.instance
	if not updateCooldown( instance ) then SF.throw( "You cannot run a find right now; use 'find_library.canFind()'", 2 ) end
	
	return convert( player.GetAll(), filter )
end

--- Finds all entitites
-- @param filter Optional function to filter results, arguments: entity
-- @return An array of found entities
function find_library.all ( filter )
	if not SF.Permissions.check( SF.instance.player, nil, "find" ) then SF.throw( "Insufficient permissions", 2 ) end
	local instance = SF.instance
	if not updateCooldown( instance ) then SF.throw( "You cannot run a find right now; use 'find_library.canFind()'", 2 ) end
	
	return convert( ents.GetAll(), filter )
end
