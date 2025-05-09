--- Provides permissions for URLs

local whitelist_file = SERVER and "sf_url_whitelist.txt" or "starfall/cl_url_whitelist.txt"
local urlrestrictor
local function checkWhitelist(instance, url, key)
	if TypeID(url) ~= TYPE_STRING then return false, "The url is not a string" end

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
		SF.AddNotify(LocalPlayer(), errmsg, "ERROR", 7, "SILENT")
	end
end

local function loadDefaultWhitelist()
	local filename = "starfall/starfall_whitelist_default.lua"
	local code = file.Read(filename, "LUA")
	if not code then whitelistNotifyError(filename, "Could not open file!") end
	return code
end

local function runWhitelist(filename, code)
	urlrestrictor = SF.StringRestrictor(false)

	local env = {
		pattern = function(txt)
			if not isstring(txt) then return end
			txt = "^"..txt.."$"
			urlrestrictor:addWhitelistEntry(txt)
		end,
		simple = function(txt)
			if not isstring(txt) then return end
			txt = "^"..string.PatternSafe(txt).."/.*"
			urlrestrictor:addWhitelistEntry(txt)
		end,
		blacklist = function(txt)
			if not isstring(txt) then return end
			txt = "^"..string.PatternSafe(txt)..".*"
			urlrestrictor:addBlacklistEntry(txt)
		end,
		blacklistpattern = function(txt)
			if not isstring(txt) then return end
			txt = "^"..txt.."$"
			urlrestrictor:addBlacklistEntry(txt)
		end,
	}

	local func = SF.CompileString(code, filename, false)
	if isstring(func) then
		whitelistNotifyError(filename, func)
		return false
	end

	setfenv(func, env)

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
	local code = file.Read(whitelist_file, "DATA")
	if not (code and code ~= "") then
		code = loadDefaultWhitelist()
		if (code and code ~= "") then
			file.Write(whitelist_file, code)
		end
	end

	if not ((code and code ~= "") and runWhitelist(whitelist_file, code)) then
		urlrestrictor = SF.StringRestrictor(false)
	end
end
SF.ReloadUrlWhitelist()

