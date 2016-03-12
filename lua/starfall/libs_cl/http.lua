--- HTTP Library

--- Http library. Requests content from urls.
-- @shared
local http_library, _ = SF.Libraries.Register( "http" )

-- Runs the appropriate callback after a http request
local function runCallback ( instance, callback, ... )
	if callback then
		local args = { ... }
		if IsValid( instance.data.entity ) and not instance.error then
			local ok, msg, traceback = instance:runFunction( callback, unpack( args ) )
			if not ok then
				instance:Error( "http callback errored with: " .. msg, traceback )
			end
		end
	end
end

--- Runs a new http GET request
-- @param url http target url
-- @param callbackSuccess the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)
-- @param callbackFail the function to be called on request fail, taking the failing reason as an argument
function http_library.get ( url, callbackSuccess, callbackFail )
	local instance = SF.instance
	if instance.player ~= LocalPlayer() then SF.throw( "Http must only be used on the owner of the starfall", 2 ) end
	
	SF.CheckType( url, "string" )
	SF.CheckType( callbackSuccess, "function" )
	if callbackFail then SF.CheckType( callbackFail, "function" ) end
	
	http.Fetch( url, function ( body, len, headers, code ) 
		runCallback( instance, callbackSuccess, body, len, headers, code )
	end, function ( err )
		runCallback( instance, callbackFail, err )
	end )
end

--- Runs a new http POST request
-- @param url http target url
-- @param params POST parameters to be sent
-- @param callbackSuccess the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)
-- @param callbackFail the function to be called on request fail, taking the failing reason as an argument
function http_library.post ( url, params, callbackSuccess, callbackFail )
	local instance = SF.instance
	if instance.player ~= LocalPlayer() then SF.throw( "Http must only be used on the owner of the starfall", 2 ) end
	SF.CheckType( url, "string" )
	
	if params then
		SF.CheckType( params, "table" )
		for k,v in pairs( params ) do
			if type( k ) ~= "string" or type( v ) ~= "string" then
				SF.throw( "Post parameters can only contain string keys and string values", 2 )
			end
		end
	end
	
	SF.CheckType( callbackSuccess, "function" )	
	if callbackFail then SF.CheckType( callbackFail, "function" ) end
	
	http.Post( url, params, function ( body, len, headers, code )
		runCallback( instance, callbackSuccess, body, len, headers, code )
	end, function ( err )
		runCallback( instance, callbackFail, err )
	end )
end
