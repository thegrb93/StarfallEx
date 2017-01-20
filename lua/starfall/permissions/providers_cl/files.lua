--- Starfall file library permission provider
local P = {}

-- define what permission keys we will check
local keys = {
	[ "file.read" ] = true,
	[ "file.write" ] = true,
	[ "file.exists" ] = true
}

function P.check ( principal, target, key )
	-- allow if the localplayer is trying to write a file to their computer
	if keys[ key ] then
		if principal == LocalPlayer() then
			return true
		else
			return false
		end
	end
end

-- register the provider
SF.Permissions.registerProvider( P )
