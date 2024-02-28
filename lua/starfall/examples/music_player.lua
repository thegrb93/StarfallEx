--@name MusicPlayer
--@author Sparky
--@model models/props_lab/citizenradio.mdl

if SERVER then
	hook.add("PlayerSay", "Hey", function(ply, txt)
		if ply==owner() and txt:sub(1, 6)=="!song " then
			net.start("playSong")
			net.writeString(txt:sub(7))
			net.send()

			return ""
		end
	end)
else
	local function loadSong(songURL)
		if song then song:stop() end

		bass.loadURL(songURL, "3d noblock", function(snd, err, errtxt)
			if snd then
				song = snd
				snd:setFade(500, 2000)
				snd:setVolume(2)
				pcall(snd.setLooping, snd, true) -- pcall in case of audio stream

				hook.add("think", "snd", function()
					if isValid(snd) and isValid(chip()) then
						snd:setPos(chip():getPos())
					end
				end)
			else
				print(errtxt)
			end
		end)

		url = nil
	end

	net.receive("playSong", function(len)
		url = net.readString()

		if not hasPermission("bass.loadURL", url) then
			print("Press E to grant URL sound permission")
			return
		end

		loadSong(url)
	end)

	setupPermissionRequest({"bass.loadURL"}, "URL sounds from external sites", true)

	hook.add("permissionrequest", "permission", function()
		if url and hasPermission("bass.loadURL", url) then
			loadSong(url)
		end
	end)
end
