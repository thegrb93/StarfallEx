--- Provides permissions for URLs

local urlrestrictor = SF.StringRestrictor(false)

local P = {}
P.id = "urlwhitelist"
P.name = "URL Whitelist"
P.settingsoptions = { "Enabled", "Disabled" }
P.defaultsetting = 1
P.checks = {
	function(instance, target, key)
		if TypeID(target) ~= TYPE_STRING then return false, "The url is not a string" end
		local prefix = string.match(target,"^(%w-)://") -- Check if protocol was given
		if not prefix then -- If not, add http://
			target = "http://"..target
		end

		local prefix, site, data = string.match(target,"^(%w-)://([^/]*)/?(.*)")
		if not site then return false, "This url is malformed" end
		site = site.."/"..(data or "") -- Make sure there is / at the end of site
		return urlrestrictor:check(site), "This url is not whitelisted"
	end,
	function() return true end,
}

SF.Permissions.registerProvider(P)


local function pattern(txt)
	txt = "^"..txt.."$"
	urlrestrictor:addWhitelistEntry(txt)
end
local function simple(txt)
	txt = "^"..string.PatternSafe(txt).."/.*"
	urlrestrictor:addWhitelistEntry(txt)
end
local function blacklist(txt)
	txt = "^"..string.PatternSafe(txt)..".*"
	urlrestrictor:addBlacklistEntry(txt)
end
local function blacklistpattern(txt)
	txt = "^"..txt.."$"
	urlrestrictor:addBlacklistEntry(txt)
end

-----------------------------------------
-- https://github.com/Metastruct/gurl/ --
-----------------------------------------

-- Dropbox
--- Examples:
---  https://dl.dropboxusercontent.com/u/12345/abc123/abc123.bin
---  https://www.dropbox.com/s/abcd123/efg123.txt?dl=0
---  https://dl.dropboxusercontent.com/content_link/abc123/file?dl=1

simple [[dl.dropboxusercontent.com]]
simple [[dl.dropbox.com]] --Sometimes redirects to usercontent link

-- OneDrive
--- Examples:
---  https://onedrive.live.com/redir?resid=123!178&authkey=!gweg&v=3&ithint=abcd%2cefg

simple [[onedrive.live.com/redir]]

-- Google Drive
--- Examples:
---  https://docs.google.com/uc?export=download&confirm=UYyi&id=0BxUpZqVaDxVPeENDM1RtZDRvaTA

simple [[docs.google.com/uc]]

-- Imgur
--- Examples:
---  http://i.imgur.com/abcd123.xxx

simple [[i.imgur.com]]

-- pastebin
--- Examples:
---  http://pastebin.com/abcdef

simple [[pastebin.com]]

-- gitlab

simple [[gitlab.com]]

-- bitbucket

simple [[bitbucket.org]]

-- github / gist
--- Examples:
---  https://gist.githubusercontent.com/LUModder/f2b1c0c9bf98224f9679/raw/5644006aae8f0a8b930ac312324f46dd43839189/sh_sbdc.lua
---  https://raw.githubusercontent.com/LUModder/FWP/master/weapon_template.txt

simple [[raw.githubusercontent.com]]
simple [[gist.githubusercontent.com]]

-- teknik
simple [[u.teknik.io]]
simple [[p.teknik.io]]

-- TinyPic
--- Examples:
---  http://i68.tinypic.com/24b3was.gif
pattern [[i([%w-_]+)%.tinypic%.com/(.+)]]

-- paste.ee
--- Examples:
---  https://paste.ee/r/J3jle
simple [[paste.ee]]

-- hastebin
--- Examples:
---  http://hastebin.com/icuvacogig.txt

simple [[hastebin.com]]

-- puush
--- Examples:
---  http://puu.sh/asd/qwe.obj
simple [[puu.sh]]

-- Steam
--- Examples:
---  http://images.akamai.steamusercontent.com/ugc/367407720941694853/74457889F41A19BD66800C71663E9077FA440664/
---  https://steamcdn-a.akamaihd.net/steamcommunity/public/images/apps/4000/dca12980667e32ab072d79f5dbe91884056a03a2.jpg
simple [[images.akamai.steamusercontent.com]]
simple [[steamcdn-a.akamaihd.net]]
blacklist [[steamcommunity.com/linkfilter]]


-----------------
-- End of GURL --
-----------------

--  Note:
-- 	If you want to pullrequest additional rules add them below with name example and patterns

--  Note 2:
--  Patterns have ^ and $ forced, so don't add them and make sure your pattern matches whole url
--  "Simple" entries musn't contain slash at the end but all subdomains have to be added as separate entries

--  Note 3:
--  Sites that you wish to add musn't allow tracking user in any way
--  Those have to be trusted and have considerable userbase
--  Don't pullrequest your own domains

-- Discord
--- Examples:
---  https://cdn.discordapp.com/attachments/269175189382758400/421572398689550338/unknown.png
---  https://images-ext-2.discordapp.net/external/UVPTeOLUWSiDXGwwtZ68cofxU1uaA2vMb2ZCjRY8XXU/https/i.imgur.com/j0QGfKN.jpg?width=1202&height=677

pattern [[cdn[%w-_]*.discordapp%.com/(.+)]]
pattern [[images-([%w%-]+)%.discordapp%.net/external/(.+)]]

-- Reddit
--- Examples:
---  https://i.redd.it/u46wumt13an01.jpg
---  https://i.redditmedia.com/RowF7of6hQJAdnJPfgsA-o7ioo_uUzhwX96bPmnLo0I.jpg?w=320&s=116b72a949b6e4b8ac6c42487ffb9ad2

simple [[i.redditmedia.com]]
simple [[i.redd.it]]

-- Ungodly things
--- Examples:
--- you don't even wanna know

simple [[static1.e621.net]]

-- ipfs
--- Examples:
--- https://ipfs.io/ipfs/QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco/I/m/Ellis_Sigil.jpg

simple [[ipfs.io]]

-- neocities
--- Examples:
--- https://fauux.neocities.org/LainDressSlow.gif

pattern pattern [[([%w-_]+)%.neocities%.org/(.+)]]
