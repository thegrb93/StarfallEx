--- Provides permissions for URLs

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
	return urlrestrictor:check(site), "This url is not whitelisted."
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

local function runWhitelist(filename, func)
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

local function loadDefaultWhitelist()
	local filename = "starfall/starfall_whitelist_default.lua"
	-- Clientside lua files can't be file.Read if client doesn't have addon installed
	local func = CompileFile( filename )
	if func then
		runWhitelist(filename, func)
	else
		whitelistNotifyError(filename, "Could not open file!")
	end
end

local function loadUserWhitelist()
	local filename = SERVER and "sf_url_whitelist.txt" or "starfall/cl_url_whitelist.txt"
	local code = file.Read(filename, "DATA")
	
	if (code and code ~= "") then
		local func = SF.CompileString(code, filename, false)
		if isstring(func) then
			whitelistNotifyError(filename, func)
		else
			runWhitelist(filename, func)
		end
	else
		file.Write(filename, "-- This file can be used to adjust the url whitelist.\n-- See https://raw.githubusercontent.com/thegrb93/StarfallEx/refs/heads/master/lua/starfall/starfall_whitelist_default.lua for examples.\n")
	end
end

function SF.ReloadUrlWhitelist()
	urlrestrictor = SF.StringRestrictor(false)
	loadDefaultWhitelist()
	loadUserWhitelist()
end
SF.ReloadUrlWhitelist()

