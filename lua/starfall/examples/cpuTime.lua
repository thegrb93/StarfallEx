--@name cpuTime Example
--@author INP - Radon

if CLIENT then return end

-- This function helps us check if we can run.
-- Use a mixture of quotaUsed() and quotaAverage()
-- quotaUsed() returns the value of the current buffer.
-- quotaAverage() gives the cpuTime average across the whole buffer.
-- You chip will quota if quotaAverage() > quotaMax()
-- n is a parameter between 0 and 1 that represents the percent. 0.8 = 80%.
local function quotaCheck ( n )
	return ( quotaUsed() < quotaMax() * n ) and ( quotaAverage() < quotaMax() )
end

-- Standard think hook, see hook example for this.
hook.add( "think", "", function ()
	-- Simple incrementer inside a while loop
	local i = 0
	while( quotaCheck( 0.95 ) ) do
		-- We'll increment until we reach 95%
		i = i + 1
	end
	-- Then print the final counter, this is how many times the while loop executed this think
	print( i )
end )
