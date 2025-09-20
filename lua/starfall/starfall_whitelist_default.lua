-- These are urls allowed to be accessed by users' starfalls

-----------------------------------------
-- https://github.com/Metastruct/gurl/ --
-----------------------------------------

-- Dropbox
--- Examples:
---  https://dl.dropboxusercontent.com/u/12345/abc123/abc123.bin
---  https://www.dropbox.com/s/abcd123/efg123.txt?dl=0
---  https://dl.dropboxusercontent.com/content_link/abc123/file?dl=1
simple [[dl.dropboxusercontent.com]]
pattern [[%w+%.dl%.dropboxusercontent%.com/(.+)]]
simple [[www.dropbox.com]]
simple [[dl.dropbox.com]] --Sometimes redirects to usercontent link

-- OneDrive
--- Examples:
---  https://onedrive.live.com/redir?resid=123!178&authkey=!gweg&v=3&ithint=abcd%2cefg
simple [[onedrive.live.com]]
simple [[api.onedrive.com]]

-- Google Drive
--- Examples:
---  https://docs.google.com/uc?export=download&confirm=UYyi&id=0BxUpZqVaDxVPeENDM1RtZDRvaTA
pattern [[docs%.google%.com/uc.+]]
pattern [[drive%.google%.com/uc.+]]

-- Backblaze B2
--- Examples:
--- https://f002.backblazeb2.com/file/djje-CDN/ShareX/0221/1613775658.png
pattern [[(%w+)%.backblazeb2%.com/(.+)]]

-- Imgur
--- Examples:
---  http://i.imgur.com/abcd123.xxx
simple [[i.imgur.com]]

-- Gyazo
--- Examples:
--- https://i.gyazo.com/c3eb33a90ada4de716100e7491fa1a8d.png
simple [[i.gyazo.com]]

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
---  https://raw.github.com/github/explore/master/topics/lua/lua.png
---  https://user-images.githubusercontent.com/13347909/103649539-ef956e80-4f5e-11eb-94dc-d22ee20380e9.png
---  https://avatars2.githubusercontent.com/u/6713261?s=460&v=4
simple [[raw.githubusercontent.com]]
simple [[gist.githubusercontent.com]]
simple [[raw.github.com]]
simple [[cloud.githubusercontent.com]]
simple [[user-images.githubusercontent.com]]
pattern [[avatars(%d*)%.githubusercontent%.com/(.+)]]

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
---  https://steamuserimages-a.akamaihd.net/ugc/1475443067859980096/685F2468519E31C5C214959EC3AA0B0757B01E1B/
---  https://steamcdn-a.akamaihd.net/steamcommunity/public/images/apps/4000/dca12980667e32ab072d79f5dbe91884056a03a2.jpg
simple [[steamcommunity.com/profiles]]
simple [[steamuserimages-a.akamaihd.net]]
simple [[steamcdn-a.akamaihd.net]]
pattern [[images%.[%w-_]+%.steamusercontent%.com/(.+)]]
pattern [[avatars%.[%w-_]+%.steamstatic%.com/(.+)]]
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
---  https://images-ext-2.discordapp.net/external/UVPTeOLUWSiDXGwwtZ68cofxU1uaA2vMb2ZCjRY8XXU/https/i.imgur.com/j0QGfKN.jpg?width=1202&height=67
---  https://media.discordapp.net/attachments/695591357158391879/1096409191792508958/image.png?width=1432&height=88
pattern [[cdn[%w-_]*.discordapp%.com/(.+)]]
pattern [[images-([%w%-]+)%.discordapp%.net/external/(.+)]]
pattern [[media%.discordapp%.net/attachments/(.+)]]

-- Reddit
--- Examples:
---  https://i.redd.it/u46wumt13an01.jpg
---  https://i.redditmedia.com/RowF7of6hQJAdnJPfgsA-o7ioo_uUzhwX96bPmnLo0I.jpg?w=320&s=116b72a949b6e4b8ac6c42487ffb9ad2
---  https://preview.redd.it/injjlk3t6lb51.jpg?width=640&height=800&crop=smart&auto=webp&s=19261cc37b68ae0216bb855f8d4a77ef92b76937
simple [[i.redditmedia.com]]
simple [[i.redd.it]]
simple [[preview.redd.it]]

-- Fur affinity :3d
--- Examples:
--- https://d.furaffinity.net/art/leo-wolf/1665345394/1665345394.leo-wolf_riding_a_wolf.jpg
simple [[d.furaffinity.net]]

-- Deviant art
--- Examples:
--- https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/6641bbbc-78c6-4cce-912f-9ce3ed931446/d9su1ex-94570701-2092-4299-8aa7-19b5f0bd3906.jpg/v1/fit/w_600,h_789,q_70,strp/where_light_and_darkness_meet____video_process__by_jojoesart_d9su1ex-375w-2x.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9Nzg5IiwicGF0aCI6IlwvZlwvNjY0MWJiYmMtNzhjNi00Y2NlLTkxMmYtOWNlM2VkOTMxNDQ2XC9kOXN1MWV4LTk0NTcwNzAxLTIwOTItNDI5OS04YWE3LTE5YjVmMGJkMzkwNi5qcGciLCJ3aWR0aCI6Ijw9NjAwIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmltYWdlLm9wZXJhdGlvbnMiXX0.Pa6ozcWJesGRb3FNHPZ9aMbFbSU_EpGsUDq1AGE0U_4
pattern [[([%w-_]+)%.wixmp%.com/(.+)]]

-- ipfs
--- Examples:
--- https://ipfs.io/ipfs/QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco/I/m/Ellis_Sigil.jpg
simple [[ipfs.io]]

-- neocities
--- Examples:
--- https://fauux.neocities.org/LainDressSlow.gif
pattern [[([%w-_]+)%.neocities%.org/(.+)]]

-- Soundcloud
--- Examples:
--- https://i1.sndcdn.com/artworks-000046176006-0xtkjy-large.jpg
pattern [[(%w+)%.sndcdn%.com/(.+)]]

-- Shoutcast
--- Examples:
--- http://yp.shoutcast.com/sbin/tunein-station.pls?id=567807
simple [[yp.shoutcast.com]]

-- Google Translate API
--- Examples:
--- http://translate.google.com/translate_tts?&q=Hello%20World&ie=utf-8&client=tw-ob&tl=en
simple [[translate.google.com]]

-- Youtube Image Hosting
--- Examples:
--- https://i.ytimg.com/vi_webp/NTw9LRFdUeE/maxresdefault.webp
simple [[i.ytimg.com]]

-- Spotify Image CDN
--- Examples:
--- https://i.scdn.co/image/ab67616d0000b27343e93700df19c025747eebd2
simple [[i.scdn.co]]

-- Deezer Image CDN
--- Examples:
--- https://e-cdns-images.dzcdn.net/images/cover/dfa0fb51f7c872d87309943e17e30e81/1000x1000-000000-80-0-0.jpg
pattern [[([%w-_]+)%.dzcdn%.net/(.+)]]

-- DECTalk Online
-- Examples:
-- https://tts.cyzon.us/tts?text=test
pattern [[tts.cyzon.us/(.+)]]

-- Revolt
--- Examples:
---  https://static.revolt.chat/emoji/mutant/1f440.svg?rev=3
---  https://autumn.revolt.chat/emojis/01G7J9RTHKEPJM8DM19TX35M8N
---  https://autumn.revolt.chat/attachments/mmCR_bFMLEfBAE8mweH2u4o9_x6DiDtU9JXoSbdvZE/live-bocchi-reaction.gif
simple [[static.revolt.chat]]
simple [[autumn.revolt.chat]]
simple [[cdn.revoltusercontent.com]]

-- Youtube Converter API
--- Examples:
---  https://youtube.michaelbelgium.me/storage/5zrORMBb0-8.mp3
simple [[youtube.michaelbelgium.me]]

-- Nekoweb
--- Examples:
---  https://website.nekoweb.org/path/to/resource
pattern [[([%w-_]+)%.nekoweb%.org/(.+)]]

-- RawGit (raw.githack.com)
--- Examples:
--- https://rawcdn.githack.com/Metastruct/garrysmod-chatsounds/63658b902893e11710e51b3d94b9e57f0daaf379/sound/chatsounds/autoadd/anime/i%20love%20you.ogg
--- https://raw.githack.com/Metastruct/garrysmod-chatsounds/master/sound/chatsounds/autoadd/anime/i%20love%20you.ogg
simple [[raw.githack.com]]
simple [[rawcdn.githack.com]]

-- Statically CDN
--- Examples:
--- https://cdn.statically.io/gh/Metastruct/garrysmod-chatsounds/master/sound/chatsounds/autoadd/anime/i%20love%20you.ogg
--- https://cdn.statically.io/img/statically.dev/w=300,h=500/cat.jpg
simple [[cdn.statically.io]]
