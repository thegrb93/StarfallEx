--- HTTP Library

--- Http library. Requests content from urls.
-- @shared
local http_library = SF.RegisterLibrary("http")
local http_interval = CreateConVar("sf_http_interval", "0.5", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Interval in seconds in which one http request can be made")
local http_max_active = CreateConVar("sf_http_max_active", "3", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The maximum amount of active http requests at the same time")


SF.Permissions.registerPrivilege("http.get", "HTTP Get method", "Allows the user to request html data", { client = { default = 1 }, usergroups = { default = 3 }, urlwhitelist = { default = 2 } })
SF.Permissions.registerPrivilege("http.post", "HTTP Post method", "Allows the user to post html data", { client = { default = 1 }, usergroups = { default = 3 }, urlwhitelist = { default = 2 } })

-- Initializes the lastRequest variable to a value which ensures that the first call to httpRequestReady returns true
-- and the "active requests counter" to 0
SF.AddHook("initialize", function(instance)
	instance.data.http = {
		lastRequest = 0,
		active = 0
	}
end)

-- Returns an error when a http request was already triggered in the current interval
-- or the maximum amount of simultaneous requests is currently active, returns true otherwise
local function httpRequestReady (instance)
	local httpData = instance.data.http
	if CurTime() - httpData.lastRequest < http_interval:GetFloat() or httpData.active >= http_max_active:GetInt() then
		SF.Throw("You can't run a new http request yet", 2)
	end
	return true
end

-- Runs the appropriate callback after a http request
local function runCallback (instance, callback, ...)
	if callback then
		if IsValid(instance.data.entity) then
			instance:runFunction(callback, ...)
		end
	end
	instance.data.http.active = instance.data.http.active - 1
end

--- Checks if a new http request can be started
function http_library.canRequest ()
	local httpData = SF.instance.data.http
	return CurTime() - httpData.lastRequest >= http_interval:GetFloat() and httpData.active < http_max_active:GetInt()
end

--- Runs a new http GET request
-- @param url http target url
-- @param callbackSuccess the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)
-- @param callbackFail the function to be called on request fail, taking the failing reason as an argument
-- @param headers GET headers to be sent
function http_library.get (url, callbackSuccess, callbackFail, headers)
	local instance = SF.instance
	SF.Permissions.check(instance, nil, "http.get")

	httpRequestReady(instance)

	SF.CheckLuaType(url, TYPE_STRING)
	SF.CheckLuaType(callbackSuccess, TYPE_FUNCTION)
	if callbackFail then SF.CheckLuaType(callbackFail, TYPE_FUNCTION) end
	if headers~=nil then
		SF.CheckLuaType(headers, TYPE_TABLE)
		for k, v in pairs(headers) do
			if type(k) ~= "string" or type(v) ~= "string" then
				SF.Throw("Headers can only contain string keys and string values", 2)
			end
		end
	end
	if CLIENT then SF.HTTPNotify(instance.player, url) end

	instance.data.http.lastRequest = CurTime()
	instance.data.http.active = instance.data.http.active + 1
	http.Fetch(url, function (body, len, headers, code)
		runCallback(instance, callbackSuccess, body, len, headers, code)
	end, function (err)
		runCallback(instance, callbackFail, err)
	end,
	headers)
end

--- Runs a new http POST request
-- @param url http target url
-- @param payload POST payload to be sent, can be both table and string. When table is used, the request body is encoded as application/x-www-form-urlencoded
-- @param callbackSuccess the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)
-- @param callbackFail the function to be called on request fail, taking the failing reason as an argument
-- @param headers POST headers to be sent
function http_library.post (url, payload, callbackSuccess, callbackFail, headers)
	local instance = SF.instance
	SF.Permissions.check(instance, nil, "http.post")

	httpRequestReady(instance)

	local request = {
		url = SF.CheckLuaType(url, TYPE_STRING),
		method = "POST"
	}

	if payload~=nil then
		local payloadType = TypeID(payload)

		if payloadType == TYPE_TABLE then
			for k, v in pairs(payload) do
				if type(k) ~= "string" or type(v) ~= "string" then
					SF.Throw("Post parameters can only contain string keys and string values", 2)
				end
			end

			request.parameters = payload
		elseif payloadType == TYPE_STRING then
			request.body = payload
		else
			SF.ThrowTypeError("table or string", SF.GetType(payload), 2)
		end
	end

	if headers~=nil then
		SF.CheckLuaType(headers, TYPE_TABLE)
		
		for k, v in pairs(headers) do
			if type(k) ~= "string" or type(v) ~= "string" then
				SF.Throw("Headers can only contain string keys and string values", 2)
			end

			if string.lower(k) == "content-type" then
				request.type = v
			end
		end
		
		request.headers = headers
	end

	SF.CheckLuaType(callbackSuccess, TYPE_FUNCTION)
	if callbackFail then SF.CheckLuaType(callbackFail, TYPE_FUNCTION) end

	request.success, request.failed =
		function(body, len, headers, code)
			runCallback(instance, callbackSuccess, body, len, headers, code)
		end,

		function(err)
			runCallback(instance, callbackFail, err)
		end

	if CLIENT then SF.HTTPNotify(instance.player, url) end

	instance.data.http.lastRequest = CurTime()
	instance.data.http.active = instance.data.http.active + 1

	HTTP(request)
end

--- Converts data into base64 format or nil if the string is 0 length
--@param data The data to convert
--@return The converted data
function http_library.base64Encode(data)
	SF.CheckLuaType(data, TYPE_STRING)
	return util.Base64Encode(data)
end
