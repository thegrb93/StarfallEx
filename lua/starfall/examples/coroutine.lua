--@name Coroutine Example
--@author Radon

if not SERVER then return end

-- Some functions for checking our quota usage.
local function checkQ (n)
	return math.max(quotaUsed(),quotaAverage()) < quotaMax() * n
end

-- Check if we should yield
local function yieldCheck ()
	if not checkQ(0.95) then
		coroutine.yield()
	end
end

-- Create the coroutine
-- The Function here is "Sieve of Eratosthenes" and is used to find Primes up to a given integer.
local erato = coroutine.create(function (n)

		local time = timer.systime()
		if n < 2 then return {} end
		local t = { 0 } -- clears '1'
		local sqrtlmt = math.sqrt(n)

		for i = 2, n do
			-- Because we're in a for loop, best make sure we check to yield.
			yieldCheck()
			t[i] = 1
		end

		for i = 2, sqrtlmt do
			if t[i] ~= 0 then
				-- Because we're in a for loop, best make sure we check to yield.
				yieldCheck()
				for j = i * i, n, i do
					-- Because we're in a for loop, best make sure we check to yield.
					yieldCheck()
					t[j] = 0
				end
			end
		end

		local primes = {}
		for i = 2, n do
			-- Because we're in a for loop, best make sure we check to yield.
			yieldCheck()
			if t[i] ~= 0 then
				table.insert(primes, i)
			end
		end

		-- Finally we want to return our table of primes we've generated.
		-- Therefore we yield but pass it the table to yield back.
		print((timer.systime() - time) .. " seconds to complete")
		coroutine.yield(primes)
end)

hook.add("think", "primeNumbers", function ()
	-- If the coroutine isn't running and hasn't died, then we need to start it or resume it.
	if coroutine.status(erato) ~= "running" and coroutine.status(erato) ~= "dead" then
		-- Make sure we're sufficiently below quota to resume
		if checkQ(0.8) then
			-- r will be nil until the final yield which gives us our primes.
			-- This will start / resume the coroutine.
			local r = coroutine.resume(erato, 5000000)

			-- Therefore we check if it's not nil, and print the highest prime.
			if r then
				print("Highest prime: " .. r[#r])
			end
		end
	end

	-- Since we've finished calculating all our primes, remove our think hook.
	if coroutine.status(erato) == "dead" then
		hook.remove("think", "primeNumbers")
	end
end)
