local P = {}

local keys = {
	[ "input" ] = true,
	[ "input.key" ] = true,
	[ "input.mouse" ] = true
}

local keyboardPolling = CreateConVar( "sf_input_key_polling", "0", { FCVAR_ARCHIVE },
	"Whether starfall chips that are not yours are allowed to poll your keys" )

local mousePolling = CreateConVar( "sf_input_mouse_polling", "0", { FCVAR_ARCHIVE },
	"Whether starfall chips that are not yours are allowed to poll your mouse" )

function P.check ( principal, target, key )
	if principal == LocalPlayer() then return true end

	if keys[ key ] then
		if key == "input.key" then
			return keyboardPolling:GetBool()
		elseif key == "input.mouse" then
			return mousePolling:GetBool()
		end
	end
end

SF.Permissions.registerProvider( P )
