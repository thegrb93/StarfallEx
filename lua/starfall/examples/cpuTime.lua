--@name cpuTime Example
--@author INP - Radon
--@server

-- This function helps us check if we can run.
-- Use a mixture of quotaUsed() and quotaAverage()
-- quotaUsed() returns the value of the current buffer.
-- quotaAverage() gives the cpuTime average across the whole buffer.
-- Your chip will throw an error if quotaAverage() > quotaMax()
-- n is a parameter between 0 and 1 that represents the percent. 0.8 = 80%.
local function quotaCheck(n)
	return math.max(quotaAverage(), quotaUsed()) < quotaMax()*n
end

-- Standard think hook.
hook.add("think", "", function ()
	-- Simple incrementer inside a while loop
	local i = 0
	while(quotaCheck(0.95)) do
		-- We'll increment until we reach 95%
		i = i + 1
	end
	-- Then print the final counter, this is how many times the while loop executed this think
	print(i)
end)
