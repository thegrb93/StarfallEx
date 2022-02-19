--@name Coroutine Example
--@author Radon
--@server

-- Some functions for checking our quota usage.
local function checkQ(n)
	return quotaAverage() < quotaMax()*n
end

-- Check if we should yield
local function yieldCheck()
	if not checkQ(0.95) then
		coroutine.yield()
	end
end

-- Create the coroutine
-- The Function here is "Sieve of Eratosthenes" and is used to find Primes up to a given integer.
local erato = coroutine.create(function (n)
	local time = timer.systime()
	if n < 2 then return {} end
	local t = {}
	local sqrtlmt = math.sqrt(n)

	for i = 2, sqrtlmt do
		if not t[i] then
			for j = i * i, n, i do
				-- Because we're in a for loop, best make sure we check to yield.
				yieldCheck()
				t[j] = true
			end
		end
	end

	local primes = {}
	for i = 2, n do
		-- Because we're in a for loop, best make sure we check to yield.
		yieldCheck()
		if not t[i] then
			primes[#primes + 1] = i
		end
	end

	-- Finally we want to return our table of primes we've generated.
	-- Therefore we yield but pass it the table to yield back.
	print((timer.systime() - time) .. " seconds to complete")
	return primes
end)

hook.add("think", "primeNumbers", function ()
	-- If the coroutine hasn't died, then we need to start it or resume it.
	if coroutine.status(erato) ~= "dead" then
		-- Make sure we're sufficiently below quota to resume
		if checkQ(0.8) then
			-- r will be nil until the final yield which gives us our primes.
			-- This will start / resume the coroutine.
			local r = coroutine.resume(erato, 50000)

			-- Therefore we check if it's not nil, and print the highest prime.
			if r then
				print("Highest prime: " .. r[#r])

				-- Since we've finished calculating all our primes, remove our think hook.
				hook.remove("think", "primeNumbers")
			end
		end
	end
end)
