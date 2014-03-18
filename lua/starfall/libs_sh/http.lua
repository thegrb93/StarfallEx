--- Http library. Requests content from urls.
-- @shared
local http_library, _ = SF.Libraries.Register( "http" )
local http_interval = CreateConVar( "sf_http_interval", "0.5", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Interval in seconds in which one http request can be made" )
local http_max_active = CreateConVar( "sf_http_max_active", "3", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The maximum amount of active http requests at the same time" )

-- Initializes the lastRequest variable to a value which ensures that the first call to httpRequestReady returns true
-- and the "active requests counter" to 0
SF.Libraries.AddHook( "initialize", function( instance )
	instance.data.http = {
		lastRequest = 0,
		active = 0
	}
end )

-- Returns an error when a http request was already triggered in the current interval
-- or the maximum amount of simultaneous requests is currently active, returns true otherwise
local function httpRequestReady ( instance )
	local httpData = instance.data.http
	if CurTime() - httpData.lastRequest < http_interval:GetFloat() or httpData.active >= http_max_active:GetInt() then
		SF.throw( "You can't run a new http request yet", 2 )
	end
	return true
end

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
	instance.data.http.active = instance.data.http.active - 1
end

--- Checks if a new http request can be started
function http_library.canRequest ( )
	local httpData = SF.instance.data.http
	return CurTime() - httpData.lastRequest >= http_interval:GetFloat() and httpData.active < http_max_active:GetInt()
end

--- Runs a new http GET request
-- @param url http target url
-- @param callbackSuccess the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)
-- @param callbackFail the function to be called on request fail, taking the failing reason as an argument
function http_library.get ( url, callbackSuccess, callbackFail )
	local instance = SF.instance
	
	httpRequestReady( instance )
	
	SF.CheckType( url, "string" )
	SF.CheckType( callbackSuccess, "function" )
	if callbackFail then SF.CheckType( callbackFail, "function" ) end
	
	instance.data.http.lastRequest = CurTime()
	instance.data.http.active = instance.data.http.active + 1
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
	
	httpRequestReady( instance )
	
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
	
	instance.data.http.lastRequest = CurTime()
	instance.data.http.active = instance.data.http.active + 1
	http.Post( url, params, function ( body, len, headers, code )
		runCallback( instance, callbackSuccess, body, len, headers, code )
	end, function ( err )
		runCallback( instance, callbackFail, err )
	end )
end
