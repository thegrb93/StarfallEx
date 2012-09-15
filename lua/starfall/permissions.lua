---------------------------------------------------------------------
-- SF Permissions management
---------------------------------------------------------------------

-- TODO: Client version

--- Permission format
-- @name Permission
-- @class table
-- @field name The name of the permission
-- @field desc The description of the permission.
-- @field level The abusability of the permission. 0 = low (print to console),
--                1 = normal (modify entities), 2 = high (run arbitrary lua)
-- @field value Boolean. True to allow, false to deny

SF.Permissions = {}
SF.Permissions.__index = SF.Permissions

SF.Permissions.permissions = {}

--- Called to assign the permissions manager to an Instance. The default implementation sets
-- self.instance to the passed argument.
function SF.Permissions:assign(instance)
	self.instance = instance
end

--- Requests a set of permissions. The default implementation of this does nothing, but implementors
-- can use this to change the permissions of a script dynamically
-- @param permissions A list of permission names to request
function SF.Permissions:requestPermissions(permissions)
	-- Nothing
end

--- Creates a new permission
-- @param tbl The permission data to register
function SF.Permissions:registerPermission(tbl)
	self.permissions[tbl.name] = tbl
end

--- Returns data about a permission
-- @param name The name of the permission
-- @return The permission data table
function SF.Permissions:getPermissionData(name)
	return self.permissions[name]
end

--- Checks a permission
-- @param name The permission name
-- @return True to allow
function SF.Permissions:checkPermission(name)
	return self.permissions[name].value
end
