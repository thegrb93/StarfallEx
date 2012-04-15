---------------------------------------------------------------------
-- SF callback class.
-- @author Daranable
---------------------------------------------------------------------

-- Initialize the class, and set it's __index value to itself.
local P, P_meta = SF.Typedef("Callback")
P_meta.__newindex = function()
	return
end

-- Store the class on starfall global table.
SF.Callback = {}

---------------------------------------------------------------------
-- Methods
---------------------------------------------------------------------

--- Adds a listener to the callback object's storage
-- @param func the callback function that will be called when data is returned
function P:addListener( func )
	self.listeners[func] = func
end

--- Removes a listener from the callback object's storage
-- @param func the function you want to remove from listening
function P:removeListener( func )
	self.listeners[func] = nil
end

--- Calls all of the stored listeners, passing them the data you pass
-- @params ... data
-- @return if any function errors, returns the error message
function P:dispatch( ... )
	local error = nil
	for _, listener in pairs(self.listeners) do
		error = pcall( listener, ... )
	end
	
	return error
end

---------------------------------------------------------------------
-- Constructor
---------------------------------------------------------------------
function SF.Callback.new()
	local table = {}
	table.listeners = {}
	setmetatable( table, P_meta )
	
	
end