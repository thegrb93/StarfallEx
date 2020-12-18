-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege


local http_interval = CreateConVar("sf_http_interval", "0.5", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Interval in seconds in which one http request can be made")
local http_max_active = CreateConVar("sf_http_max_active", "3", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The maximum amount of active http requests at the same time")

registerprivilege("http.get", "HTTP Get method", "Allows the user to request html data", { client = { default = 1 }, urlwhitelist = { default = 2 } })
registerprivilege("http.post", "HTTP Post method", "Allows the user to post html data", { client = { default = 1 }, urlwhitelist = { default = 2 } })

--- Http library. Requests content from urls.
-- @name http
-- @class library
-- @libtbl http_library
SF.RegisterLibrary("http")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

-- Initializes the lastRequest variable to a value which ensures that the first call to httpRequestReady returns true
-- and the "active requests counter" to 0
instance:AddHook("initialize", function()
	instance.data.http = {
		lastRequest = 0,
		active = 0
	}
end)


local http_library = instance.Libraries.http

-- Returns an error when a http request was already triggered in the current interval
-- or the maximum amount of simultaneous requests is currently active, returns true otherwise
local function httpRequestReady()
	local httpData = instance.data.http
	if CurTime() - httpData.lastRequest < http_interval:GetFloat() or httpData.active >= http_max_active:GetInt() then
		SF.Throw("You can't run a new http request yet", 3)
	end
	return true
end

-- Runs the appropriate callback after a http request
local function runCallback(callback)
	return function(...)
		if callback then
			instance:runFunction(callback, ...)
		end
		instance.data.http.active = instance.data.http.active - 1
	end
end

--- Checks if a new http request can be started
function http_library.canRequest()
	local httpData = instance.data.http
	return CurTime() - httpData.lastRequest >= http_interval:GetFloat() and httpData.active < http_max_active:GetInt()
end

--- Runs a new http GET request
-- @param url http target url
-- @param callbackSuccess the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)
-- @param callbackFail the function to be called on request fail, taking the failing reason as an argument
-- @param headers GET headers to be sent
function http_library.get(url, callbackSuccess, callbackFail, headers)
	checkpermission(instance, url, "http.get")

	httpRequestReady()

	checkluatype(url, TYPE_STRING)
	checkluatype(callbackSuccess, TYPE_FUNCTION)
	if callbackFail ~= nil then checkluatype(callbackFail, TYPE_FUNCTION) end
	if headers~=nil then
		checkluatype(headers, TYPE_TABLE)
		for k, v in pairs(headers) do
			if not isstring(k) or not isstring(v) then
				SF.Throw("Headers can only contain string keys and string values", 2)
			end
		end
	end

	if CLIENT then SF.HTTPNotify(instance.player, url) end

	instance.data.http.lastRequest = CurTime()
	instance.data.http.active = instance.data.http.active + 1
	http.Fetch(url, runCallback(callbackSuccess), runCallback(callbackFail), headers)
end

--- Runs a new http POST request
-- @param url http target url
-- @param payload optional POST payload to be sent, can be both table and string. When table is used, the request body is encoded as application/x-www-form-urlencoded
-- @param callbackSuccess optional function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)
-- @param callbackFail optional function to be called on request fail, taking the failing reason as an argument
-- @param headers optional POST headers to be sent
function http_library.post(url, payload, callbackSuccess, callbackFail, headers)
	checkluatype(url, TYPE_STRING)
	checkpermission(instance, url, "http.post")

	httpRequestReady()

	local request = {
		url = url,
		method = "POST"
	}

	if payload~=nil then
		local payloadType = TypeID(payload)

		if payloadType == TYPE_TABLE then
			for k, v in pairs(payload) do
				if not isstring(k) or not isstring(v) then
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
		checkluatype(headers, TYPE_TABLE)
		
		for k, v in pairs(headers) do
			if not isstring(k) or not isstring(v) then
				SF.Throw("Headers can only contain string keys and string values", 2)
			end

			if string.lower(k) == "content-type" then
				request.type = v
			end
		end
		
		request.headers = headers
	end

	if callbackSuccess ~= nil then checkluatype(callbackSuccess, TYPE_FUNCTION) end
	if callbackFail ~= nil then checkluatype(callbackFail, TYPE_FUNCTION) end
	
	request.success = function(code, body, headers)
		local callback = runCallback(callbackSuccess)
		callback(body, #body, headers, code)
	end
	request.failed = runCallback(callbackFail)

	if CLIENT then SF.HTTPNotify(instance.player, url) end

	instance.data.http.lastRequest = CurTime()
	instance.data.http.active = instance.data.http.active + 1

	HTTP(request)
end

--- Converts data into base64 format or nil if the string is 0 length
--@name http_library.base64Encode
--@class function
--@param data The data to convert
--@return The converted data
function http_library.base64Encode(data)
	checkluatype(data, TYPE_STRING)
	return string.gsub(util.Base64Encode(data),"\n","")
end

--- Converts data from base64 format
--@name http_library.base64Decode
--@class function
--@param data The data to convert
--@return The converted data
http_library.base64Decode = util.Base64Decode

--- Encodes illegal url characters to be legal
--@param data The data to convert
--@return The converted data
function http_library.urlEncode(data)
	checkluatype(data, TYPE_STRING)
	data = string.gsub(data, "[^%w_~%.%-%(%)!%*]", function(char)
		return string.format("%%%02X", string.byte(char))
	end)
	return data
end

end
