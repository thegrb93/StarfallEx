-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege


local http_interval = CreateConVar("sf_http_interval", "0.5", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Interval in seconds in which one http request can be made")
local http_max_active = CreateConVar("sf_http_max_active", "3", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The maximum amount of active http requests at the same time")

local permission_level = SERVER and 1 or 3
registerprivilege("http.get", "HTTP Get method", "Allows the user to request html data", { client = {}, urlwhitelist = { default = permission_level } })
registerprivilege("http.post", "HTTP Post method", "Allows the user to post html data", { client = { default = 1 }, urlwhitelist = { default = permission_level } })

local requests = SF.EntityTable("playerHTTPRequests")

--- Http library. Requests content from urls.
-- @name http
-- @class library
-- @libtbl http_library
SF.RegisterLibrary("http")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local http_library = instance.Libraries.http

-- Runs the appropriate callback after a http request
local function runCallback(callback)
	return function(...)
		if callback then
			instance:runFunction(callback, ...)
		end
		requests[instance.player] = nil
	end
end

--- Checks if a new http request can be started
function http_library.canRequest()
	return not requests[instance.player]
end

--- Runs a new http GET request
-- @param string url Http target url
-- @param function callbackSuccess The function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)
-- @param function? callbackFail The function to be called on request fail, taking the failing reason as an argument
-- @param table? headers GET headers to be sent
function http_library.get(url, callbackSuccess, callbackFail, headers)
	checkluatype(url, TYPE_STRING)
	checkpermission(instance, url, "http.get")

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

	if requests[instance.player] then SF.Throw("You can't run a new http request yet", 2) end
	requests[instance.player] = true

	if CLIENT then SF.HTTPNotify(instance.player, url) end
	http.Fetch(url, runCallback(callbackSuccess), runCallback(callbackFail), headers)
end

--- Runs a new http POST request
-- @param string url Http target url
-- @param table? payload Optional POST payload to be sent, can be both table and string. When table is used, the request body is encoded as application/x-www-form-urlencoded
-- @param function? callbackSuccess Optional function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)
-- @param function? callbackFail Optional function to be called on request fail, taking the failing reason as an argument
-- @param table? headers Optional POST headers to be sent
function http_library.post(url, payload, callbackSuccess, callbackFail, headers)
	checkluatype(url, TYPE_STRING)
	checkpermission(instance, url, "http.post")

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

	if requests[instance.player] then SF.Throw("You can't run a new http request yet", 2) end
	requests[instance.player] = true

	if CLIENT then SF.HTTPNotify(instance.player, url) end
	HTTP(request)
end

--- Converts data into base64 format or nil if the string is 0 length
-- @name http_library.base64Encode
-- @class function
-- @param string data The data to convert
-- @return string The converted data
function http_library.base64Encode(data)
	checkluatype(data, TYPE_STRING)
	return string.gsub(util.Base64Encode(data),"\n","")
end

--- Converts data from base64 format
-- @name http_library.base64Decode
-- @class function
-- @param string data The data to convert
-- @return string The converted data
http_library.base64Decode = util.Base64Decode

--- Encodes illegal url characters to be legal
-- @param string data The data to convert
-- @return string The converted data
function http_library.urlEncode(data)
	checkluatype(data, TYPE_STRING)
	data = string.gsub(data, "[^%w_~%.%-%(%)!%*]", function(char)
		return string.format("%%%02X", string.byte(char))
	end)
	return data
end

--- Decodes the % escaped chars in a url
-- @param string data The data to convert
-- @return string The converted data
function http_library.urlDecode(data)
	checkluatype(data, TYPE_STRING)
	data = string.gsub(data, "%%(..)", function(char)
		char = tonumber(char, 16)
		if char==nil or char < 0 or char > 255 then error("Invalid '%' value found: "..char) end
		return string.char(char)
	end)
	return data
end

--- Converts a simple google drive url to a raw one
-- @param string url The url to convert
-- @return string The converted url
function http_library.urlGoogleDriveToRaw(url)
    local id = string.match(url, "https://drive%.google%.com/file/d/([^/]+)/view")
	if not id then SF.Throw("Failed to parse google drive link!", 2) end
    return "https://drive.google.com/uc?export=download&id="..id
end

end
