-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

if SERVER then
	registerprivilege("game.blastDamage", "Create explosions", "Allows the user to create explosions", { usergroups = { default = 1 } })
	registerprivilege("game.bulletDamage", "Fire bullets", "Allows the user to fire bullets", {})
end

local fireBulletsBurst = SERVER and SF.BurstObject("bullets", "bullets", 40, 40, " bullets fired per second", "Number of bullets that can be fired in a short time")
local fireBulletsDPSBurst = SERVER and SF.BurstObject("bullets_damage", "bullet damage", 100, 100, " bullets damage per second", "Damage per second bullets can deal")

local maxBulletForce = SERVER and CreateConVar("sf_bullets_maxforce", 100, FCVAR_ARCHIVE, "Maximum amount of force a bullet can have", 0)
local maxBulletHull = SERVER and CreateConVar("sf_bullets_maxhull", 10, FCVAR_ARCHIVE, "Maximum hull size a bullet can have", 0)

--- Game functions
-- @name game
-- @class library
-- @libtbl game_library
SF.RegisterLibrary("game")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local game_library = instance.Libraries.game
local ent_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_methods, vec_meta, vwrap, vunwrap = instance.Types.Vector.Methods, instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local vunwrap1, vunwrap2, vunwrap3
instance:AddHook("initialize", function()
	vunwrap1, vunwrap2, vunwrap3 = vec_meta.QuickUnwrap1, vec_meta.QuickUnwrap2, vec_meta.QuickUnwrap3
end)

--- Returns the map name
-- @name game_library.getMap
-- @class function
-- @return string The name of the current map
game_library.getMap = game.GetMap

--- Returns The hostname
-- @name game_library.getHostname
-- @class function
-- @return string The hostname of the server
game_library.getHostname = GetHostName

--- Returns true if the server is on a LAN
-- @return boolean True if the game is a lan game
function game_library.isLan()
	return GetConVar("sv_lan"):GetBool()
end

--- Returns whether or not the current game is single player
-- @name game_library.isSinglePlayer
-- @class function
-- @return boolean True if the game is singleplayer
game_library.isSinglePlayer = game.SinglePlayer

--- Returns whether or not the server is a dedicated server
-- @name game_library.isDedicated
-- @class function
-- @return boolean True if the game is a dedicated server
game_library.isDedicated = game.IsDedicated

--- Returns the maximum player limit
-- @name game_library.getMaxPlayers
-- @class function
-- @return number The max players allowed by the server
game_library.getMaxPlayers = game.MaxPlayers

--- Checks whether the specified game is mounted
-- @name game_library.isMounted
-- @class function
-- @param string str String identifier of the game, eg. 'cstrike'
-- @return boolean True if the game is mounted
game_library.isMounted = IsMounted

--- Returns the game time scale
-- @name game_library.getTimeScale
-- @class function
-- @return number Time scale
game_library.getTimeScale = game.GetTimeScale

--- Returns the expected number of seconds between each gametick
-- @name game_library.getTickInterval
-- @class function
-- @return number Time interval in seconds
game_library.getTickInterval = engine.TickInterval

--- Returns the measured number of seconds between each gametick
-- @name game_library.getRealTickInterval
-- @class function
-- @return number Time interval in seconds
game_library.getRealTickInterval = engine.AbsoluteFrameTime

--- Returns the number of ticks since the game started
-- @name game_library.getTickCount
-- @class function
-- @return number Ticks
game_library.getTickCount = engine.TickCount

--- Returns AmmoData for given id
-- @param number id See https://wiki.facepunch.com/gmod/Default_Ammo_Types
-- @return table AmmoData, see https://wiki.facepunch.com/gmod/Structures/AmmoData
function game_library.getAmmoData(id)
	return game.GetAmmoData(id)
end

--- Returns the real maximum amount of ammo of given ammo ID, regardless of the setting of gmod_maxammo convar
-- @param number id See https://wiki.facepunch.com/gmod/Default_Ammo_Types
-- @return number The maximum amount of reserve ammo a player can hold of this ammo type
function game_library.getAmmoMax(id)
	return game.GetAmmoMax(id)
end

--- Returns the worldspawn entity
-- @return Entity Worldspawn
function game_library.getWorld()
	return ewrap(game.GetWorld())
end

--- Returns a table with keys that are condensed model path names and value identifiers of said paths
-- @shared
-- @return table List of valid playermodels
function game_library.getPlayerModels()
	local ret = {}
	for k, v in pairs(player_manager.AllValidModels()) do
		ret[k] = v
	end
	return ret
end

--- Given a 64bit SteamID will return a STEAM_0: style Steam ID
-- @param string id The 64 bit Steam ID
-- @return string STEAM_0 style Steam ID
function game_library.steamIDFrom64(id)
	return util.SteamIDFrom64(id)
end

--- Given a STEAM_0 style Steam ID will return a 64bit Steam ID
-- @param string id The STEAM_0 style id
-- @return string 64bit Steam ID
function game_library.steamIDTo64(id)
	return util.SteamIDTo64(id)
end

if SERVER then

	--- Applies explosion damage to all entities in the specified radius
	-- @server
	-- @param Vector damageOrigin The center of the explosion
	-- @param number damageRadius The radius in which entities will be damaged (0 - 1500)
	-- @param number damage The amount of damage to be applied
	function game_library.blastDamage(damageOrigin, damageRadius, damage)
		checkpermission(instance, nil, "game.blastDamage")
		util.BlastDamage(instance.entity, instance.player, vunwrap1(damageOrigin), math.Clamp(damageRadius, 0, 1500), damage)
	end

	--- Fires a bullet. Bullet made with this function will not have any tracer, you will have to make them yourself.
	-- @server
	-- @param Vector src The position to fire the bullets from.
	-- @param Vector Dir The fire direction.
	-- @param number? damage The damage dealt by the bullet. Default: (1-100)
	-- @param number? num The amount of bullets to fire. Default: (1-40)
	-- @param number? force The force of the bullets. Default: (0-100)
	-- @param number? distance Maximum distance the bullet can travel.
	-- @param Vector? Spread The spread, only x and y are needed.
	-- @param number? hullSize The hull size of the bullet. Default: (0-10)
	-- @param Entity? ignoreEntity The entity that the bullet will ignore when it will be shot.
	-- @param function? callback Function to be called with attacker, traceResult after the bullet was fired but before the damage is applied (the callback is called even if no damage is applied).
	function game_library.bulletDamage(src, dir, damage, num, force, distance, spread, hullSize, ignoreEntity, cb)
		checkpermission(instance, nil, "game.bulletDamage")
		src = vunwrap1(src)
		dir = vunwrap2(dir)
		if spread ~= nil then spread = vunwrap3(spread) end
		if damage ~= nil then checkluatype(damage, TYPE_NUMBER) damage = math.Clamp(damage, 1, fireBulletsDPSBurst.max) end
		if force ~= nil then checkluatype(force, TYPE_NUMBER) force = math.Clamp(force, 0, maxBulletForce:GetInt()) else force = 0 end
		if distance ~= nil then checkluatype(distance, TYPE_NUMBER) distance = math.Clamp(distance, 0, 56756) end
		if hullSize ~= nil then checkluatype(hullSize, TYPE_NUMBER) hullSize = math.Clamp(hullSize, 0, maxBulletHull:GetInt()) end
		if num ~= nil then checkluatype(num, TYPE_NUMBER) num = math.Clamp(num, 1, fireBulletsBurst.max) end
		if ignoreEntity ~= nil then ignoreEntity = eunwrap(ignoreEntity) end

		local callback

		if cb then
			checkluatype(cb, TYPE_FUNCTION)
			callback = function(attacker, tr, dmginfo)
				instance:runFunction(cb, instance.WrapObject(attacker), SF.StructWrapper(instance, tr, "TraceResult"))
			end
		end

		local BulletInfo = {
			Src = src,
			Dir = dir,
			Attacker = instance.player,
			Damage = damage,
			Force = force,
			Distance = distance,
			Num = num,
			Tracer = 0,
			TracerName = "",
			Spread = spread,
			HullSize = hullSize,
			IgnoreEntity = ignoreEntity,
			Callback = callback,
		}

		fireBulletsBurst:use(instance.player, BulletInfo.Num)
		fireBulletsDPSBurst:use(instance.player, BulletInfo.Damage * BulletInfo.Num)

		instance.entity:FireBullets(BulletInfo)
	end

	--- Return if the given bullets can be fired.
	-- @server
	-- @param number damage The damage dealt by the bullet. (1-100)
	-- @param number num The amount of bullets to fire. (1-5)
	-- @return boolean true if the given bullets can be fired or else false
	function game_library.canFireBullets(damage, num)
		checkluatype(damage, TYPE_NUMBER)
		checkluatype(num, TYPE_NUMBER)
		return (fireBulletsBurst:check(instance.player) >= num and fireBulletsDPSBurst:check(instance.player) >= damage * num)
	end

	--- Return the amount of bullets left to fire
	-- @server
	-- @return number Number of bullets left to fire
	function game_library.bulletsLeft()
		return fireBulletsBurst:check(instance.player)
	end

	--- Return the amount of damage left bullets can deal
	-- @server
	-- @return number Damage left bullets can deal
	function game_library.bulletsDPSLeft()
		return fireBulletsDPSBurst:check(instance.player)
	end

else

	--- Returns if the game has focus or not, i.e. will return false if the game is minimized
	-- @name game_library.hasFocus
	-- @client
	-- @class function
	-- @return boolean True if the game is focused
	game_library.hasFocus = system.HasFocus

	--- Returns the direction and how obstructed the map's sun is or nil if it doesn't exist
	-- @client
	-- @return Vector The direction of the sun
	-- @return number How obstructed the sun is 0 to 1.
	function game_library.getSunInfo()
		local info = util.GetSunInfo()
		if info then return vwrap(info.direction), info.obstruction end
	end

	--- Check whether the skybox is visible from the point specified
	-- @client
	-- @param Vector position The position to check the skybox visibility from
	-- @return boolean Whether the skybox is visible from the position
	function game_library.isSkyboxVisibleFromPoint(position)
		return util.IsSkyboxVisibleFromPoint(vunwrap1(position))
	end

	--- Returns the server's frame time and standard deviation
	-- @name game_library.serverFrameTime
	-- @client
	-- @class function
	-- @return number Server frametime
	-- @return number Server frametime standard deviation
	game_library.serverFrameTime = engine.ServerFrameTime

	--- Returns if the client is currently timing out from the server
	-- @name game_library.isTimingOut
	-- @client
	-- @class function
	-- @return boolean If currently timing out
	-- @return number Time since the connection started to timeout
	game_library.isTimingOut = GetTimeoutInfo

end

end
