--- Provides permissions for URLs

local P = {}
P.id = "urlwhitelist"
P.name = "URL Whitelist"
P.settingsoptions = { "Enabled", "Disabled" }
P.defaultsetting = 1
P.checks = {
	function(instance, target, key)
		local prefix = string.match(target,"^(%w-)://") -- Check if protocol was given
		if not prefix then -- If not, add http://
			target = "http://"..target
		end

		local prefix, site, data = string.match(target,"^(%w-)://([^/]*)/?(.*)")
		if not site then return false end
		site = site.."/"..(data or "") -- Make sure there is / at the end of site
		return SF.UrlRestrictor:check(site)
	end,
	function() return true end,
}

SF.Permissions.registerProvider(P)