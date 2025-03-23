-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

-- Register privileges
-- 3 = no one, 2 = anyone, 1 = admin
registerprivilege("navmesh.generate", "Begin generation", "Allows the user to generate a navmesh for the map. This process is highly resource intensive and not wise to use during normal gameplay", { usergroups = { default = 3 } })
registerprivilege("navmesh.reset", "Reset navmesh", "Allows the user to reset the map navmesh. You shouldn't enable this.", { usergroups = { default = 3 } })
registerprivilege("navmesh.load", "Load navmesh", "Allows the user to load and discard changes on the current map navmesh. You shouldn't enable this.", { usergroups = { default = 3 } })
registerprivilege("navmesh.save", "Reset navmesh", "Allows the user to save the map navmesh. You shouldn't enable this.", { usergroups = { default = 3 } })

registerprivilege("navmesh.modify", "Modify navmesh", "Allows the user to modify the map navmesh before generation", { usergroups = { default = 3 } })

registerprivilege("navarea.create", "Create NavArea", "Allows the user to create a CNavArea", { usergroups = { default = 2 } })
registerprivilege("navarea.openlist", "Modify NavArea Openlist", "Allows the user to modify the global navarea openlist", { usergroups = { default = 1 } })

--- Library for navmesh navigation with the NavArea type
-- @name navmesh
-- @class library
-- @libtbl navmesh_library
SF.RegisterLibrary("navmesh")

--- NavArea type, returned by navmesh library functions
-- @name NavArea
-- @class type
-- @libtbl navarea_methods
-- @libtbl navarea_meta
SF.RegisterType("NavArea", true, false, nil, "LockedNavArea")
SF.RegisterType("LockedNavArea", true, false) -- NavArea that can't be modified.

local entList = SF.EntManager("navareas", "navareas", 40, "The number of CNavAreas allowed to spawn via Starfall", 1, true)

return function(instance)
	local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

	local navmesh_library = instance.Libraries.navmesh
	local navarea_methods, navarea_meta, navwrap, navunwrap = instance.Types.NavArea.Methods, instance.Types.NavArea, instance.Types.NavArea.Wrap, instance.Types.NavArea.Unwrap
	local lnavarea_methods, lnavarea_meta, lnavwrap, lnavunwrap = instance.Types.LockedNavArea.Methods, instance.Types.LockedNavArea, instance.Types.LockedNavArea.Wrap, instance.Types.LockedNavArea.Unwrap

	local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
	local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
	local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
	local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
	local cunwrap = instance.Types.Color.Unwrap


	local getent
	local vunwrap1, vunwrap2
	instance:AddHook("initialize", function()
		getent = instance.Types.Entity.GetEntity
		vunwrap1, vunwrap2 = vec_meta.QuickUnwrap1, vec_meta.QuickUnwrap2
	end)

	instance:AddHook("deinitialize", function()
		entList:deinitialize(instance, true)
	end)

	function lnavarea_meta:__tostring()
		return "NavArea"
	end

	--- Starts the generation of a new navmesh
	function navmesh_library.beginGeneration()
		checkpermission(instance, nil, "navmesh.generate")
		navmesh.BeginGeneration()
	end

	--- Whether we're currently generating a new navmesh with navmesh.beginGeneration
	-- @class function
	-- @name navmesh_library.isGenerating
	-- @return boolean Whether we're generating a nav mesh or not.
	navmesh_library.isGenerating = navmesh.IsGenerating

	--- Returns true if a navmesh has been loaded when loading the map.
	-- @class function
	-- @name navmesh_library.isLoaded
	-- @return boolean Whether a navmesh has been loaded when loading the map.
	navmesh_library.isLoaded = navmesh.IsLoaded

	--- Loads a new navmesh from the .nav file for current map discarding any changes made to the navmesh previously.
	-- Requires the 'navmesh.load' privilege
	function navmesh_library.load()
		checkpermission(instance, nil, "navmesh.load")
		navmesh.Load()
	end

	--- Deletes every NavArea and NavLadder on the map without saving the changes.
	-- Requires the 'navmesh.reset' privilege
	function navmesh_library.reset()
		checkpermission(instance, nil, "navmesh.reset")
		navmesh.Reset()
	end

	--- Saves any changes made to navmesh to the .nav file.
	-- Requires the 'navmesh.save' privilege
	function navmesh_library.save()
		checkpermission(instance, nil, "navmesh.save")
		navmesh.Save()
	end

	--- Add this position and normal to the list of walkable positions, used before map generation with navmesh.beginGeneration
	-- Requires the `navmesh.modify` permission
	-- @param Vector pos The terrain position.
	-- @param Vector normal The terrain normal.
	function navmesh_library.addWalkableSeed(pos, dir)
		checkpermission(instance, nil, "navmesh.modify")
		navmesh.AddWalkableSeed( vwrap(pos), vwrap(dir) )
	end

	--- Clears all the walkable positions, used before calling navmesh.beginGeneration.
	-- Requires the `navmesh.modify` permission
	function navmesh_library.clearWalkableSeeds()
		checkpermission(instance, nil, "navmesh.modify")
		navmesh.ClearWalkableSeeds()
	end

	--- Returns the currently marked NavArea, for use with editing console commands.
	-- @return NavArea The currently marked NavArea.
	function navmesh_library.getMarkedArea()
		return lnavwrap( navmesh.GetMarkedArea() )
	end

	--- Returns the classname of the player spawn entity.
	-- @name navmesh_library.getPlayerSpawnName
	-- @class function
	-- @return string The classname of the spawn point entity. By default returns "info_player_start"
	navmesh_library.getPlayerSpawnName = navmesh.GetPlayerSpawnName

	--- Sets the CNavArea as marked, so it can be used with editing console commands.
	-- Requires the `navmesh.modify` permission
	-- @param NavArea area The CNavArea to set as the marked area.
	function navmesh_library.setMarkedArea(area)
		checkpermission(instance, nil, "navmesh.modify")
		navmesh.SetMarkedArea( lnavunwrap(area) )
	end

	--- Sets the classname of the default spawn point entity, used before generating a new navmesh with navmesh.beginGeneration.
	-- @param string spawnPointClass The classname of what the player uses to spawn, automatically adds it to the walkable positions during map generation.
	function navmesh_library.setPlayerSpawnName(spawnPointClass)
		checkluatype(spawnPointClass, TYPE_STRING)
		checkpermission(instance, nil, "navmesh.modify")
		navmesh.SetPlayerSpawnName(spawnPointClass)
	end

	--- Creates a new NavArea
	-- @param Vector corner The first corner of the new NavArea
	-- @param Vector opposite_corner The opposite (diagonally) corner of the new NavArea
	-- @return NavArea? The new NavArea or nil if we failed for some reason
	function navmesh_library.createNavArea(corner, opposite_corner)
		checkpermission(instance, nil, "navarea.create")
		entList:checkuse(instance.player, 1)

		local area = navmesh.CreateNavArea( vunwrap1(corner), vunwrap2(opposite_corner) )
		if area then
			entList:register(instance, area)
			return navwrap(area)
		end
	end

	function navmesh_library.getGroundHeight(pos)
		local height, normal = navmesh.GetGroundHeight( vunwrap1(pos) )
		return height, vwrap(normal)
	end

	--- Returns an integer indexed table of all `NavArea`s on the current map.
	-- If the map doesn't have a navmesh generated then this will return an empty table.
	-- The navareas will be immutable.
	-- @return table A table of all the `NavArea`s on the current map
	function navmesh_library.getAllNavAreas()
		local out = {}
		for idx, navarea in ipairs(navmesh.GetAllNavAreas()) do
			out[idx] = lnavwrap(navarea)
		end
		return out
	end

	--- Returns a bunch of areas within distance, used to find hiding spots by NextBots for example.
	-- @param Vector pos The position to search around
	-- @param number radius Radius to search within (max 100000)
	-- @param number stepdown Maximum fall distance allowed (max 50000)
	-- @param number stepup Maximum jump height allowed (max 50000)
	-- @return table A table of immutable `NavArea`s
	function navmesh_library.find(pos, radius, stepdown, stepup)
		checkluatype(radius, TYPE_NUMBER)
		checkluatype(stepdown, TYPE_NUMBER)
		checkluatype(stepup, TYPE_NUMBER)

		radius = math.Clamp(radius, 0, 100000)
		stepdown = math.Clamp(stepdown, 0, 50000)
		stepup = math.Clamp(stepup, 0, 50000)

		local out = {}
		for idx, navarea in ipairs( navmesh.Find( vunwrap1(pos), radius, stepdown, stepup ) ) do
			out[idx] = lnavwrap(navarea)
		end
		return out
	end

	--- Returns the highest ID of all nav areas on the map.
	-- While this can be used to get all nav areas, this number may not actually be the actual number of nav areas on the map.
	-- @class function
	-- @name navmesh_library.getNavAreaCount
	-- @return number The highest ID of all nav areas on the map.
	navmesh_library.getNavAreaCount = navmesh.GetNavAreaCount

	--- Returns the NavArea at the given id.
	-- @param number id ID of the NavArea to get. Starts with 1.
	-- @return NavArea The NavArea with given ID.
	function navmesh_library.getNavAreaByID(id)
		checkluatype(id, TYPE_NUMBER)
		return lnavwrap( navmesh.GetNavAreaByID(id) )
	end

	--- Returns the NavArea contained in this position that also satisfies the elevation limit.
	-- @param Vector pos The position to search for.
	-- @param number limit The elevation limit at which the NavArea will be searched.
	-- @return NavArea The NavArea.
	function navmesh_library.getNavArea(pos, limit)
		checkluatype(limit, TYPE_NUMBER)
		return lnavwrap( navmesh.GetNavArea( vunwrap1(pos), limit ) )
	end

	--- Returns the closest NavArea to given position at the same height, or beneath it.
	-- This function will ignore blocked NavAreas.
	-- See navmesh.getNavArea for a function that does see blocked areas.
	-- @param Vector pos The position to look from
	-- @param number maxDist Maximum distance from the given position that the function will look for a CNavArea (Default 10000)
	-- @param boolean checkLOS If this is set to true then the function will internally do a trace from the starting position to each potential CNavArea with a MASK_NPCSOLID_BRUSHONLY. If the trace fails then the CNavArea is ignored. If this is set to false then the function will find the closest CNavArea through anything, including the world. (Default false)
	-- @param boolean checkGround If checkGround is true then this function will internally call navmesh.getNavArea to check if there is a CNavArea directly below the position, and return it if so, before checking anywhere else. (Default true)
	-- @return NavArea The closest NavArea found with the given parameters, or a NULL NavArea if one was not found.
	function navmesh_library.getNearestNavArea(pos, maxDist, checkLOS, checkGround)
		return lnavwrap( navmesh.GetNearestNavArea( vunwrap1(pos), nil, maxDist, checkLOS, checkGround ) )
	end

	--- Returns the position of the edit cursor when nav_edit is set to 1.
	-- @return Vector The position of the edit cursor.
	function navmesh_library.getGetEditCursorPosition()
		return vwrap(navmesh.GetEditCursorPosition())
	end

	--- Returns whether this area is in the Open List.
	-- Used in pathfinding via the A* algorithm.
	-- More information can be found here: https://wiki.facepunch.com/gmod/Simple_Pathfinding
	-- @name navarea_methods.isOpen
	-- @return boolean Whether this area is in the Open List.
	function lnavarea_methods:isOpen()
		return lnavunwrap(self):IsOpen()
	end

	--- Returns whether the Open List is empty or not.
	-- Used in pathfinding via the A* algorithm.
	-- More information can be found here: https://wiki.facepunch.com/gmod/Simple_Pathfinding
	-- @name navarea_methods.isOpenListEmpty
	-- @return boolean Whether the Open List is empty or not.
	function lnavarea_methods:isOpenListEmpty()
		return lnavunwrap(self):IsOpenListEmpty()
	end

	--- Returns whether this NavArea is valid or not.
	-- @name navarea_methods.isValid
	-- @return boolean Whether this NavArea is valid or not
	function lnavarea_methods:isValid()
		return lnavunwrap(self):IsValid()
	end

	--- Whether this NavArea is placed underwater.
	-- @name navarea_methods.isUnderwater
	-- @return boolean Whether we're underwater or not.
	function lnavarea_methods:isUnderwater()
		return lnavunwrap(self):IsUnderwater()
	end

	--- Returns true if this NavArea contains the given vector.
	-- @name navarea_methods.contains
	-- @param Vector v The position to check
	-- @return boolean If the vector is inside the area
	function lnavarea_methods:contains(v)
		return lnavunwrap(self):Contains( vunwrap1(v) )
	end

	--- Returns whether this Nav Area is flat within the tolerance of the nav_coplanar_slope_limit_displacement and nav_coplanar_slope_limit convars.
	-- @name navarea_methods.isFlat
	-- @return boolean Whether this NavArea is mostly flat.
	function lnavarea_methods:isFlat()
		return lnavunwrap(self):IsFlat()
	end

	--- Returns whether this NavArea has an outgoing ( one or two way ) connection to given NavArea.
	-- See NavArea:isConnectedAtSide for a function that only checks for outgoing connections in one direction.
	-- @name navarea_methods.isConnected
	-- @param NavArea other The other NavArea to check for connection to.
	-- @return boolean Whether this NavArea has an outgoing ( one or two way ) connection to given NavArea.
	function lnavarea_methods:isConnected(other)
		return lnavunwrap(self):IsConnected( lnavunwrap(other) )
	end

	--- Returns whether this NavArea has an outgoing ( one or two way ) connection to given NavArea in given direction.
	-- @name navarea_methods.isConnectedAtSide
	-- @param NavArea other The other NavArea to check for connection to.
	-- @param number navDirType The direction, in which to look for the connection. See NAV_DIR enums
	-- @return boolean
	function lnavarea_methods:isConnectedAtSide(other, navDirType)
		checkluatype(navDirType, TYPE_NUMBER)
		return lnavunwrap(self):IsConnectedAtSide( lnavunwrap(other), navDirType )
	end

	--- Returns whether this Nav Area is in the same plane as the given one.
	-- @name navarea_methods.isCoplanar
	-- @param NavArea other The other NavArea to check against
	-- @return boolean Whether we're coplanar or not.
	function lnavarea_methods:isCoplanar(other)
		return lnavunwrap(self):IsCoplanar( lnavunwrap(other) )
	end

	--- Returns the NAV_DIR direction that the given vector faces on this NavArea.
	-- @name navarea_methods.computeDirection
	-- @param Vector pos The position to compute direction towards.
	-- @return number The direction the vector is in relation to this NavArea. See NAV_DIR enums
	function lnavarea_methods:computeDirection(pos)
		return lnavunwrap(self):ComputeDirection( vunwrap1(pos) )
	end

	--- Returns the height difference on the Z axis of the two CNavAreas. This is calculated from the center most point on both CNavAreas.
	-- @name navarea_methods.computeGroundHeightChange
	-- @param NavArea other The nav area to test against.
	-- @return number
	function lnavarea_methods:computeGroundHeightChange(other)
		return lnavunwrap(self):ComputeGroundHeightChange( lnavunwrap(other) )
	end

	--- Returns the height difference between the edges of two connected navareas.
	-- @name navarea_methods.computeAdjacentConnectionHeightChange
	-- @param NavArea other The nav area to test against.
	-- @return number The height change
	function lnavarea_methods:computeAdjacentConnectionHeightChange(other)
		return lnavunwrap(self):ComputeAdjacentConnectionHeightChange( lnavunwrap(other) )
	end

	--- Returns a table of all the CNavAreas that have a ( one and two way ) connection from this NavArea.
	-- If an area has a one-way incoming connection to this NavArea, then it will not be returned from this function, use NavArea:getIncomingConnections to get all one-way incoming connections.
	-- See NavArea:getAdjacentAreasAtSide for a function that only returns areas from one side/direction.
	-- @name navarea_methods.getAdjacentAreas
	-- @return table A table of all CNavArea that have a ( one and two way ) connection from this CNavArea.
	function lnavarea_methods:getAdjacentAreas()
		local out = {}
		for k, area in ipairs( lnavunwrap(self):GetAdjacentAreas() ) do
			out[k] = lnavwrap(area)
		end
		return out
	end

	--- Returns a table of all the CNavAreas that have a ( one and two way ) connection from this CNavArea in given direction.
	-- If an area has a one-way incoming connection to this CNavArea, then it will not be returned from this function, use CNavArea:GetIncomingConnections to get all incoming connections.
	-- See CNavArea:getAdjacentAreas for a function that returns all areas from all sides/directions.
	-- @name navarea_methods.getAdjacentAreasAtSide
	-- @param number navDir The direction, in which to look for CNavAreas, see NAV_DIR enums
	-- @return table A table of all CNavArea that have a ( one and two way ) connection from this CNavArea in given direction.
	function lnavarea_methods:getAdjacentAreasAtSide(navDir)
		checkluatype(navDir, TYPE_NUMBER)
		local out = {}
		for k, area in ipairs( lnavunwrap(self):GetAdjacentAreas() ) do
			out[k] = lnavwrap(area)
		end
		return out
	end

	--- Returns the amount of CNavAreas that have a connection ( one and two way ) from this CNavArea.
	-- See CNavArea:GetAdjacentCountAtSide for a function that only returns area count from one side/direction.
	-- @name navarea_methods.getAdjacentCount
	-- @return number The amount of CNavAreas that have a connection ( one and two way ) from this CNavArea.
	function lnavarea_methods:getAdjacentCount()
		return lnavunwrap(self):GetAdjacentCount()
	end

	--- Returns the amount of CNavAreas that have a connection ( one or two way ) from this CNavArea in given direction.
	-- See CNavArea:getAdjacentCount for a function that returns CNavArea count from/in all sides/directions.
	-- @name navarea_methods.getAdjacentCountAtSide
	-- @param number The direction, in which to look for CNavAreas, see NAV_DIR enums.
	-- @return number The amount of CNavAreas that have a connection ( one or two way ) from this CNavArea in given direction.
	function lnavarea_methods:getAdjacentCountAtSide()
		checkluatype(navDir, TYPE_NUMBER)
		return lnavunwrap(self):GetAdjacentCountAtSide(navDir)
	end

	--- Returns the attribute mask for the given CNavArea.
	-- @name navarea_methods.getAttributes
	-- @return number Attribute mask for this CNavArea, see NAV_MESH for the specific flags.
	function lnavarea_methods:getAttributes()
		return lnavunwrap(self):GetAttributes()
	end

	--- Returns the center position of the CNavArea.
	-- @name navarea_methods.getCenter
	-- @return Vector The center vector.
	function lnavarea_methods:getCenter()
		return vwrap( lnavunwrap(self):GetCenter() )
	end

	--- Returns the closest point of this NavArea from the given position.
	-- @name navarea_methods.getClosestPointOnArea
	-- @param Vector pos The given position, can be outside of the NavArea bounds.
	-- @return Vector The closest point on the NavArea.
	function lnavarea_methods:getClosestPointOnArea(pos)
		return vwrap( lnavunwrap(self):GetClosestPointOnArea( vunwrap1(pos) ) )
	end

	--- Returns the vector position of the corner for the given CNavArea.
	-- @name navarea_methods.getCorner
	-- @param number cornerId The target corner to get the position of, takes NAV_CORNER.
	-- @return Vector The vector position of the corner.
	function lnavarea_methods:getCorner(cornerId)
		checkluatype(cornerId, TYPE_NUMBER)
		return vwrap( lnavunwrap(self):GetCorner(cornerId) )
	end

	--- Returns the cost from starting area this area when pathfinding. Set by NavArea:setCostSoFar
	-- @name navarea_methods.getCostSoFar
	-- @return number The cost so far.
	function lnavarea_methods:getCostSoFar()
		return lnavunwrap(self):GetCostSoFar()
	end

	--- Returns a table of very bad hiding spots in this area.
	-- See also NavArea:getHidingSpots
	-- @name navarea_methods.getExposedSpots
	-- @return table A table of Vectors
	function lnavarea_methods:getExposedSpots()
		local out = {}
		for k, spot in ipairs( lnavunwrap(self):GetExposedSpots() ) do
			out[k] = vwrap(spot)
		end
		return out
	end

	--- Returns size info about the nav area.
	-- Vector hi
	-- Vector lo
	-- number SizeX
	-- number SizeY
	-- number SizeZ
	-- @name navarea_methods.getExtentInfo
	-- @return table Struct containing the above keys
	function lnavarea_methods:getExtentInfo()
		return SF.StructWrapper(instance, lnavunwrap(self):GetExtent(), "NavExtentInfo")
	end

	--- Returns this CNavAreas unique ID.
	-- @name navarea_methods.getID
	-- @return number The unique ID.
	function lnavarea_methods:getID()
		return lnavunwrap(self):GetID()
	end

	--- Returns a table of all the CNavAreas that have a one-way connection to this CNavArea.
	-- If a CNavArea has a two-way connection to or from this CNavArea then it will not be returned from this function, use CNavArea:GetAdjacentAreas to get outgoing ( one and two way ) connections.
	-- See CNavArea:getIncomingConnectionsAtSide for a function that returns one-way incoming connections from only one side/direction.
	-- @name navarea_methods.getIncomingConnections
	-- @return table Table of all CNavAreas with one-way connection to this CNavArea.
	function lnavarea_methods:getIncomingConnections()
		local out = {}
		for k, area in ipairs( lnavunwrap(self):GetIncomingConnections() ) do
			out[k] = lnavwrap(area)
		end
		return out
	end

	--- Returns a table of all the CNavAreas that have a one-way connection to this CNavArea from given direction.
	-- If a CNavArea has a two-way connection to or from this CNavArea then it will not be returned from this function, use CNavArea:getAdjacentAreas to get outgoing ( one and two way ) connections.
	-- See CNavArea:getIncomingConnections for a function that returns one-way incoming connections from all sides/directions.
	-- @name navarea_methods.getIncomingConnectionsAtSide
	-- @param number navDir The direction, from which to look for CNavAreas, see NAV_DIR enums.
	-- @return table Table of all CNavAreas with one-way connection to this CNavArea from given direction.
	function lnavarea_methods:getIncomingConnectionsAtSide(navDir)
		checkluatype(navDir, TYPE_NUMBER)

		local out = {}
		for k, area in ipairs( lnavunwrap(self):GetIncomingConnectionsAtSide(navDir) ) do
			out[k] = lnavwrap(area)
		end
		return out
	end

	--- Returns the parent NavArea
	-- @name navarea_methods.getParent
	-- @return NavArea The parent NavArea
	function lnavarea_methods:getParent()
		return lnavwrap( lnavunwrap(self):GetParent() )
	end

	--- Returns how this CNavArea is connected to its parent.
	-- @name navarea_methods.getParentHow
	-- @return number
	function lnavarea_methods:getParentHow()
		return lnavunwrap(self):GetParentHow()
	end

	--- Returns the place of the NavArea
	-- @name navarea_methods.getPlace
	-- @return string The place of the nav area, or no value if it doesn't have a place set.
	function lnavarea_methods:getPlace()
		return lnavunwrap(self):GetPlace()
	end

	--- Returns a random CNavArea that has an outgoing ( one or two way ) connection from this CNavArea in given direction.
	-- @name navarea_methods.getRandomAdjacentAreaAtSide
	-- @param number navDir The direction, from which to look for CNavAreas, see NAV_DIR enums.
	-- @return NavArea The random CNavArea that has an outgoing ( one or two way ) connection from this CNavArea in given direction, if any.
	function lnavarea_methods:getRandomAdjacentAreaAtSide(navDir)
		checkluatype(navDir, TYPE_NUMBER)
		return lnavwrap( lnavunwrap(self):GetRandomAdjacentAreaAtSide(navDir) )
	end

	--- Returns a random point on the nav area.
	-- @name navarea_methods.getRandomPoint
	-- @return Vector The random point on the nav area.
	function lnavarea_methods:getRandomPoint()
		return vwrap( lnavunwrap(self):GetRandomPoint() )
	end

	--- Returns the width this Nav Area.
	-- @name navarea_methods.getSizeX
	-- @return number Width
	function lnavarea_methods:getSizeX()
		return lnavunwrap(self):GetSizeX()
	end

	--- Returns the height this Nav Area.
	-- @name navarea_methods.getSizeY
	-- @return number Height
	function lnavarea_methods:getSizeY()
		return lnavunwrap(self):GetSizeY()
	end

	--- Returns the total cost when passing from starting area to the goal area through this node. Set by NavArea:setTotalCost.
	-- @name navarea_methods.getTotalCost
	-- @return number The total cost
	function lnavarea_methods:getTotalCost()
		return lnavunwrap(self):GetTotalCost()
	end

	--- Returns the elevation of this Nav Area at the given position.
	-- @name navarea_methods.getZ
	-- @param Vector The position to get the elevation from, the z value from this position is ignored and only the X and Y values are used to this task.
	-- @return number Elevation
	function lnavarea_methods:getZ(pos)
		return lnavunwrap(self):GetZ( vunwrap1(pos) )
	end

	--- Returns true if the given CNavArea has this attribute flag set.
	-- @name navarea_methods.hasAttributes
	-- @param number attributes Attribute mask to check for, see NAV_MESH enums
	-- @return boolean True if the CNavArea matches the given mask. False otherwise.
	function lnavarea_methods:hasAttributes(attributes)
		checkluatype(attributes, TYPE_NUMBER)
		return lnavunwrap(self):HasAttributes(attributes)
	end

	--- Returns whether the nav area is blocked or not, i.e. whether it can be walked through or not.
	-- @name navarea_methods.isBlocked
	-- @param number? teamID The team ID to test, -2 = any team. Only 2 actual teams are available, 0 and 1. (Default -2)
	-- @param boolean? ignoreNavBlockers Whether to ignore func_nav_blocker entities. (Default false)
	-- @return boolean Whether the area is blocked or not
	function lnavarea_methods:isBlocked(teamID, ignoreNavBlockers)
		checkluatype(teamID, TYPE_NUMBER)
		checkluatype(ignoreNavBlockers, TYPE_BOOLEAN)

		return lnavunwrap(self):IsBlocked(teamID, ignoreNavBlockers)
	end

	--- Returns whether this node is in the Closed List.
	-- @name navarea_methods.isClosed
	-- @return boolean Whether this node is in the Closed List.
	function lnavarea_methods:isClosed()
		return lnavunwrap(self):IsClosed()
	end

	--- Returns whether this CNavArea can completely (i.e. all corners of this area can see all corners of the given area) see the given CNavArea.
	-- @name navarea_methods.isCompletelyVisible
	-- @param NavArea area The area to test visibility with.
	-- @return boolean Whether this CNavArea can see the given CNavArea.
	function lnavarea_methods:isCompletelyVisible(area)
		return lnavunwrap(self):IsCompletelyVisible( lnavunwrap(area) )
	end

	--- Returns if this position overlaps the NavArea within the given tolerance.
	-- @name navarea_methods.isOverlapping
	-- @param Vector pos The position to test.
	-- @param number? tolerance The tolerance of the overlapping, set to 0 for no tolerance. (Default 0)
	-- @return number Whether the given position overlaps the NavArea or not.
	function lnavarea_methods:isOverlapping(pos, tolerance)
		checkluatype(tolerance, TYPE_NUMBER)

		return lnavunwrap(self):IsOverlapping( vunwrap1(pos), tolerance )
	end

	--- Returns true if this CNavArea is overlapping the given CNavArea.
	-- @name navarea_methods.isOverlappingArea
	-- @param NavArea area The area to test.
	-- @return boolean True if the given CNavArea overlaps this CNavArea at any point.
	function lnavarea_methods:isOverlappingArea(area)
		return lnavunwrap(self):IsOverlappingArea( lnavunwrap(area) )
	end

	--- Returns whether this CNavArea can see given position.
	-- @name navarea_methods.isPartiallyVisible
	-- @param Vector pos The position to test.
	-- @param Entity? ignoreEnt If set, the given entity will be ignored when doing LOS tests (Default NULL)
	-- @return boolean Whether the given position is visible from this area
	function lnavarea_methods:isPartiallyVisible(pos, ignoreEnt)
		return lnavunwrap(self):IsPartiallyVisible( vunwrap1(pos), eunwrap(ignoreEnt) )
	end

	--- Returns whether this CNavArea can potentially see the given CNavArea.
	-- @name navarea_methods.isPotentiallyVisible
	-- @param NavArea area The area to test.
	-- @return boolean Whether the given area is visible from this area
	function lnavarea_methods:isPotentiallyVisible(area)
		return lnavunwrap(self):IsPotentiallyVisible( lnavunwrap(area) )
	end

	--- Returns if we're shaped like a square.
	-- @name navarea_methods.isRoughlySquare
	-- @return boolean If we're a square or not.
	function lnavarea_methods:isRoughlySquare()
		return lnavunwrap(self):IsRoughlySquare()
	end

	--- Returns whether we can be seen from the given position.
	-- @name navarea_methods.isVisible
	-- @param Vector pos The position to check.
	-- @return boolean Whether we can be seen or not.
	-- @return Vector If we can be seen, this is returned with either the center or one of the corners of the Nav Area.
	function lnavarea_methods:isVisible(pos)
		local a, b = lnavunwrap(self):IsVisible( vunwrap1(pos) )
		return a, vwrap(b)
	end

	--- Drops a corner or all corners of a CNavArea to the ground below it.
	-- @param number corner The corner(s) to drop, uses NAV_CORNER enums
	function navarea_methods:placeOnGround(corner)
		checkluatype(corner, TYPE_NUMBER)
		return lnavunwrap(self):PlaceOnGround(corner)
	end

	--- Removes a CNavArea from the Open List with the lowest cost to traverse to from the starting node, and returns it.
	-- Requires the `navarea.openlist` permission
	-- @return NavArea The CNavArea from the Open List with the lowest cost to traverse to from the starting node.
	function navarea_methods:popOpenList()
		checkpermission(instance, nil, "navarea.openlist")

		return lnavwrap( lnavunwrap(self):PopOpenList() )
	end

	--- Removes the given NavArea.
	function navarea_methods:remove()
		local nav = navunwrap(self)
		entList:remove(nav)
		navarea_meta.sf2sensitive[self] = nil
		navarea_meta.sensitive2sf[nav] = nil
	end

	--- Removes the given NavArea from the Closed List
	function navarea_methods:removeFromClosedList()
		navunwrap(self):Remove()
	end

	--- Sets the attributes for given CNavArea.
	-- @param number attributes The attribute bitflag. See NAV_MESH enums
	function navarea_methods:setAttributes(attributes)
		checkluatype(attributes, TYPE_NUMBER)
		navunwrap(self):SetAttributes(attributes)
	end

	--- Sets the position of a corner of a nav area.
	-- @param number corner The corner to set, uses NAV_CORNER enums
	-- @param Vector pos The new position to set.
	function navarea_methods:setCorner(corner, pos)
		checkluatype(corner, TYPE_NUMBER)
		navunwrap(self):SetCorner(corner, vunwrap1(pos))
	end

	--- Sets the cost from starting area this area when pathfinding.
	-- @param number cost The cost so far
	function navarea_methods:setCostSoFar(cost)
		checkluatype(cost, TYPE_NUMBER)
		navunwrap(self):SetCostSoFar(cost)
	end

	--- Sets the new parent of this CNavArea.
	-- @param NavArea parent The new parent to set
	-- @param number how How we get from parent to us using NAV_TRAVERSE_TYPE
	function navarea_methods:setParent(parent, how)
		checkluatype(how, TYPE_NUMBER)
		navunwrap(self):SetParent( navunwrap(parent), how )
	end

	--- Sets the Place of the nav area.
	-- There is a limit of 256 Places per nav file
	-- @param string? place Place to set. Leave as nil to remove place from NavArea
	-- @return boolean True if operation succeeded, false otherwise.
	function navarea_methods:setPlace(place)
		return navunwrap(self):SetPlace(place or '')
	end

	--- Sets the total cost when passing from starting area to the goal area through this node.
	-- @param number cost The total cost of the path to set. (>= 0)
	function navarea_methods:setTotalCost(cost)
		checkluatype(cost, TYPE_NUMBER)
		navunwrap(self):SetTotalCost( math.max(0, cost) )
	end

	--- Moves this open list to appropriate position based on its CNavArea:getTotalCost compared to the total cost of other areas in the open list.
	function navarea_methods:updateOnOpenList()
		navunwrap(self):UpdateOnOpenList()
	end

	--- Disconnects this nav area from given area or ladder. (Only disconnects one way)
	-- @name navarea_methods.disconnect
	-- @param NavArea other The other NavArea to disconnect from.
	function navarea_methods:disconnect(other)
		navunwrap(self):Disconnect( navunwrap(other) )
	end

	--- Adds a hiding spot onto this nav area.
	-- There's a limit of 255 hiding spots per area.
	-- 0 = None (not recommended)
	-- 1 = In Cover/basically a hiding spot, in a corner with good hard cover nearby
	-- 2 = good sniper spot, had at least one decent sniping corridor
	-- 4 = perfect sniper spot, can see either very far, or a large area, or both
	-- 8 = exposed, spot in the open, usually on a ledge or cliff
	-- Values over 255 will be clamped.
	-- @param Vector pos The position of the hiding spot on the nav area
	-- @param number flags Flags describing what kind of hiding spot this is.
	function navarea_methods:addHidingSpot(pos, flags)
		checkluatype(flags, TYPE_NUMBER)
		navunwrap(self):AddHidingSpot( vunwrap1(pos), flags )
	end

	--- Adds this CNavArea to the closed list, a list of areas that have been checked by A* pathfinding algorithm.
	function navarea_methods:addToClosedList()
		navunwrap(self):AddToClosedList()
	end

	--- Adds this CNavArea to the Open List.
	-- Requires `navarea.openlist` permission
	function navarea_methods:addToOpenList()
		checkpermission(instance, nil, "navarea.openlist")
		navunwrap(self):AddToOpenList()
	end

	--- Clears the open and closed lists for a new search.
	function navarea_methods:clearSearchLists()
		navunwrap(self):ClearSearchLists()
	end

	--- Connects this CNavArea to another CNavArea with a one way connection. ( From this area to the target )
	-- @param NavArea other The CNavArea this area leads to.
	function navarea_methods:connectTo(other)
		navunwrap(self):ConnectTo( navunwrap(other) )
	end
end
