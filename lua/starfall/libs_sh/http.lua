-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local registerprivilege = SF.Permissions.registerPrivilege


local http_interval = CreateConVar("sf_http_interval", "0.5", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Interval in seconds in which one http request can be made")
local http_max_active = CreateConVar("sf_http_max_active", "3", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The maximum amount of active http requests at the same time")

registerprivilege("http.get", "HTTP Get method", "Allows the user to request html data", { client = { default = 1 }, urlwhitelist = { default = 2 } })
registerprivilege("http.post", "HTTP Post method", "Allows the user to post html data", { client = { default = 1 }, urlwhitelist = { default = 2 } })

local base64Digits = {}
do
	local base64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	
	for i = 1, #base64Alphabet do
		base64Digits[string.byte(base64Alphabet[i])] = i - 1
	end
end

--- Http library. Requests content from urls.
-- @name http
-- @class library
-- @libtbl http_library
SF.RegisterLibrary("http")

return function(instance)

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
	if headers ~= nil then
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
--@param data The data to convert
--@return The converted data
function http_library.base64Encode(data)
	checkluatype(data, TYPE_STRING)
	return util.Base64Encode(data)
end

--- Converts data from base64 format
--@param data The data to convert
--@param threaded Optional bool
--@return The converted data
function http_library.base64Decode(data, threaded)
	checkluatype(data, TYPE_STRING)

	local thread
	if threaded ~= nil then
		if checkluatype(threaded, TYPE_BOOL) then
			thread = coroutine.running()

			if not thread then
				SF.Throw("Tried to use threading while not in a thread!", 2)
			end
		end
	end

	local bit_band, bit_rshift = bit.band, bit.rshift
	local string_char, string_byte = string.char, string.byte
	local coroutine_yield = coroutine.yield
	local unpack = unpack

	local digitBufferPos = 1
	local digitBuffer = {}

	local chunkBufferPos = 1
	local chunkBuffer = {}

	data = string.gsub(data, "=?=?$", "", 1)
	data = string.gsub(data, "\n", "")
	local dataLen = #data

	for i = 1, dataLen - 3, 4 do
		local b0, b1, b2, b3 = string_byte(data, i, i + 3)
		local d0, d1, d2, d3 = base64Digits[b0], base64Digits[b1], base64Digits[b2], base64Digits[b3]

		if not (d0 and d1 and d2 and d3) then
			SF.Throw("Base64 string contains invalid characters", 2)
		end

		digitBuffer[digitBufferPos]     = 0x04 * d0                 + bit_rshift(d1, 4)
		digitBuffer[digitBufferPos + 1] = 0x10 * bit_band(d1, 0x0F) + bit_rshift(d2, 2)
		digitBuffer[digitBufferPos + 2] = 0x40 * bit_band(d2, 0x03) + d3

		if digitBufferPos <= 7993 then
			digitBufferPos = digitBufferPos + 3
		else
			chunkBuffer[chunkBufferPos] = string_char(unpack(digitBuffer))
			chunkBufferPos = chunkBufferPos + 1

			digitBufferPos = 1
		end

		if threaded then coroutine_yield() end
	end

	local bytesRemain = dataLen % 4
	if bytesRemain ~= 0 then
		local start = dataLen - bytesRemain + 1
		local b0, b1, b2 = string_byte(data, start, start + 2)
		local d0, d1, d2 = base64Digits[b0], base64Digits[b1], base64Digits[b2]

		if not (d0 and d1 and (d2 or bytesRemain == 2)) then
			SF.Throw("Base64 string contains invalid characters", 2)
		end

		digitBuffer[digitBufferPos] = 0x04 * d0 + bit_rshift(d1, 4)
		digitBufferPos = digitBufferPos + 1

		if d2 then
			digitBuffer[digitBufferPos] = 0x10 * bit_band(d1, 0x0F) + bit_rshift(d2, 2)
			digitBufferPos = digitBufferPos + 1
		end
	end

	if digitBufferPos ~= 1 then
		chunkBuffer[chunkBufferPos] = string_char(unpack(digitBuffer, 1, digitBufferPos - 1))
	end

	return table.concat(chunkBuffer)
end

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
