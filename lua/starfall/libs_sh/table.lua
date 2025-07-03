
local dgetmeta = debug.getmetatable

--- Lua table library https://wiki.garrysmod.com/page/Category:table
-- @name table
-- @class library
-- @libtbl table_library
SF.RegisterLibrary("table")

return function(instance)

local table_library = instance.Libraries.table

--- Adds the contents from one table into another. The target table will be modified.
-- @class function
-- @param table target The table to insert the new values into
-- @param table source The table to retrieve the values from
-- @return table The target table
table_library.add = table.Add

--- Returns the string address of the table
-- @class function
-- @param table target The target to get the address of
-- @return string The table's string address
function table_library.address(target)
	return string.format("%p",target)
end

--- Changes all keys to sequential integers. This creates a new table object and does not affect the original.
-- @class function
-- @param table tbl The original table to modify
-- @param boolean? saveKeys Optional save the keys within each member table. This will insert a new field __key into each value, and should not be used if the table contains non-table values. Defaults to false
-- @return table Table with integer keys
table_library.clearKeys = table.ClearKeys

--- Collapses a table with keyvalue structure
-- @class function
-- @param table tbl The input table
-- @return table Output table
table_library.collapseKeyValue = table.CollapseKeyValue

--- Concatenates the contents of a table to a string.
-- @class function
-- @param table tbl The table to concatenate
-- @param string? concatenator A seperator to insert between each string. Defaults to ""
-- @param number? startPos Optional key to start at. Defaults to 1
-- @param number? endPos Optional key to end at. Defaults to #tbl
-- @return string Concatenated string
table_library.concat = table.concat

--- Empties the target table, and merges all values from the source table into it.
-- @class function
-- @param table source The table to copy from
-- @param table target The table to write to
table_library.copyFromTo = table.CopyFromTo

--- Counts the amount of keys in a table. This should only be used when a table is not numerically and sequentially indexed, for those table consider # operator
-- @class function
-- @param table tbl The table to count the keys of
-- @return number The number of keyvalue pairs
table_library.count = table.Count

--- Removes all values from a table
-- @class function
-- @param table tbl The table to empty
table_library.empty = table.Empty

--- Inserts a value in to the given table even if the table is non-existent
-- @class function
-- @param table tbl Table to insert value in to. If not supplied, will create a table
-- @param any val Value to insert
-- @return table The supplied or created table
table_library.forceInsert = table.ForceInsert

--- Returns all keys of a table
-- @class function
-- @param table tbl The table to get keys of
-- @return table Table of keys
table_library.getKeys = table.GetKeys

--- Returns a key of the supplied table with the highest number value.
-- @class function
-- @param table tbl The table to search in
-- @return any Winning key
table_library.getWinningKey = table.GetWinningKey

--- Checks if a table has a value. This function is very inefficient for large tables (O(n)).
-- @class function
-- @param table tbl Table to check
-- @param any val Value to search for
-- @return boolean Returns true if the table has that value, false otherwise
table_library.hasValue = table.HasValue
	
--- Checks if a table contains any value.
-- @class function
-- @param table tbl Table to check
-- @return boolean Returns true if the table contains any value, false otherwise
table_library.isEmpty = table.IsEmpty

--- Copies any missing data from base to target, and sets the target's BaseClass member to the base table's pointer.
-- @class function
-- @param table target Table to copy data to
-- @param table base Table to copy data from
-- @return table The target table
table_library.inherit = table.Inherit

--- Inserts a value into a table at the end of the table or at the given position.
-- @class function
-- @param table tbl The table to insert the variable into
-- @param any pos The position in the table to insert the variable. If the third argument is not provided, this argument becomes the value to insert at the end of given table
-- @param any val The variable to insert into the table
-- @return number The index the variable was placed at.
table_library.insert = function(a,b,c) if c~=nil then b = math.Clamp(b, 1, 2^31-1) return table.insert(a,b,c) else return table.insert(a,b) end end

--- Returns whether or not the table's keys are sequential.
-- @class function
-- @param table tbl Table to check
-- @return boolean True if sequential
table_library.isSequential = table.IsSequential

--- Returns the first key found to be containing the supplied value.
-- @class function
-- @param table tbl Table to search
-- @param any val Value to search for
-- @return any Found key
table_library.keyFromValue = table.KeyFromValue

--- Returns a table of keys containing the supplied value.
-- @class function
-- @param table tbl Table to search
-- @param any val Value to search for
-- @return table Table of keys
table_library.keysFromValue = table.KeysFromValue

--- Returns a copy of the input table with all string keys converted to be lowercase recursively.
-- @class function
-- @param table tbl Table to convert
-- @return table New converted table
table_library.lowerKeyNames = table.LowerKeyNames

--- Returns the highest numerical key.
-- @class function
-- @param table tbl The table to search
-- @return number The highest numerical key
table_library.maxn = table.maxn

--- Returns a random value from the supplied table.
-- @class function
-- @param table tbl The table to choose from
-- @return any A random value from the table
-- @return any The key associated with the random value
table_library.random = table.Random

--- Removes a value from a table and shifts any other values down to fill the gap.
-- @class function
-- @param table tbl The table to remove the value from
-- @param number? index Optional index of the value to remove. Defaults to #tbl
-- @return any The value that was removed
table_library.remove = table.remove

--- Removes the first instance of a given value from the specified table with table.remove, then returns the key that the value was found at
-- @class function
-- @param table tbl The table that will be searched
-- @param any val The value to find within the table
-- @return any The key at which the value was found, or false if the value was not found
table_library.removeByValue = table.RemoveByValue

--- Returns a reversed copy of a sequential table. Any non-sequential and non-numeric keyvalue pairs will not be copied
-- @class function
-- @param table tbl Table to reverse
-- @return table A reversed copy of the table
table_library.reverse = table.Reverse

--- Performs an inline Fisher-Yates shuffle on the table in O(n) time
-- @class function
-- @param table tbl Table to shuffle
table_library.shuffle = table.Shuffle

--- Sorts a table either ascending or by the given sort function
-- @class function
-- @param table tbl The table to sort
-- @param function? sorter If specified, the function will be called with 2 parameters each. Return true in this function if you want the first parameter to come first in the sorted array
function table_library.sort(tbl, sorter)
	if debug.getinfo(128) then error("stack overflow") end
	return table.sort(tbl, sorter)
end

--- Returns a list of keys sorted based on values of those keys.
-- @class function
-- @param table tbl Table to sort. All values of this table must be of same type
-- @param boolean? descending Optional, should the order be descending? Defaults to false
table_library.sortByKey = table.SortByKey

--- Sorts a table by a named member.
-- @class function
-- @param table tbl Table to sort
-- @param any member The key used to identify the member
-- @param boolean? ascending Optional, should be ascending? Defaults to false
table_library.sortByMember = table.SortByMember

--- Sorts a table in reverse order from table.sort
-- @class function
-- @param table tbl The table to sort in descending order
-- @return table Sorted table
table_library.sortDesc = table.SortDesc

--- Converts a table into a string
-- @class function
-- @param table tbl The table to iterate over
-- @param string? displayName Optional name for the table
-- @param boolean? niceFormatting Optional, adds new lines and tabs to the string. Defaults to false
table_library.toString = table.ToString

--- Creates a deep copy and returns that copy. This function does NOT copy userdata, such as Vectors and Angles!
-- @class function
-- @param table tbl The table to be copied
-- @return table A deep copy of the original table
function table_library.copy( tbl, lookup_table )
	if ( tbl == nil ) then return nil end

	local meta = dgetmeta( tbl )
	if meta and instance.object_unwrappers[meta] then return tbl end
	local copy = {}
	setmetatable( copy, meta )
	for i, v in pairs( tbl ) do
		if ( not istable( v ) ) then
			copy[ i ] = v
		else
			lookup_table = lookup_table or {}
			lookup_table[ tbl ] = copy
			if ( lookup_table[ v ] ) then
				copy[ i ] = lookup_table[ v ] -- we already copied this table. reuse the copy.
			else
				copy[ i ] = table_library.copy( v, lookup_table ) -- not yet copied. copy it.
			end
		end
	end
	return copy
end

--- Merges the contents of the second table with the content in the first one.
-- @class function
-- @param table dest The table you want the source table to merge with
-- @param table source The table you want to merge with the destination table
-- @return table Destination table
function table_library.merge( dest, source )

	for k, v in pairs( source ) do
		if ( istable( v ) and istable( dest[ k ] ) and not instance.IsSFType( v ) and not instance.IsSFType( dest[ k ] ) ) then
			table_library.merge( dest[ k ], v )
		else
			dest[ k ] = v
		end
	end

	return dest

end

end
