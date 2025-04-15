--- Provides permissions for URLs

local whitelist_file = SERVER and "sf_url_whitelist.txt" or "starfall/cl_url_whitelist.txt"
local urlrestrictor
local function checkWhitelist(instance, url, key)
	if TypeID(url) ~= TYPE_STRING then return false, "The url is not a string" end
	print(instance, url, key)

	if not string.match(url,"^(%w-)://") then
		url = "http://"..url
	end

	local result = hook.Run("CanAccessUrl", url)
	if result==true then return true
	elseif result==false then return false, "The url was blocked"
	end

	local prefix, site, data = string.match(url,"^(%w-)://([^/]*)/?(.*)")
	if not site then return false, "This url is malformed" end
	site = site.."/"..(data or "") -- Make sure there is / at the end of site
	return urlrestrictor:check(site), "This url is not whitelisted. See data/"..whitelist_file.." for valid sites."
end

local P = {}
P.id = "urlwhitelist"
P.name = "URL Whitelist"
P.settingsoptions = { "Enabled", "Disabled" }
P.defaultsetting = 1
P.checks = {
	checkWhitelist,
	"allow",
}

if CLIENT then
	P.settingsoptions[3] = "Disabled for owner"
	P.checks[3] = function(instance, url, player)
		if instance.player == LocalPlayer() then return true end
		return checkWhitelist(instance, url, player)
	end
end

SF.Permissions.registerProvider(P)


local function whitelistNotifyError(filename, err)
	local errmsg = "Error in "..filename..": "..err
	if SERVER then
		ErrorNoHalt(errmsg)
	else
		SF.AddNotify(LocalPlayer(), errmsg, "ERROR", 7, "ERROR1")
	end
end

local function loadDefaultWhitelist()
	local filename = "data_static/starfall_whitelist_default.txt"
	local f = file.Open(filename, "rb", "GAME")
	if not f then whitelistNotifyError(filename, "Could not open file!") return "" end
	local code = util.Decompress(f:Read())
	f:Close()
	if code==nil or code=="" then whitelistNotifyError(filename, "Could not decode file!") return "" end
	return code
end

local function runWhitelist(filename, code)
	urlrestrictor = SF.StringRestrictor(false)

	local function pattern(txt)
		if not isstring(txt) then return end
		txt = "^"..txt.."$"
		urlrestrictor:addWhitelistEntry(txt)
	end
	local function simple(txt)
		if not isstring(txt) then return end
		txt = "^"..string.PatternSafe(txt).."/.*"
		urlrestrictor:addWhitelistEntry(txt)
	end
	local function blacklist(txt)
		if not isstring(txt) then return end
		txt = "^"..string.PatternSafe(txt)..".*"
		urlrestrictor:addBlacklistEntry(txt)
	end
	local function blacklistpattern(txt)
		if not isstring(txt) then return end
		txt = "^"..txt.."$"
		urlrestrictor:addBlacklistEntry(txt)
	end

	local func = SF.CompileString(code, filename, false)
	if isstring(func) then
		whitelistNotifyError(filename, func)
		return false
	end

	setfenv(func, {pattern=pattern, simple=simple, blacklist=blacklist, blacklistpattern=blacklistpattern})

	local start = SysTime()
	debug.sethook(function() if SysTime()-start>2 then error("Infinite loop break") end end, "", 2000)
	local ok, err = pcall(func)
	debug.sethook()

	if not ok then
		whitelistNotifyError(filename, err)
		return false
	end

	return true
end

function SF.ReloadUrlWhitelist()
	local code
	if file.Exists(whitelist_file, "DATA") then
		code = file.Read(whitelist_file, "DATA")
	else
		code = loadDefaultWhitelist()
		file.Write(whitelist_file, code)
	end

	if not runWhitelist(whitelist_file, code) then
		runWhitelist("starfall_whitelist_default.txt", loadDefaultWhitelist())
	end
end
SF.ReloadUrlWhitelist()

