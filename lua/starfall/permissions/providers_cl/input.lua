local P = {}
P.__index = SF.Permissions.Provider
setmetatable( P, P )

local ALLOW = SF.Permissions.Result.ALLOW
local DENY = SF.Permissions.Result.DENY
local NEUTRAL = SF.Permissions.Result.NEUTRAL

local keys = {
	[ "input" ] = true,
	[ "input.key" ] = true,
	[ "input.mouse" ] = true
}

local keyboardPolling = CreateConVar( "sf_input_key_polling", "0", { FCVAR_ARCHIVE },
	"Whether starfall chips that are not yours are allowed to poll your keys" )

local mousePolling = CreateConVar( "sf_input_mouse_polling", "0", { FCVAR_ARCHIVE },
	"Whether starfall chips that are not yours are allowed to poll your mouse" )

function P:check ( principal, target, key )
	if type( principal ) ~= "player" then return NEUTRAL end

	if principal == LocalPlayer() then return ALLOW end

	if keys[ key ] then
		if key == "input.key" and keyboardPolling:GetBool( ) then
			return ALLOW
		elseif key == "input.mouse" and mousePolling:GetBool( ) then
			return ALLOW
		end
		return DENY
	else
		return NEUTRAL
	end
end

SF.Permissions.registerProvider( P )
