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
			if isValid(snd) then
				song = snd
				snd:setFade(500, 2000)
				snd:setVolume(2)
				pcall(snd.setLooping, snd, true) -- pcall in case of audio stream

				-- CRITICAL NOTE: Tags aren't available immediately!
				-- Must use a timer to wait 100-500ms for BASS to parse metadata during stream init
				timer.simple( 0.3, function()					
					-- Try all tag formats (BASS auto-detects format)
					local tags = snd:getTagsID3()		-- ID3v1 only (NOT ID3v2)
					if not tags or not next(tags) then
						tags = snd:getTagsOGG()		-- OGG Vorbis comments
					end
					if not tags or not next(tags) then
						tags = snd:getTagsMP4()		-- MP4/M4A metadata
					end
					if not tags or not next(tags) then
						tags = snd:getTagsWMA()		-- WMA metadata
					end

					-- For Shoutcast/Icecast streams:
					local icyMeta = snd:getTagsMeta()		-- ICY metadata (e.g., "Artist - Title")
					local icyHeaders = snd:getTagsHTTP()	-- HTTP headers (icy-name, icy-genre, etc.)

					-- Display results
					if tags and next(tags) then
						print("Tags found:")
						for k, v in pairs(tags) do
							print(string.format("  %s: %s", k, v))
						end
					elseif icyMeta and icyMeta ~= "" then
						print("Stream metadata:", icyMeta)
						if icyHeaders then
							print("   Station:", icyHeaders["icy-name"] or "Unknown")
							print("   Genre:", icyHeaders["icy-genre"] or "Unknown")
						end
					else print("No tags found (may be ID3v2-only file or unsupported format)") end

					-- Optional: Show technical info
					print(string.format("Duration: %.1fs | Bitrate: %d kbps | Sample rate: %d Hz | Bits per sample: %d | Is Block Streamed: %s | Pitch: %d",
						snd:getBufferedTime(),
						snd:getFileName(),
						snd:getAverageBitRate(),
						snd:getSamplingRate(),
						snd:getBitsPerSample(),
						snd:isBlockStreamed(),
						snd:getPitch()
					))
				end )

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
